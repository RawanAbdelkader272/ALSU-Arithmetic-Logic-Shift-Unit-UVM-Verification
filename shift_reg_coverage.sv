package shift_reg_coverage_pkg;
import shift_reg_seq_item_pkg::*;
import shift_reg_shared_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class shift_reg_coverage extends uvm_component;
  `uvm_component_utils(shift_reg_coverage)
  
  uvm_analysis_export #(shift_reg_seq_item) cov_export;
  uvm_tlm_analysis_fifo #(shift_reg_seq_item) cov_fifo;

  shift_reg_seq_item seq_item_cov;

  //------------------- covergroup start ----------------------------\\
  covergroup cvr_grp;
    datain_cvp : coverpoint seq_item_cov.datain; // data from seq_item
    serialin_cvp : coverpoint seq_item_cov.serial_in;
    direction_cvp : coverpoint seq_item_cov.direction;
    mode_cvp : coverpoint seq_item_cov.mode;
  endgroup
  //------------------- covergroup end ----------------------------\\

  function new(string name = "shift_reg_coverage", uvm_component parent = null) ;
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
      // sample only while the ALSU is really using the shift register
      if (seq_item_cov.valid_op)
        cvr_grp.sample(); // sample data 
    end
  endtask

endclass
endpackage
