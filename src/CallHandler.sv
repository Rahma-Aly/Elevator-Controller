import sys_pkg::*;

module CallHandler (
    input                  clk,
    input                  rst_n,
    input [NUM_FLOORS-1:0] elevators_location, //(E2,E1)
    input [NUM_FLOORS-1:0] up_call,
    input [NUM_FLOORS-1:0] down_call,
    input E_states         E1_state,
    input E_states         E2_state,
    
    output [2:0]           E1_location,
    output [2:0]           E2_location,
    output logic [2:0]     E1_go_to_floors[$],
    output logic [2:0]     E2_go_to_floors[$],
    output logic           E1_rf_valid,
    output logic           E2_rf_valid
    
);

logic [NUM_FLOORS-1:0] up_call_reg,down_call_reg;
bit new_Call_up;
bit new_Call_down;

Call_handler_states present_state,next_state;
logic [2:0] stored_calls[$];

/*--------------------------------------------------*/
assign E1_location = elevators_location[2:0];
assign E2_location = elevators_location[5:3];
/*-------------------------------------------------*/
assign new_Call_up = (up_call != up_call_reg); 
assign new_Call_down = (down_call != down_call_reg); 
/*-------------------------------------------------*/
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)begin
        up_call_reg <= 'b0;
        down_call_reg <= 'b0;
    end
    else begin
            up_call_reg <= up_call;
            down_call_reg <= down_call;
    end
end
/*-------------------------------------------------*/
always @(posedge clk or negedge rst_n) begin
   if (~rst_n) begin
       present_state <= NO_NEW_CALL;
   end
   else begin
       present_state <= next_state;
   end
end

always_comb begin : next_state_logic
   case (present_state)
       NO_NEW_CALL : begin
           if (stored_calls.size()!=0) begin //(new_Call_up || new_Call_down)begin 
               next_state = ASSIGN_CALL;
           end
           else begin
                next_state = NO_NEW_CALL;
           end
       end
       ASSIGN_CALL : begin
           if (stored_calls.size() != 0) begin
               next_state = ASSIGN_CALL;
           end
           else begin
                   next_state = NO_NEW_CALL;
           end
       end
       default : begin
           next_state = NO_NEW_CALL;
       end
   endcase 
end
always@(posedge clk) begin
    case(present_state)
        NO_NEW_CALL:begin
            check_new_call();
        end
        ASSIGN_CALL: begin
            check_new_call();
            assign_calls();
        end
        default:begin
        end
        endcase
end

always_comb begin
    if (E1_state == SERVE) begin
         E1_rf_valid = 1;
    end
    else begin
         E1_rf_valid = 0;   
    end    
    if (E2_state == SERVE) begin
            E2_rf_valid = 1;
    end
    else begin
            E2_rf_valid = 0;
    end    
end

/*-----------------------------------------------*/

