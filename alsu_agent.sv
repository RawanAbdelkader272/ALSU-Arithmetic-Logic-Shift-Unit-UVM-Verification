package alsu_agent_pkg;

import alsu_monitor_pkg::*;
import alsu_driver_pkg::*;
import alsu_config_pkg::*;
import alsu_sequencer_pkg::*;
import alsu_seq_item_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class alsu_agent extends uvm_agent;
  `uvm_component_utils(alsu_agent);

  alsu_sequencer sqr;
  alsu_driver drv;
  alsu_monitor mon;
  alsu_config alsu_cfg;

  uvm_analysis_port #(alsu_seq_item) agt_ap;

  function new (string name = "alsu_agent", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(alsu_config)::get(this , "", "ALSU_CFG", alsu_cfg))begin
      `uvm_fatal("build_phase" , "Unable to get configuration object")
    end

    if (alsu_cfg.is_active == UVM_ACTIVE) begin
      sqr = alsu_sequencer::type_id::create("sqr",this);
      drv = alsu_driver::type_id::create("drv",this);
    end
    mon = alsu_monitor::type_id::create("mon",this);

    agt_ap = new("agt_ap", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    mon.alsu_vif = alsu_cfg.alsu_vif;
    mon.mon_ap.connect(agt_ap);

    if (alsu_cfg.is_active == UVM_ACTIVE) begin
      drv.alsu_vif = alsu_cfg.alsu_vif;
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction
endclass
endpackage
