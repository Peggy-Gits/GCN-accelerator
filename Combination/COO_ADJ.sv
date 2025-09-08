module COO_ADJ
#(
    parameter FM_WM_COLS=3,
    parameter FM_WM_ROWS=6,
    parameter WEIGHT_WIDTH=16,
    parameter COO_NUM_OF_COLS = 6,			
    parameter COO_NUM_OF_ROWS = 2,			
    parameter COO_BW = $clog2(COO_NUM_OF_COLS)	
)

(
    input logic clk,
    input logic reset,
    input logic done,
    input logic [COO_BW - 1:0]coo_address,
    output logic coo_incr,
    output logic wr_en,
    output logic FM_WM_ROW,
    output logic cnt_reset,
    input logic skip,
    output logic ADJ_fm_wm_done
);
    typedef enum logic [2:0] {
	START,
	READ_FM_WM_DATA_1,
	WRITE_FM_WM_DATA_1,
	READ_FM_WM_DATA_2,
	WRITE_FM_WM_DATA_2,
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
		coo_incr=1'b0;
		wr_en=1'b0;
		FM_WM_ROW=1'b0;
		cnt_reset=1'b1;
		ADJ_fm_wm_done=1'b0;
		if(done==1'b1)begin
			next_state=READ_FM_WM_DATA_1;
		end
	end
	READ_FM_WM_DATA_1: begin
		wr_en=1'b1;
		coo_incr=1'b0;
		FM_WM_ROW=1'b0;
		cnt_reset=1'b0;
		next_state=WRITE_FM_WM_DATA_1;
	end
	WRITE_FM_WM_DATA_1: begin
		wr_en=1'b0;
		if(skip==1'b1)begin
			if(coo_address==6'b000101)begin
				next_state=DONE;
			end
			else begin
				coo_incr=1'b1;
				next_state=READ_FM_WM_DATA_1;
			end
		end
		else begin
			next_state=READ_FM_WM_DATA_2;
		end
	end	
	READ_FM_WM_DATA_2:begin
		wr_en=1'b1;
		FM_WM_ROW=1'b1;
		next_state=WRITE_FM_WM_DATA_2;
	end
	WRITE_FM_WM_DATA_2:begin
		wr_en=1'b0;
		coo_incr=1'b1;
		if(coo_address==6'b000101)begin
			next_state=DONE;
		end
		else begin
			next_state=READ_FM_WM_DATA_1;
		end
	end
	DONE: begin
		wr_en=1'b0;
		coo_incr=1'b0;
		FM_WM_ROW=1'b0;
		ADJ_fm_wm_done=1'b1;
		next_state=DONE;
	end
	default: begin
		next_state=START;
	end
	endcase
  end
endmodule