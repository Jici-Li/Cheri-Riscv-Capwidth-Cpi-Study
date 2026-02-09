`timescale 1ns/1ps
module mux2to1(
input[32:0]A,B,
input sel,
output[32:0]out
);
assign out=sel?A:B;
endmodule
