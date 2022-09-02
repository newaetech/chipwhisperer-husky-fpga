/* 
ChipWhisperer Artix Target - Example of connections between example registers
and rest of system.

Copyright (c) 2020, NewAE Technology Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted without restriction. Note that modules within
the project may have additional restrictions, please carefully inspect
additional licenses.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of NewAE Technology Inc.
*/

`timescale 1ns / 1ps
`default_nettype none 


module simple_ddr3_rwtest #(
   parameter pDATA_WIDTH = 32,
   parameter pADDR_WIDTH = 30,
   parameter pMASK_WIDTH = 4
)(
   input wire                           clk,
   input wire                           reset,
   input wire                           active_usb,
   input wire                           init_calib_complete,
   input wire                           clear_fail,
   output reg                           pass,
   output reg                           fail,
   output reg  [15:0]                   iteration,
   output reg  [7:0]                    errors,
   output reg  [pADDR_WIDTH-1:0]        error_addr,
   input  wire [7:0]                    ddrtest_incr,
   input  wire [31:0]                   ddrtest_stop,
   output reg  [31:0]                   ddr_read_read,
   output reg  [31:0]                   ddr_read_idle,
   output reg  [31:0]                   ddr_write_write,
   output reg  [31:0]                   ddr_write_idle,
   output reg  [15:0]                   ddr_max_read_stall_count,
   output reg  [15:0]                   ddr_max_write_stall_count,

   output reg  [pADDR_WIDTH-1:0]        app_addr,
   output wire [2:0]                    app_cmd,
   output reg                           app_en,
   output wire [pDATA_WIDTH-1:0]        app_wdf_data,
   output reg                           app_wdf_end,
   output reg                           app_wdf_wren,
   output wire                          app_sr_req,
   output wire                          app_ref_req,
   output wire                          app_zq_req,
   output wire [pMASK_WIDTH-1:0]        app_wdf_mask,

   input  wire                          app_sr_active,
   input  wire                          app_ref_ack,
   input  wire                          app_zq_ack,
   input  wire [pDATA_WIDTH-1:0]        app_rd_data,
   input  wire                          app_rd_data_end,
   input  wire                          app_rd_data_valid,
   input  wire                          app_rdy,
   input  wire                          app_wdf_rdy
);

localparam pS_WRITE0          = 4'd0;
localparam pS_WRITE1          = 4'd1;
localparam pS_WRITE2          = 4'd2;
localparam pS_READ0           = 4'd3;
localparam pS_READ1           = 4'd4;
localparam pS_READ2           = 4'd5;
localparam pS_WAIT_READS_DONE = 4'd6;
localparam pS_IDLE            = 4'd7;
localparam pS_LOAD_LFSR       = 4'd8;
reg [3:0] state, next_state;

localparam CMD_WRITE = 3'b000;
localparam CMD_READ = 3'b001;

assign app_sr_req = 0;
assign app_ref_req = 0;
assign app_zq_req = 0;
assign app_wdf_mask = 0;

reg comp_error;
reg comp_good;

reg reset_address;
reg incr_address;
reg incr_iteration;
reg load_lfsr;
reg  [pADDR_WIDTH-1:0] verify_addr;
reg [31:0] lfsr;
wire read_valid;
reg write_valid;

reg [15:0] read_stall_count;
reg [15:0] write_stall_count;

assign app_wdf_data = lfsr ^ app_addr;
wire [31:0] expected_payload = lfsr ^ verify_addr;

wire writing = (state == pS_WRITE0) ||
               (state == pS_WRITE1) ||
               (state == pS_WRITE2);
wire reading = (state == pS_READ0) ||
               (state == pS_READ1) ||
               (state == pS_READ2) ||
               (state == pS_WAIT_READS_DONE);

assign app_cmd = writing? CMD_WRITE : CMD_READ;

// since "active" controls FSM states, let's sync it properly:
(* ASYNC_REG = "TRUE" *) reg[2:0] active_pipe;
reg active;
reg active_r;
always @ (posedge clk) begin
    if (reset) begin
        active_pipe <= 0;
        active <= 0;
        active_r <= 0;
    end 
    else begin
        {active_r, active, active_pipe} <= {active, active_pipe, active_usb};
    end 
end


