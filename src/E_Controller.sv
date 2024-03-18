import sys_pkg::*;

module E_Controller(
	input clk,
	input                  rst_n,
	input [NUM_FLOORS-1:0] requested_floors,  
    input                  rf_valid, //1 -> valid    
    input [2:0]            E_location,
    input                  door_status, // 1->closed 
    input logic [2:0]      E_go_to_floors[$],
    
    output E_states        E_state,
    output logic           up,
    output logic           down,
    output logic           stop
);
	
E_states present_state,next_state,previous_state;
logic [2:0] go_to_floor;
logic [2:0] rf_go_to_floor [$];
int rf_go_to_floor_index [$];
int max_floor_index [$];
logic [2:0] max_floor[$];
/*-----------------------------------------------*/
//storing input go to floor, to avoid it being overwritten 
logic [2:0] E_go_to_floors_internal[$];
logic [2:0] requested_floors_internal[$];

/*-----------------------------------------------*/	
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        previous_state <= IDLE;
        present_state <= IDLE;
    end
    else begin
        previous_state <=  present_state;
        present_state <= next_state;
    end    
end

always_comb begin :next_state_update
    case(present_state)
        IDLE: begin
           if (~door_status ) begin //open
               next_state = IDLE;
           end
           else if (E_go_to_floors_internal.size() != 0 ) begin //calls not empty
                  //check max value
                if (E_location < max_floor[0]) begin
                    next_state = MOVE_UP;
                end
                else if (E_location > max_floor[0]) begin
                    next_state = MOVE_DOWN;
                end
                else begin // serve
                    if (previous_state == SERVE) begin
                        next_state = IDLE;
                    end
                    else begin
                        next_state = SERVE; 
                    end    
                end    
           end
           else begin
                   next_state = IDLE;
           end     
        end
        MOVE_UP: begin  //queue is sorted from low to high
            if (E_location == go_to_floor) begin
                next_state = SERVE;
            end
            else if (E_location == 'd5)begin
                next_state = SERVE;
            end  
            else begin
                next_state = MOVE_UP;
            end     
        end
        MOVE_DOWN : begin
            if (E_location == go_to_floor) begin
                next_state = SERVE;
            end
            else if (E_location == 0)begin
                next_state = SERVE;
            end  
            else begin
                next_state = MOVE_DOWN;
            end    
        end
        SERVE: begin
            if ((E_go_to_floors_internal.size() == 0)&&(requested_floors_internal.size() == 0)) begin
                     next_state = IDLE;                     
            end
            else if (door_status) begin //closed
                if (E_go_to_floors_internal.size() != 0) begin
                    if (previous_state == MOVE_UP) begin
                         next_state = MOVE_UP;
                    end
                    else if (previous_state == MOVE_DOWN) begin
                         next_state = MOVE_DOWN;
                    end  
                end
                else if (requested_floors_internal.size() != 0) begin
                   if (previous_state == MOVE_UP) begin
                       next_state = MOVE_DOWN;
                    end
                    else if (previous_state == MOVE_DOWN) begin
                         next_state = MOVE_UP;
                    end       
                end
                else begin
                        next_state = IDLE;
                end     
            end
            else begin
                    next_state = SERVE;
            end        
        end 
        default: next_state = IDLE;    
    endcase
end

always@(posedge clk) begin
   case(present_state)
       IDLE     : begin
           Add_new_calls();
           if (E_go_to_floors_internal.size() != 0) begin //calls not empty
             //check max value 
             max_floor = E_go_to_floors_internal.max();
             max_floor_index = E_go_to_floors_internal.find_index(item)with (item == max_floor[0]);
                 if (max_floor[0] == E_location)begin // serve
                   go_to_floor = max_floor[0];
                   E_go_to_floors_internal.delete(max_floor_index[0]);
                end 
           end
           else begin
                   go_to_floor = E_location;
                   max_floor.delete();
           end 
       end
       MOVE_UP  :begin
           Add_new_calls();
           if (E_go_to_floors_internal.size() !=0) begin
                go_to_floor = E_go_to_floors_internal.pop_front();
                if (E_location != go_to_floor) begin
                    E_go_to_floors_internal.push_front(go_to_floor);
                end
           end 
       end
       MOVE_DOWN: begin
           Add_new_calls();  
           E_go_to_floors_internal.rsort(); //sort from high to low since we are moving down
           if (E_go_to_floors_internal.size() !=0) begin
                go_to_floor = E_go_to_floors_internal.pop_front();
                if (E_location != go_to_floor) begin
                    E_go_to_floors_internal.push_front(go_to_floor);
                end
           end   
       end
       SERVE    : begin
           //check requested floor if valid and insert it 
           if (rf_valid) begin //store
                   //insert floors 
               InsertFloor(requested_floors,requested_floors_internal);
               if (previous_state == MOVE_DOWN) begin
                 rf_go_to_floor = requested_floors_internal.find(item) with (item < E_location);
                 rf_go_to_floor_index = requested_floors_internal.find_index(item) with (item < E_location);
                 Insert_RF(rf_go_to_floor); //insert found values into E_go_to_floors_internal
                 Remove_RF(rf_go_to_floor_index); //remove entered values from requested_floors_internal
                 E_go_to_floors_internal.rsort(); //sort from high to low
             end
             else if (previous_state == MOVE_UP) begin
                 rf_go_to_floor = requested_floors_internal.find(item) with (item > E_location);
                 rf_go_to_floor_index = requested_floors_internal.find_index(item) with (item > E_location);
                 Insert_RF(rf_go_to_floor); //insert found values into E_go_to_floors_internal
                 Remove_RF(rf_go_to_floor_index); //remove entered values from requested_floors_internal
             end
         end
         if (door_status) begin //closed
              if ((E_go_to_floors_internal.size() == 0) && (requested_floors_internal.size() != 0)) begin
                  E_go_to_floors_internal = requested_floors_internal;
                  requested_floors_internal.delete();
                  if (previous_state == MOVE_UP) begin
                      E_go_to_floors_internal.rsort();
                  end
                  else if (previous_state == MOVE_DOWN) begin
                    E_go_to_floors_internal.sort();
                  end       
             end  
         end
         max_floor = E_go_to_floors_internal.max();
       end
       default:begin
           //
       end
       endcase 
end

always_comb begin
    E_state = present_state;
     case(present_state)
        IDLE: begin
            stop = 1;
            up = 0;
            down = 0; 
        end
        MOVE_UP: begin
            stop = 0;
            up = 1;
            down = 0; 
        end
        MOVE_DOWN: begin
            stop = 0;
            up = 0;
            down = 1; 
        end
        SERVE: begin
            stop = 1;
            up = 0;
            down = 0; 
        end
        default: begin
            stop = 1;
            up = 0;
            down = 0; 
        end
    endcase   
end
/*-------------------------------functions----------------------------------------*/
function automatic void Add_new_calls ();
    if (E_go_to_floors_internal != E_go_to_floors) begin //new entries sent,store then remove repetitions
        foreach (E_go_to_floors[i]) begin
            E_go_to_floors_internal.push_front(E_go_to_floors[i]);
        end
        E_go_to_floors_internal = E_go_to_floors_internal.unique(); //remove repetition
        E_go_to_floors_internal.sort() ; //sort array from low to high
        if(E_go_to_floors_internal[0] == E_location) begin
            E_go_to_floors_internal.pop_front();
        end
        
    end 
    E_go_to_floors.delete();//?
endfunction
/*----------------------------------------------------------------------------------*/
function automatic void Insert_RF(ref logic [2:0] rf_array[$]);
    for (int i = 0; i < rf_array.size();i++) begin
        E_go_to_floors_internal.push_back(rf_array[i]);
        rf_array.delete(i--);
    end
    E_go_to_floors_internal = E_go_to_floors_internal.unique();
    E_go_to_floors_internal.sort();
endfunction
/*-----------------------------------------------------------------------------*/
function automatic void Remove_RF(ref int rf_array_index[$]);
        foreach (rf_array_index[i]) begin
            requested_floors_internal.delete(rf_array_index[i]);
        end
endfunction : Remove_RF
	
endmodule : E_Controller
