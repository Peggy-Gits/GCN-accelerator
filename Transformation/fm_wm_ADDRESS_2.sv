module fm_wm_ADDRESS_2
#(
  parameter ADDRESS_WIDTH = 13,
  parameter FEATURE_ROWS = 6,
  parameter WEIGHT_COLS = 3,  
  parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
  parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS)
)
(
  input logic clk,
  input logic reset,
  input logic enable_weight_count,
  input logic enable_feature_count, 
  input logic enable_scratch_pad,
  output logic [ADDRESS_WIDTH - 1:0] mem_address
);
  logic [2:0]feature_count;
  logic [COUNTER_WEIGHT_WIDTH - 1:0]weight_count;
  always@(posedge clk or posedge reset) begin
	if(reset==1'b1)begin
		mem_address<=13'h0;
		feature_count<='0;
		weight_count<='0;
	end
	else begin
		if(feature_count==3'b101&&enable_feature_count==1'b1)begin
			feature_count<='0;
			mem_address<=13'h200;
		end
		else if(enable_feature_count==1'b1| enable_scratch_pad==1'b1) begin
			feature_count<=feature_count+enable_feature_count;
			mem_address<=feature_count+13'h200+enable_feature_count;
		end
		else if(enable_weight_count==1'b1)begin
			if(weight_count==3'b010)begin
				weight_count<='0;
				mem_address<='0;
			end
			else begin
				weight_count<=weight_count+1;
				mem_address<=weight_count+13'h0+1;
			end
		end
	end		
  end
  

  
endmodule
