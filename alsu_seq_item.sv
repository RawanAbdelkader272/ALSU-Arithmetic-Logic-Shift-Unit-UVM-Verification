package alsu_seq_item_pkg;
import alsu_shared_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class alsu_seq_item extends uvm_sequence_item;
`uvm_object_utils(alsu_seq_item);

//inputs
rand bit rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, serial_in;
rand direction_e direction;
rand opcode_e opcode;
rand logic [2:0] A, B;

//outputs
logic [15:0] leds;
logic signed [5:0] out;

//helper fields used by the constraints
rand reg_e enum_a, enum_b;
rand logic [2:0] real_a, real_b;

bit [2:0] walking_ones [] = '{3'b001, 3'b010, 3'b100};
rand bit [2:0] ones_true, ones_false;

rand opcode_e op_arr [unique_op];

    function new(string name = "alsu_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("%s rst = 0b%0b, cin = 0b%0b, red_op_A = 0b%0b, red_op_B = 0b%0b, bypass_A = 0b%0b, bypass_B = 0b%0b, direction = %s, serial_in = 0b%0b, opcode = %s, A = 0d%0d, B = 0d%0d, leds = 0b%0b, out = 0d%0d",
                         super.convert2string(), rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction.name(), serial_in, opcode.name(), $signed(A), $signed(B), leds, out);
    endfunction

    function string convert2string_stimulus();
        return $sformatf("rst = 0b%0b, cin = 0b%0b, red_op_A = 0b%0b, red_op_B = 0b%0b, bypass_A = 0b%0b, bypass_B = 0b%0b, direction = %s, serial_in = 0b%0b, opcode = %s, A = 0d%0d, B = 0d%0d",
                         rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction.name(), serial_in, opcode.name(), $signed(A), $signed(B));
    endfunction

    //constrain blocks 
    constraint crst{
        rst dist {0:=98 , 1:=2};
    }

    constraint adder_inputs{
        !(real_a inside {MAXPOS, ZERO, MAXNEG});
        !(real_b inside {MAXPOS, ZERO, MAXNEG});

        ones_true inside {walking_ones};
        !(ones_false inside {walking_ones});

        if(opcode == OR || opcode == XOR){
            if(red_op_A == 1){
                B == 0;
                A dist {ones_true := 80, ones_false :=20};

            }else if(red_op_B == 1){
                A == 0;
                B dist {ones_true := 80, ones_false :=20};
            }
        }else{
            red_op_A dist {1:= 20, 0:= 80};
            red_op_B dist {1:= 20, 0:= 80};

            if (opcode == ADD || opcode == MULT){
                A dist {enum_a:= 80, real_a:=20};
                B dist {enum_b:= 80, real_b:=20};
            }
        }
    }

    constraint otherr{
        opcode dist{[OR:ROTATE] :=80 , [INVALID_6:INVALID_7] := 20};

        bypass_A dist{1:=2, 0:=98};
        bypass_B dist{1:=2 ,0:=98};
    }

    constraint unique_opcode {
        foreach (op_arr[i]) {
            op_arr[i] != INVALID_6;
            op_arr[i] != INVALID_7;
        }
        unique {op_arr};
    }

endclass
endpackage
