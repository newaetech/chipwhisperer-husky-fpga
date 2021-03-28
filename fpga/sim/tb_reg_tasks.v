task write_byte;
   input [pADDR_WIDTH-1:0] address;
   input [7:0] data;
   write_1byte(address, data);
endtask


task read_byte;
   input [pADDR_WIDTH-1:0] address;
   output [7:0] data;
   read_1byte(address, data);
endtask


task write_word;
   input [pADDR_WIDTH-1:0] address;
   input [31:0] data;
   int subbyte;
   rw_lots_bytes(address);
   for (subbyte = 0; subbyte < 4; subbyte = subbyte + 1)
      write_next_byte(data[subbyte*8 +: 8]);
endtask


task read_word;
   input [pADDR_WIDTH-1:0] address;
   output [31:0] data;
   int subbyte;
   rw_lots_bytes(address);
   for (subbyte = 0; subbyte < 4; subbyte = subbyte + 1)
      read_next_byte(data[subbyte*8 +: 8]);
endtask


task write_1byte;
   input [pADDR_WIDTH-1:0] address;
   input [7:0] data;
   usb_cen = 1'b1;
   @(posedge usb_clk);
   usb_alen = 1'b0;
   usb_addr = address;
   @(posedge usb_clk);
   usb_alen = 1'b1;
   repeat(4) @(posedge usb_clk);
   usb_wdata = data;
   usb_wrn = 0;
   @(posedge usb_clk);
   usb_wrn = 1;
   usb_cen = 0;
   @(posedge usb_clk);
   usb_cen = 1;
   @(posedge usb_clk);
endtask

task read_1byte;
   input [pADDR_WIDTH-1:0] address;
   output [7:0] data;
   usb_cen = 1'b1;
   @(posedge usb_clk);
   usb_alen = 1'b0;
   usb_addr = address;
   @(posedge usb_clk);
   usb_alen = 1'b1;
   repeat(2) @(posedge usb_clk);
   usb_rdn = 0;
   usb_cen = 0;
   @(posedge usb_clk);
   usb_cen = 1;
   //data = usb_data;
   @(posedge usb_clk);
   #1 data = usb_data;
   @(posedge usb_clk);
   usb_rdn = 1;
   @(posedge usb_clk);
endtask

task rw_lots_bytes;
   input [pADDR_WIDTH-1:0] address;
   usb_cen = 1'b1;
   @(posedge usb_clk);
   usb_alen = 1'b0;
   usb_addr = address;
   @(posedge usb_clk);
   usb_alen = 1'b1;
   repeat(2) @(posedge usb_clk);
   if (pSLOW_READS)
      repeat($urandom_range(2, 20)) @(posedge usb_clk);
endtask

task read_next_byte;
   output [7:0] data;
   usb_rdn = 0;
   usb_cen = 0;
   @(posedge usb_clk);
   usb_cen = 1;
   if (pSTREAM) begin
      usb_rdn = 1;
      data = usb_data;
      repeat(1) @(posedge usb_clk);
   end
   else begin
      @(posedge usb_clk);
      #1 data = usb_data;
      @(posedge usb_clk);
      usb_rdn = 1;
      repeat (1) @(posedge usb_clk);
      if (pSLOW_READS)
         repeat($urandom_range(2, 20)) @(posedge usb_clk);
   end
endtask

task read_next_sample;
   output [11:0] sample;
   begin
      if (pADC_LOW_RES) begin
         read_next_byte(rdata);
         sample = {4'b0, rdata};
      end
      else begin
         // we need either one or two fifo reads:
         if (i12BitReadCount == 0) begin
            read_next_byte(rdata_r);
            read_next_byte(rdata);
            sample = {rdata_r, rdata[7:4]};
         end
         else begin
            rdata_r = rdata;
            read_next_byte(rdata);
            sample = {rdata_r[3:0], rdata};
         end
         i12BitReadCount = ~i12BitReadCount;
      end
   end
endtask


task write_next_byte;
   input [7:0] data;
   usb_wdata = data;
   usb_wrn = 0;
   @(posedge usb_clk);
   usb_wrn = 1;
   usb_cen = 0;
   @(posedge usb_clk);
   usb_cen = 1;
   @(posedge usb_clk);
endtask

