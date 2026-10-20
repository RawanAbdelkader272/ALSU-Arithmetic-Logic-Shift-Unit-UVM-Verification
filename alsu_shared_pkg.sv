package alsu_shared_pkg;
  typedef enum {RIGHT, LEFT} direction_e;
  typedef enum bit [2:0] {OR, XOR, ADD, MULT, SHIFT, ROTATE, INVALID_6, INVALID_7} opcode_e;
  typedef enum bit [2:0] {MAXPOS = 3'b011, ZERO = 3'b000, MAXNEG = 3'b100} reg_e;
  parameter unique_op = 6;
endpackage
