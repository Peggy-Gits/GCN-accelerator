`timescale 1ps/100fs
module Transformation_block_2
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
    input logic start,
    input logic [COUNTER_FEATURE_WIDTH-1:0] read_fm_wm_row,
    input logic [WEIGHT_WIDTH - 1:0] data_in [WEIGHT_ROWS-1:0],
    
    output logic read_feature_or_weight,
    output logic [ADDRESS_WIDTH - 1:0]fm_wm_address,
    output logic done_Transformation,
    output logic [DOT_PROD_WIDTH - 1:0] fm_wm_row_out [WEIGHT_COLS - 1:0]

);


  logic [COUNTER_WEIGHT_WIDTH-1:0] weight_count;
  logic [COUNTER_FEATURE_WIDTH-1:0] feature_count;
  logic [DOT_PROD_WIDTH-1:0] wm_fm_dot_product;  
  logic [WEIGHT_WIDTH - 1:0] weight_matrix_scratch_pad[0:WEIGHT_ROWS-1];
  logic enable_write_fm_wm_prod;
  logic enable_read;
  logic enable_write;
  logic enable_scratch_pad;
  logic enable_weight_counter;
  logic enable_feature_counter;
  logic enable_feature_count;
  logic enable_weight_count;
  logic reset_w;
  logic INCR_FEATURE;
  logic MULTI_DONE;

  //assign reset_w=reset|done_Transformation;
  

Vector_Multiplier_3 Multi
(
  .FM_row(data_in),
  .WM_col(weight_matrix_scratch_pad),
  .MULTI_EN(cnt_en),
  .TRANS_DONE(done_Transformation),
  .clk(clk),
  .reset(reset),
  .done(MULTI_DONE),
  .INCR_FEATURE(INCR_FEATURE),
  .product(wm_fm_dot_product)
); 

fm_wm_ADDRESS_2 fm_wm_address_2
(
  .clk(clk),
  .reset(reset),
  .enable_weight_count(enable_weight_counter),
  .enable_feature_count(enable_feature_counter), 
  .enable_scratch_pad(enable_scratch_pad),
  .mem_address(fm_wm_address)
);

FEATURE_COUNTER fm_row
(
  .clk(clk),
  .reset(reset),
  .incr(MULTI_DONE),
  .feature_count(feature_count)
);

WEIGHT_COUNTER weight_counter
(
  .clk(clk),
  .reset(reset),
  .incr(enable_weight_count),
  .weight_count(weight_count)
);

Transformation_FSM_2 CTRL
(
  .clk(clk),
  .reset(reset),
  .weight_count(weight_count),
  .feature_count(feature_count),
  .start(start),
  .MULTI_DONE(MULTI_DONE),
  .INCR_FEATURE(INCR_FEATURE),


  .enable_write_fm_wm_prod(enable_write_fm_wm_prod),
  .enable_read(enable_read),
  .enable_write(enable_write),
  .enable_scratch_pad(enable_scratch_pad),
  .enable_weight_counter(enable_weight_counter),
  .enable_feature_counter(enable_feature_counter),
  .cnt_en(cnt_en),
  .read_feature_or_weight(read_feature_or_weight), 
  .done(done_Transformation),
  .enable_weight_count(enable_weight_count),
  .enable_feature_count(enable_feature_count)
);

Matrix_FM_WM_Memory FM_WM_Mem
(
   .clk(clk),
   .rst(reset),
   .write_row(feature_count),
   .write_col(weight_count),
   .read_row(read_fm_wm_row),
   .wr_en(enable_write_fm_wm_prod),
   .fm_wm_in(wm_fm_dot_product),
   .fm_wm_row_out(fm_wm_row_out)
);

Scratch_Pad Mem
(
   .clk(clk),
   .reset(reset),
   .write_enable(enable_scratch_pad),
   .weight_col_in(data_in),
   .weight_col_out(weight_matrix_scratch_pad)
);

endmodule 
