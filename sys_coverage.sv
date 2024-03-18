`ifndef SYS_COVERGE_SV
`define SYS_COVERGE_SV

import uvm_pkg::*;
import sys_pkg::*;
`include"sys_transaction.sv"

class sys_coverage extends uvm_subscriber #(sys_transaction);
	`uvm_component_utils(sys_coverage)
    bit [NUM_FLOORS-1:0]   up_call;
    bit [NUM_FLOORS-1:0]   down_call;                             
    bit [2*NUM_FLOORS-1:0] requested_floors;
    bit [5:0]              elevators_location; // updated whenever the elevator goes up (+1) or down (-1) (E2,E1)
    bit [1:0]              doors_status; //0 -> opened , 1 -> closed
    bit [1:0]              up; //MSB -> elevator 2 (E2), LSB -> elevator 1 (E1)
    bit [1:0]              down;
    bit [1:0]              stop; // 1-> stop     
    
    covergroup call_floors;
        up_call_val: coverpoint up_call {
            bins no_call         = {'b0};
            bins one_floor_only = {'b100000,'b010000,'b001000,'b000100,'b000010,'b000001};
            bins two_floors_or_more = {[0:'1]} with (!(item inside {'b0,'b100000,'b010000,'b001000,'b000100,'b000010,'b000001})); 
        }
        down_call_val: coverpoint down_call {
            bins no_call         = {'b0};
            bins one_floor_only = {'b100000,'b010000,'b001000,'b000100,'b000010,'b000001};
            bins two_floors_or_more = {[0:'1]} with (!(item inside {'b0,'b100000,'b010000,'b001000,'b000100,'b000010,'b000001}));   
        }
        UpDown_val: cross up_call_val,down_call_val;

        E1_req_floor : coverpoint requested_floors[NUM_FLOORS-1:0] {
        	bins no_req        = {'b0};
            bins one_floor_only = {'b100000,'b010000,'b001000,'b000100,'b000010,'b000001};
            bins two_floors_or_more = {[0:'1]} with (!(item inside {'b0,'b100000,'b010000,'b001000,'b000100,'b000010,'b000001}));   
        }
        E2_req_floor : coverpoint requested_floors[2*NUM_FLOORS-1:NUM_FLOORS] {
        	bins no_req        = {'b0};
            bins one_floor_only = {'b100000,'b010000,'b001000,'b000100,'b000010,'b000001};
            bins two_floors_or_more = {[0:'1]} with (!(item inside {'b0,'b100000,'b010000,'b001000,'b000100,'b000010,'b000001}));   
        }
        E1E2_req_floors : cross E1_req_floor,E2_req_floor;

    endgroup
    
    covergroup E_location;
        E1_loc_val: coverpoint elevators_location[2:0] {
            bins smallest_floor = {'b0};
            bins Last_floor     = {'b111};
            bins others         = {['b1:'b110]}; 
        }
        E2_loc_val: coverpoint elevators_location[5:3] {
            bins smallest_floor = {'b0};
            bins Last_floor     = {'b111};
            bins others         = {['b1:'b110]}; 
        }
        E1_E2_loc_val : cross E1_loc_val,E2_loc_val;
    endgroup
    
    // covergroup movement_door;
    //     E1_door: coverpoint doors_status[0] {
    //         bins E1_open   = {'b0};
    //         bins E1_closed = {'b1};   
    //     }
    //     E2_door: coverpoint doors_status[1] {
    //         bins E2_open   = {'b0};
    //         bins E2_closed = {'b1};   
    //     }
    //     E1_state: coverpoint ({up[0],down[0],stop[0]}) {
    //         bins E1_up   = {'b100};
    //         bins E1_down = {'b010};
    //         bins E1_stop = {'b001};
    //     }
    //     E2_state: coverpoint ({up[1],down[1],stop[1]}) {
    //         bins E2_up   = {'b100};
    //         bins E2_down = {'b010};
    //         bins E2_stop = {'b001};
    //     }
    //     E1_state_door : cross E1_door,E1_state {
    //         illegal_bins E1_open_up_down = E1_state_door with (E1_door == 0 && (E1_state == 'b100 || E1_state == 'b010));
    //     }
    //     E2_state_door : cross E2_door,E2_state {
    //         illegal_bins E2_open_up_down = E2_state_door with (E2_door == 0 && (E2_state == 'b100 || E2_state == 'b010));
    //     }
    // endgroup
    
    function new(string name = "sys_coverage", uvm_component parent = null);
    	super.new(name,parent);
        call_floors = new();
        E_location   = new();
        // movement_door = new();
    endfunction
    
    virtual function void write(input sys_transaction t);
        up_call   = t.up_call;
        down_call = t.down_call;       
        requested_floors   = t.requested_floors;
        elevators_location = t.elevators_location ;
        doors_status = t.doors_status;
        up   = t.up; 
        down = t.down;
        stop = t.stop;
        
        call_floors.sample();
        E_location.sample();
        // movement_door.sample();
    endfunction : write
    
    
    
    
    
endclass: sys_coverage


`endif

