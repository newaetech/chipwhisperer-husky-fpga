`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2022, NewAE Technology Inc. All rights reserved.
Author: Jean-Pierre Thibault <jpthibault@newae.com>

  chipwhisperer is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  chipwhisperer is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Lesser General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with chipwhisperer.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************/

module fifo_sync #(
    parameter pDATA_WIDTH = 8,
    parameter pDEPTH = 32,
    parameter pFALLTHROUGH = 0, // "first word fall through" 
    parameter pFLOPS = 1,       // pFLOPS, pBRAM and pDISTRIBUTED are mutually exclusive
    parameter pBRAM = 0,        // Setting pBRAM or pDISTRIBUTE instantiates a Xilinx
    parameter pDISTRIBUTED = 0  // xpm_memory_sdpram instance for storage; otherwise, flops.
)(
    input  wire                         clk, 
    input  wire                         rst_n,
    /* verilator lint_off UNUSED */
    input  wire [31:0]                  full_threshold_value,
    input  wire [31:0]                  empty_threshold_value,
    /* verilator lint_on UNUSED */
    input  wire                         wen, 
    input  wire [pDATA_WIDTH-1:0]       wdata,
    output wire                         full,
    output wire                         almost_full,
    output reg                          overflow,
    output wire                         full_threshold,
    input  wire                         ren, 
    output wire [pDATA_WIDTH-1:0]       rdata,
    output wire                         empty,
    output wire                         almost_empty,
    output wire                         empty_threshold,
    output reg                          underflow
);

    localparam pADDR_WIDTH = (pDEPTH ==    32)? 5 :
                             (pDEPTH ==    64)? 6 :
                             (pDEPTH ==   128)? 7 :
                             (pDEPTH ==   256)? 8 :
                             (pDEPTH ==   512)? 9 :
                             (pDEPTH ==  1024)? 10 :
                             (pDEPTH ==  2048)? 11 :
                             (pDEPTH ==  4096)? 12 :
                             (pDEPTH ==  8192)? 13 :
                             (pDEPTH == 16384)? 14 :
                             (pDEPTH == 32768)? 15 :
                             (pDEPTH == 65536)? 16 : 0;

    wire [pADDR_WIDTH-1:0] full_threshold_value_trimmed = full_threshold_value[pADDR_WIDTH-1:0];
    wire [pADDR_WIDTH-1:0] empty_threshold_value_trimmed = empty_threshold_value[pADDR_WIDTH-1:0];
    wire [pADDR_WIDTH-1:0] waddr, raddr;
    reg  [pADDR_WIDTH:0] wptr, rptr;

    assign waddr = wptr[pADDR_WIDTH-1:0];
    assign raddr = rptr[pADDR_WIDTH-1:0];

    // r/w pointers:
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr <= 0;
            rptr <= 0;
        end
        else begin
            if (wen && !full)
                wptr <= wptr + 1;
            if (ren && !empty)
                rptr <= rptr + 1;
        end
    end

    // over/underflow flags:
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            overflow <= 1'b0;
            underflow <= 1'b0;
        end
        else begin
            if (wen && full) 
                overflow <= 1'b1;
            else 
                overflow <= 1'b0;
            if (ren && empty) 
                underflow <= 1'b1;
            else 
                underflow <= 1'b0;
        end
    end

    // storage:
    `ifdef FAST_FIFO_SIM // flops simulate substantially faster (~50% faster Husky-Pro simulation)
        localparam pFAST_SIM_FLOPS = 1;
    `else
        localparam pFAST_SIM_FLOPS = 0;
    `endif

    generate
        if (pBRAM || pDISTRIBUTED) begin : xilinx_inst
            localparam pMEMORY_PRIMITIVE = (pBRAM)? "block" : "distributed";
            localparam pREAD_LATENCY = (pBRAM)? 1 : 0;

            wire [pDATA_WIDTH-1:0] memout;
            wire [pADDR_WIDTH-1:0] mem_raddr;
            wire mem_rd;

            if (pDISTRIBUTED) begin: distributed_memout_inst
                reg [pDATA_WIDTH-1:0] memout_reg;
                always @(posedge clk) if (ren && !empty) memout_reg <= memout;
                assign rdata = (pFALLTHROUGH)? memout : memout_reg;
                assign mem_raddr = raddr;
                assign mem_rd = 1'b1;
            end // distributed_memout_inst

            else if (pBRAM) begin: bram_memout_inst
                reg [pADDR_WIDTH-1:0] current_raddr, next_raddr;
                wire [pADDR_WIDTH-1:0] raddr_fwft;
                assign mem_raddr = (pFALLTHROUGH)? raddr_fwft : raddr;
                assign raddr_fwft = ren? next_raddr : current_raddr;
                assign rdata = memout;
                assign mem_rd = (pFALLTHROUGH)? ~empty : ren;
                always @(posedge clk or negedge rst_n) begin
                    if (~rst_n) begin
                        current_raddr <= 0;
                        next_raddr <= 1;
                    end
                    else if (ren && ~empty) begin
                        current_raddr <= current_raddr + 1;
                        next_raddr <= next_raddr + 1;
                    end
                end
                `ifdef __ICARUS__
                    wire warning = (wen && mem_rd && (mem_raddr == waddr));
                    always @(posedge clk) begin
                        if (warning)
                            $display("%t WARNING: reading and writing same BRAM address simultaneously; probably won't work as expected! (%m)", $time);
                    end
                `endif
            end // bram_memout_inst

            `ifndef LINT
            if (pFAST_SIM_FLOPS == 0) begin: xpm_inst
                // IMPORTANT NOTE: to simulate with iverilog, some assertions in
                // xpm_memory.sv need to be commented out (with Vivado 2020.2, the
                // whole gen_coll_msgs block), and the -gsupported-assertion
                // iverilog option used.
                xpm_memory_sdpram #(
                    .ADDR_WIDTH_A                       (pADDR_WIDTH),
                    .ADDR_WIDTH_B                       (pADDR_WIDTH),
                    .AUTO_SLEEP_TIME                    (0),
                    .BYTE_WRITE_WIDTH_A                 (pDATA_WIDTH),
                    .CLOCKING_MODE                      ("common_clock"),
                    .ECC_MODE                           ("no_ecc"),
                    .MEMORY_INIT_FILE                   ("none"),
                    .MEMORY_INIT_PARAM                  ("0"),
                    .MEMORY_OPTIMIZATION                ("true"),
                    .MEMORY_PRIMITIVE                   (pMEMORY_PRIMITIVE),
                    .MEMORY_SIZE                        (pDATA_WIDTH*pDEPTH),
                    .MESSAGE_CONTROL                    (0),
                    .READ_DATA_WIDTH_B                  (pDATA_WIDTH),
                    .READ_LATENCY_B                     (pREAD_LATENCY),
                    .READ_RESET_VALUE_B                 ("0"),
                    .RST_MODE_A                         ("SYNC"),
                    .RST_MODE_B                         ("SYNC"),
                    .USE_EMBEDDED_CONSTRAINT            (0),
                    .USE_MEM_INIT                       (0),
                    .WAKEUP_TIME                        ("disable_sleep"),
                    .WRITE_DATA_WIDTH_A                 (pDATA_WIDTH),
                    .WRITE_MODE_B                       ("read_first")
                )
                xpm_memory_sdpram_inst (
                    .dbiterrb                           (),         // 1-bit output: Status signal to indicate double bit error occurrence on the data output of port B.
                    .doutb                              (memout),   // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
                    .sbiterrb                           (),         // 1-bit output: Status signal to indicate single bit error occurrence on the data output of port B.
                    .addra                              (waddr),    // ADDR_WIDTH_A-bit input: Address for port A write operations.
                    .addrb                              (mem_raddr),// ADDR_WIDTH_B-bit input: Address for port B read operations.
                    .clka                               (clk),      // 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
                    .clkb                               (1'b0),     // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
                    .dina                               (wdata),    // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
                    .ena                                (1'b1),     // 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
                    .enb                                (mem_rd),   // 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
                    .injectdbiterra                     (1'b0),     // 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
                    .injectsbiterra                     (1'b0),     // 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
                    .regceb                             (1'b1),     // 1-bit input: Clock Enable for the last register stage on the output data path.
                    .rstb                               (~rst_n),    // 1-bit input: Reset signal for the final port B output register stage.  Synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
                    .sleep                              (1'b0),     // 1-bit input: sleep signal to enable the dynamic power saving feature.
                    .wea                                (wen)       // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
                );
            end // xpm_inst
            `endif // LINT
        end // xilinx_inst

        if (pFLOPS || pFAST_SIM_FLOPS) begin: flop_inst
            // RTL Verilog memory model
            reg [pDATA_WIDTH-1:0] mem [0:pDEPTH-1];
            wire [pDATA_WIDTH-1:0] rdata_fwft;
            reg  [pDATA_WIDTH-1:0] rdata_reg;
            assign rdata_fwft = mem[raddr];
            always @(posedge clk) begin
                if (wen && !full) mem[waddr] <= wdata;
                if (ren && !empty) rdata_reg <= rdata_fwft;
            end

            // optional first word fall through mode
            assign rdata = pFALLTHROUGH ? rdata_fwft : rdata_reg;
    
            //debug only:
            //wire [63:0] mem0 = mem[0];
            //wire [63:0] mem1 = mem[1];
            //wire [63:0] mem2 = mem[2];
            //wire [63:0] mem3 = mem[3];
        end // flop_inst
    endgenerate


    assign empty = (wptr == rptr);
    wire [pADDR_WIDTH:0] rptr_plus1 = rptr + 1;
    assign almost_empty = (wptr == rptr_plus1) || empty;

    assign full = ( (wptr[pADDR_WIDTH] != rptr[pADDR_WIDTH]) &&
                    (wptr[pADDR_WIDTH-1:0] == rptr[pADDR_WIDTH-1:0]) );

    wire [pADDR_WIDTH:0] wptr_plus1 = wptr + 1;
    assign almost_full = ( (wptr_plus1[pADDR_WIDTH] != rptr[pADDR_WIDTH]) &&
                           (wptr_plus1[pADDR_WIDTH-1:0] == rptr[pADDR_WIDTH-1:0]) ) || full;

    // programmable almost full threshold
    // The comparison is a bit tricky but boils down to: add an MSB (set to 0)
    // to both pointers to prevent overflow when adding the threshold value,
    // except when wptr has wrapped around but rptr hasn't: in that case, add
    // an MSB set to 1 to wptr, to make it as though it didn't overflow.
    wire [pADDR_WIDTH+1:0] adjust_rt = {1'b0, rptr} + {2'b0, full_threshold_value_trimmed};
    wire [pADDR_WIDTH+1:0] adjust_wt1 = {1'b0, wptr};
    wire [pADDR_WIDTH+1:0] adjust_wt2 = {1'b1, wptr};
    wire case2 = (~wptr[pADDR_WIDTH] && rptr[pADDR_WIDTH]);
    assign full_threshold = (adjust_rt <= ((case2)? adjust_wt2 : adjust_wt1));

    // similar idea is used for programmable almost empty threshold:
    wire [pADDR_WIDTH+1:0] rptr_plust = {1'b0, rptr} + {2'b0, empty_threshold_value_trimmed};
    assign empty_threshold = (((case2)? adjust_wt2 : adjust_wt1) <= rptr_plust);

endmodule

`default_nettype wire

