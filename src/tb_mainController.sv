`timescale 1ns/1ns
import sys_pkg::*;

module tb_mainController();
    
	 reg                  clk,rst_n;
     reg [NUM_FLOORS-1:0] elevators_location,up_call,down_call;
     reg [2*NUM_FLOORS-1:0] requested_floors;
     reg [1:0] doors_status;
     wire [1:0] up,down,stop;
	
	MainController DUT(
	    .clk(clk),
	    .rst_n(rst_n),
	    .up_call(up_call),
	    .down_call(down_call),
	    .requested_floors(requested_floors),
	    .elevators_location(elevators_location),
	    .doors_status(doors_status),
	    .up(up),
	    .down(down),
	    .stop(stop)
	);
	
	localparam CLK_PERIOD = 100;
	always #(CLK_PERIOD/2) clk = ~clk;
	/*----------------------------------------------------------------*/
    initial begin
        clk = 0;
        /*-----------------------------------------------------------*/
        apply_rst();
        /*---------------------Move up--------------------------------*/
        //move up from idle state at E_location = 0
        @(posedge clk)up_call = 'b100_100; //5 2 
         #(CLK_PERIOD) doors_status = 'b11; //both E1, E2 doors are closed
        
        requested_floors = 'b10; //1
        doors_status = 'b11;
        //        wait (DUT.E1_rf_valid) 
//        #(CLK_PERIOD) requested_floors = 'b0; 
    end
    
     /*--------------------------update elevators location--------------------------*/
    always @(posedge clk) begin
       #1; 
        if (up[0]) begin
            elevators_location[2:0] = elevators_location[2:0]+1;
        end
        else if (down[0] && (elevators_location[2:0]!=0))begin
            elevators_location[2:0] = elevators_location[2:0]-1;
        end
        
        if (up[1]) begin
            elevators_location[5:3] = elevators_location[5:3]+1;
        end
        else if (down[1] && (elevators_location[5:0]!=0))begin
            elevators_location[5:3] = elevators_location[5:3]-1;
        end
    end
   /*---------------------------Apply rest-----------------------------------------*/
    task apply_rst();
        rst_n = 1;
        requested_floors = 0;
        up_call =0;
        down_call = 0;
        elevators_location = 0;
        doors_status = 'b0; //both doors are opened
        #30;
        rst_n = 0;
        #80;
        rst_n = 1;
    endtask : apply_rst
    /*-------------------------------------------------------------------------*/
endmodule : tb_mainController