// FSM issues write command + data, read command:
always @(*) begin
    // defaults:
    app_en = 0;
    app_wdf_wren = 0;
    app_wdf_end = 0;
    reset_address = 0;
    incr_address = 0;
    incr_iteration = 0;
    load_lfsr = 0;
    write_valid = 0;

    case (state)
        pS_IDLE: begin
            if (~active)
                next_state = pS_IDLE;
            else if (init_calib_complete && app_rdy && app_wdf_rdy) begin
                reset_address = 1'b1;
                load_lfsr = 1'b1;
                next_state = pS_WRITE1;
            end
            else
                next_state = pS_IDLE;
        end

        pS_WRITE0: begin
            if (app_rdy && app_wdf_rdy)
                next_state = pS_WRITE1;
            else
                next_state = pS_WRITE0;
        end

        pS_WRITE1: begin
            app_en = 1'b1;
            app_wdf_wren = 1'b1;
            app_wdf_end = 1'b0;
            // note: going to IDLE now if !active seems to mess up the controller, presumably because it doesn't get app_wdf_end
            if (app_rdy && app_wdf_rdy) begin
                write_valid = 1'b1;
                next_state = pS_WRITE2;
            end
            else
                next_state = pS_WRITE1;
        end

        pS_WRITE2: begin
            app_en = 1'b0;
            app_wdf_wren = 1'b1;
            app_wdf_end = 1'b1;
            if (app_wdf_rdy) begin
                write_valid = 1'b1;
                if (~active)
                    next_state = pS_IDLE;
                else if (app_addr == ddrtest_stop) begin
                    reset_address = 1'b1;
                    next_state = pS_READ0;
                end
                else begin
                    incr_address = 1'b1;
                    if (app_rdy)
                        next_state = pS_WRITE1;
                    else
                        next_state = pS_WRITE0;
                end
            end
            else
                next_state = pS_WRITE2;
        end

        pS_READ0: begin
            app_en = 1'b0;
            if (app_rdy) begin
                load_lfsr = 1'b1;
                next_state = pS_READ1;
            end
            else
                next_state = pS_READ0;
        end

        pS_READ1: begin
            app_en = 1'b1;
            if (app_rdy)
                next_state = pS_READ2;
            else
                next_state = pS_READ1;
        end

        pS_READ2: begin
            app_en = 1'b0;
            if (~active)
                next_state = pS_IDLE;
            else if (app_rdy) begin
                if (app_addr == ddrtest_stop) begin
                    next_state = pS_WAIT_READS_DONE;
                end
                else begin
                    incr_address = 1'b1;
                    next_state = pS_READ1;
                end
            end
            else
                next_state = pS_READ2;
        end

        pS_WAIT_READS_DONE: begin
            if (~active)
                next_state = pS_IDLE;
            else if (verify_addr == ddrtest_stop) begin
                reset_address = 1'b1;
                incr_iteration = 1'b1;
                next_state = pS_LOAD_LFSR;
            end
            else
                next_state = pS_WAIT_READS_DONE;
        end

        pS_LOAD_LFSR: begin
            load_lfsr = 1'b1;
            next_state = pS_WRITE0;
        end


        default: begin
            next_state = pS_IDLE;
        end

    endcase

end


