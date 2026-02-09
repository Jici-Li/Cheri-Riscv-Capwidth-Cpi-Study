`timescale 1ns/1ps
module aluControl(
    input wire[1:0]ALUOp,
    input wire[2:0]funct3,
    input wire[6:0]funct7,
    output reg[3:0]ALUctl
);
always@(*)begin
        case (ALUOp)
            2'b00:ALUctl=4'b0000;//ADD
            2'b01:ALUctl=4'b0001;//SUB
            2'b10:begin//R-type
                case (funct3)
                    3'b000:ALUctl=(funct7[5]?4'b0001:4'b0000);//SUB/ADD
                    3'b111:ALUctl=4'b0010;//AND
                    3'b110:ALUctl=4'b0011;//OR
                    3'b100:ALUctl=4'b0100;//XOR
                    3'b010:ALUctl=4'b0101;//SLT
                    3'b011:ALUctl=4'b0110;//SLTU
                    3'b001:ALUctl=4'b0111;//SLL
                    3'b101:ALUctl=(funct7[5]?4'b1001:4'b1000);//SRA/SRL
                    default:ALUctl=4'b0000;
                endcase
            end
            2'b11:begin//I-type ALU
                case (funct3)
                    3'b000:ALUctl=4'b0000;//ADDI
                    3'b111:ALUctl=4'b0010;//ANDI
                    3'b110:ALUctl=4'b0011;//ORI
                    3'b100:ALUctl=4'b0100;//XORI
                    3'b010:ALUctl=4'b0101;//SLTI
                    3'b011:ALUctl=4'b0110;//SLTIU
                    3'b001:ALUctl=4'b0111; // SLLI
                    3'b101:ALUctl=(funct7[5]?4'b1001:4'b1000);//SRAI/SRLI
                    default:ALUctl=4'b0000;
                endcase
            end
            default: ALUctl = 4'b0000;
    endcase
end
endmodule
