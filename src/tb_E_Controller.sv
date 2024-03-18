`timescale 1ns/1ns
import sys_pkg::*;

module tb_E_Controller();
    
 reg clk,rst_n,rf_valid,door_status;
 reg [NUM_FLOORS-1:0] requested_floors,calls;
 logic [2:0]      E_go_to_floors[$];
 logic [2:0] E_location; 
 E_states E_state;
 wire up,down,stop;

E_Controller DUT(
    .clk(clk),
    .rst_n(rst_n),
    .requested_floors(requested_floors),
    .rf_valid(rf_valid),
    .E_location(E_location),
    .door_status(door_status),
    .E_go_to_floors(E_go_to_floors),
    .E_state(E_state),
    .up(up),
    .down(down),
    .stop(stop)
);
	localparam CLK_PERIOD = 100;
    always #(CLK_PERIOD/2) clk = ~clk;
    
    
    initial begin
        clk = 0;
        /*-----------------------------------------------------------*/
        apply_rst();
        /*---------------------Move up--------------------------------*/
        //move up from idle state at E_location = 0
        @(posedge clk)calls = 'b100_100; //5 2
        InsertFloor(calls, E_go_to_floors);
        #(CLK_PERIOD) calls =0;
        door_status = 1; //closed
        wait(DUT.present_state == SERVE) #1;
        rf_valid = 1;
        requested_floors = 'b10; //1
        @(posedge clk) rf_valid = 0;
        /*---------------------------Move down----------------------------------*/
        wait(DUT.present_state == IDLE) 
        #(3*CLK_PERIOD)
        E_location = 5;
        @(posedge clk)calls = 'b010_101; //4 2 0
        E_go_to_floors.delete();
        InsertFloor(calls, E_go_to_floors);
        #(CLK_PERIOD) calls =0;
        
    end
    
     /*--------------------------update elevators location--------------------------*/
    always @(posedge clk) begin
        #1;
        if (up) begin
            E_location = E_location+1;
        end
        else if (down && (E_location!=0))begin
            E_location = E_location-1;
        end
        
//        foreach (calls[i])begin
//            if (i == E_location) calls[i] = 0;
//        end
    end
    
//    always @(posedge clk) begin
//        if (E_state == SERVE) rf_valid = 1;
//        else rf_valid = 0;
//    end
     /*----------------------------------------------------------------------*/
    task apply_rst();
        rst_n = 1;
        rf_valid = 0;
        door_status = 0; //opened
        requested_floors = 0;
        E_location = 0;
        calls = 0;
        @(negedge clk);
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
    endtask : apply_rst
endmodule : tb_E_Controller
