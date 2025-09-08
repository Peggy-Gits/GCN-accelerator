module counter
#(
  parameter FEATURE_ROWS=6,
  parameter FEATURE_WIDTH=$clog2(FEATURE_ROWS)
)
(
  input logic incr,
  input logic clk,
  input logic reset,
  output logic [FEATURE_WIDTH-1:0] cnt
);
 
  //logic [FEATURE_WIDTH-1:0] cnt_reg;  

  always@(posedge clk or posedge reset)begin
	if(reset==1'b1)begin
		cnt<=3'b0;
	end
	else begin
		if(incr==1'b1)begin
			cnt<=cnt+incr;
		end
	end
  end
endmodule
