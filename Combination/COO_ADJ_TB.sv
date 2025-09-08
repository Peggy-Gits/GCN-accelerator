`timescale 1ps/100fs
module COO_ADJ_TB
  #(parameter FEATURE_COLS = 96,
    parameter WEIGHT_ROWS = 96,
    parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter FEATURE_WIDTH = 5,
    parameter WEIGHT_WIDTH = 5,
    parameter DOT_PROD_WIDTH = 16,
    parameter ADDRESS_WIDTH = 13,
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
    parameter NUM_OF_NODES = 6,			 
    parameter COO_NUM_OF_COLS = 6,			
    parameter COO_NUM_OF_ROWS = 2,			
    parameter COO_BW = $clog2(COO_NUM_OF_COLS),
    parameter MAX_ADDRESS_WIDTH = 2,
    parameter HALF_CLOCK_CYCLE = 5
)
();

  logic clk;
  logic reset;
  logic done;
  logic ADJ_fm_wm_done;
  logic [COUNTER_FEATURE_WIDTH-1:0] cnt;
  logic [COO_BW - 1:0]coo_address;
  logic coo_incr;
  logic [COO_BW - 1:0] coo_in [1:0]; 
  logic adj_wr_en;
  logic fm_wm_wr_en;
  logic [FEATURE_WIDTH-1:0] write_fm_wm_row;
  logic [FEATURE_WIDTH-1:0] write_adj_row;
  logic [WEIGHT_WIDTH-1:0] write_fm_wm_col;
  logic [FEATURE_WIDTH-1:0] read_adj_row;
  logic [FEATURE_WIDTH - 1:0] read_fm_wm_row;
  logic FM_WM_ROW;
  logic [DOT_PROD_WIDTH-1:0]fm_wm_mem_in;
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_row_mem_in [0:WEIGHT_COLS-1];  
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_row_mem_out  [0:WEIGHT_COLS-1];
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_row_mem_out  [0:WEIGHT_COLS-1];
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_1;
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_2;
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_3;

	// Clock Generator
        initial begin
            clk <= '0;
            forever #(HALF_CLOCK_CYCLE) clk <= ~clk;
        end
	/*always@(posedge clk)begin
		$display("fm_wm_out: %d, %d, %d:",fm_wm_row_out[0], fm_wm_row_out[1], fm_wm_row_out[2]);
	end*/
	
	initial begin
		reset = 1'b1;
		#10
		// Reset the DUT
		/*repeat(3) begin
			#10;
		end*/
		//wait (done === 1'b1);
		/*done = 1'b1;
		#5*/
		reset = 1'b0;
		fm_wm_wr_en = 1'b1;
		for(int i=0;i<FEATURE_ROWS;i++)begin
			for(int j=0;j<WEIGHT_COLS;j++)begin
				fm_wm_mem_in=i;
				write_fm_wm_row=i;
				write_fm_wm_col=j;
				#10	;			
			end
		end
				
		/*for(int i=0;i<FEATURE_ROWS;i++)begin
			read_fm_wm_row=i;
			#10;
		end*/
		done=1'b1;
		#300
		
		/*write_row=0;
		read_row=0;
		#10
		done=1'b1;#8
		#10//cnt=3'b010;#10
		reset=1'b0;#2
		done=1'b0;#100
		//cnt=3'b110;#10*/
		
		
		$finish;
 	end

	assign fm_wm_1=fm_wm_adj_row_mem_out[0];
	assign fm_wm_2=fm_wm_adj_row_mem_out[1];
	assign fm_wm_3=fm_wm_adj_row_mem_out[2];

COO_ADJ COO_ADJ_2
(
  .clk(clk),
  .reset(reset),
  .done(done),
  .coo_address(coo_address),
  .coo_incr(coo_incr), 
  .wr_en(adj_wr_en),
  .FM_WM_ROW(FM_WM_ROW),
  .cnt_reset(cnt_reset),
  .skip(skip),
  .ADJ_fm_wm_done(ADJ_fm_wm_done)
); 

ADJ_FM_WM AD_FM_WM_COMB
(
   .FM_WM_ROW(FM_WM_ROW),
   .clk(clk),
   .reset(cnt_reset),
   .coo_incr(coo_incr),
   .coo_in(coo_in), 
   .fm_wm_row_in(fm_wm_row_mem_out), 
   .fm_wm_adj_row_in(fm_wm_adj_row_mem_out), 
   .skip(skip),
   .fm_wm_adj_row_out(fm_wm_adj_row_mem_in),
   .read_fm_wm_address(read_fm_wm_row),
   .coo_address(coo_address),
   .write_address(write_adj_row)
);

Matrix_FM_WM_Memory FM_WM_Mem
(
   .clk(clk),
   .rst(reset),
   .write_row(write_fm_wm_row),
   .write_col(write_fm_wm_col),
   .read_row(read_fm_wm_row),
   .wr_en(fm_wm_wr_en),
   .fm_wm_in(fm_wm_mem_in),
   .fm_wm_row_out(fm_wm_row_mem_out)
);

COO_MEM COO_Matrix
(
   .clk(clk),
   .reset(reset),
   .coo_address(coo_address),
   .coo_in(coo_in)
);


Matrix_FM_WM_ADJ_Memory FM_WM_ADJ
(
    .clk(clk),
    .rst(reset),
    .write_row(write_adj_row),
    .read_row(write_adj_row),
    .wr_en(adj_wr_en),
    .fm_wm_adj_row_in(fm_wm_adj_row_mem_in),
    .fm_wm_adj_out(fm_wm_adj_row_mem_out)
);

	// This function loops through the address matrix, from the dut and the gold values, to make sure that the correct values have been computed
	/*function void check_for_correct_address(input logic [MAX_ADDRESS_WIDTH - 1:0] dut_output_addr [0:FEATURE_ROWS - 1],
						input logic [MAX_ADDRESS_WIDTH - 1:0] gold_output_addr [0:FEATURE_ROWS - 1]);

		foreach (dut_output_addr[address]) begin

			$display("max_addi_answer[%0d]     DUT: %d       GOLD: %d ", address, dut_output_addr[address], gold_output_addr[address]);
			assert(dut_output_addr[address] === gold_output_addr[address]) else $error("!!!ERROR: The above address outputs are Conflicting");


		end
		$display("\n");

	endfunction*/

endmodule 
