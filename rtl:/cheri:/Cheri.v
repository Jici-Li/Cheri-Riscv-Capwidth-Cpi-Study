`timescale 1ns/1ps
module Cheri(
    input wire tag,
    input wire[127:0]base,
    input wire[127:0]length,
    input wire[127:0]addr,
    input wire need_load,
    input wire need_store,
    input wire need_exec,
    input wire perm_load,
    input wire perm_store,
    input wire perm_exec,
    output reg ok,
    output reg[2:0]cause
);
    localparam[2:0]
        CAUSE_NONE=3'b000,
        CAUSE_TAG=3'b001,
        CAUSE_BOUNDS=3'b010,
        CAUSE_PERM=3'b011;

    wire need_any=need_load|need_store|need_exec;

    wire[127:0]top=base+length;
    wire[127:0]last=addr+128'd3;

    always@(*)begin
        ok=1'b1;
        cause=CAUSE_NONE;
        if(need_any)begin
            if(!tag)begin
                ok=1'b0;
                cause=CAUSE_TAG;
            end else if((addr<base)||(last>=top))begin
                ok=1'b0;
                cause=CAUSE_BOUNDS;
            end else if((need_load&&!perm_load)||
                         (need_store&&!perm_store)||
                         (need_exec&&!perm_exec))begin
                ok=1'b0;
                cause=CAUSE_PERM;
            end
        end
    end
endmodule
