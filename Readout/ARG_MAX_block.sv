`timescale 1ps/100fs
module ARG_MAX_block
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
  input logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_row_mem_out  [0:WEIGHT_COLS-1],

  output logic done_max,
  output logic [COUNTER_FEATURE_WIDTH-1:0] read_MAX_adj_row,
  output logic[MAX_ADDRESS_WIDTH - 1:0] max_addi_ans [0:FEATURE_ROWS-1]
  

);


  logic read_max;
  logic write_max;
 
ARG_MAX_COMB MAX_COMB
(
  .clk(clk),
  .reset(reset),
  .read(read_max),
  .write(write_max),
  .fm_wm_adj_row_in(fm_wm_adj_row_mem_out),  
  .read_fm_wm_adj_row(read_MAX_adj_row),
  .max_addi_ans(max_addi_ans)
);

ARG_MAX MAX_FSM
(
    .clk(clk), 
    .reset(reset),
    .start(done),
    .cnt(read_MAX_adj_row),
    
    .read(read_max),
    .write(write_max),
    .done(done_max)
);

endmodule 
