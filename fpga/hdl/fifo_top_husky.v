`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

module fifo_top_husky(
    input wire    reset,

    //ADC Sample Input
    input wire [11:0]   adc_datain,
    input wire          adc_sampleclk,
    input wire          adc_write_mask,
    input wire          adc_capture_go, //Set to '1' to start capture, keep at 1 until adc_capture_stop goes high
    input wire          adc_segment_go,
    output wire         adc_capture_stop,
    input wire          arm_i,
    input wire [15:0]   num_segments,
    input wire [19:0]   segment_cycles,

    //FIFO to USB Read Interface
    input wire          clk_usb,
    input wire          low_res,        // if set, return just 8 bits per sample; if clear return all 12 bits per sample
    input wire          low_res_lsb,    // useless except for testing: if set, return the 8 LSB bits when in low_res mode
    input wire          fifo_read_fifoen,
    output wire         fifo_read_fifoempty,
    output reg   [7:0]  fifo_read_data,

    input wire  [31:0] presample_i,
    input wire  [31:0] max_samples_i,
    output wire [31:0] max_samples_o,
    output wire [31:0] samples_o,
    input wire  [12:0] downsample_i, //Ignores this many samples inbetween captured measurements

    output wire      fifo_overflow, //If overflow happens (bad during stream mode)
    input wire       stream_mode //1=Enable stream mode, 0=Normal
);

    // TODO: TEMPORARY:
    `define MAX_SAMPLES 2048
    parameter FIFO_FULL_SIZE = `MAX_SAMPLES - 128; // TODO: adjust?
    parameter FIFO_FULL_SIZE_LARGEWORDS = ((`MAX_SAMPLES - 32) / 3) / 4; // TODO: ?

    wire                fast_fifo_wr;
    reg                 fast_fifo_presample_drain = 1'b0;
    reg                 fast_fifo_rd_en = 1'b0;
    wire                fast_fifo_rd;
    wire [11:0]         fast_fifo_dout;
    wire                fast_fifo_full;
    wire                fast_fifo_empty;
    wire                fast_fifo_overflow;
    wire                fast_fifo_underflow;

    reg  [35:0]         slow_fifo_din;
    reg                 slow_fifo_prewr = 1'b0;
    reg                 slow_fifo_wr_premask = 1'b0;
    wire                slow_fifo_wr;
    reg                 slow_fifo_rd;
    wire [35:0]         slow_fifo_dout;
    reg  [3:0]          slow_fifo_dout_r;
    wire                slow_fifo_full;
    wire                slow_fifo_empty;
    wire                slow_fifo_overflow;
    wire                slow_fifo_underflow;

    reg                 adc_capture_stop_reg;
    wire                fifo_overflow_int;      // TODO: need to drive this, for streaming mode
    reg                 fifo_overflow_reg;
    wire                stream_write;
    reg  [31:0]         presample_counter;      // TODO: reduced size as required when FIFOs are finalized
    reg  [31:0]         sample_counter;         // TODO: reduced size as required when FIFOs are finalized
    reg  [15:0]         segment_counter;
    reg  [19:0]         segment_cycle_counter;
    reg                 fifo_capture_en;

    reg                 arm_r;
    reg                 arm_r2;
    reg                 arm_fifo_rst_adc;
    wire                arm_fifo_rst_usb;
    reg                 armed_and_ready;
    reg                 arming;
    reg                 adc_segment_go_r;

    assign stream_write = (stream_mode) ? adc_capture_go : 1'b1; //In stream mode we don't write until trigger
    assign fifo_overflow = fifo_overflow_reg;
    assign adc_capture_stop = (stream_mode) ? fifo_overflow_int : adc_capture_stop_reg;
    assign fifo_read_fifoempty = slow_fifo_empty;

    //Counter for downsampling (NOT proper decimation)
    reg [12:0] downsample_ctr;
    wire downsample_max;
    reg downsample_wr_en;

    assign downsample_max = (downsample_ctr == downsample_i) ? 1'b1 : 'b0;

    always @(posedge adc_sampleclk) begin
       //if ((arm_fifo_rst_adc == 1'b1) || (adc_capture_go == 1'b0)) begin
       if (arm_fifo_rst_adc == 1'b1) begin
          downsample_ctr <= 13'd0;
          downsample_wr_en <= 1'b0;
       end 
       else begin
          if (downsample_max) begin
             downsample_ctr <= 13'd0;
             downsample_wr_en <= 1'b1;
          end
          else begin
             downsample_ctr <= downsample_ctr + 13'd1;
             downsample_wr_en <= 1'b0;
          end
       end
    end

    //TODO: return correct value
    assign max_samples_o = FIFO_FULL_SIZE ;


    /* TODO: this logic is obsolete
    // Keep fifo write enabled until we reach number of samples
    always @(posedge adc_sampleclk) begin
       if (~adc_capture_go)
          presample_counter <= FIFO_FULL_SIZE-6; //max_samples_i
       else if (downsample_max & adc_write_mask)
          presample_counter <= presample_counter - 32'd1;
    end

    always @(posedge adc_sampleclk) begin
       if((presample_counter == presample_i) && (stream_mode == 1'b0))
          adc_capture_stop_reg <= 1'b1;
       else
          adc_capture_stop_reg <= 1'b0;
    end
    */

    // Presample logic: when armed, we always write to the fast FIFO. When
    // we reach the requested number of presamples, we start to also read
    // and discard, so as to keep exactly the requested number of presamples
    // in the fast FIFO. During this time, no data is sent to the slow FIFO.
    // When the trigger is received, the fast FIFO read data is then written
    // to the slow FIFO.

    localparam pS_IDLE = 0;
    localparam pS_PRESAMP_FILLING = 1;
    localparam pS_PRESAMP_FULL = 2;
    localparam pS_TRIGGERED = 3;
    localparam pS_SEGMENT_DONE = 4;
    localparam pS_DONE = 5;
    reg [2:0] state;

    // strictly for easier debugging:
    wire state_idle = (state == pS_IDLE);
    wire state_presamp_filling = (state == pS_PRESAMP_FILLING);
    wire state_presamp_full = (state == pS_PRESAMP_FULL);
    wire state_triggered = (state == pS_TRIGGERED);
    wire state_segment_done = (state == pS_SEGMENT_DONE);
    wire state_done = (state == pS_DONE);

    wire stop_capture_conditions;
    wire fsm_fast_wr_en;

    assign stop_capture_conditions = fifo_rst_pre || adc_capture_stop; // XXX removed adc_capture_stop condition for segmenting, fingers crossed it doesn't break stuff
    //assign stop_capture_conditions = fifo_rst_pre;

    assign fsm_fast_wr_en = ((state == pS_PRESAMP_FILLING) || (state == pS_PRESAMP_FULL) || (state == pS_TRIGGERED));

    always @ (posedge adc_sampleclk) begin
       if (reset) begin
          state <= pS_IDLE;
          presample_counter <= 0;
          sample_counter <= 0;
          sample_counter <= 0;
          fast_fifo_presample_drain <= 1'b0;
          adc_capture_stop_reg <= 1'b0;
          fast_fifo_rd_en <= 1'b0;
          segment_counter <= 0;
          segment_cycle_counter <= 0;
       end

       else begin
          case (state)

             pS_IDLE: begin
                presample_counter <= 0;
                sample_counter <= 0;
                fast_fifo_presample_drain <= 1'b0;
                adc_capture_stop_reg <= 1'b0;
                fast_fifo_rd_en <= 1'b0;
                segment_counter <= 0;
                segment_cycle_counter <= 0;
                if (armed_and_ready && ~adc_capture_stop_reg)
                   if (arm_i & (presample_i > 0))
                      state <= pS_PRESAMP_FILLING;
                   else if (adc_capture_go)
                      state <= pS_TRIGGERED;
             end

             pS_PRESAMP_FILLING: begin
                fast_fifo_presample_drain <= 1'b0;
                if (stop_capture_conditions)
                   state <= pS_DONE;
                // TODO: flag if we were unable to capture enough presamples - which is definitely possible with segmenting
                else if ( (adc_capture_go && (segment_counter == 0)) || (adc_segment_go && (segment_counter > 0)) )
                   state <= pS_TRIGGERED;
                else if (presample_counter == presample_i)
                   state <= pS_PRESAMP_FULL;
                else if (fast_fifo_wr)
                   presample_counter <= presample_counter + 1;
             end

             pS_PRESAMP_FULL: begin
                if (stop_capture_conditions)
                   state <= pS_DONE;
                //else if (adc_capture_go) begin
                else if ( (adc_capture_go && (segment_counter == 0)) || (adc_segment_go && (segment_counter > 0)) ) begin
                   sample_counter <= presample_counter;
                   state <= pS_TRIGGERED;
                end
                if (fast_fifo_wr)
                   fast_fifo_presample_drain <= 1'b1;
                else
                   fast_fifo_presample_drain <= 1'b0;
             end

             pS_TRIGGERED: begin
                fast_fifo_presample_drain <= 1'b0;
                fast_fifo_rd_en <= 1'b1;
                segment_cycle_counter <= segment_cycle_counter + 1;
                if (stop_capture_conditions || ((sample_counter == max_samples_i) && (segment_counter == num_segments))) begin
                   adc_capture_stop_reg <= 1'b1;
                   state <= pS_DONE;
                end
                else if ( (sample_counter == max_samples_i) && (segment_counter < num_segments) ) begin
                   //adc_capture_stop_reg <= 1'b1;
                   state <= pS_SEGMENT_DONE;
                end
                if (fast_fifo_wr) begin
                   sample_counter <= sample_counter + 1;
                   //fast_fifo_rd <= 1'b1;
                end
                //else
                //   fast_fifo_rd <= 1'b0;
             end

             pS_SEGMENT_DONE: begin
                segment_cycle_counter <= segment_cycle_counter + 1;
                //adc_capture_stop_reg <= 1'b0;
                if (fast_fifo_empty) begin
                   fast_fifo_rd_en <= 1'b0;
                   if (presample_i > 0) begin
                      segment_counter <= segment_counter + 1;
                      sample_counter <= 0;
                      presample_counter <= 0;
                      state <= pS_PRESAMP_FILLING;
                   end
                   else if ((adc_segment_go && ~adc_segment_go_r) || (segment_cycle_counter == segment_cycles)) begin
                   //else if (segment_cycle_counter == segment_cycles) begin
                      segment_counter <= segment_counter + 1;
                      segment_cycle_counter <= 0;
                      sample_counter <= 0;
                      state <= pS_TRIGGERED;
                   end
                end
             end

             pS_DONE: begin
                // serves two purposes:
                // 1. wait for fast FIFO to empty;
                // 2. wait state so that we don't get back out of idle right away
                if (fast_fifo_empty) begin
                   fast_fifo_rd_en <= 1'b0;
                   state <= pS_IDLE;
                end
             end

          endcase
       end
    end

   (* ASYNC_REG = "TRUE" *) reg[1:0] reset_done_pipe;
   reg reset_done_r;
   reg reset_done_r2;

    always @(posedge adc_sampleclk) begin
       if (reset) begin
          reset_done_pipe <= 0;
          reset_done_r <= 1'b0;
          reset_done_r2 <= 1'b0;
          arming <= 1'b0;
          armed_and_ready <= 1'b0;
          adc_segment_go_r <= 1'b0;
       end
       else begin
          adc_segment_go_r <= adc_segment_go;
          {reset_done_r2, reset_done_r, reset_done_pipe} <= {reset_done_r, reset_done_pipe, reset_done};
          arm_r <= arm_i;
          arm_r2 <= arm_r;
          arm_fifo_rst_adc <= ~arm_r2 & arm_r;
          if (arm_i && ~arm_r && ~arming) begin
             arming <= 1'b1;
             armed_and_ready <= 1'b0;
          end
          else if (arming && ~reset_done_r2 && reset_done_r) begin
             arming <= 1'b0;
             armed_and_ready <= 1'b1;
          end
          else if (adc_capture_stop_reg)
             armed_and_ready <= 1'b0;
       end
    end

    // TODO: check on fast_fifo_full is temporary, probably need to detect and flag overflow events
    assign fast_fifo_wr = downsample_wr_en & fsm_fast_wr_en & stream_write & adc_write_mask & reset_done & !fifo_rst_pre & !fast_fifo_full;
    //assign fast_fifo_rd = fast_fifo_rd_en & reset_done & !fifo_rst_pre;
    assign slow_fifo_wr = slow_fifo_wr_premask & reset_done & !fifo_rst_pre;

    // Xilinx FIFO is very particular about its reset: it must be wide enough
    // and the FIFO shouldn't be accessed for some time after reset has been
    // released. USB (slow) clock is 96 MHz, ADC (fast) clock is anywhere from
    // 5 to 200 MHz.  So we make the FIFO reset four 5 MHz cycles long = 76 USB
    // clocks, and prevent FIFO access for thirty 5 MHz cycles = 570 USB clocks
    // after reset. (Ref: Xilinx PG057 v13.2, p.129).

   cdc_pulse U_fifo_rst_cdc (
      .reset_i       (reset),
      .src_clk       (adc_sampleclk),
      .src_pulse     (arm_fifo_rst_adc),
      .dst_clk       (clk_usb),
      .dst_pulse     (arm_fifo_rst_usb)
   );

    //wire fifo_rst_start = arm_fifo_rst_usb || (reset && ~reset_r);
    wire fifo_rst_start = arm_fifo_rst_usb || reset;
    reg fifo_rst_start_r;

    reg reset_r;
    reg [6:0] reset_hi_count;
    reg [9:0] reset_lo_count;
    reg fifo_rst_pre;
    reg fifo_rst;
    reg reset_done;
    always @(posedge clk_usb) begin
       reset_r <= reset;
       fifo_rst <= fifo_rst_pre;
       fifo_rst_start_r <= fifo_rst_start;
       if (fifo_rst_start_r) begin
          fifo_rst_pre <= 1'b1;
          reset_hi_count <= 1;
          reset_lo_count <= 1;
          reset_done <= 1'b0;
       end
       else if (reset_hi_count > 0) begin
          if (reset_hi_count < 76)
             reset_hi_count <= reset_hi_count + 1;
          else begin
             reset_hi_count <= 0;
             fifo_rst_pre <= 0;
          end
       end
       else if (reset_lo_count > 0) begin
          if (reset_lo_count < 576)
             reset_lo_count <= reset_lo_count + 1;
          else begin
             reset_hi_count <= 0;
             reset_lo_count <= 0;
             reset_done <= 1'b1;
          end
       end
    end

    reg [1:0] fast_read_count;

    // Write slow FIFO:
    always @(posedge adc_sampleclk) begin
       if (reset) begin
          fast_read_count <= 0;
          slow_fifo_prewr <= 1'b0;
          slow_fifo_wr_premask <= 1'b0;
       end

       else begin
          slow_fifo_wr_premask <= slow_fifo_prewr;
          if (fifo_rst_pre || ~reset_done) begin
             fast_read_count <= 0;
             slow_fifo_prewr <= 0;
          end
          else if (adc_capture_go || (state == pS_DONE)) begin
          //else if (~fast_fifo_empty) begin
             if (!fast_fifo_empty && !slow_fifo_full) begin
                if (fast_read_count < 2) begin
                   fast_read_count <= fast_read_count + 1;
                   slow_fifo_prewr <= 1'b0;
                end
                else begin
                   fast_read_count <= 0;
                   slow_fifo_prewr <= 1'b1;
                end

             end
             else begin
                slow_fifo_prewr <= 1'b0;
             end
          end

          else
             slow_fifo_prewr <= 1'b0;

          if (fast_fifo_rd)
             slow_fifo_din <= {slow_fifo_din[23:0], fast_fifo_dout};

       end
    end

    reg [3:0] slow_read_count;

    // Read slow FIFO:
    always @(posedge clk_usb) begin
       if (reset || ~reset_done) begin
          slow_read_count <= 0;
          slow_fifo_rd <= 1'b0;
          slow_fifo_dout_r <= 0;
       end

       else if (fifo_read_fifoen) begin
          if (low_res) begin // return 8 bits per sample
             if (slow_read_count < 2) begin
                slow_read_count <= slow_read_count + 1;
                slow_fifo_rd <= 1'b0;
             end
             else begin
                slow_read_count <= 0;
                slow_fifo_rd <= 1'b1;
             end
          end

          else begin // hi_res, return all 12 bits per sample
             if (slow_read_count < 8)
                slow_read_count <= slow_read_count + 1;
             else
                slow_read_count <= 0;
             if ((slow_read_count == 8) || (slow_read_count == 3)) begin
                slow_fifo_rd <= 1;
                slow_fifo_dout_r <= slow_fifo_dout[3:0];
             end
             else
                slow_fifo_rd <= 0;
          end

       end
       else
          slow_fifo_rd <= 1'b0;
    end

    always @(*) begin
       if (low_res) begin
          if (low_res_lsb)
             fifo_read_data = slow_fifo_dout[(2-slow_read_count)*12 +: 8];
          else
             fifo_read_data = slow_fifo_dout[(2-slow_read_count)*12 + 4 +: 8];
       end
       else begin
          case (slow_read_count)
             0: fifo_read_data = slow_fifo_dout[35:28];
             1: fifo_read_data = slow_fifo_dout[27:20];
             2: fifo_read_data = slow_fifo_dout[19:12];
             3: fifo_read_data = slow_fifo_dout[11:4];
             4: fifo_read_data = {slow_fifo_dout_r, slow_fifo_dout[35:32]};
             5: fifo_read_data = slow_fifo_dout[31:24];
             6: fifo_read_data = slow_fifo_dout[23:16];
             7: fifo_read_data = slow_fifo_dout[15:8];
             8: fifo_read_data = slow_fifo_dout[7:0];
             default: fifo_read_data = 8'h00;
          endcase
       end
    end

    assign fast_fifo_rd = fast_fifo_presample_drain || (fast_fifo_rd_en && !slow_fifo_full && !fast_fifo_empty);

    `ifdef NOFIFO
       //for clean iverilog compilation
    `else
       adc_fast_fifo U_adc_fast_fifo(
          .clk          (adc_sampleclk),
          .rst          (fifo_rst),
          .din          (adc_datain),
          .wr_en        (fast_fifo_wr),
          .rd_en        (fast_fifo_rd),
          .dout         (fast_fifo_dout),
          .full         (fast_fifo_full),
          .empty        (fast_fifo_empty),
          .overflow     (fast_fifo_overflow),
          .underflow    (fast_fifo_underflow)
       );

       usb_slow_fifo U_usb_slow_fifo(
          .rst          (fifo_rst),
          .wr_clk       (adc_sampleclk),
          .rd_clk       (clk_usb),
          .din          (slow_fifo_din),
          .wr_en        (slow_fifo_wr),
          .rd_en        (slow_fifo_rd),
          .dout         (slow_fifo_dout),
          .full         (slow_fifo_full),
          .empty        (slow_fifo_empty),
          .overflow     (slow_fifo_overflow),
          .underflow    (slow_fifo_underflow)
       );

    `endif

   `ifdef ILA_FIFO
       ila_fast_fifo U_ila_fast_fifo (
          .clk            (adc_sampleclk),        // input wire clk
          .probe0         (reset),                // input wire [0:0]  probe0  
          .probe1         (adc_datain),           // input wire [11:0] probe1 
          .probe2         (fast_fifo_wr),         // input wire [0:0]  probe2 
          .probe3         (fast_fifo_rd),         // input wire [7:0]  probe3 
          .probe4         (fast_fifo_dout),       // input wire [11:0] probe4 
          .probe5         (fast_fifo_full),       // input wire [0:0]  probe5 
          .probe6         (fast_fifo_empty),      // input wire [0:0]  probe6 
          .probe7         (fast_fifo_overflow),   // input wire [0:0]  probe7 
          .probe8         (fast_fifo_underflow),  // input wire [0:0]  probe8 
          .probe9         (downsample_wr_en),     // input wire [0:0]  probe9 
          .probe10        (stream_write),         // input wire [0:0]  probe10 
          .probe11        (adc_write_mask),       // input wire [0:0]  probe11 
          .probe12        (reset_done),           // input wire [0:0]  probe12 
          
          .probe13        (fifo_rst_start_r),     // input wire [0:0]  probe13 
          .probe14        (reset_hi_count),       // input wire [6:0]  probe14 
          .probe15        (reset_lo_count),       // input wire [9:0]  probe15 
          .probe16        (fifo_rst),             // input wire [0:0]  probe16 
          .probe17        (adc_capture_go),       // input wire [0:0]  probe17 

          .probe18        (adc_capture_stop),     // input wire [0:0]  probe18 
          .probe19        (presample_counter[11:0]), // input wire [11:0] probe19 
          .probe20        (sample_counter[11:0]),    // input wire [11:0] probe20 
          .probe21        (state_idle),           // input wire [0:0]  probe21
          .probe22        (state_presamp_filling),// input wire [0:0]  probe22
          .probe23        (state_presamp_full),   // input wire [0:0]  probe23
          .probe24        (state_triggered),      // input wire [0:0]  probe24
          .probe25        (state_done)            // input wire [0:0]  probe25
       );

       ila_slow_fifo U_ila_slow_fifo (
          .clk            (clk_usb),              // input wire clk
          .probe0         (reset),                // input wire [0:0]  probe0  
          .probe1         (slow_fifo_din),        // input wire [35:0] probe1 
          .probe2         (slow_fifo_wr),         // input wire [0:0]  probe2 
          .probe3         (slow_fifo_rd),         // input wire [7:0]  probe3 
          .probe4         (slow_fifo_dout),       // input wire [35:0] probe4 
          .probe5         (slow_fifo_full),       // input wire [0:0]  probe5 
          .probe6         (slow_fifo_empty),      // input wire [0:0]  probe6 
          .probe7         (slow_fifo_overflow),   // input wire [0:0]  probe7 
          .probe8         (slow_fifo_underflow),  // input wire [0:0]  probe8 
          .probe9         (fifo_rst),             // input wire [0:0]  probe9
          .probe10        (reset_done)            // input wire [0:0]  probe10
       );


   `endif


endmodule
`default_nettype wire
