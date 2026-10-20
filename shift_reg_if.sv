////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: Shift register Interface (no clock, no reset)
// 
////////////////////////////////////////////////////////////////////////////////
interface shift_reg_if ();
  logic serial_in, direction, mode;
  logic [5:0] datain, dataout;
  logic valid_op; // high while the ALSU is executing a valid SHIFT/ROTATE (used to gate coverage)
endinterface : shift_reg_if
