import sys_pkg::*;

module MainController( 
    input                    clk, //system clk
    input                    rst_n, //asynchronous negative edge clk
    input [NUM_FLOORS-1:0]   up_call, //1 bit for each requesting floor (1 -> request)
    input [NUM_FLOORS-1:0]   down_call,//                               
    input [2*NUM_FLOORS-1:0] requested_floors, //(E2,E1)
    input    [5:0]           elevators_location, // updated whenever the elevator goes up (+1) or down (-1) (E2,E1)
    input    [1:0]           doors_status, //0 -> opened , 1 -> closed
    output   [1:0]           up, //MSB -> elevator 2 (E2), LSB -> elevator 1 (E1)
    output   [1:0]           down,
    output   [1:0]           stop  // 1-> stop  

);

E_states    E1_state,E2_state;
wire        E1_rf_valid,E2_rf_valid;
wire [2:0]  E1_location,E2_location;
logic [2:0] E1_go_to_floors [$];
logic [2:0] E2_go_to_floors [$];

CallHandler CallHandler_instance(
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

E_Controller E1_Controller(
    .clk(clk),
    .rst_n(rst_n),
    .requested_floors(requested_floors[NUM_FLOORS-1:0]),
    .rf_valid(E1_rf_valid),
    .E_location(E1_location),
    .door_status(doors_status[0]),
    .E_go_to_floors(E1_go_to_floors),
    .E_state(E1_state),
    .up(up[0]),
    .down(down[0]),
    .stop(stop[0])
);

E_Controller E2_Controller(
    .clk(clk),
    .rst_n(rst_n),
    .requested_floors(requested_floors[2*NUM_FLOORS-1:NUM_FLOORS]),
    .rf_valid(E2_rf_valid),
    .E_location(E2_location),
    .door_status(doors_status[1]),
    .E_go_to_floors(E2_go_to_floors),
    .E_state(E2_state),
    .up(up[1]),
    .down(down[1]),
    .stop(stop[1])
);
	
endmodule : MainController
