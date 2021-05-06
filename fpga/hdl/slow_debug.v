`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/* Convert short pulses into longer pulses, so that it can be observed on slow
   logic analyzers
*/

module slow_debug(  
    input wire         clk,
    input wire         I_fast,
    output reg         O_slow
);

   reg fast_r = 1'b0;
   reg [3:0] count;
   
   always @ (posedge clk) begin
      fast_r <= I_fast;
      if (I_fast & ~fast_r) begin
         count <= 0;
         O_slow <= 1;
      end
      else if (count < 15)
         count <= count + 1;
      else if (~I_fast)
         O_slow <= 0;
   end

endmodule
`default_nettype wire
