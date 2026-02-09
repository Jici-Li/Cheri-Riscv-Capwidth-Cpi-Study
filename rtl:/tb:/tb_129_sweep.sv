`timescale 1ns/1ps
module tb_129_sweep;

  // ===== clock / reset =====
  reg clk = 0;
  always #5 clk = ~clk;

  reg rst;
  reg enable_switch;
  wire [31:0] pc_out;
  reg  [31:0] instr;

  // ===== DUT =====
  design129 dut (
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .enable_switch(enable_switch),
    .pc_out(pc_out)
  );

  // ===== "Instruction memory" (very simple) =====
  // We index by pc_out[31:2]. The DUT increments PC when an instruction completes.
  localparam int IMEM_WORDS = 4096;
  reg [31:0] imem [0:IMEM_WORDS-1];

  // RISC-V encodings used (standard RV32I)
  localparam [31:0] INSTR_LW_X1_0_X0   = 32'h0000_2083; // lw  x1, 0(x0)
  localparam [31:0] INSTR_SW_X1_0_X0   = 32'h0010_2023; // sw  x1, 0(x0)
  localparam [31:0] INSTR_ADDI_X1_X1_1 = 32'h0010_8093; // addi x1, x1, 1
  localparam [31:0] INSTR_NOP          = 32'h0000_0013; // addi x0, x0, 0

  // Drive instr from imem
  always @(*) begin
    int idx;
    idx = pc_out[31:2];
    if (idx >= 0 && idx < IMEM_WORDS) instr = imem[idx];
    else instr = INSTR_NOP;
  end

  // ===== helpers =====
  task automatic do_reset;
    begin
      rst = 1;
      repeat (3) @(negedge clk);
      rst = 0;
      @(negedge clk);
    end
  endtask

  // Fill imem with a synthetic workload:
  // Every mem_gap instructions: one LW (memory op) otherwise ADDI (ALU op).
  // This lets CPI respond to your wait-state model.
  task automatic build_workload(input int total_insts, input int mem_gap);
    int i;
    begin
      for (i = 0; i < IMEM_WORDS; i=i+1) imem[i] = INSTR_NOP;

      for (i = 0; i < total_insts && i < IMEM_WORDS; i=i+1) begin
        if (mem_gap <= 1) begin
          imem[i] = INSTR_LW_X1_0_X0;
        end else begin
          if ((i % mem_gap) == 0) imem[i] = INSTR_LW_X1_0_X0;
          else                    imem[i] = INSTR_ADDI_X1_X1_1;
        end
      end

      // End padding
      for (i = total_insts; i < total_insts + 8 && i < IMEM_WORDS; i=i+1)
        imem[i] = INSTR_NOP;
    end
  endtask

  // Run until instret_cnt reaches target (or timeout).
  task automatic run_until_instret(input int target_instret, input int max_cycles);
    int cycles;
    begin
      cycles = 0;
      while (dut.instret_cnt < target_instret && cycles < max_cycles) begin
        @(negedge clk);
        cycles = cycles + 1;
      end
    end
  endtask

  // One sweep point: set enable_switch, reset, run workload, print CSV line.
  task automatic run_point(input int mem_gap, input bit comp_en);
    real cpi;
    begin
      enable_switch = comp_en;
      do_reset();

      // Let the core run; stop after N retired instructions.
      run_until_instret(2000, 200000);

      cpi = dut.cycle_cnt * 1.0 / dut.instret_cnt;

      $display("%0d,%0d,%0d,%0d,%0f",
        mem_gap, comp_en, dut.cycle_cnt, dut.instret_cnt, cpi);
    end
  endtask

  // ===== main =====
  integer g;
  integer gaps [0:5];

  initial begin
    $dumpfile("tb_129_sweep.vcd");
    $dumpvars(0, tb_129_sweep);

    // Sweep points (acts like your "working set" axis; here it's "memory intensity")
    gaps[0]=1; gaps[1]=2; gaps[2]=4; gaps[3]=8; gaps[4]=16; gaps[5]=32;

    // Default signals
    rst = 1'b0;
    enable_switch = 1'b0;

    // Print CSV header
    $display("mem_gap,comp_en,cycles,instret,cpi");

    // Build one workload length (instructions); reused across points by re-fill
    // Here we always fill IMEM with 3000 static instructions per point.
    for (g = 0; g <= 5; g=g+1) begin
      build_workload(3000, gaps[g]);
      run_point(gaps[g], 1'b0); // baseline
      build_workload(3000, gaps[g]);
      run_point(gaps[g], 1'b1); // compressed
    end

    #50;
    $finish;
  end

endmodule
