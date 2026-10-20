package alsu_scoreboard_pkg;

import alsu_seq_item_pkg::*;
import alsu_shared_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class alsu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(alsu_scoreboard)

  uvm_analysis_export #(alsu_seq_item) sb_export;
  uvm_tlm_analysis_fifo #(alsu_seq_item) sb_fifo;

  alsu_seq_item seq_item_sb;

  logic [15:0] leds_ref;            //outputs
  logic signed [5:0] out_ref;

  //input registers (the DUT registers its inputs, so the model works on the previous cycle's inputs)
  bit red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg;
  logic signed [1:0] cin_reg;
  logic [2:0] opcode_reg;
  logic signed [2:0] A_reg, B_reg;

  int error_count = 0;
  int correct_count = 0;

  function new(string name = "alsu_scoreboard", uvm_component parent = null) ;
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_export = new("sb_export", this);
    sb_fifo = new("sb_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sb_export.connect(sb_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      sb_fifo.get(seq_item_sb);

      ref_model(seq_item_sb);

      if ((seq_item_sb.out != out_ref) || (seq_item_sb.leds != leds_ref)) begin
        `uvm_error("run_phase", $sformatf("Comparsion failed: %s | out_ref = 0d%0d, leds_ref = 0b%0b", seq_item_sb.convert2string(), out_ref, leds_ref));
        error_count++;
      end
      else begin
        `uvm_info("run_phase", $sformatf("Correct ALSU out: %s ", seq_item_sb.convert2string()), UVM_HIGH);
        correct_count++;
      end
    end
  endtask

//--------------------------------------golden model start ---------------------------------------//
  function bit is_invalid();
    if (opcode_reg == INVALID_6 || opcode_reg == INVALID_7)
      return 1;
    else if ((opcode_reg > 3'b001) && (red_op_A_reg || red_op_B_reg))
      return 1;
    else
      return 0;
  endfunction

  task reset_internals();
    {red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg} = 6'b000000;
    cin_reg = 2'b00;
    opcode_reg = 3'b000;
    A_reg = 3'b000;
    B_reg = 3'b000;
  endtask

  task update_internals(alsu_seq_item seq_item_chk);
    cin_reg = seq_item_chk.cin;
    red_op_B_reg = seq_item_chk.red_op_B;
    red_op_A_reg = seq_item_chk.red_op_A;
    bypass_B_reg = seq_item_chk.bypass_B;
    bypass_A_reg = seq_item_chk.bypass_A;
    direction_reg = seq_item_chk.direction;
    serial_in_reg = seq_item_chk.serial_in;
    opcode_reg = seq_item_chk.opcode;
    A_reg = seq_item_chk.A;
    B_reg = seq_item_chk.B;
  endtask

  task ref_model(alsu_seq_item seq_item_chk);
    if (seq_item_chk.rst) begin
      out_ref = 0;
      leds_ref = 0;
      reset_internals();
    end
    else begin
      if (is_invalid())
        leds_ref = ~leds_ref;
      else
        leds_ref = 0;

      if (bypass_A_reg)
        out_ref = A_reg;
      else if (bypass_B_reg)
        out_ref = B_reg;
      else if (is_invalid())
        out_ref = 0;
      else begin
        // or
        if (opcode_reg == OR) begin
          if (red_op_A_reg)
            out_ref = |A_reg;
          else if (red_op_B_reg)
            out_ref = |B_reg;
          else
            out_ref = A_reg | B_reg;
        end
        // xor
        else if (opcode_reg == XOR) begin
          if (red_op_A_reg)
            out_ref = ^A_reg;
          else if (red_op_B_reg)
            out_ref = ^B_reg;
          else
            out_ref = A_reg ^ B_reg;
        end
        // add
        else if (opcode_reg == ADD) begin
          out_ref = A_reg + B_reg + cin_reg;
        end
        // mult
        else if (opcode_reg == MULT) begin
          out_ref = A_reg * B_reg;
        end
        // shift
        else if (opcode_reg == SHIFT) begin
          if (direction_reg)
            out_ref = {out_ref[4:0], serial_in_reg};
          else
            out_ref = {serial_in_reg, out_ref[5:1]};
        end
        // rotate
        else if (opcode_reg == ROTATE) begin
          if (direction_reg)
            out_ref = {out_ref[4:0], out_ref[5]};
          else
            out_ref = {out_ref[0], out_ref[5:1]};
        end
      end

      update_internals(seq_item_chk);
    end
  endtask
//--------------------------------------golden model end ---------------------------------------//

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("report_phase", $sformatf("Total successful transactions: %0d",correct_count), UVM_MEDIUM);
    `uvm_info("report_phase", $sformatf("Total failed transactions: %0d",error_count), UVM_MEDIUM);
  endfunction

endclass
endpackage
