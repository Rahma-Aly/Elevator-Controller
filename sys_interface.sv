`ifndef SYS_INTERFACE_SV
`define SYS_INTERFACE_SV

`timescale 1ns/1ns
import sys_pkg::*;

interface sys_interface;
    bit                    clk; //system clk
    bit                    rst_n; //asynchronous negative edge clk
    logic [NUM_FLOORS-1:0] up_call; //1 bit for each requesting floor (1 -> request)
    logic [NUM_FLOORS-1:0] down_call;//                               
    logic [2*NUM_FLOORS-1:0] requested_floors; //1 floor per elevator (E2,E1)
    logic    [5:0]         elevators_location; // updated whenever the elevator goes up (+1) or down (-1) (E2,E1)
    logic    [1:0]         doors_status; //0 -> opened , 1 -> closed
    logic    [1:0]         up; //MSB -> elevator 2 (E2), LSB -> elevator 1 (E1)
    logic    [1:0]         down;
    logic    [1:0]         stop;  // 1-> stop  
    
    
    // clocking cb_driver @(posedge clk);
    //     default input #5ns output #10ns;
    //     output rst_n,up_call,down_call,requested_floors,elevators_location,doors_status;
    //     input  up,down,stop;
    // endclocking

    // clocking cb_monitor @(posedge clk);
    //     default input #5ns output #10ns;
    //     input rst_n,up_call,down_call,requested_floors,elevators_location,doors_status, up,down,stop;
    // endclocking
    
endinterface : sys_interface


`endif

