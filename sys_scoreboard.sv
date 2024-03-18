`ifndef SYS_SCOREBOARD_SV
`define SYS_SCOREBOARD_SV

import uvm_pkg::*;
import sys_pkg::*;
`include "uvm_macros.svh"
`include "sys_transaction.sv"

class sys_scoreboard extends  uvm_subscriber #(sys_transaction);
	`uvm_component_utils(sys_scoreboard)
	// sys_transaction m_trans;

	function new (string name = "sys_scoreboard",uvm_component parent = null);
		super.new(name,parent);
	endfunction : new

	virtual function void write(sys_transaction t);
		//insert up_call and down_call into a temp queue, check E_location exists in queue -> stop = 1
		logic [2:0] temp_array[$];
		logic [2:0] found[$];
		InsertFloor(t.up_call|t.down_call,temp_array);
		found = temp_array.find(item) with (item == t.elevators_location[5:3] || item == t.elevators_location[2:0]);
		// if (found.size() != 0) begin
		// 	if (t.stop[0] | t.stop[1]) begin
		// 		`uvm_info("sys_scoreboard",$sformatf("E_location = call floor, stop = %0b ",t.stop),UVM_LOW)
		// 	end
		// end
		//wasn't able to check sanity using scoreboard , it was done by observing the waveform
	endfunction : write



endclass : sys_scoreboard

`endif
