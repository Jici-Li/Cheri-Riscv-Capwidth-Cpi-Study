`timescale 1ns/1ps
module signExtend(
    input  wire[31:0]instr,
    output reg[31:0]imm32
);
    wire[6:0]opcode=instr[6:0];
    always @(*) begin
        case (opcode)
            7'b0010011,
            7'b0000011,
            7'b1100111:
                imm32 = {{20{instr[31]}}, instr[31:20]};
            7'b0100011:
                imm32 = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011:
                imm32 = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            7'b0110111,
            7'b0010111:
                imm32 = {instr[31:12], 12'b0};
            default:
                imm32 = 32'b0;
        endcase
    end
endmodule

