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
    - add Xilinx xpm_memory_sdpram instantiation

*************************************************************************/

module fifo_async #(
    parameter pDATA_WIDTH = 8,
    parameter pDEPTH = 32,
    parameter pFALLTHROUGH = 0, // "first word fall through" 
    parameter pFLOPS = 1,       // pFLOPS, pBRAM and pDISTRIBUTED are mutually exclusive
    parameter pBRAM = 0,        // Setting pBRAM or pDISTRIBUTE instantiates a Xilinx
    parameter pDISTRIBUTED = 0  // xpm_memory_sdpram instance for storage; otherwise, flops.
) (
    input  wire                         wclk, 
    input  wire                         rclk, 
    input  wire                         wrst_n,
    input  wire                         rrst_n,
    input  wire [31:0]                  wfull_threshold_value,
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

    wire [pADDR_WIDTH-1:0] wfull_threshold_value_trimmed = wfull_threshold_value[pADDR_WIDTH-1:0];

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


    `ifdef FAST_FIFO_SIM // flops simulate substantially faster (~50% faster Husky-Pro simulation)
        localparam pFAST_SIM_FLOPS = 1;
    `else
        localparam pFAST_SIM_FLOPS = 0;
    `endif

    // fifomem module in original code:
    generate
        if (pBRAM || pDISTRIBUTED) begin : xilinx_inst
            localparam pMEMORY_PRIMITIVE = (pBRAM)? "block" : "distributed";
            localparam pREAD_LATENCY = (pBRAM)? 1 : 0;

            wire [pDATA_WIDTH-1:0] memout;
            wire [pADDR_WIDTH-1:0] mem_raddr;
            wire mem_rd;

            if (pDISTRIBUTED) begin: distributed_memout_inst
                reg [pDATA_WIDTH-1:0] memout_reg;
                always @(posedge rclk) if (ren && !rempty) memout_reg <= memout;
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
                assign mem_rd = (pFALLTHROUGH)? ~rempty : ren;
                always @(posedge rclk or negedge rrst_n) begin
                    if (~rrst_n) begin
                        current_raddr <= 0;
                        next_raddr <= 1;
                    end
                    else if (ren && ~rempty) begin
                        current_raddr <= current_raddr + 1;
                        next_raddr <= next_raddr + 1;
                    end
                end
                `ifdef __ICARUS__
                    wire warning = (wen && mem_rd && (mem_raddr == waddr));
                    always @(posedge rclk or posedge wclk) begin
                        if (warning)
                            $display("%t WARNING: reading and writing same BRAM address simultaneously; probably won't work as expected! (%m)", $time);
                    end
                `endif
            end // bram_memout_inst

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
                    .CLOCKING_MODE                      ("independent_clock"),
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
                    .clka                               (wclk),     // 1-bit input: Clock signal for port A. Also clocks port B when parameter CLOCKING_MODE is "common_clock".
                    .clkb                               (rclk),     // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
                    .dina                               (wdata),    // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
                    .ena                                (1'b1),     // 1-bit input: Memory enable signal for port A. Must be high on clock cycles when write operations are initiated. Pipelined internally.
                    .enb                                (mem_rd),   // 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read operations are initiated. Pipelined internally.
                    .injectdbiterra                     (1'b0),     // 1-bit input: Controls double bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
                    .injectsbiterra                     (1'b0),     // 1-bit input: Controls single bit error injection on input data when ECC enabled (Error injection capability is not available in "decode_only" mode).
                    .regceb                             (1'b1),     // 1-bit input: Clock Enable for the last register stage on the output data path.
                    .rstb                               (~rrst_n),  // 1-bit input: Reset signal for the final port B output register stage.  Synchronously resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
                    .sleep                              (1'b0),     // 1-bit input: sleep signal to enable the dynamic power saving feature.
                    .wea                                (wen)       // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1 bit wide when word-wide writes are used. In byte-wide write configurations, each bit controls the writing one byte of dina to address addra. For example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be 4'b0010.
                );
            end // xpm_inst
        end // xilinx_inst

        if (pFLOPS || pFAST_SIM_FLOPS) begin: flop_inst
            // RTL Verilog memory model
            reg [pDATA_WIDTH-1:0] mem [0:pDEPTH-1];
            assign rdata_fwft = mem[raddr];
            always @(posedge wclk)
                if (wen && !wfull) mem[waddr] <= wdata;
            always @(posedge rclk)
                if (ren && !rempty) rdata_reg <= rdata_fwft;
            // New: optional first word fall through mode
            assign rdata = pFALLTHROUGH ? rdata_fwft : rdata_reg;
            //debug only:
            wire [63:0] mem0 = mem[0];
            wire [63:0] mem1 = mem[1];
            wire [63:0] mem2 = mem[2];
            wire [63:0] mem3 = mem[3];
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
    // The comparison is a bit tricky but boils down to: add an MSB (set to 0)
    // to both pointers to prevent overflow when adding the threshold value,
    // except when wbin has wrapped around but rbin hasn't: in that case, add
    // an MSB set to 1 to wbin, to make it as though it didn't overflow.
    wire [pADDR_WIDTH:0] wq2_rptr_bin = wq2_rptr ^ (wq2_rptr_bin>>1);
    reg  [pADDR_WIDTH:0] wq2_rptr_bin_r;

    wire [pADDR_WIDTH+1:0] adjust_rt = {1'b0, wq2_rptr_bin_r} + {2'b0, wfull_threshold_value_trimmed};
    wire [pADDR_WIDTH+1:0] adjust_wt1 = {1'b0, wbin};
    wire [pADDR_WIDTH+1:0] adjust_wt2 = {1'b1, wbin};
    wire case2 = (~wbin[pADDR_WIDTH] && wq2_rptr_bin_r[pADDR_WIDTH]);

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wfull_threshold <= 1'b0;
            wq2_rptr_bin_r <= 0;
        end
        else begin
            wq2_rptr_bin_r <= wq2_rptr_bin; // help timing?
            if (adjust_rt <= ((case2)? adjust_wt2 : adjust_wt1))
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

