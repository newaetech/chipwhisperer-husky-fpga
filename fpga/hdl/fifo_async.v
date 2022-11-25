`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

This code is from:
http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf

Initial version is verbatim from the paper, except for the addition of default_nettype,
and adding the missing wire declarations necessitated by this.

*************************************************************************/

module fifo_async #(
    parameter pDATA_WIDTH = 8,
    parameter pADDR_WIDTH = 4,
    parameter pBRAM = 0
) (
    input  wire                         wclk, 
    input  wire                         rclk, 
    input  wire                         wrst_n,
    input  wire                         rrst_n,
    input  wire                         wen, 
    input  wire [pDATA_WIDTH-1:0]       wdata,
    output reg                          wfull,
    input  wire                         ren, 
    output wire [pDATA_WIDTH-1:0]       rdata,
    output reg                          rempty
);

    wire [pADDR_WIDTH-1:0] waddr, raddr;
    reg  [pADDR_WIDTH:0] wq1_rptr, wq2_rptr, rq1_wptr, rq2_wptr, wptr, rptr;
    reg [pADDR_WIDTH:0] rbin;
    wire [pADDR_WIDTH:0] rgraynext, rbinnext;
    wire rempty_val;
    reg [pADDR_WIDTH:0] wbin;
    wire [pADDR_WIDTH:0] wgraynext, wbinnext;
    wire wfull_val;


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
            localparam pDEPTH = 1<<pADDR_WIDTH;
            reg [pDATA_WIDTH-1:0] mem [0:pDEPTH-1];
            assign rdata = mem[raddr];
            always @(posedge wclk)
                if (wen && !wfull) mem[waddr] <= wdata;
        end
    endgenerate


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
    // assign wfull_val=((wgnext[pADDR_WIDTH] !=wq2_rptr[pADDR_WIDTH] ) &&
    // (wgnext[pADDR_WIDTH-1] !=wq2_rptr[pADDR_WIDTH-1]) &&
    // (wgnext[pADDR_WIDTH-2:0]==wq2_rptr[pADDR_WIDTH-2:0]));
    //------------------------------------------------------------------
    assign wfull_val = (wgraynext=={~wq2_rptr[pADDR_WIDTH:pADDR_WIDTH-1],
                                     wq2_rptr[pADDR_WIDTH-2:0]});
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) wfull <= 1'b0;
        else wfull <= wfull_val;

endmodule

`default_nettype wire

