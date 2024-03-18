`ifndef SYS_TRANSACTION_SV
`define SYS_TRANSACTION_SV

import uvm_pkg::*;
import sys_pkg::*;
`include "uvm_macros.svh"

class sys_transaction extends uvm_sequence_item;
	`uvm_object_utils(sys_transaction)

    bit                         clk; //system clk
    bit                         rst_n; //asynchronous negative edge clk
    rand bit [NUM_FLOORS-1:0]   up_call; //1 bit for each requesting floor (1 -> request)
    rand bit [NUM_FLOORS-1:0]   down_call;//                               
    rand bit [2*NUM_FLOORS-1:0] requested_floors; //(E2,E1)
    rand bit    [1:0]           doors_status; //0 -> opened , 1 -> closed
         bit    [5:0]           elevators_location; // updated whenever the elevator goes up (+1) or down (-1) (E2,E1)
    logic       [1:0]           up; //MSB -> elevator 2 (E2), LSB -> elevator 1 (E1)
    logic       [1:0]           down;
    logic       [1:0]           stop;  // 1-> stop  
    
    function new (string name = "sys_transaction");
    	super.new(name);
    endfunction

    virtual function string convert2string();
		return $sformatf("up_call: %0b, down_call: %0b, requested_floors: %0b, E1_location: %0d, E2_location: %0d, doors_status: %0b up = %0b , down = %0b, stop = %0b", 
			up_call,down_call,requested_floors,elevators_location[2:0],elevators_location[5:3],doors_status,up,down,stop);
	endfunction

endclass: sys_transaction


`endif
