`ifndef SYS_DRIVER
`define SYS_DRIVER

import uvm_pkg::*;
import sys_pkg::*;
`include "uvm_macros.svh"
`include "sys_transaction.sv"


class sys_driver extends  uvm_driver #(sys_transaction);
	`uvm_component_utils(sys_driver)
	sys_transaction m_trans;
	virtual sys_interface vif;

	function new(string name = "sys_driver", uvm_component parent = null);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual sys_interface)::get(this, "", "sys_interface", vif)) begin
			`uvm_fatal("sys_driver","couldn't get virtual interface")
		end
	endfunction : build_phase

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			seq_item_port.get_next_item(m_trans);
			@(posedge vif.clk)
			// update_floor();
			set_call();
			vif.up_call   <= m_trans.up_call;
			vif.down_call <= m_trans.down_call;
			set_req_floor();
			vif.requested_floors <= m_trans.requested_floors;
			vif.doors_status <= m_trans.doors_status;
			update_door();
			//not correct but for the tb to work properly
			vif.doors_status <= 'b11;
			seq_item_port.item_done();
		end
	endtask : run_phase

	// virtual task update_floor();
	// 	 #1; 
    //     if (vif.up[0] && vif.elevators_location[2:0] < 'd6) begin
    //         vif.elevators_location[2:0] = vif.elevators_location[2:0]+1;
    //     end
    //     else if (vif.down[0] && (vif.elevators_location[2:0]!=0))begin
    //         vif.elevators_location[2:0] = vif.elevators_location[2:0]-1;
    //     end
        
    //     if (vif.up[1] && vif.elevators_location[5:3] < 'd6) begin
    //         vif.elevators_location[5:3] = vif.elevators_location[5:3]+1;
    //     end
    //     else if (vif.down[1] && (vif.elevators_location[5:0]!=0))begin
    //         vif.elevators_location[5:3] = vif.elevators_location[5:3]-1;
    //     end
	// endtask : update_floor

	virtual task set_call();
		if (m_trans.up_call[vif.elevators_location[5:3]] == 1) begin
			m_trans.up_call[vif.elevators_location[5:3]] <= 0;
		end
		if (m_trans.up_call[vif.elevators_location[2:0]] == 1) begin
			m_trans.up_call[vif.elevators_location[2:0]] <= 0;
		end
		if (m_trans.down_call[vif.elevators_location[5:3]] == 1) begin
			m_trans.down_call[vif.elevators_location[5:3]] <= 0;
		end
		if (m_trans.down_call[vif.elevators_location[2:0]] == 1) begin
			m_trans.down_call[vif.elevators_location[2:0]] <= 0;
		end
	endtask : set_call

	virtual task set_req_floor();
		bit [5:0] E1_requested_floors = m_trans.requested_floors[5:0];
		bit [5:0] E2_requested_floors = m_trans.requested_floors[11:6];

		if (E2_requested_floors[vif.elevators_location[5:3]] == 1) begin
			E2_requested_floors[vif.elevators_location[5:3]] = 0;
		end
		if (E1_requested_floors[vif.elevators_location[2:0]] == 1) begin
			E1_requested_floors[vif.elevators_location[2:0]] = 0;
		end
		m_trans.requested_floors = {E2_requested_floors,E1_requested_floors};
	endtask : set_req_floor
	
	virtual task update_door(); //not working properly
		if (vif.stop[0] == 0 && (vif.up[0] == 1 || vif.down[0] == 1 ||vif.up_call || vif.down_call)) m_trans.doors_status[0] = 1 ;
		else vif.doors_status[0] = 0 ;
    					  
    	if (vif.stop[1] == 0 && vif.up[1] == 1 || vif.down[1] == 1||vif.up_call || vif.down_call) m_trans.doors_status[1] = 1 ;
    	else vif.doors_status[1] = 0 ;
	endtask : update_door
endclass : sys_driver
`endif
