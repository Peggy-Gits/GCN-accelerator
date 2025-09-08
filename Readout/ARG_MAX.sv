module ARG_MAX
#(
    
    parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter FEATURE_WIDTH = 5,
    parameter WEIGHT_WIDTH = 5,
    parameter DOT_PROD_WIDTH = 16,
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
    parameter NUM_OF_NODES = 6,	
    parameter MAX_ADDRESS_WIDTH = 2,
    parameter HALF_CLOCK_CYCLE = 5
)

(
    input logic clk, 
    input logic reset,
    input logic start,
    input logic [COUNTER_FEATURE_WIDTH-1:0] cnt,
    
    output logic read,
    output logic write,
    output logic done
);

  typedef enum logic [1:0] {
	START,
	READ,
	WRITE,
	DONE
  } state_t;
  
  state_t current_state, next_state;

  always@(posedge clk or posedge reset)begin
	if(reset==1'b1)begin
		current_state<=START;
	end
	else begin
		current_state<=next_state;
	end
  end

  always_comb begin
	case(current_state)

	START: begin
		read=1'b0;
		write=1'b0;
		done=1'b0;
		if(start==1'b1)begin
			next_state=READ;
		end
		else begin
			next_state=START;
		end
	end
	
	READ: begin
		read=1'b1;
		write=1'b0;
		done=1'b0;
		next_state=WRITE;
	end 

	WRITE: begin
		read=1'b0;
		write=1'b1;
		done=1'b0;
		if(cnt==3'b101)begin
			next_state=DONE;
		end
		else begin
			next_state=READ;
		end
	end

	DONE: begin
		read=1'b0;
		write=1'b0;
		done=1'b1;
		next_state=DONE;
	end
	
	endcase
  end

endmodule
