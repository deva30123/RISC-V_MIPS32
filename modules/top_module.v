/*
will have 2 modes
1. code:- will write instructions into the inst mem 
2 excecute:- will excecute the instructions in the inst bank in repeat until halted
*/
module mips32(
  input mode,
  input in,
  input enter,
  input clr
)
