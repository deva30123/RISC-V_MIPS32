module ifetch(
  input ALU,
  input sel,
  output NPC,
  output IR
);
  reg [31:0] PC;
  NPC = sel?ALU:(PC+1);
  IR = inst_mem(.addr_r(PC))
endmodule
