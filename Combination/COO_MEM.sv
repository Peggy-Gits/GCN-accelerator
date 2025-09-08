module COO_MEM
#(
   parameter COO_NUM_OF_COLS = 6,			
   parameter COO_NUM_OF_ROWS = 2,			
   parameter COO_BW = $clog2(COO_NUM_OF_COLS)
)

(
   input clk,
   input reset,
   input logic [COO_BW - 1:0]coo_address,
   output logic [COO_BW - 1:0]coo_in [0 : COO_NUM_OF_ROWS-1]
);

   logic [COO_BW - 1:0] mem [0:COO_NUM_OF_COLS - 1][0:COO_NUM_OF_ROWS - 1];
   always@(posedge clk)begin
	if(reset==1'b1)begin
		for(int i=0;i<COO_NUM_OF_COLS;i++)begin
			mem[i][0]=i;
			mem[i][1]=i;
		end
		//mem[5][0]=0;
		//mem[5][1]=0;
	end
   end
   assign coo_in=mem[coo_address];
endmodule
