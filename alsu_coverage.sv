package alsu_coverage_pkg;
import alsu_seq_item_pkg::*;
import alsu_shared_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class alsu_coverage extends uvm_component;
  `uvm_component_utils(alsu_coverage)
  
  uvm_analysis_export #(alsu_seq_item) cov_export;
  uvm_tlm_analysis_fifo #(alsu_seq_item) cov_fifo;

  alsu_seq_item seq_item_cov;

  //------------------- covergroup start ----------------------------\\
  covergroup cvr_grp;
    // helper coverpoints (weight 0, used only for the crosses)
    cin_cp : coverpoint seq_item_cov.cin { option.weight = 0; }
    direction_cp : coverpoint seq_item_cov.direction { option.weight = 0; }
    serial_in_cp : coverpoint seq_item_cov.serial_in { option.weight = 0; }
    red_op_A_cp : coverpoint seq_item_cov.red_op_A { option.weight = 0; }
    red_op_B_cp : coverpoint seq_item_cov.red_op_B { option.weight = 0; }

    A_cp: coverpoint seq_item_cov.A {
        bins A_data_0 = {3'b000};
        bins A_data_max = {MAXPOS};
        bins A_data_min = {MAXNEG};
        bins A_data_default = default;
    }

    A_red_cp: coverpoint seq_item_cov.A iff(seq_item_cov.red_op_A) {
        bins A_data_walkingones[] = {3'b001, 3'b010, 3'b100};
    }

    B_cp: coverpoint seq_item_cov.B {
        bins B_data_0 = {3'b000};
        bins B_data_max = {MAXPOS};
        bins B_data_min = {MAXNEG};
        bins B_data_default = default;
    }

    B_red_cp: coverpoint seq_item_cov.B iff(seq_item_cov.red_op_B && !seq_item_cov.red_op_A) {
        bins B_data_walkingones[] = {3'b001, 3'b010, 3'b100};
    }

    ALU_cp: coverpoint seq_item_cov.opcode {
        bins Bins_shift[] = {SHIFT, ROTATE};
        bins Bins_arith[] = {ADD, MULT};
        bins Bins_bitwise[] = {OR, XOR};
        bins Bins_trans = (OR => XOR => ADD => MULT => SHIFT => ROTATE);
        illegal_bins Bins_invalid = {INVALID_6, INVALID_7};
    }

    cross_perm: cross A_cp, B_cp, ALU_cp {
        ignore_bins ig_shift = binsof(ALU_cp.Bins_shift);
        ignore_bins ig_trans = binsof(ALU_cp.Bins_trans);
    }

    cross_cin: cross cin_cp, ALU_cp {
        option.cross_auto_bin_max = 0;
        bins cin_bins = binsof(ALU_cp.Bins_arith);
    }

    cross_direct_shift: cross direction_cp, ALU_cp {
        option.cross_auto_bin_max = 0;
        bins direction_bins = binsof(ALU_cp.Bins_shift);
    }

    shift_cp: coverpoint seq_item_cov.opcode {
        bins only_shift = {SHIFT};
    }

    cross_shift_in: cross shift_cp, serial_in_cp;

    cross_walking_A: cross A_red_cp, B_cp, ALU_cp iff(seq_item_cov.red_op_A) {
        ignore_bins ig_B_max = binsof(B_cp.B_data_max);
        ignore_bins ig_B_min = binsof(B_cp.B_data_min);
        ignore_bins ig_not_bitwise = !binsof(ALU_cp.Bins_bitwise);
    }

    cross_walking_B: cross B_red_cp, A_cp, ALU_cp iff(seq_item_cov.red_op_B) {
        ignore_bins ig_A_max = binsof(A_cp.A_data_max);
        ignore_bins ig_A_min = binsof(A_cp.A_data_min);
        ignore_bins ig_not_bitwise = !binsof(ALU_cp.Bins_bitwise);
    }

    not_bitwise_cp: coverpoint seq_item_cov.opcode {
        option.weight = 0;
        bins not_bitwise[] = {[ADD:$]};
    }

    cross_invaild_A: cross red_op_A_cp, not_bitwise_cp {
        ignore_bins a_0 = binsof(red_op_A_cp) intersect {0};
        illegal_bins a_1 = binsof(red_op_A_cp) intersect {1};
    }

    cross_invaild_B: cross red_op_B_cp, not_bitwise_cp {
        ignore_bins B_0 = binsof(red_op_B_cp) intersect {0};
        illegal_bins B_1 = binsof(red_op_B_cp) intersect {1};
    }
  endgroup
  //------------------- covergroup end ----------------------------\\

  function new(string name = "alsu_coverage", uvm_component parent = null) ;
    super.new(name, parent);
    cvr_grp = new(); // create cvr_g
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cov_export = new("cov_export", this);
    cov_fifo = new("cov_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    cov_export.connect(cov_fifo.analysis_export); // src to dst
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      cov_fifo.get(seq_item_cov);// first then sample data
      // same sampling condition as the original testbench: skip reset and double bypass
      if (!seq_item_cov.rst && (!seq_item_cov.bypass_A || !seq_item_cov.bypass_B))
        cvr_grp.sample(); // sample data 
    end
  endtask

endclass
endpackage
