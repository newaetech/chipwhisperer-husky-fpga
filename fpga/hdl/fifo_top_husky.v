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
    output wire         adc_capture_stop,
    input wire          arm_i,

    //FIFO to USB Read Interface
    input wire          clk_usb,
    input wire          fifo_read_fifoen,
    output wire         fifo_read_fifoempty,
    output wire  [7:0]  fifo_read_data,

    input wire  [31:0] presample_i,
    input wire  [31:0] max_samples_i, // TODO XXX unused
    output wire [31:0] max_samples_o,
    output wire [31:0] samples_o,
    input wire  [12:0] downsample_i, //Ignores this many samples inbetween captured measurements

    output wire      fifo_overflow, //If overflow happens (bad during stream mode)
    input wire       stream_mode //1=Enable stream mode, 0=Normal
);

    // TODO: TEMPORARY:
    //`define MAX_SAMPLES 1024
    parameter FIFO_FULL_SIZE = `MAX_SAMPLES - 128;
    parameter FIFO_FULL_SIZE_LARGEWORDS = ((`MAX_SAMPLES - 32) / 3) / 4;

    wire                fast_fifo_wr;
    reg                 fast_fifo_rd = 1'b0;
    wire [11:0]         fast_fifo_dout;
    wire                fast_fifo_full;
    wire                fast_fifo_empty;
    wire                fast_fifo_overflow;
    wire                fast_fifo_underflow;

    reg  [35:0]         slow_fifo_din;
    reg                 slow_fifo_prewr = 1'b0;
    reg                 slow_fifo_wr = 1'b0;
    reg                 slow_fifo_rd;
    wire [35:0]         slow_fifo_dout;
    wire                slow_fifo_full;
    wire                slow_fifo_empty;
    wire                slow_fifo_overflow;
    wire                slow_fifo_underflow;

    wire                adc_capture_stop_int;
    wire                adc_capture_stop_reg;
    wire                fifo_overflow_int;
    reg                 fifo_overflow_reg;
    wire                stream_write;
    reg  [31:0]         presample_counter;
    reg                 fifo_capture_en;
    reg                 adcfifo_wr_en;

    reg                 arm_r;
    reg                 arm_r2;
    reg                 fifo_rst;

    assign stream_write = (stream_mode) ? adc_capture_go : 1'b1; //In stream mode we don't write until trigger
    assign fifo_overflow = fifo_overflow_reg;
    assign adc_capture_stop_int = (stream_mode) ? fifo_overflow_int : adc_capture_stop_reg;
    assign adc_capture_stop = adc_capture_stop_int;

    //Counter for downsampling (NOT proper decimation)
    reg [12:0] downsample_ctr;
    wire downsample_max;

    assign downsample_max = (downsample_ctr == downsample_i) ? 1'b1 : 'b0;

    always @(posedge adc_sampleclk) begin
       if ((fifo_rst == 1'b1) || (adc_capture_go == 1'b0)) begin
          downsample_ctr <= 13'd0;
       end else begin
          if (downsample_max)
             downsample_ctr <= 13'd0;
          else
             downsample_ctr <= downsample_ctr + 13'd1;
       end
    end

    //3 samples per 4 bytes
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
    assign adc_capture_stop_reg = 1'b0;

    always@(posedge adc_sampleclk) begin
       arm_r <= arm_i;
       arm_r2 <= arm_r;
       fifo_rst <= ~arm_r2 & arm_r;
       // TODO: pass fifo_rst to FIFO; extend it to 5 cycles too
    end

    always @(posedge adc_sampleclk) begin
       if (fifo_rst)
          fifo_capture_en <= 1'b1;
       else if (adc_capture_stop_int)
          fifo_capture_en <= 1'b0;
    end

    always @(posedge adc_sampleclk) begin
       if (fifo_capture_en == 0)
          adcfifo_wr_en <= 0;
       else begin
          if (downsample_max)
             adcfifo_wr_en <= 1;
          else
             adcfifo_wr_en <= 0;
       end
    end

    assign fast_fifo_wr = adcfifo_wr_en & stream_write & adc_write_mask & reset_done;

    reg reset_done;
    reg [7:0] reset_r;

    always @(posedge adc_sampleclk) reset_r <= {reset_r[6:0], reset};
    always @(posedge adc_sampleclk) begin
       if (reset)
          reset_done <= 1'b0;
       else begin
          if (reset_r[7] & !reset_r[6])
             reset_done <= 1'b1;
       end
    end

    reg [1:0] fast_read_count;
    // bridge the two fifos:
    always @(posedge adc_sampleclk) begin
       if (reset) begin
          fast_read_count <= 0;
          fast_fifo_rd <= 1'b0;
          slow_fifo_prewr <= 1'b0;
          slow_fifo_wr <= 1'b0;
       end

       else begin
          slow_fifo_wr <= slow_fifo_prewr;
          if (adc_capture_go) begin
             if (!fast_fifo_empty && !slow_fifo_full) begin
                fast_fifo_rd <= 1'b1;
                //slow_fifo_din <= {slow_fifo_din[23:0], fast_fifo_dout};
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
                fast_fifo_rd <= 1'b0;
                slow_fifo_prewr <= 1'b0;
             end
          end

          if (fast_fifo_rd)
             slow_fifo_din <= {slow_fifo_din[23:0], fast_fifo_dout};

       end
    end

    reg [1:0] slow_read_count;
    // read slow FIFO
    always @(posedge clk_usb) begin
       if (reset) begin
          slow_read_count <= 0;
          slow_fifo_rd <= 1'b0;
       end
       else if (fifo_read_fifoen) begin
          if (slow_read_count < 2) begin
             slow_read_count <= slow_read_count + 1;
             slow_fifo_rd <= 1'b0;
          end
          else begin
             slow_read_count <= 0;
             slow_fifo_rd <= 1'b1;
          end
       end
       else
          slow_fifo_rd <= 1'b0;
    end

    // TOOD-temp: returning just 8 bit per sample for now, because it's easier
    assign fifo_read_data = slow_fifo_dout[(2-slow_read_count)*12 +: 8];

    `ifdef NOFIFO
       //for clean iverilog compilation
    `else
       adc_fast_fifo U_adc_fast_fifo(
          .clk          (adc_sampleclk),
          .rst          (reset),
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
          .rst          (reset),
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
	.probe9         (adcfifo_wr_en),        // input wire [0:0]  probe9 
	.probe10        (stream_write),         // input wire [0:0]  probe10 
	.probe11        (adc_write_mask),       // input wire [0:0]  probe11 
	.probe12        (reset_done)            // input wire [0:0]  probe12 
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
	.probe8         (slow_fifo_underflow)   // input wire [0:0]  probe8 
       );


   `endif


endmodule
`default_nettype wire
