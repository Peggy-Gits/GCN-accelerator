module Vector_Multiplier_3
#(  parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter FEATURE_WIDTH=5,
    parameter WEIGHT_WIDTH=5,
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
    parameter VECTOR_LENGTH=96,
    parameter CSA_LENGTH=8,
    parameter ADD_DIVISOR=3,
    parameter DOT_PROD_WIDTH=16)

(
	
	input logic [FEATURE_WIDTH-1:0]FM_row[0:VECTOR_LENGTH-1],
	input logic [WEIGHT_WIDTH-1:0]WM_col[0:VECTOR_LENGTH-1],
	input logic MULTI_EN,
	input logic TRANS_DONE,
	input logic clk,
	input logic reset,

	output logic done,
	output logic INCR_FEATURE,
	output logic [DOT_PROD_WIDTH-1:0]product			
);
	//logic [DOT_PROD_WIDTH-1:0]data_in_reg[0:VECTOR_LENGTH-1];
	
	logic [DOT_PROD_WIDTH-1:0]partial_product[0:VECTOR_LENGTH/ADD_DIVISOR-1];	
	logic [DOT_PROD_WIDTH-1:0]partial_product_reg[0:VECTOR_LENGTH/ADD_DIVISOR-1];
	//logic [DOT_PROD_WIDTH-1:0]partial_sum_1[0:VECTOR_LENGTH/ADD_DIVISOR-1];
	//logic [DOT_PROD_WIDTH-1:0]partial_carry_1[0:VECTOR_LENGTH/ADD_DIVISOR-1];		
	//logic [DOT_PROD_WIDTH-1:0]WM_col_copy[0:VECTOR_LENGTH/ADD_DIVISOR-1];
	//logic [DOT_PROD_WIDTH-1:0]FM_row_copy[0:VECTOR_LENGTH/ADD_DIVISOR-1];
	logic [FEATURE_WIDTH-1:0]FM_row_reg[0:VECTOR_LENGTH-1];
	//logic [DOT_PROD_WIDTH-1:0]shifted[0:2][0:VECTOR_LENGTH/ADD_DIVISOR-1];

	logic [DOT_PROD_WIDTH-1:0]dot_product;
	logic [DOT_PROD_WIDTH-1:0]CSA_S1;
	logic [DOT_PROD_WIDTH-1:0]CSA_C1;
	logic [DOT_PROD_WIDTH-1:0]CSA_S2;
	logic [DOT_PROD_WIDTH-1:0]CSA_C2;
	logic [DOT_PROD_WIDTH-1:0]CSA_S3;
	logic [DOT_PROD_WIDTH-1:0]CSA_C3;
	logic [DOT_PROD_WIDTH-1:0]CSA_S4;
	logic [DOT_PROD_WIDTH-1:0]CSA_C4;
	logic [DOT_PROD_WIDTH-1:0]CSA_S5;
	logic [DOT_PROD_WIDTH-1:0]CSA_C5;
	logic [DOT_PROD_WIDTH-1:0]CSA_S5_reg;
	logic [DOT_PROD_WIDTH-1:0]CSA_C5_reg;
	logic [DOT_PROD_WIDTH-1:0]CSA_S6;
	logic [DOT_PROD_WIDTH-1:0]CSA_C6;
	
	logic start;
	logic stage_0;
	logic stage_1;
	logic stage_2;
	logic [1:0]stage_3;
		
	logic [1:0]cnt;

	always@(posedge clk or posedge reset)begin
		if(reset==1'b1|TRANS_DONE==1'b1)begin
			for(int l=0;l<VECTOR_LENGTH;l++)begin
				FM_row_reg[l]='0;
			end
			for(int l=0;l<(VECTOR_LENGTH/ADD_DIVISOR);l++)begin
				partial_product_reg[l]='0;
			end
			dot_product<='0;
			cnt<='0;
			CSA_C5_reg<='0;
			CSA_S5_reg<='0;
			start<='0;
			stage_0<='0;
			stage_1<='0;
			stage_2<='0;
			stage_3<='0;
		end
		
		else if (MULTI_EN==1'b0)begin
			for(int i=0;i<VECTOR_LENGTH;i++)begin
				FM_row_reg[i]='0;
			end
			stage_0<=1'b0;	
			stage_3<=stage_3+stage_2;
			dot_product<=product;
		end
		
		else begin
			for(int l=0;l<VECTOR_LENGTH/ADD_DIVISOR;l++)begin
				partial_product_reg[l]=partial_product[l];
			end	
			for(int l=0;l<VECTOR_LENGTH;l++)begin
				FM_row_reg[l]=FM_row[l];
			end		
			if(cnt==2'b10)begin
				cnt<='0;
			end
			else begin
				cnt<=cnt+start;
			end
			CSA_C5_reg<=CSA_C5;
			CSA_S5_reg<=CSA_S5;
			
			start<='1;
			stage_0<='1;
			stage_1<=stage_0;
			stage_2<=stage_1;
			if(stage_3==2'b10)begin
				stage_3<='0;
				dot_product<='0;
			end
			else begin
				stage_3<=stage_3+stage_2;
				dot_product<=product;
			end
			/*if(stage_3==2'b01)begin
				done<=1'b1;
			end
			else begin
				done<=1'b0;
			end
			if(cnt==2'b01)begin
				INCR_FEATURE<=1'b1;
			end
			else begin
				INCR_FEATURE<=1'b0;
			end*/
		end
	end

	always_comb begin
		//if(FM_VALID)begin
		for(int i=0;i<VECTOR_LENGTH/ADD_DIVISOR;i++)begin
			/*WM_col_copy[i]=WM_col[i+cnt*VECTOR_LENGTH/ADD_DIVISOR]<<<1;
			FM_row_copy[i]=FM_row_reg[i+cnt*VECTOR_LENGTH/ADD_DIVISOR];*/
			partial_product[i]=FM_row_reg[i+cnt*VECTOR_LENGTH/ADD_DIVISOR]*WM_col[i+cnt*VECTOR_LENGTH/ADD_DIVISOR];
			/*for(int j=0;j<3;j++)begin
				case({WM_col_copy[i][2*j+2],WM_col_copy[i][2*j+1],WM_col_copy[i][2*j]})
					3'b000: begin
						shifted[j][i]='0;
					end
					3'b001:begin
						shifted[j][i]=FM_row_copy[i]<<(j*2);
					end
					3'b010:begin
						shifted[j][i]=FM_row_copy[i]<<(j*2);
					end
					3'b011:begin
						shifted[j][i]=FM_row_copy[i]<<(j*2+1);
					end
					3'b100:begin
						shifted[j][i]=(-FM_row_copy[i]<<(j*2+1));
					end
					3'b101:begin
						shifted[j][i]=(-FM_row_copy[i]<<(j*2));
					end
					3'b110:begin
						shifted[j][i]=(-FM_row_copy[i]<<(j*2));
					end
					3'b111:begin
						shifted[j][i]='0;
					end
				endcase
				
			end*/
			//partial_product[i]=FM_row[i]*WM_col[i];
		end
		/*for(int i=0;i<VECTOR_LENGTH/ADD_DIVISOR;i++)begin
			partial_sum_1[i]=(shifted[0][i]^shifted[1][i])^shifted[2][i];
			partial_carry_1[i]=(shifted[0][i]&shifted[1][i])|((shifted[0][i]|shifted[1][i])&shifted[2][i]);
			partial_product[i]=partial_sum_1[i]+(partial_carry_1[i]<<1);
		end	*/		
	end

	assign CSA_S6=(CSA_S5_reg^CSA_C5_reg)^dot_product;
	assign CSA_C6=(CSA_S5_reg&CSA_C5_reg)|(dot_product&(CSA_S5_reg|CSA_C5_reg));
	assign product=CSA_S6+(CSA_C6<<1);
	assign INCR_FEATURE=(cnt==2'b10)&(MULTI_EN==1'b1);	
	assign done=(stage_3==2'b10);

	CSA CSA_M1(
	   .data_in_0(partial_product_reg[0]),
	   .data_in_1(partial_product_reg[1]),
	   .data_in_2(partial_product_reg[2]),
	   .data_in_3(partial_product_reg[3]),
	   .data_in_4(partial_product_reg[4]),
	   .data_in_5(partial_product_reg[5]),
	   .data_in_6(partial_product_reg[6]),
	   .data_in_7(partial_product_reg[7]),
	   .CSA_S(CSA_S1),
	   .CSA_C(CSA_C1)
	);
	CSA CSA_M2(
	   .data_in_0(partial_product_reg[8]),
	   .data_in_1(partial_product_reg[9]),
	   .data_in_2(partial_product_reg[10]),
	   .data_in_3(partial_product_reg[11]),
	   .data_in_4(partial_product_reg[12]),
	   .data_in_5(partial_product_reg[13]),
	   .data_in_6(partial_product_reg[14]),
	   .data_in_7(partial_product_reg[15]),
	   .CSA_S(CSA_S2),
	   .CSA_C(CSA_C2)
	);
	CSA CSA_M3(
	   .data_in_0(partial_product_reg[16]),
	   .data_in_1(partial_product_reg[17]),
	   .data_in_2(partial_product_reg[18]),
	   .data_in_3(partial_product_reg[19]),
	   .data_in_4(partial_product_reg[20]),
	   .data_in_5(partial_product_reg[21]),
	   .data_in_6(partial_product_reg[22]),
	   .data_in_7(partial_product_reg[23]),
	   .CSA_S(CSA_S3),
	   .CSA_C(CSA_C3)
	);
	CSA CSA_M4(
	   .data_in_0(partial_product_reg[24]),
	   .data_in_1(partial_product_reg[25]),
	   .data_in_2(partial_product_reg[26]),
	   .data_in_3(partial_product_reg[27]),
	   .data_in_4(partial_product_reg[28]),
	   .data_in_5(partial_product_reg[29]),
	   .data_in_6(partial_product_reg[30]),
	   .data_in_7(partial_product_reg[31]),
	   .CSA_S(CSA_S4),
	   .CSA_C(CSA_C4)
	);
	CSA CSA_M5(
	   .data_in_0(CSA_S1),
	   .data_in_1(CSA_C1),
	   .data_in_2(CSA_S2),
	   .data_in_3(CSA_C2),
	   .data_in_4(CSA_S3),
	   .data_in_5(CSA_C3),
	   .data_in_6(CSA_S4),
	   .data_in_7(CSA_C4),
	   .CSA_S(CSA_S5),
	   .CSA_C(CSA_C5)
	);

endmodule

module CSA
#(
   parameter FEATURE_ROWS = 6,
   parameter WEIGHT_COLS = 3,
   parameter FEATURE_WIDTH=5,
   parameter WEIGHT_WIDTH=5,
   parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
   parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
   parameter VECTOR_LENGTH=96,
   parameter CSA_LENGTH=8,
   parameter ADD_DIVISOR=3,
   parameter DOT_PROD_WIDTH=16

)
(
	input logic [DOT_PROD_WIDTH-1:0]data_in_0,
	input logic [DOT_PROD_WIDTH-1:0]data_in_1,
	input logic [DOT_PROD_WIDTH-1:0]data_in_2,
	input logic [DOT_PROD_WIDTH-1:0]data_in_3,
	input logic [DOT_PROD_WIDTH-1:0]data_in_4,
	input logic [DOT_PROD_WIDTH-1:0]data_in_5,
	input logic [DOT_PROD_WIDTH-1:0]data_in_6,
	input logic [DOT_PROD_WIDTH-1:0]data_in_7,
	output logic [DOT_PROD_WIDTH-1:0]CSA_S,
	output logic [DOT_PROD_WIDTH-1:0]CSA_C
	
);
	
	logic [DOT_PROD_WIDTH-1:0]CSA1_S1;
	logic [DOT_PROD_WIDTH-1:0]CSA1_C1;
	logic [DOT_PROD_WIDTH-1:0]CSA1_S2;
	logic [DOT_PROD_WIDTH-1:0]CSA1_C2;
	logic [DOT_PROD_WIDTH-1:0]CSA2_S1;
	logic [DOT_PROD_WIDTH-1:0]CSA2_C1;
	logic [DOT_PROD_WIDTH-1:0]CSA2_S2;
	logic [DOT_PROD_WIDTH-1:0]CSA2_C2;
	logic [DOT_PROD_WIDTH-1:0]CSA3_S1;
	logic [DOT_PROD_WIDTH-1:0]CSA3_C1;
	
	
	always_comb begin
	CSA1_S1=(data_in_0^data_in_1)^data_in_2;
	CSA1_C1=(data_in_0&data_in_1)|(data_in_2&(data_in_0|data_in_1));	
		
	CSA1_S2=(data_in_4^data_in_5)^data_in_6;
	CSA1_C2=(data_in_4&data_in_5)|(data_in_6&(data_in_4|data_in_5));	

	CSA2_S1=(CSA1_S1^(CSA1_C1<<1))^data_in_3;
	CSA2_C1=(CSA1_S1&(CSA1_C1<<1))|(data_in_3&(CSA1_S1|(CSA1_C1<<1)));	
		
	CSA2_S2=(CSA1_S2^(CSA1_C2<<1))^data_in_7;
	CSA2_C2=(CSA1_S2&(CSA1_C2<<1))|(data_in_7&(CSA1_S2|(CSA1_C2<<1)));

	CSA3_S1=(CSA2_C2<<1)^(CSA2_C1<<1)^CSA2_S2;
	CSA3_C1=((CSA2_C2<<1)&CSA2_C1<<1)|(CSA2_S2&((CSA2_C2<<1)|(CSA2_C1<<1)));

	CSA_S=(CSA3_C1<<1)^(CSA3_S1)^CSA2_S1;
	CSA_C=(((CSA3_C1<<1)&CSA3_S1)|(CSA2_S1&((CSA3_C1<<1)|CSA3_S1)))<<1;
	
	end	
endmodule