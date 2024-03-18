`timescale 1ns/1ns
import sys_pkg::*;

module tb_CallHandler();
	
	 reg                  clk,rst_n;
     reg [NUM_FLOORS-1:0] elevators_location,up_call,down_call;
     E_states             E1_state,E2_state;
     wire                 E1_rf_valid,E2_rf_valid;
     wire [2:0]           E1_location,E2_location;
     logic [2:0] E1_go_to_floors [$];
     logic [2:0] E2_go_to_floors [$];
    
	
	
	CallHandler DUT(
	    .clk(clk),
	    .rst_n(rst_n),
	    .elevators_location(elevators_location),
	    .up_call(up_call),
	    .down_call(down_call),
	    .E1_state(E1_state),
	    .E2_state(E2_state),
	    .E1_location(E1_location),
	    .E2_location(E2_location),
	    .E1_go_to_floors(E1_go_to_floors),
	    .E2_go_to_floors(E2_go_to_floors),
	    .E1_rf_valid(E1_rf_valid),
	    .E2_rf_valid(E2_rf_valid)
	);
	
	localparam CLK_PERIOD = 100;
    always #(CLK_PERIOD/2) clk = ~clk;
	
	 initial begin
        clk = 0;
        /*------------------------------------------------------------------------*/
        apply_rst();
        elevators_location[5:3] = 'd2;
        /*------------------------------------------------------------------------*/
        @(posedge clk) up_call = 'b101;
        /*----------------------------------------------------------------------*/
        @(posedge clk) #10;
//        @ (DUT.present_state == ASSIGN_CALL)
/*if (E1_go_to_floors.size() != 0)*/ E2_state = MOVE_UP;
E1_state = MOVE_DOWN;
        /*-----------------------------------------------------------*/
        @(posedge clk) #1;
        up_call = 'b111;
        down_call = 'b1010;
        #(CLK_PERIOD);
        E2_state = MOVE_DOWN;
        #(CLK_PERIOD);
        
    end
    
    always @(posedge clk) begin
        #10;
        $display("%0t up_call : %0b , down_call: %0b , or %0b ",$time,up_call,down_call,(up_call|down_call));
        $display("%0t stored calls %0p",$time,DUT.stored_calls);
        $display("%0t E1 go to list %0p",$time,E1_go_to_floors);
        $display("%0t E2 go to list %0p",$time,E2_go_to_floors);
    end
    
    always @(posedge clk) begin
        if (E1_state == MOVE_UP) begin
            if (elevators_location[2:0] < 6) elevators_location[2:0] ++;
        end
        else if (E1_state == MOVE_DOWN) begin
            if (elevators_location[2:0] > 0)    elevators_location[2:0] --;
        end
        
        if (E2_state == MOVE_UP) begin
            if (elevators_location[5:3] < 6) elevators_location[5:3] ++;
        end
        else if (E2_state == MOVE_DOWN) begin
            if (elevators_location[5:3] > 0)    elevators_location[5:3] --;
        end
        
    end
    
	
	task apply_rst();
        rst_n = 1;
        up_call =0;
        down_call = 0;
        elevators_location = 0;
        E1_state = IDLE;
        E2_state = IDLE;
        @(negedge clk);
        rst_n = 0;
        #10;
        @(negedge clk);
        rst_n = 1;
    endtask : apply_rst
    
     /*--------------------------------- Assertions ------------------------------------*/
    property check_rst;
        @(posedge clk)
        ~rst_n |-> ((DUT.present_state == NO_NEW_CALL) and (E1_location == 0) and (E2_location == 0) 
                    and (E1_go_to_floors.size() == 0) 
                    and (E2_go_to_floors.size() == 0) 
                    and (E1_rf_valid == 0) and (E2_rf_valid == 0)
        );
    endproperty: check_rst
    
    RST_TEST: assert property(check_rst) else $error("rst test failed");
endmodule : tb_CallHandler
