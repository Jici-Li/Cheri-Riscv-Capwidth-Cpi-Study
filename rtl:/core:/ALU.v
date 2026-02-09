`timescale 1ns/1ps
module ALU129(
    input wire[128:0]A,B,
    input wire[3:0]ALUctl,
    output reg[128:0]Y,
    output wire Zero
);

    wire[31:0]a32=A[31:0];
    wire[31:0]b32=B[31:0];
    reg[31:0]r32;

always@(*)begin
r32=32'b0;
 case(ALUctl)
  4'b0000:Y=a32+b32;
  4'b0001:Y=a32-b32;
  4'b0010:Y=a32&b32; 
  4'b0011:Y=a32|b32;
  4'b0100:Y=a32^b32;
   default Y=32'b0;
endcase
Y={A[128],A[127:32],r32};
end
assign Zero=(r32==32'b0);
endmodule

