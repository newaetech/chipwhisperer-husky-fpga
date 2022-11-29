`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

This code originates from:
http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf
Changes made:
    - default_nettype and the missing wire declarations necessitated by this.
    - combine the original 6 modules into a single one
    - over/underflow flags
    - programmable full threshold
    - parameterize depth instead of address width
    - make "first word fall through" an option

*************************************************************************/

module fifo_async #(
    parameter pDATA_WIDTH = 8,
    parameter pDEPTH = 32,
    parameter pFALLTHROUGH = 0, // "first word fall through" 
    parameter pBRAM = 0
) (
    input  wire                         wclk, 
    input  wire                         rclk, 
    input  wire                         wrst_n,
    input  wire                         rrst_n,
    input  wire [pADDR_WIDTH-1:0]       wfull_threshold_value,
    input  wire                         wen, 
    input  wire [pDATA_WIDTH-1:0]       wdata,
    output reg                          wfull,
    output reg                          woverflow,
    output reg                          wfull_threshold,
    input  wire                         ren, 
    output wire [pDATA_WIDTH-1:0]       rdata,
    output reg                          rempty,
    output reg                          runderflow
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

    wire [pADDR_WIDTH-1:0] waddr, raddr;
    reg  [pADDR_WIDTH:0] wq1_rptr, wq2_rptr, rq1_wptr, rq2_wptr, wptr, rptr;
    reg [pADDR_WIDTH:0] rbin;
    wire [pADDR_WIDTH:0] rgraynext, rbinnext;
    wire rempty_val;
    reg [pADDR_WIDTH:0] wbin;
    wire [pADDR_WIDTH:0] wgraynext, wbinnext;
    wire wfull_val;
    wire [pDATA_WIDTH-1:0] rdata_fwft;
    reg  [pDATA_WIDTH-1:0] rdata_reg;

    // New: overflow flag
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) woverflow <= 1'b0;
        else if (wen && wfull) woverflow <= 1'b1;
        else woverflow <= 1'b0;

    // New: underflow flag
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) runderflow <= 1'b0;
        else if (ren && rempty) runderflow <= 1'b1;
        else runderflow <= 1'b0;

    //sync_r2w module in original code:
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) {wq2_rptr,wq1_rptr} <= 0;
        else {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};

    //sync_w2r module in original code:
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) {rq2_wptr,rq1_wptr} <= 0;
        else {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};

    // fifomem module in original code:
    generate
        if (pBRAM) begin : bram_inst
            // instantiation of a vendor's dual-port RAM
            // TODO: Xilinx BRAM
            vendor_ram mem (
                .dout(rdata), 
                .din(wdata),
                .waddr(waddr), 
                .raddr(raddr),
                .wen(wen),
                .wclken_n(wfull), 
                .clk(wclk)
            );
        end
        else begin: flop_inst
            // RTL Verilog memory model
            reg [pDATA_WIDTH-1:0] mem [0:pDEPTH-1];
            assign rdata_fwft = mem[raddr];
            always @(posedge wclk)
                if (wen && !wfull) mem[waddr] <= wdata;
            always @(posedge rclk)
                if (ren && !rempty) rdata_reg <= rdata_fwft;
            //debug only:
            wire [63:0] mem0 = mem[0];
            wire [63:0] mem1 = mem[1];
            wire [63:0] mem2 = mem[2];
            wire [63:0] mem3 = mem[3];
        end
    endgenerate

    // New: optional first word fall through mode
    assign rdata = pFALLTHROUGH ? rdata_fwft : rdata_reg;

    // rptr_empty module in original code:
    // GRAYSTYLE2 pointer
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) {rbin, rptr} <= 0;
        else {rbin, rptr} <= {rbinnext, rgraynext};
    // Memory read-address pointer (okay to use binary to address memory)
    assign raddr = rbin[pADDR_WIDTH-1:0];
    assign rbinnext = rbin + (ren & ~rempty);
    assign rgraynext = (rbinnext>>1) ^ rbinnext;
    //---------------------------------------------------------------
    // FIFO empty when the next rptr == synchronized wptr or on reset
    //---------------------------------------------------------------
    assign rempty_val = (rgraynext == rq2_wptr);
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) rempty <= 1'b1;
        else rempty <= rempty_val;

    // wptr_full module in original code:
    // GRAYSTYLE2 pointer
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) {wbin, wptr} <= 0;
        else {wbin, wptr} <= {wbinnext, wgraynext};
    // Memory write-address pointer (okay to use binary to address memory)
    assign waddr = wbin[pADDR_WIDTH-1:0];
    assign wbinnext = wbin + (wen & ~wfull);
    assign wgraynext = (wbinnext>>1) ^ wbinnext;
    //------------------------------------------------------------------
    // Simplified version of the three necessary full-tests:
    // assign wfull_val = ((wgraynext[pADDR_WIDTH]    !=wq2_rptr[pADDR_WIDTH] ) &&
    //                     (wgraynext[pADDR_WIDTH-1]  !=wq2_rptr[pADDR_WIDTH-1]) &&
    //                     (wgraynext[pADDR_WIDTH-2:0]==wq2_rptr[pADDR_WIDTH-2:0]));
    //------------------------------------------------------------------
    assign wfull_val = (wgraynext=={~wq2_rptr[pADDR_WIDTH:pADDR_WIDTH-1],
                                     wq2_rptr[pADDR_WIDTH-2:0]});
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) wfull <= 1'b0;
        else wfull <= wfull_val;

    // New: programmable almost full threshold
    // Convert the read pointer from gray to binary so that it can be compared
    // against the write pointer + threshold in binary.
    // Gray to binary conversion examples and tests:
    wire [pADDR_WIDTH:0] wq2_rptr_bin = wq2_rptr ^ (wq2_rptr_bin>>1);
    reg  [pADDR_WIDTH:0] wq2_rptr_bin_r;
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wfull_threshold <= 1'b0;
            wq2_rptr_bin_r <= 0;
        end
        else begin
            wq2_rptr_bin_r <= wq2_rptr_bin; // help timing?
            if (wq2_rptr_bin_r + wfull_threshold_value <= wbin)
                wfull_threshold <= 1'b1;
            else
                wfull_threshold <= 1'b0;
        end
    end

    // examples of gray-to-binary conversions, to validate:
    //wire [pADDR_WIDTH:0] wgray2bin = wgraynext ^ (wbinnext>>1);
    //wire [pADDR_WIDTH:0] wgray2bin2 = wgraynext ^ (wgray2bin2>>1);
    //wire g2b_pass = wgray2bin == wbinnext;
    //wire g2b_pass2 = wgray2bin2 == wbinnext;


endmodule

`default_nettype wire

