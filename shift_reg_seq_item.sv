package shift_reg_seq_item_pkg;
import shift_reg_shared_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class shift_reg_seq_item extends uvm_sequence_item;
`uvm_object_utils(shift_reg_seq_item);

rand bit serial_in;
rand direction_e direction;
rand mode_e mode;
rand logic [5:0] datain;

logic [5:0] dataout;
bit valid_op; // set by the monitor: ALSU is executing a valid SHIFT/ROTATE

    function new(string name = "shift_reg_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("%s serial_in = 0b%0b, direction = 0b%0b, mode = 0b%0b, datain = 0b%0b , dataout = 0b%0b, valid_op = 0b%0b" , super.convert2string(), serial_in, direction, mode, datain, dataout, valid_op);
    endfunction

    function string convert2string_stimulus();
        return $sformatf("serial_in = 0b%0b, direction = 0b%0b, mode = 0b%0b, datain = 0b%0b" , serial_in, direction, mode, datain);
    endfunction

endclass
endpackage
