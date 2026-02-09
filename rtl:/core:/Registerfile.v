`timescale 1ns/1ps
module Registerfile129(
    input clk,
    input we,
    input wire[4:0]ra1,ra2,wa,
    input wire[128:0]wd,
    output wire[128:0]rd1,rd2
);

    reg[128:0]regs[0:31];
    integer i;
    initial begin
        for(i=0;i<32;i=i+1)regs[i]=129'b0;
        end
    // Read 
    assign rd1=(ra1==5'b0)?129'b0:regs[ra1];
    assign rd2=(ra2==5'b0)?129'b0:regs[ra2];
    
    // Write
    always@(posedge clk)begin
        if(we&&(wa!=5'b0))begin
            regs[wa]<=wd;
        end
    regs[0]<=129'b0;
    end
    endmodule
     
