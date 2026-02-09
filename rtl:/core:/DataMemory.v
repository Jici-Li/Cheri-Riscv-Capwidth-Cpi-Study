`timescale 1ns/1ps
module DataMemory129#(
    parameter DEPTH_WORDS=256)
    (
    input  wire clk,
    input  wire MemRead,
    input  wire MemWrite,
    input  wire[31:0]addr,       // byte address
    input  wire[128:0]wd,
    output reg[128:0]rd
);
    reg[31:0]mem[0:DEPTH_WORDS-1];
    wire[31:0]word_index=addr[31:2];

    integer i;
    initial begin
        for(i=0;i<DEPTH_WORDS;i=i+1)mem[i]=32'b0;
        rd=129'b0;
    end

    always@(posedge clk)begin
        if(MemWrite)begin
            mem[word_index]<=wd[31:0];
        end
    end

    always@(*)begin
        if(MemRead)rd={1'b0,96'b0,mem[word_index]};
        else         rd=129'b0;
    end
endmodule