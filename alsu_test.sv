////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
package alsu_test_pkg;

import alsu_env_pkg::*;
import shift_reg_env_pkg::*;
import alsu_main_sequence_pkg::*;
import alsu_reset_sequence_pkg::*;
import alsu_config_pkg::*;
import shift_reg_config_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"


class alsu_test extends uvm_test;
`uvm_component_utils(alsu_test)

  alsu_env env_alsu;
  shift_reg_env env_sr;

  alsu_config alsu_cfg;
  shift_reg_config shift_reg_cfg;

  alsu_main_sequence main_seq;
  alsu_reset_sequence reset_seq;

function new(string name = "alsu_test", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env_alsu = alsu_env::type_id::create("alsu_env", this);
    env_sr = shift_reg_env::type_id::create("shift_reg_env", this);

    alsu_cfg = alsu_config::type_id::create("alsu_cfg");
    shift_reg_cfg = shift_reg_config::type_id::create("shift_reg_cfg");

    main_seq = alsu_main_sequence::type_id::create("main_seq",this);
    reset_seq = alsu_reset_sequence::type_id::create("reset_seq",this);

    // get the two virtual interfaces from the top module
    if (!uvm_config_db #(virtual alsu_if)::get(this, "", "ALSU_IF", alsu_cfg.alsu_vif))
        `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the ALSU from the uvm_config_db");
    if (!uvm_config_db #(virtual shift_reg_if)::get(this, "", "SR_IF", shift_reg_cfg.shift_reg_vif))
        `uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the shift_reg from the uvm_config_db");

    // ALSU agent drives the interface, shift_reg agent only monitors
    alsu_cfg.is_active = UVM_ACTIVE;
    shift_reg_cfg.is_active = UVM_PASSIVE;

    uvm_config_db #(alsu_config)::set(this, "alsu_env*", "ALSU_CFG", alsu_cfg);
    uvm_config_db #(shift_reg_config)::set(this, "shift_reg_env*", "SR_CFG", shift_reg_cfg);

endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    //reset sequence
    `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
    reset_seq.start(env_alsu.agt.sqr);
    `uvm_info("run_phase", "Reset Deasserted", UVM_LOW)


    //main sequence
    `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
    main_seq.start(env_alsu.agt.sqr);
    `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)
    phase.drop_objection(this);
    
endtask: run_phase

endclass: alsu_test
endpackage