/*------------------functions----------------------*/
/*-----------------------------------------------------*/
//asssigns input calls to elevators
function automatic void assign_calls();
    if (E1_state == IDLE && E2_state == IDLE)begin
        if (E1_location > E2_location)begin //move E1 up and E2 down
            E1_go_to_floors = SendUpperFloors(stored_calls,E1_location);
            if (E1_go_to_floors.size() == 0) E1_go_to_floors = SendLowerFloors(stored_calls,E1_location);
            E2_go_to_floors = SendLowerFloors(stored_calls, E2_location);
            if (E2_go_to_floors.size() == 0) E2_go_to_floors = SendUpperFloors(stored_calls,E2_location);
        end
        else if (E1_location < E2_location) begin  //move E2 up and E1 down
            E2_go_to_floors = SendUpperFloors(stored_calls,E2_location);
            if (E2_go_to_floors.size() == 0) E2_go_to_floors = SendLowerFloors(stored_calls, E2_location);
            E1_go_to_floors = SendLowerFloors(stored_calls, E1_location);
            if (E1_go_to_floors.size() == 0)E1_go_to_floors =  SendUpperFloors(stored_calls,E1_location);
        end
        else begin //move E1 up and E2 down
            E1_go_to_floors = SendUpperFloors(stored_calls,E1_location);
            if (E1_go_to_floors.size() == 0) E1_go_to_floors = SendLowerFloors(stored_calls,E1_location);
            E2_go_to_floors = SendLowerFloors(stored_calls, E2_location);
            if (E2_go_to_floors.size() == 0) E2_go_to_floors = SendUpperFloors(stored_calls,E2_location);
        end            
    end
    else if (E1_state == IDLE && E2_state == MOVE_UP) begin //send E2 upper floors and the rest to E1 depending on it's location
         E2_go_to_floors = SendUpperFloors(stored_calls,E2_location);
         E1_go_to_floors = SendLowerFloors(stored_calls, E1_location);
         if (E1_go_to_floors.size() == 0)E1_go_to_floors =  SendUpperFloors(stored_calls,E1_location);  
    end
    else if (E1_state == IDLE && E2_state == MOVE_DOWN) begin
        E1_go_to_floors = SendUpperFloors(stored_calls,E1_location);
         if (E1_go_to_floors.size() == 0) E1_go_to_floors = SendLowerFloors(stored_calls,E1_location);
        E2_go_to_floors = SendLowerFloors(stored_calls, E2_location);
    end
    else if (E1_state == MOVE_UP  && E2_state == IDLE) begin
        E1_go_to_floors = SendUpperFloors(stored_calls,E1_location);
        E2_go_to_floors = SendLowerFloors(stored_calls, E2_location);
        if (E2_go_to_floors.size() == 0) E2_go_to_floors = SendUpperFloors(stored_calls,E2_location);
    end  
    else if (E1_state == MOVE_UP && E2_state == MOVE_UP) begin
        E1_go_to_floors = SendUpperFloors(stored_calls,E1_location);
        E2_go_to_floors = SendUpperFloors(stored_calls,E2_location);
    end  
    else if (E1_state == MOVE_UP && E2_state == MOVE_DOWN) begin
        E1_go_to_floors = SendUpperFloors(stored_calls,E1_location);
        E2_go_to_floors = SendLowerFloors(stored_calls, E2_location);    
    end 
    else if (E1_state == MOVE_DOWN  && E2_state == IDLE) begin
            $display("%0t, stored_call: %0p",$time,stored_calls);
        E1_go_to_floors = SendLowerFloors(stored_calls, E1_location);
        E2_go_to_floors = SendUpperFloors(stored_calls,E2_location);
        if (E2_go_to_floors.size() == 0) E2_go_to_floors = SendLowerFloors(stored_calls, E2_location);
    end  
    else if (E1_state == MOVE_DOWN  && E2_state == MOVE_UP) begin
        E1_go_to_floors = SendLowerFloors(stored_calls, E1_location);
        E2_go_to_floors = SendUpperFloors(stored_calls,E2_location);
    end 
    else begin // if (E1_state == MOVE_DOWN && E2_state == MOVE_DOWN) begin
        E1_go_to_floors = SendLowerFloors(stored_calls, E1_location);
        E2_go_to_floors = SendLowerFloors(stored_calls, E2_location); 
    end  
    
endfunction : assign_calls
/*---------------------------------------------------------------------*/
/*---------------------------------------------------------------------*/  
//finds floors above elevator's location 
function automatic reg3bits_depth6 SendUpperFloors (ref logic [2:0] floor_array[$], input [2:0] E_location);
    logic [2:0] E_GT_list [$];
    automatic int j = 0;
    for (int i = 0; i < floor_array.size();i++) begin 
        if (floor_array[i]>=E_location)begin //>
            E_GT_list[j] = floor_array[i];
            j = j+1;
            floor_array.delete(i--);
        end      
    end
    return E_GT_list;
endfunction: SendUpperFloors
/*----------------------------------------------------------------------*/
/*---------------------------------------------------------------------*/
//finds floors above elevator's location 
function automatic reg3bits_depth6 SendLowerFloors (ref logic [2:0] floor_array[$], input [2:0] E_location);
    logic [2:0] E_GT_list [$];
    automatic int j = 0;
    for (int i = 0; i < floor_array.size();i++) begin
        if (floor_array[i] <= E_location)begin //or <
            E_GT_list[j] = floor_array[i];
            j = j+1;
            floor_array.delete(i--);
        end      
    end
    E_GT_list.rsort();
    return E_GT_list;
endfunction: SendLowerFloors
/*----------------------------------------------------------------------*/
function automatic void check_new_call();
    if (new_Call_up&& up_call !=0 && !new_Call_down) begin
       InsertFloor(up_call, stored_calls);
    end
    else if (new_Call_down && down_call !=0 && !new_Call_up) begin
       InsertFloor(down_call, stored_calls);     
    end
    else if (new_Call_up&& up_call !=0 && new_Call_down && down_call !=0 )begin
       InsertFloor((up_call|down_call), stored_calls);
    end
endfunction: check_new_call    
/*----------------------------------------------------------------------*/
endmodule