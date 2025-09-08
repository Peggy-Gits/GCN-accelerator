module FEATURE_COUNTER
#(
  parameter FEATURE_ROWS = 6,
  parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS)
)
(
  input logic clk,
  input logic reset,
  input logic incr,
  output logic [COUNTER_FEATURE_WIDTH-1:0] feature_count
  
);

always@(posedge clk or posedge reset)begin
	if(reset==1'b1)begin
		feature_count<=6'b0;
	end
	else begin
		if(feature_count==6'b000101&&incr==1'b1)begin
			feature_count<=6'b0;
		end
		else begin
			feature_count<=feature_count+incr;
		end
	end
  end


endmodule