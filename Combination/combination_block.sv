`timescale 1ps/100fs
module Combination_block
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

(
  input logic clk,
  input logic reset,
  input logic done,
  input logic [COO_BW - 1:0] coo_in [1:0], 
  input logic [COUNTER_FEATURE_WIDTH-1:0] read_MAX_adj_row,
  input logic [DOT_PROD_WIDTH - 1:0] fm_wm_row_mem_out  [0:WEIGHT_COLS-1],

  output logic ADJ_fm_wm_done,
  output logic [COO_BW - 1:0]coo_address,
  output logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_row_mem_out  [0:WEIGHT_COLS-1],
  output logic [COUNTER_FEATURE_WIDTH - 1:0] read_fm_wm_row
);

  
  logic coo_incr; 
  logic FM_WM_ROW;
  logic skip;
  logic adj_wr_en;
  logic [COUNTER_FEATURE_WIDTH-1:0] read_adj_row;
  logic [COUNTER_FEATURE_WIDTH-1:0] write_adj_row; 
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_row_in  [0:WEIGHT_COLS-1];
   

  always_comb begin 
	if(ADJ_fm_wm_done==1'b1)begin
		read_adj_row=read_MAX_adj_row;
	end
	else begin 
		read_adj_row=write_adj_row;
	end
  end

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
   .fm_wm_adj_row_out(fm_wm_adj_row_in),
   .read_fm_wm_address(read_fm_wm_row),
   .coo_address(coo_address),
   .write_address(write_adj_row)
);

Matrix_FM_WM_ADJ_Memory FM_WM_ADJ
(
    .clk(clk),
    .rst(reset),
    .write_row(write_adj_row),
    .read_row(read_adj_row),
    .wr_en(adj_wr_en),
    .fm_wm_adj_row_in(fm_wm_adj_row_in),
    .fm_wm_adj_out(fm_wm_adj_row_mem_out)
);

endmodule 
