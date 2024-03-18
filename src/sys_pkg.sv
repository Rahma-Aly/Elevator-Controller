`ifndef SYS_PKG_SV
`define SYS_PKG_SV

package sys_pkg;
 
 
parameter NUM_FLOORS = 6;

typedef enum logic {
    NO_NEW_CALL  = 'b0,
    ASSIGN_CALL  = 'b1
} Call_handler_states;
   
typedef enum logic [2:0]{
    IDLE = 0,
    MOVE_UP,
    MOVE_DOWN,
    SERVE
} E_states;
/*-------------used in function return value----------------------*/
typedef logic [2:0] reg3bits;
typedef reg3bits reg3bits_depth6[$];
/*------------------functions----------------------*/
function automatic void InsertFloor(input [5:0] floor, ref logic [2:0] floor_array[$]);
     //used with up_call, down_call inputs -> to translate the input into equivalent floors
    automatic int j;
    j = floor_array.size();
    foreach (floor[i]) begin
        if (floor[i]) begin //if true , floor[i] has called the elevator
            floor_array[j] = i; //insert floor number into floor array
            floor_array.sort();
            j = j + 1;
        end
    end 
    
    if (floor_array.size() > 1) begin
        foreach(floor_array[i]) begin //delete repeated entries
            if (floor_array[i] == floor_array[i+1]) floor_array.delete(i);
        end
    end
    floor_array = floor_array.unique();
endfunction : InsertFloor
/*-----------------------------------------------------*/

endpackage

`endif
