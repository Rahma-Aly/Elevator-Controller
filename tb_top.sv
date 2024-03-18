
`timescale 1ns/1ns
import sys_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "test.sv"

module tb_top ();

sys_interface sys_inter();  

MainController DUT(
	    .clk(sys_inter.clk),
	    .rst_n(sys_inter.rst_n),
	    .up_call(sys_inter.up_call),
	    .down_call(sys_inter.down_call),
	    .requested_floors(sys_inter.requested_floors),
	    .elevators_location(sys_inter.elevators_location),
	    .doors_status(sys_inter.doors_status),
	    .up(sys_inter.up),
	    .down(sys_inter.down),
	    .stop(sys_inter.stop)
	);

localparam CLK_PERIOD = 100;
always #(CLK_PERIOD/2) sys_inter.clk = ~sys_inter.clk;

initial begin
	sys_inter.clk   <= 0;
	sys_inter.rst_n <= 1;
	uvm_config_db#(virtual sys_interface)::set(null, "uvm_test_top", "sys_interface", sys_inter);
	run_test("test");
end

always @(posedge sys_inter.clk) begin
       #1; 
        if (sys_inter.up[0] && sys_inter.elevators_location[2:0] < 'd5) begin
            sys_inter.elevators_location[2:0] = sys_inter.elevators_location[2:0]+1;
            // if(sys_inter.elevators_location[2:0] == 'd6) begin
            // 	sys_inter.elevators_location[2:0] = 'd5;
            // end
        end
        else if (sys_inter.down[0] && (sys_inter.elevators_location[2:0]!=0))begin
            sys_inter.elevators_location[2:0] = sys_inter.elevators_location[2:0]-1;
        end
        
        if (sys_inter.up[1] && sys_inter.elevators_location[5:3] < 'd5) begin
            sys_inter.elevators_location[5:3] = sys_inter.elevators_location[5:3]+1;
        end
        else if (sys_inter.down[1] && (sys_inter.elevators_location[5:0]!=0))begin
            sys_inter.elevators_location[5:3] = sys_inter.elevators_location[5:3]-1;
        end
    end

endmodule
