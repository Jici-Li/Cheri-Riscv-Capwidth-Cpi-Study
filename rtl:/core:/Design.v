`timescale 1ns/1ps
module design129(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] instr,
    input  wire        enable_switch,
    output wire [31:0] pc_out
);
    reg [31:0] pc;
    assign pc_out = pc;

    reg [31:0] instr_r;       // latched instruction
    reg        stalled;
    reg [3:0]  wait_cnt;      // wait-state counter for mem ops

    localparam integer MEM_WAIT_BASE = 4; // no compression
    localparam integer MEM_WAIT_COMP = 3; // with compression

    // =========================
    // 2) Performance counters
    // =========================
    reg [31:0] cycle_cnt;
    reg [31:0] instret_cnt;

    // expose via hierarchical reference in tb, or add outputs if you want

    // =========================
    // Decode uses instr_r (NOT instr)
    // =========================
    wire [6:0] opcode = instr_r[6:0];
    wire [4:0] rd     = instr_r[11:7];
    wire [2:0] funct3 = instr_r[14:12];
    wire [4:0] rs1    = instr_r[19:15];
    wire [4:0] rs2    = instr_r[24:20];
    wire [6:0] funct7 = instr_r[31:25];

    wire RegWrite_raw, MemRead_raw, MemWrite_raw, MemToReg, ALUSrc, Branch;
    wire [1:0] ALUOp;

    controlUnit CU(
        .opcode(opcode),
        .RegWrite(RegWrite_raw),
        .MemRead(MemRead_raw),
        .MemWrite(MemWrite_raw),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    wire [31:0] imm32;
    signExtend IG(.instr(instr_r), .imm32(imm32));

    wire [128:0] rd1, rd2;
    wire [128:0] writeBackData_final;

    // IMPORTANT: gate RegWrite when stalled
    wire RegWrite = RegWrite_raw & ~stalled;

    Registerfile129 RF(
        .clk(clk),
        .we(RegWrite),
        .ra1(rs1),
        .ra2(rs2),
        .wa(rd),
        .wd(writeBackData_final),
        .rd1(rd1),
        .rd2(rd2)
    );

    wire [3:0] ALUctl;
    aluControl ALC(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUctl(ALUctl)
    );

    wire [128:0] imm129 = {1'b0, 96'b0, imm32};
    wire [128:0] srcB   = ALUSrc ? imm129 : rd2;
    wire [128:0] srcA   = rd1;

    wire [128:0] aluY;
    wire zero;

    ALU129 ALU(
        .A(srcA),
        .B(srcB),
        .ALUctl(ALUctl),
        .Y(aluY),
        .Zero(zero)
    );

    wire takeBranch = Branch & zero;
    wire [31:0] pc_plus4  = pc + 32'd4;
    wire [31:0] pc_branch = pc + imm32;
    wire [31:0] pc_next_nominal = takeBranch ? pc_branch : pc_plus4;

    // =========================
    // 3) Memory (gate MemRead/MemWrite during stall if you want)
    // =========================
    // Simplest: keep MemRead/MemWrite asserted only on "start" cycle
    wire isMemOp = MemRead_raw | MemWrite_raw;
    wire startMem = isMemOp & ~stalled;    // first cycle of mem op

    wire MemRead  = MemRead_raw  & startMem;
    wire MemWrite = MemWrite_raw & startMem;

    wire [128:0] memRData129;
    DataMemory129 DM(
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(aluY[31:0]),
        .wd(rd2),
        .rd(memRData129)
    );

    wire [128:0] writeBackData_raw = MemToReg ? memRData129 : aluY;

    CapabilityCompressor129 COMP(
        .cap_in(writeBackData_raw),
        .enable_comp(enable_switch),
        .cap_out(writeBackData_final)
    );

    // =========================
    // 4) Stall FSM + counters + PC update
    // =========================
    wire mem_done = (wait_cnt == 0);

    // Instruction "completes" when:
    // - non-mem op: immediately (not stalled)
    // - mem op: when wait_cnt reaches 0
    wire inst_complete = (~isMemOp & ~stalled) | (stalled & mem_done);

    always @(posedge clk) begin
        if (rst) begin
            pc          <= 32'd0;
            instr_r     <= 32'd0;
            stalled     <= 1'b0;
            wait_cnt    <= 4'd0;
            cycle_cnt   <= 32'd0;
            instret_cnt <= 32'd0;
        end else begin
            // cycle counter always increments
            cycle_cnt <= cycle_cnt + 1;

            // latch new instruction only when not stalled
            if (!stalled) begin
                instr_r <= instr;
            end

            // start a mem stall on mem op
            if (startMem) begin
                stalled  <= 1'b1;
                wait_cnt <= enable_switch ? MEM_WAIT_COMP : MEM_WAIT_BASE;
            end else if (stalled) begin
                // count down stall
                if (wait_cnt != 0) wait_cnt <= wait_cnt - 1;
                // finish stall when reaches 0
                if (mem_done) stalled <= 1'b0;
            end

            // PC updates only when instruction completes
            if (inst_complete) begin
                pc <= pc_next_nominal;
                instret_cnt <= instret_cnt + 1;
            end
        end
    end

endmodule
