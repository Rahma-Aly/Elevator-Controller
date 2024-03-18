`ifndef SYS_MONITOR
`define SYS_MONITOR 

import sys_pkg::*;
import uvm_pkg::*;

`include "uvm_macros.svh"
`include "sys_transaction.sv"

class sys_monitor extends  uvm_monitor;
	`uvm_component_utils(sys_monitor)
	virtual sys_interface vif;
	sys_transaction m_trans;
	uvm_analysis_port #(sys_transaction) m_analysis_port;

	function new (string name = "sys_monitor",uvm_component parent = null);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual sys_interface)::get(this, "", "sys_interface", vif))begin
			`uvm_fatal("sys_monitor","Couldn't get virtual interface")
		end
		m_analysis_port = new("m_analysis_port",this);
	endfunction : build_phase

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			@(negedge vif.clk);
			if (vif.rst_n) begin
				m_trans = sys_transaction::type_id::create("m_trans");
				m_trans.up_call   		 	= vif.up_call;
				m_trans.down_call 		 	= vif.down_call;
				m_trans.requested_floors 	= vif.requested_floors; 
				m_trans.elevators_location  = vif.elevators_location;
				m_trans.doors_status		= vif.doors_status; 
				m_trans.up  				= vif.up; 
				m_trans.down 				= vif.down; 
				m_trans.stop 				= vif.stop;

				m_analysis_port.write(m_trans);
				`uvm_info("sys_monitor", $sformatf("transaction: ",m_trans.convert2string()),UVM_HIGH)
			end
		end
	endtask : run_phase

endclass : sys_monitor
`endif
