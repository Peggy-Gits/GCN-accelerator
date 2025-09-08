module WEIGHT_COUNTER
#(
  parameter WEIGHT_COLS = 3,
  parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS)
)
(
  input logic clk,
  input logic reset,
  input logic incr,
  output logic [COUNTER_WEIGHT_WIDTH-1:0] weight_count
  
);

//logic [COUNTER_WEIGHT_WIDTH-1:0] weight_count_reg;

always@(posedge clk or posedge reset)begin
	if(reset==1'b1)begin
		weight_count<=3'b0;
	end
	else begin
		if(incr==1'b1)begin
			weight_count<=weight_count+incr;
		end
	end
  end


endmodule
