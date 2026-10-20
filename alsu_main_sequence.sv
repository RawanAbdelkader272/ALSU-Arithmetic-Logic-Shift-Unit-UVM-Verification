package alsu_main_sequence_pkg;
import alsu_seq_item_pkg::*;
import alsu_shared_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class alsu_main_sequence extends uvm_sequence #(alsu_seq_item);
`uvm_object_utils(alsu_main_sequence);

alsu_seq_item seq_item;

    function new(string name = "alsu_main_sequence");
        super.new(name);
    endfunction

    virtual task body();
        seq_item = alsu_seq_item::type_id::create("seq_item");

        // phase 1: fully constrained random stimulus
        seq_item.unique_opcode.constraint_mode(0);
        repeat (10000) begin
            start_item(seq_item);
                assert (seq_item.randomize());
            finish_item(seq_item);
        end

        // phase 2: walk through every valid opcode once per randomization
        seq_item.constraint_mode(0);
        seq_item.unique_opcode.constraint_mode(1);
        repeat (10000) begin
            assert (seq_item.randomize() with {
                rst == 0;
                bypass_A == 0;
                bypass_B == 0;
                red_op_A == 0;
                red_op_B == 0;
            });
            for (int i = 0; i < unique_op; i++) begin
                start_item(seq_item);
                    seq_item.opcode = seq_item.op_arr[i];
                finish_item(seq_item);
            end
        end
    endtask
endclass

endpackage
