/* 
Very simple behavioural model for Xilinx DDR MIG's "app" interface.

Copyright (c) 2022, NewAE Technology Inc.
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


module ddr3_app_model #(
   parameter pDATA_WIDTH = 32,
   parameter pADDR_WIDTH = 30,
   parameter pMASK_WIDTH = 4
)(
   input  wire                          clk,
   input  wire                          reset,
   output wire                          init_calib_complete,

   input  wire [pADDR_WIDTH-1:0]        app_addr,
   input  wire [2:0]                    app_cmd,
   input  wire                          app_en,
   input  wire [pDATA_WIDTH-1:0]        app_wdf_data,
   input  wire                          app_wdf_end,
   input  wire                          app_wdf_wren,

   output wire [pDATA_WIDTH-1:0]        app_rd_data,
   output reg                           app_rd_data_end,
   output reg                           app_rd_data_valid,
   output wire                          app_rdy,
   output wire                          app_wdf_rdy
);

    localparam CMD_WRITE = 3'b000;
    localparam CMD_READ = 3'b001;

    assign init_calib_complete = 1'b1;
    assign app_wdf_rdy = 1'b1;

`ifdef TINYDDR
    reg [pDATA_WIDTH*2-1:0] memory [0:255];
`else
    reg [pDATA_WIDTH*2-1:0] memory [0:65535];
`endif

`ifdef FAST_DDR_WRITES
    localparam pSLOW_DDR_PROB = 10;
`else
    localparam pSLOW_DDR_PROB = 1;
`endif


    reg [pDATA_WIDTH-1:0] app_wdf_data_r;

    reg app_rdy_wr;
    reg app_rdy_rd;

    reg  [63:0] fifo_in;
    reg  fifo_wr;
    reg  fifo_rd;
    wire [63:0] fifo_out;
    wire fifo_full;
    wire prog_full;
    wire fifo_empty;
    wire fifo_overflow;
    wire fifo_underflow;

    reg read_allowed;
    reg fifo_rd_r;
    reg fifo_rd_r2;
    reg dropped_read_request;


    assign app_rdy = app_rdy_wr & app_rdy_rd;

`ifndef LINT

    // write logic:
    initial begin
        app_rdy_wr = 1'b0;
        // initial ready delay:
        repeat ($urandom_range(100, 900)) @(posedge clk);
        app_rdy_wr = 1'b1;
        while (1) begin
            // write part 1:
            wait (app_en && app_wdf_wren && app_cmd == CMD_WRITE);
            //app_wdf_data_r = app_wdf_data; // this led to *very* rare failures
            @(posedge clk);
            // write part 2:
            wait (app_en && app_wdf_wren);
            #1 memory[app_addr>>3] = {app_wdf_data, app_wdf_data_r};
            @(posedge clk);
            if ($urandom_range(0, pSLOW_DDR_PROB) == 0) begin
                app_rdy_wr = 1'b0;
                repeat ($urandom_range(1, 10)) @(posedge clk);
                app_rdy_wr = 1'b1;
            end
        end
    end

    always @(posedge clk)
        if (app_en && app_wdf_wren && app_cmd == CMD_WRITE)
            app_wdf_data_r <= app_wdf_data;

    // read logic: FIFO write thread
    // simple model to emulate how reads are serviced: the first request
    // has some delay, but after that replies come quickly
    always @(posedge clk) begin
        if (reset) begin
            dropped_read_request <= 1'b0;
        end
        else begin
            if (app_rdy && app_en && (app_cmd == CMD_READ)) begin
                if (fifo_full) begin
                    fifo_wr <= 1'b0;
                    dropped_read_request <= 1'b1;
                end
                else begin
                    fifo_wr <= 1'b1;
                    fifo_in <= memory[app_addr >> 3];
                end
            end
            else
                fifo_wr <= 1'b0;

            // use a lower full threshold to throttle read requests on smaller
            // captures too (prog full goes high at 16 entries = 85 12-bit samples)
            if (prog_full)
                app_rdy_rd <= 1'b0;
            else
                app_rdy_rd <= 1'b1;
        end
    end

    // read logic: FIFO read thread
    always @(posedge clk) begin
        fifo_rd_r <= fifo_rd;
        fifo_rd_r2 <= fifo_rd_r;
        if (~fifo_empty && read_allowed && ~fifo_rd)
            fifo_rd <= 1'b1;
        else
            fifo_rd <= 1'b0;
        if (fifo_rd) begin
            app_rd_data_valid <= 1'b1;
            app_rd_data_end <= 1'b0;
            //app_rd_data <= fifo_out[63:32];
        end
        else if (fifo_rd_r) begin
            app_rd_data_valid <= 1'b1;
            app_rd_data_end <= 1'b1;
            //app_rd_data <= fifo_out[31:0];
        end
        else begin
            app_rd_data_valid <= 1'b0;
            app_rd_data_end <= 1'b0;
            //app_rd_data <= 32'b0;
        end
    end

    assign app_rd_data = fifo_rd_r?  fifo_out[31:0] :
                         fifo_rd_r2? fifo_out[63:32] : 32'b0;

    // read logic: throttle FIFO reads
    initial begin
        read_allowed = 1'b0;
        while (1) begin
            wait (~fifo_empty);
            repeat ($urandom_range(2, 10)) @(posedge clk);
            read_allowed = 1'b1;
            if ($urandom_range(0,4) == 0) begin
                read_allowed = 1'b0;
                repeat ($urandom_range(2, 10)) @(posedge clk);
            end
        end
    end

    `ifdef NOXILINXFIFO
        fifo_sync #(
            .pDATA_WIDTH    (64),
            .pDEPTH         (512),
            .pFALLTHROUGH   (0),
            .pFLOPS         (1),
            .pDISTRIBUTED   (0),
            .pBRAM          (0)
        ) U_read_fifo (
            .clk            (clk),
            .rst_n          (~reset),
            .full_threshold_value (16),
            .wen            (fifo_wr),
            .wdata          (fifo_in),
            .full           (fifo_full),
            .full_threshold (prog_full),
            .overflow       (fifo_overflow),
            .ren            (fifo_rd),
            .rdata          (fifo_out),
            .empty          (fifo_empty),
            .almost_empty   (),
            .underflow      (fifo_underflow)
        );

    `else
        ddr_model_fifo U_read_fifo(
           .clk          (clk),
           .rst          (reset),
           .din          (fifo_in),
           .wr_en        (fifo_wr),
           .rd_en        (fifo_rd),
           .dout         (fifo_out),
           .full         (fifo_full),
           .empty        (fifo_empty),
           .prog_full    (prog_full),
           .overflow     (fifo_overflow),
           .underflow    (fifo_underflow)
        );
    `endif

    // debug only:
    wire [pDATA_WIDTH*2-1:0] memory0 = memory[0];
    wire [pDATA_WIDTH*2-1:0] memory1 = memory[1];
    wire [pDATA_WIDTH*2-1:0] memory2 = memory[2];
    wire [pDATA_WIDTH*2-1:0] memory3 = memory[3];
    wire [pDATA_WIDTH*2-1:0] memory8192 = memory[8192];
    wire [pDATA_WIDTH*2-1:0] memory8193 = memory[8193];
    wire [pDATA_WIDTH*2-1:0] memory8194 = memory[8194];
    wire [pDATA_WIDTH*2-1:0] memory8195 = memory[8195];
    wire [pDATA_WIDTH*2-1:0] memory8196 = memory[8196];
    wire [pDATA_WIDTH*2-1:0] memory8197 = memory[8197];
    wire [pDATA_WIDTH*2-1:0] memory8198 = memory[8198];
    wire [pDATA_WIDTH*2-1:0] memory8199 = memory[8199];
    wire [pDATA_WIDTH*2-1:0] memory32776 = memory[32776];
    wire [pDATA_WIDTH*2-1:0] memory32777 = memory[32777];
    wire [pDATA_WIDTH*2-1:0] memory32778 = memory[32778];
    wire [pDATA_WIDTH*2-1:0] memory32779 = memory[32779];
    wire [pDATA_WIDTH*2-1:0] memory32780 = memory[32780];

`endif

endmodule

`default_nettype wire

