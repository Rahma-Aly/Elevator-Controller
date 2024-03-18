`ifndef SYS_ENV_SV
`define SYS_ENV_SV

import uvm_pkg::*;
import sys_pkg::*;
`include "uvm_macros.svh"
`include "sys_agent.sv"
`include "sys_coverage.sv"
`include "sys_scoreboard.sv"

class sys_env extends  uvm_env;
	`uvm_component_utils(sys_env)
	sys_agent m_agent;
	sys_scoreboard m_scrbrd;
	sys_coverage m_cov;

	function new(string name = "sys_env",uvm_component parent = null);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_agent  = sys_agent::type_id::create("m_agent",this);
		m_scrbrd = sys_scoreboard::type_id::create("m_scrbrd",this);
		m_cov    = sys_coverage::type_id::create("m_cov",this);
	endfunction : build_phase

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		m_agent.m_monitor.m_analysis_port.connect(m_scrbrd.analysis_export);
		m_agent.m_monitor.m_analysis_port.connect(m_cov.analysis_export);
	endfunction : connect_phase
endclass : sys_env

`endif
