`ifndef TEST_SV
`define TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "sys_env.sv"
`include "base_seq.sv"

class test extends uvm_test;
	`uvm_component_utils(test)
	virtual sys_interface vif;
	sys_env m_env;
	base_seq m_seq;

	function new (string name = "test", uvm_component parent = null);
		super.new(name,parent);
	endfunction 

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if (!uvm_config_db#(virtual sys_interface)::get(this, "", "sys_interface",vif )) begin
			`uvm_fatal("test","Couldn't find virtual interface")
		end
		uvm_config_db#(virtual sys_interface)::set(this, "m_env.m_agent.*", "sys_interface", vif);

		m_env = sys_env::type_id::create("m_env",this);
		m_seq = base_seq::type_id::create("m_seq");

	endfunction 

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		apply_rst();
		m_seq.start(m_env.m_agent.m_sequencer);
		#100;
		phase.drop_objection(this);
	endtask : run_phase

	task apply_rst();
        vif.rst_n <= 1;
        vif.requested_floors <= 0;
        vif.up_call <= 0;
        vif.down_call <= 0;
        vif.elevators_location <= 0;
        vif.doors_status <= 'b0; //both doors are opened
        @(posedge vif.clk)
        vif.rst_n <= 0;
        @(negedge  vif.clk) #10;
        vif.rst_n <= 1;
    endtask : apply_rst

endclass: test
`endif
