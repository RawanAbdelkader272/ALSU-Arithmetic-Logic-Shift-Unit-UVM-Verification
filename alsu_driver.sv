package alsu_driver_pkg;

import alsu_config_pkg::*;
import alsu_seq_item_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class alsu_driver extends uvm_driver #(alsu_seq_item);
`uvm_component_utils(alsu_driver);

virtual alsu_if alsu_vif;
alsu_seq_item stim_seq_item;

    function new(string name = "alsu_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            stim_seq_item = alsu_seq_item::type_id::create("stim_seq_item");

            seq_item_port.get_next_item(stim_seq_item);

            alsu_vif.rst = stim_seq_item.rst;
            alsu_vif.cin = stim_seq_item.cin;
            alsu_vif.red_op_A = stim_seq_item.red_op_A;
            alsu_vif.red_op_B = stim_seq_item.red_op_B;
            alsu_vif.bypass_A = stim_seq_item.bypass_A;
            alsu_vif.bypass_B = stim_seq_item.bypass_B;
            alsu_vif.direction = stim_seq_item.direction;
            alsu_vif.serial_in = stim_seq_item.serial_in;
            alsu_vif.opcode = stim_seq_item.opcode;
            alsu_vif.A = stim_seq_item.A;
            alsu_vif.B = stim_seq_item.B;

            @(negedge alsu_vif.clk);
            seq_item_port.item_done();

            `uvm_info("run_phase", stim_seq_item.convert2string_stimulus(), UVM_HIGH)
        end
        
    endtask
endclass
endpackage
