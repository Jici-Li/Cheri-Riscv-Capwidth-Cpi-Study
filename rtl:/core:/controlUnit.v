`timescale 1ns/1ps
module controlUnit(
    input wire[6:0]opcode,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg ALUSrc,
    output reg Branch,
    output reg[1:0]ALUOp
);
    always@(*)begin
        // Default values
        Branch=0;MemRead=0;MemToReg=0;
        MemWrite=0;ALUSrc=0;RegWrite=0;
        ALUOp=2'b00;
        case (opcode)
            7'b0110011:begin//R-type
                RegWrite=1;
                ALUSrc=0;
                ALUOp=2'b10;
            end
            7'b0010011:begin//I-type ALU
                RegWrite=1;
                ALUSrc=1;
                ALUOp=2'b11;
            end
            7'b0000011:begin//LOAD
                RegWrite=1;
                MemRead=1;
                MemToReg=1;
                ALUSrc=1;
                ALUOp=2'b00;
            end
            7'b0100011:begin//STORE
                MemWrite=1;
                ALUSrc=1;
                ALUOp=2'b00;
            end
            7'b1100011:begin//BRANCH
                Branch=1;
                ALUSrc=0;
                ALUOp=2'b01;
            end
            default:begin end
        endcase
    end
endmodule