// sequential logic controlled by FSM + verify read data:
always @ (posedge clk) begin
    if (reset) begin
        state <= pS_IDLE;
        app_addr <= 0;
        verify_addr <= 0;
        iteration <= 0;
        pass <= 0;
        fail <= 0;
        errors <= 0;
        error_addr <= 0;
        comp_error <= 1'b0;
        comp_good <= 1'b0;
        ddr_read_read <= 0;
        ddr_read_idle <= 0;
        ddr_write_write <= 0;
        ddr_write_idle <= 0;
        read_stall_count <= 0;
        write_stall_count <= 0;
        ddr_max_read_stall_count <= 0;
        ddr_max_write_stall_count <= 0;
    end

    else begin
        state <= next_state;

        if (reset_address) begin
            app_addr <= 0;
            verify_addr <= 0;
        end
        else begin
            if (incr_address)
                app_addr <= app_addr + ddrtest_incr;
            if (app_rd_data_end && app_rd_data_valid)   // yes, it's possible to get app_rd_data_end without app_rd_data_valid!
                verify_addr <= verify_addr + ddrtest_incr;
        end

        if (state == pS_IDLE)
            iteration <= 0;
        else if (incr_iteration)
            iteration <= iteration + 1;

        if (!active | clear_fail)
            pass <= 1'b0;
        else if (comp_error)
            pass <= 1'b0;
        else if (incr_iteration & !fail & |lfsr)
            pass <= 1'b1;

        if (clear_fail) begin
            fail <= 1'b0;
            errors <= 0;
            error_addr <= 0;
            comp_error <= 1'b0;
            comp_good <= 1'b0;
        end
        else if (reading && app_rd_data_valid) begin
            if (expected_payload == app_rd_data) begin
                comp_error <= 1'b0;
                comp_good <= 1'b1;
            end
            else begin
                fail <= 1'b1;
                comp_error <= 1'b1;
                comp_good <= 1'b0;
                if (errors == 0)
                    error_addr <= verify_addr;
                if (errors < 255)
                    errors <= errors + 1;
            end
        end
        else if (writing) begin
            comp_good <= 1'b0;
            comp_error <= 1'b0;
        end

        if (active && ~active_r) begin
            ddr_read_read <= 0;
            ddr_read_idle <= 0;
            ddr_write_write <= 0;
            ddr_write_idle <= 0;
            read_stall_count <= 0;
            write_stall_count <= 0;
            ddr_max_read_stall_count <= 0;
            ddr_max_write_stall_count <= 0;
        end
        else begin

            if (reading) begin
                if (app_rd_data_valid && (ddr_read_read < {32{1'b1}}))
                    ddr_read_read <= ddr_read_read + 1;
                else if (ddr_read_idle < {32{1'b1}})
                    ddr_read_idle <= ddr_read_idle + 1;

                if (app_rd_data_valid) begin
                    read_stall_count <= 0;
                    if (read_stall_count > ddr_max_read_stall_count)
                        ddr_max_read_stall_count <= read_stall_count;
                end
                else
                    read_stall_count <= read_stall_count + 1;

            end

            if (writing) begin
                if (app_rdy && (ddr_write_write < {32{1'b1}}))
                    ddr_write_write <= ddr_write_write + 1;
                else if (ddr_write_idle < {32{1'b1}})
                    ddr_write_idle <= ddr_write_idle + 1;

                if (app_rdy) begin
                    write_stall_count <= 0;
                    if (write_stall_count > ddr_max_write_stall_count)
                        ddr_max_write_stall_count <= write_stall_count;
                end
                else
                    write_stall_count <= write_stall_count + 1;

            end
        end

    end
end

assign read_valid = reading && app_rd_data_valid;

always @ (posedge clk) begin
    if (reset) begin
        lfsr <= 0;
    end
    else begin
        if (load_lfsr)
            lfsr <= {iteration, ~iteration};
        else if (read_valid || write_valid)
            lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
    end
end


`ifdef ILA_DDR3
ila_simple_ddr3 U_ila_ddr3 (
	.clk            (clk                ),      // input wire clk
	.probe0         (active             ),      // input wire [0:0]  probe0  
	.probe1         (init_calib_complete),      // input wire [0:0]  probe1 
	.probe2         (pass               ),      // input wire [0:0]  probe2 
	.probe3         (fail               ),      // input wire [0:0]  probe3 
	.probe4         (app_addr           ),      // input wire [29:0] probe4 
	.probe5         (app_cmd            ),      // input wire [2:0]  probe5 
	.probe6         (app_en             ),      // input wire [0:0]  probe6 
	.probe7         (app_wdf_data       ),      // input wire [31:0] probe7 
	.probe8         (app_wdf_end        ),      // input wire [0:0]  probe8 
	.probe9         (app_wdf_wren       ),      // input wire [0:0]  probe9 
	.probe10        (app_ref_ack        ),      // input wire [0:0]  probe10 
	.probe11        (app_rd_data        ),      // input wire [31:0] probe11 
	.probe12        (app_rd_data_end    ),      // input wire [0:0]  probe12 
	.probe13        (app_rd_data_valid  ),      // input wire [0:0]  probe13 
	.probe14        (app_rdy            ),      // input wire [0:0]  probe14 
	.probe15        (app_wdf_rdy        ),      // input wire [0:0]  probe15
	.probe16        (state              ),      // input wire [3:0]  probe16
	.probe17        (load_lfsr          ),      // input wire [0:0]  probe17
	.probe18        (iteration          ),      // input wire [15:0] probe18
	.probe19        (comp_error         ),      // input wire [0:0]  probe19
	.probe20        (comp_good          ),      // input wire [0:0]  probe20
	.probe21        (writing            ),      // input wire [0:0]  probe21
	.probe22        (reading            ),      // input wire [0:0]  probe22
	.probe23        (expected_payload   ),      // input wire [31:0] probe23
	.probe24        (verify_addr        ),      // input wire [29:0] probe24 
	.probe25        (lfsr               ),      // input wire [31:0] probe25 
	.probe26        (write_valid        ),      // input wire [0:0]  probe26 
	.probe27        (read_valid         )       // input wire [0:0]  probe27 
);
`endif

endmodule

`default_nettype wire

