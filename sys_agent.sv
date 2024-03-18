`ifndef SYS_AGENT_SV
`define SYS_AGENT_SV 

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "sys_driver.sv"
`include "sys_monitor.sv"
`include "sys_transaction.sv"

class sys_agent extends  uvm_agent;
	`uvm_component_utils(sys_agent)
	sys_driver m_driver;
	sys_monitor m_monitor;
	uvm_sequencer #(sys_transaction) m_sequencer;

	function new (string name = "sys_agent",uvm_component parent = null);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_driver  = sys_driver::type_id::create("m_driver",this);
		m_monitor = sys_monitor::type_id::create("m_monitor",this);
		m_sequencer =  uvm_sequencer #(sys_transaction) ::type_id::create("m_sequencer",this);
	endfunction : build_phase

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
	endfunction : connect_phase

endclass : sys_agent

`endif
