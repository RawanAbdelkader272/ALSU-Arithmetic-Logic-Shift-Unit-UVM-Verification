////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: UVM Example
// 
////////////////////////////////////////////////////////////////////////////////
import alsu_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top();
    bit clk;

    initial begin
        forever
            #1 clk = ~clk;
    end

    alsu_if alsuif (clk);
    shift_reg_if sr_if ();

    ALSU #(.INPUT_PRIORITY("A"), .FULL_ADDER("ON")) DUT (
        .A(alsuif.A),
        .B(alsuif.B),
        .cin(alsuif.cin),
        .serial_in(alsuif.serial_in),
        .red_op_A(alsuif.red_op_A),
        .red_op_B(alsuif.red_op_B),
        .opcode(alsuif.opcode),
        .bypass_A(alsuif.bypass_A),
        .bypass_B(alsuif.bypass_B),
        .clk(clk),
        .rst(alsuif.rst),
        .direction(alsuif.direction),
        .leds(alsuif.leds),
        .out(alsuif.out)
    );

    // shift register interface is connected to the ALSU internals
    assign sr_if.serial_in = DUT.serial_in_reg;
    assign sr_if.direction = DUT.direction_reg;
    assign sr_if.mode      = DUT.opcode_reg[0];
    assign sr_if.datain    = DUT.out;
    assign sr_if.dataout   = DUT.out_shift_reg;
    // valid SHIFT (4) / ROTATE (5): no bypass, no reduction operation
    assign sr_if.valid_op  = ((DUT.opcode_reg == 3'h4) || (DUT.opcode_reg == 3'h5)) &&
                             !DUT.bypass_A_reg && !DUT.bypass_B_reg &&
                             !DUT.red_op_A_reg && !DUT.red_op_B_reg;

    initial begin
        uvm_config_db#(virtual alsu_if)::set(null, "uvm_test_top", "ALSU_IF", alsuif);
        uvm_config_db#(virtual shift_reg_if)::set(null, "uvm_test_top", "SR_IF", sr_if);
        run_test("alsu_test");
    end

endmodule
