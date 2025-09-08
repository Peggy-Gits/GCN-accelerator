module ARG_MAX_COMB
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
  input logic read,
  input logic write,
  input logic [DOT_PROD_WIDTH-1:0]fm_wm_adj_row_in[0:WEIGHT_COLS-1],

  output logic [COUNTER_FEATURE_WIDTH-1:0] read_fm_wm_adj_row,
  output logic [MAX_ADDRESS_WIDTH - 1:0] max_addi_ans [0:FEATURE_ROWS-1]
);

  logic [MAX_ADDRESS_WIDTH - 1:0] max_addi_reg [0:FEATURE_ROWS-1];
  logic [MAX_ADDRESS_WIDTH - 1:0] max_1;
  logic [MAX_ADDRESS_WIDTH - 1:0] max_2;

  always@(posedge clk)begin
	if(reset==1'b1)begin
		for(int i=0;i<FEATURE_ROWS;i++)begin
			max_addi_reg[i]=2'b0;
		end
	end
	else begin 
		if(read==1'b1)begin
			$display("ARG_MAX %d: %d,%d,%d ",read_fm_wm_adj_row, fm_wm_adj_row_in[0],fm_wm_adj_row_in[1],fm_wm_adj_row_in[2]);
			max_addi_reg[read_fm_wm_adj_row]=max_2;
		end		
		//max_addi_reg[read_fm_wm_adj_row]=max_2;
	end
  end  

  always_comb begin
	max_1<=(fm_wm_adj_row_in[0]>fm_wm_adj_row_in[1])?0:2'b01;
	max_2<=(fm_wm_adj_row_in[max_1]>fm_wm_adj_row_in[2])?max_1:2'b10; 
	
  end
  assign max_addi_ans[0:FEATURE_ROWS-1]=max_addi_reg[0:FEATURE_ROWS-1];

FEATURE_COUNTER CNT
(
  .clk(clk),
  .reset(reset),
  .incr(write),
  .feature_count(read_fm_wm_adj_row)
);

endmodule


