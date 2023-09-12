

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif
`include "define_state.h"

module Milestone1(
	input logic clock,
	input logic resetn,
	
	input logic M1_start,
	input logic [15:0] SRAM_read_data,
	
	output logic [17:0] SRAM_address,
	output logic [15:0] SRAM_write_data,
	output logic SRAM_we_n,
	output logic M1_finish
	
);


M1_state_type M1_state;

logic signed [31:0] U_Reg, U_buf,V_Reg, V_buf, Y_Reg, Y_buf;
logic signed [31:0] U_ACC, V_ACC;
logic unsigned [7:0] U_shift_reg[5:0];
logic unsigned [7:0] V_shift_reg[5:0];

logic signed [31:0] R_Reg, G_Reg, B_Reg, B_buf;
logic unsigned [7:0] R_O, G_O, B_O;
logic signed [31:0] R_Reg_Shifted, G_Reg_Shifted, B_Reg_Shifted, B_buf_Shifted;

logic signed [63:0] Mult_1_result_long, Mult_2_result_long;
logic signed [31:0] Mult_1_result, Mult_2_result;
logic signed [31:0] Mult_op_1, Mult_op_2, Mult_op_3, Mult_op_4;

logic [17:0] SRAM_address_Y;
logic [17:0] SRAM_address_U;
logic [17:0] SRAM_address_V;
logic [17:0] SRAM_address_RGB;

logic [7:0] col_count;
logic [7:0] row_count;

assign Mult_1_result_long = Mult_op_1 * Mult_op_2;
assign Mult_2_result_long = Mult_op_3 * Mult_op_4;

assign Mult_1_result = Mult_1_result_long [31:0];
assign Mult_2_result = Mult_2_result_long [31:0];


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
always_ff@(posedge clock or negedge resetn) begin
	if (~resetn) begin
		SRAM_address <= 18'd0;
		SRAM_we_n <= 1'b1;
		M1_state <= M1_IDLE;
		
		SRAM_address_Y <= 18'h0;
		SRAM_address_U <= 18'h9600;
		SRAM_address_V <= 18'hE100;
		SRAM_address_RGB <= 18'h23E00;
		
		Y_Reg <= 32'd0;
		U_Reg <= 32'd0;
		V_Reg <= 32'd0;
		Y_buf <= 32'd0;
		U_buf <= 32'd0;
		V_buf <= 32'd0;
		
		R_Reg <= 32'd0;
		G_Reg <= 32'd0;
		B_Reg <= 32'd0;
		B_buf <= 32'd0;
		
		U_ACC <= 32'd0;
		V_ACC <= 32'd0;
		
		U_shift_reg[0] <= 8'd0;
		U_shift_reg[1] <= 8'd0;
		U_shift_reg[2] <= 8'd0;
		U_shift_reg[3] <= 8'd0;
		U_shift_reg[4] <= 8'd0;
		U_shift_reg[5] <= 8'd0;
		
		V_shift_reg[0] <= 8'd0;
		V_shift_reg[1] <= 8'd0;
		V_shift_reg[2] <= 8'd0;
		V_shift_reg[3] <= 8'd0;
		V_shift_reg[4] <= 8'd0;
		V_shift_reg[5] <= 8'd0;
		
		M1_finish <= 1'b0;
		col_count <= 8'd0;
		row_count <= 8'd0;
		
	end else begin
		case (M1_state) 
			M1_IDLE: begin
				if(M1_start) begin
					M1_state <= L_IN_0;
					//col_count <= col_count + 8'd1;
				end
				else
					M1_state <= M1_IDLE;
			end
			L_IN_0: begin	//State 0
				if(row_count == 8'd0) begin
					SRAM_address <= SRAM_address_Y; //Y0Y1
					SRAM_address_Y <= SRAM_address_Y + 18'd1;
				end
				else begin
					if(row_count == 8'd240) begin
						M1_state <= M1_IDLE;
						M1_finish <= 1'b1;
						col_count <= 8'd0;
						row_count <= 8'd0;
					end
				
				end
				
				M1_state <= L_IN_1;
			end
			L_IN_1: begin	//State 1
				SRAM_address <= SRAM_address_U; //Pass address U0U1
				SRAM_address_U <= SRAM_address_U + 18'd1;
				
				U_ACC <= 32'd128;
				V_ACC <= 32'd128;
				
				M1_state <= L_IN_2;
			end
			L_IN_2: begin //State 2
				
				SRAM_address <= SRAM_address_V;//for V0V1
				SRAM_address_V <= SRAM_address_V + 18'd1;
				
				M1_state <= L_IN_3;
			end
			L_IN_3: begin	//State 3
				SRAM_address <= SRAM_address_V;//For V2V3
				SRAM_address_V <= SRAM_address_V + 18'd1;
				
				Y_buf <= {24'd0, SRAM_read_data[7:0]};		//Store Y0Y1 //XX sign extention?
				Y_Reg <= {24'd0, SRAM_read_data[15:8]};	//XX sign extention?
				
				M1_state <= L_IN_4;
			end
			L_IN_4: begin	//State 4
				SRAM_address <= SRAM_address_U;//For U2U3
				SRAM_address_U <= SRAM_address_U + 18'd1;
				
				U_Reg <= {24'd0, SRAM_read_data[15:8]};
				U_shift_reg[0] <= SRAM_read_data[15:8];//Updating shift reg
				U_shift_reg[1] <= SRAM_read_data[15:8];
				U_shift_reg[2] <= SRAM_read_data[15:8];
				U_shift_reg[3] <= SRAM_read_data[7:0];
				
				R_Reg <= Mult_1_result;	//a00Y0
				G_Reg <= Mult_1_result;
				B_Reg <= Mult_1_result;
				
				M1_state <= L_IN_5;
			end
			L_IN_5: begin //State 5
				
				V_Reg <= {24'd0, SRAM_read_data[15:8]};
				V_shift_reg[0] <= SRAM_read_data[15:8];//Updating shift reg
				V_shift_reg[1] <= SRAM_read_data[15:8];
				V_shift_reg[2] <= SRAM_read_data[15:8];
				V_shift_reg[3] <= SRAM_read_data[7:0];
				
				G_Reg <= G_Reg + Mult_1_result;	//a11U'0
				B_Reg <= B_Reg + Mult_2_result;	//a21U'0
				
				M1_state <= L_IN_6;
			end

			L_IN_6: begin	//State 6
				SRAM_address <= SRAM_address_RGB;//For R0G0
				SRAM_address_RGB <= SRAM_address_RGB + 18'd1;
				SRAM_we_n <= 1'b0;
					
				B_buf <= B_Reg;
				R_Reg <= R_Reg + Mult_1_result;	//a02V0'
				G_Reg <= G_Reg + Mult_2_result;	//a21V0'
				
				V_shift_reg[4] <= SRAM_read_data[15:8];
				V_shift_reg[5] <= SRAM_read_data[7:0];
				
				M1_state <= L_IN_7;
			end
			L_IN_7: begin		//State 7
				SRAM_address <= SRAM_address_U;//for U4U5
				SRAM_address_U <= SRAM_address_U + 18'd1;
				SRAM_we_n <= 1'b1;
				
				U_ACC <= U_ACC + Mult_1_result;
				U_shift_reg[4] <= SRAM_read_data[15:8];
				U_shift_reg[5] <= SRAM_read_data[7:0];
				
				V_ACC <= V_ACC + Mult_2_result;	
				
				M1_state <= L_IN_8;
			end
			L_IN_8: begin
				SRAM_address <= SRAM_address_V;	//V4V5
				SRAM_address_V <= SRAM_address_V + 18'd1;
				
				V_ACC <= V_ACC + Mult_1_result + Mult_2_result;
				
				M1_state <= L_IN_9;
			end
			L_IN_9: begin
				
				U_ACC <= U_ACC + Mult_1_result + Mult_2_result;
				V_ACC <= {{8{V_ACC[31]}}, V_ACC[31:8]};
				Y_Reg <= Y_buf;
				
				V_shift_reg[5] <= 8'd0;
				V_shift_reg[4] <= V_shift_reg[5];
				V_shift_reg[3] <= V_shift_reg[4];
				V_shift_reg[2] <= V_shift_reg[3];
				V_shift_reg[1] <= V_shift_reg[2];
				V_shift_reg[0] <= V_shift_reg[1];
				
				U_shift_reg[5] <= 8'd0;
				U_shift_reg[4] <= U_shift_reg[5];
				U_shift_reg[3] <= U_shift_reg[4];
				U_shift_reg[2] <= U_shift_reg[3];
				U_shift_reg[1] <= U_shift_reg[2];
				U_shift_reg[0] <= U_shift_reg[1];
				
				M1_state <= L_IN_10;
			end
			L_IN_10: begin
				U_buf <= {24'd0, SRAM_read_data[7:0]};
				U_shift_reg[5] <= SRAM_read_data[15:8];
				
				V_Reg <= V_ACC;
				
				R_Reg <= Mult_1_result;
				G_Reg <= Mult_1_result;
				B_Reg <= Mult_1_result;
				
				U_ACC <= {{8{U_ACC[31]}}, U_ACC[31:8]};
		
				M1_state <= L_IN_11;
			end
			L_IN_11: begin
				SRAM_address <= SRAM_address_RGB;
				SRAM_address_RGB <= SRAM_address_RGB + 18'd1;
				SRAM_we_n <= 1'b0;
				
				U_Reg <= U_ACC;
				
				V_buf <= {24'd0, SRAM_read_data[7:0]};
				V_shift_reg[5] <= SRAM_read_data[15:8];
				
				R_Reg <= R_Reg + Mult_1_result;
				G_Reg <= G_Reg + Mult_2_result;
				
				M1_state <= L_IN_12;
			end
			L_IN_12: begin
				SRAM_address <= SRAM_address_RGB;
				SRAM_address_RGB <= SRAM_address_RGB + 18'd1;
				
				G_Reg <= G_Reg + Mult_1_result;
				B_Reg <= B_Reg + Mult_2_result;
				
				M1_state <= L_IN_13;
			end
			L_IN_13: begin
				SRAM_address <= SRAM_address_Y;
				SRAM_address_Y <= SRAM_address_Y + 18'd1;
				SRAM_we_n <= 1'b1;
				
				U_ACC <= 32'd128;
				V_ACC <= 32'd128;
				
				col_count <= col_count + 8'd1;
				M1_state <= CC1_0;
			end
			CC1_0: begin	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~``

				U_Reg <= U_shift_reg[2];
				V_Reg <= V_shift_reg[2];
				
				U_ACC <= U_ACC + Mult_1_result;
				V_ACC <= V_ACC + Mult_2_result;
				
				M1_state <= CC1_1;
			end
			CC1_1: begin
				U_ACC <= U_ACC + Mult_1_result;
				V_ACC <= V_ACC + Mult_2_result;
				
				M1_state <= CC1_2;
			end
			CC1_2: begin
				
				Y_buf <= {24'd0, SRAM_read_data[7:0]};
				Y_Reg <= {24'd0, SRAM_read_data[15:8]};
				
				if(col_count < 8'd156) begin	
					U_shift_reg[5] <= U_buf[7:0];
					U_shift_reg[4] <= U_shift_reg[5];
					U_shift_reg[3] <= U_shift_reg[4];
					U_shift_reg[2] <= U_shift_reg[3];
					U_shift_reg[1] <= U_shift_reg[2];
					U_shift_reg[0] <= U_shift_reg[1];
					
					V_shift_reg[5] <= V_buf[7:0];
					V_shift_reg[4] <= V_shift_reg[5];
					V_shift_reg[3] <= V_shift_reg[4];
					V_shift_reg[2] <= V_shift_reg[3];
					V_shift_reg[1] <= V_shift_reg[2];
					V_shift_reg[0] <= V_shift_reg[1];
				end
				else begin		//Lead Out
					U_shift_reg[5] <= U_shift_reg[5];
					U_shift_reg[4] <= U_shift_reg[5];
					U_shift_reg[3] <= U_shift_reg[4];
					U_shift_reg[2] <= U_shift_reg[3];
					U_shift_reg[1] <= U_shift_reg[2];
					U_shift_reg[0] <= U_shift_reg[1];
					
					V_shift_reg[5] <= V_shift_reg[5];
					V_shift_reg[4] <= V_shift_reg[5];
					V_shift_reg[3] <= V_shift_reg[4];
					V_shift_reg[2] <= V_shift_reg[3];
					V_shift_reg[1] <= V_shift_reg[2];
					V_shift_reg[0] <= V_shift_reg[1];
				end
				U_ACC <= U_ACC + Mult_1_result;
				V_ACC <= V_ACC + Mult_2_result;
				
				
				M1_state <= CC1_3;
			end
			CC1_3: begin
				Y_Reg <= Y_buf;
				
				R_Reg <= Mult_1_result;
				G_Reg <= Mult_1_result + Mult_2_result;
				B_Reg <= Mult_1_result;
				
				U_ACC <= {{8{U_ACC[31]}}, U_ACC[31:8]};
				V_ACC <= {{8{V_ACC[31]}}, V_ACC[31:8]};
				
				M1_state <= CC1_4;
			end
			CC1_4: begin
				SRAM_address <= SRAM_address_RGB;
				SRAM_address_RGB <= SRAM_address_RGB + 18'd1;
				SRAM_we_n <= 1'b0;
				
				U_buf <= U_ACC;
				V_Reg <= V_ACC;
				
				R_Reg <= R_Reg + Mult_1_result;
				G_Reg <= G_Reg + Mult_2_result;
				
				M1_state <= CC1_5;
			end
			CC1_5: begin
				SRAM_we_n <= 1'b1;
				
				U_Reg <= U_buf;
				
				R_Reg <= Mult_2_result;
				B_Reg <= B_Reg + Mult_1_result;
				
				M1_state <= CC1_6;
			end
			CC1_6: begin
				SRAM_address <= SRAM_address_RGB;
				SRAM_address_RGB <= SRAM_address_RGB + 18'd1;
				SRAM_we_n <= 1'b0;
				
				R_Reg <= R_Reg + Mult_1_result;
				G_Reg <= Mult_1_result + Mult_2_result;
				B_Reg <= Mult_1_result;
				
				B_buf <= B_Reg;
				
				M1_state <= CC1_7;
			end
			CC1_7: begin
				SRAM_address <= SRAM_address_RGB;
				SRAM_address_RGB <= SRAM_address_RGB + 18'd1;
				
				
				G_Reg <= G_Reg + Mult_2_result;
				B_Reg <= B_Reg + Mult_1_result;
				
				
				M1_state <= CC1_8;
			end
			CC1_8: begin
				SRAM_address <= SRAM_address_Y;
				SRAM_address_Y <= SRAM_address_Y + 18'd1;
				SRAM_we_n <= 1'b1;
				
				U_ACC <= 32'd128;
				V_ACC <= 32'd128;
				
				if(row_count < 8'd240) begin		//While last row
					if(col_count > 8'd154)	begin	//Lead Out Case
						if(col_count == 8'd159) begin		//End of row >159
							M1_state <= L_IN_0;
							row_count <= row_count + 8'd1;
							col_count <= 8'd0;
						end
						else begin					//Lead out common case
							M1_state <= CC1_0;
							col_count <= col_count + 8'd1;
						end
					end
					else begin						//Common Case
						M1_state <= CC2_0;
						col_count <= col_count + 8'd1;
					end
				end
				
			end	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
			CC2_0: begin
				U_Reg <= U_shift_reg[2];
				V_Reg <= V_shift_reg[2];
				
				U_ACC <= U_ACC + Mult_1_result;
				V_ACC <= V_ACC + Mult_2_result;
				
				M1_state <= CC2_1;
			end
			CC2_1: begin
				SRAM_address <= SRAM_address_V;
				SRAM_address_V <= SRAM_address_V + 18'd1;
				
				U_ACC <= U_ACC + Mult_1_result;
				V_ACC <= V_ACC + Mult_2_result;
				
				M1_state <= CC2_2;
			end
			CC2_2: begin
				Y_buf <= {24'd0, SRAM_read_data[7:0]};//Store Y0Y1
				Y_Reg <= {24'd0, SRAM_read_data[15:8]};
				
				U_ACC <= U_ACC + Mult_1_result;
				V_ACC <= V_ACC + Mult_2_result;
				
				
				M1_state <= CC2_3;
			end
			CC2_3: begin
				SRAM_address <= SRAM_address_U;
				SRAM_address_U <= SRAM_address_U + 18'd1;
				
				Y_Reg <= Y_buf;
				U_ACC <= {{8{U_ACC[31]}}, U_ACC[31:8]};//sign extension
				V_ACC <= {{8{V_ACC[31]}}, V_ACC[31:8]};
				
				U_shift_reg[5] <= 8'd0;
				U_shift_reg[4] <= U_shift_reg[5];
				U_shift_reg[3] <= U_shift_reg[4];
				U_shift_reg[2] <= U_shift_reg[3];
				U_shift_reg[1] <= U_shift_reg[2];
				U_shift_reg[0] <= U_shift_reg[1];
				
				V_shift_reg[5] <= 8'd0;
				V_shift_reg[4] <= V_shift_reg[5];
				V_shift_reg[3] <= V_shift_reg[4];
				V_shift_reg[2] <= V_shift_reg[3];
				V_shift_reg[1] <= V_shift_reg[2];
				V_shift_reg[0] <= V_shift_reg[1];
				
				R_Reg <= Mult_1_result;	//a00Y
				G_Reg <= Mult_1_result + Mult_2_result;//a00Y + a11Ueven
				B_Reg <= Mult_1_result;//a00Y
				
				M1_state <= CC2_4;
			end
			CC2_4: begin
				SRAM_address <= SRAM_address_RGB;
				SRAM_address_RGB <= SRAM_address_RGB + 18'd1;
				SRAM_we_n <= 1'b0;
				
				V_buf <= {24'd0, SRAM_read_data[7:0]};
				V_shift_reg[5] <= SRAM_read_data[15:8];
				
				U_buf <= U_ACC;
				V_Reg <= V_ACC;
				
				R_Reg <= R_Reg + Mult_1_result;	//a00Y+a02Veven
				G_Reg <= G_Reg + Mult_2_result;//a00Y + a11Ueven + a12Veven
				M1_state <= CC2_5;
			end
			CC2_5: begin	//29
				SRAM_we_n <= 1'b1;
				
				U_Reg <= U_buf;
				
				R_Reg <= Mult_2_result;//a02Vodd
				B_Reg <= B_Reg + Mult_1_result;//a00Y + a21Ueven
				
				M1_state <= CC2_6;
			end
			CC2_6: begin
				SRAM_address <= SRAM_address_RGB;
				SRAM_address_RGB <= SRAM_address_RGB + 18'd1;
				SRAM_we_n <= 1'b0;
				
				U_buf <= {24'd0, SRAM_read_data[7:0]};
				U_shift_reg[5] <= SRAM_read_data[15:8];
				
				R_Reg <= R_Reg + Mult_1_result;//a02Vodd + a00Y
				G_Reg <= Mult_1_result + Mult_2_result;//a00Y + a11Uodd
				B_Reg <= Mult_1_result;//a00Y 
				B_buf <= B_Reg;
				
				M1_state <= CC2_7;
			end
			CC2_7: begin
				SRAM_address <= SRAM_address_RGB;
				SRAM_address_RGB <= SRAM_address_RGB + 18'd1;
				
				G_Reg <= G_Reg + Mult_2_result;//a00Y+a11Uodd+a12Vodd
				B_Reg <= B_Reg + Mult_1_result;//a00Y+a21Uodd
				
				M1_state <= CC2_8;
			end
			CC2_8: begin
				SRAM_address <= SRAM_address_Y;
				SRAM_address_Y <= SRAM_address_Y + 18'd1;
				SRAM_we_n <= 1'b1;
				
				U_ACC <= 32'd128;
				V_ACC <= 32'd128;
				
				col_count <= col_count + 8'd1;
				M1_state <= CC1_0;
			end
			default: M1_state<=M1_IDLE;
		endcase
	end	
end 


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
always_comb begin

	Mult_op_1 = 32'd0;
	Mult_op_2 = 32'd0;
	Mult_op_3 = 32'd0;
	Mult_op_4 = 32'd0;
	R_O = 8'd0;
	G_O = 8'd0;
	B_O = 8'd0;
	SRAM_write_data = 16'd0;
	R_Reg_Shifted = 32'd0;
	G_Reg_Shifted = 32'd0;
	B_Reg_Shifted = 32'd0;
	B_buf_Shifted = 32'd0;
	
	case (M1_state)
		L_IN_4: begin	//State 4
			Mult_op_1 = Y_Reg - 32'd16;
			Mult_op_2 = 32'd76284;//a00
			Mult_op_3 = 32'd0;				
			Mult_op_4 = 32'd0;				
		end
		L_IN_5: begin	//State 5
			Mult_op_1 = U_Reg - 32'd128;
			Mult_op_2 = -32'd25624;//a11
			Mult_op_3 = U_Reg - 32'd128;
			Mult_op_4 = 32'd132251;//a21 
		end
		L_IN_6: begin	
			Mult_op_1 = V_Reg - 32'd128;
			Mult_op_2 = 32'd104595;//a02
			Mult_op_3 = V_Reg - 32'd128;
			Mult_op_4 = -32'd53281;//a12	
		end
		L_IN_7: begin
			R_O = (R_Reg[31]) ? 8'd0 : ((R_Reg[30:24] == 7'd0) ? R_Reg[23:16] : 8'd255);
			G_O = (G_Reg[31]) ? 8'd0 : ((G_Reg[30:24] == 7'd0) ? G_Reg[23:16] : 8'd255);
			SRAM_write_data = {R_O,G_O};	
			
			Mult_op_1 = 32'd159;
			Mult_op_2 = {24'd0,{U_shift_reg[2]}}+{24'd0,{U_shift_reg[3]}}; //adder3
			Mult_op_3 = 32'd159;
			Mult_op_4 = {24'd0,{V_shift_reg[2]}}+{24'd0,{V_shift_reg[3]}}; //adder6
		end
		L_IN_8: begin
			Mult_op_1 = 32'd21;
			Mult_op_2 = {24'd0,{V_shift_reg[0]}}+{24'd0,{V_shift_reg[5]}}; //adder 4
			Mult_op_3 = -32'd52;
			Mult_op_4 = {24'd0,{V_shift_reg[1]}}+{24'd0,{V_shift_reg[4]}}; //adder 5	
		end
		L_IN_9: begin
			Mult_op_1 = 32'd21;
			Mult_op_2 = {24'd0,{U_shift_reg[0]}}+{24'd0,{U_shift_reg[5]}}; //adder 1
			Mult_op_3 = -32'd52;
			Mult_op_4 = {24'd0,{U_shift_reg[1]}}+{24'd0,{U_shift_reg[4]}}; //adder 2
		end
		L_IN_10: begin
			Mult_op_1 = Y_Reg - 32'd16;
			Mult_op_2 = 32'd76284;//a00
			Mult_op_3 = 32'd0;				
			Mult_op_4 = 32'd0;	
		end
		L_IN_11: begin
			Mult_op_1 = V_Reg - 32'd128;
			Mult_op_2 = 32'd104595;//a02
			Mult_op_3 = V_Reg - 32'd128;
			Mult_op_4 = -32'd53281;//a12		
		end
		L_IN_12: begin	
			R_O = (R_Reg[31]) ? 8'd0 : ((R_Reg[30:24] == 7'd0) ? R_Reg[23:16] : 8'd255);
			B_O = (B_buf[31]) ? 8'd0 : ((B_buf[30:24] == 7'd0) ? B_buf[23:16] : 8'd255);

			SRAM_write_data = {B_O,R_O};	
			
			Mult_op_1 = U_Reg - 32'd128;
			Mult_op_2 = -32'd25624;//a11
			Mult_op_3 = U_Reg - 32'd128;
			Mult_op_4 = 32'd132251;//a21
			
		end
		L_IN_13: begin
			G_O = (G_Reg[31]) ? 8'd0 : ((G_Reg[30:24] == 7'd0) ? G_Reg[23:16] : 8'd255);
			B_O = (B_Reg[31]) ? 8'd0 : ((B_Reg[30:24] == 7'd0) ? B_Reg[23:16] : 8'd255);
			SRAM_write_data = {G_O,B_O};	
		end
		CC1_0: begin
			Mult_op_1 = 32'd21;
			Mult_op_2 = {24'd0,{U_shift_reg[0]}}+{24'd0,{U_shift_reg[5]}}; //adder 1
			Mult_op_3 = 32'd21;
			Mult_op_4 = {24'd0,{V_shift_reg[0]}}+{24'd0,{V_shift_reg[5]}}; //adder 3
		end
		CC1_1: begin
			Mult_op_1 = -32'd52;
			Mult_op_2 = {24'd0,{U_shift_reg[1]}}+{24'd0,{U_shift_reg[4]}}; //adder 2
			Mult_op_3 = -32'd52;
			Mult_op_4 = {24'd0,{V_shift_reg[1]}}+{24'd0,{V_shift_reg[4]}}; //adder 5	
		end
		CC1_2: begin
			Mult_op_1 = 32'd159;
			Mult_op_2 = {24'd0,{U_shift_reg[2]}}+{24'd0,{U_shift_reg[3]}}; //adder 3
			Mult_op_3 = 32'd159;
			Mult_op_4 = {24'd0,{V_shift_reg[2]}}+{24'd0,{V_shift_reg[3]}}; //adder 6	
		end
		CC1_3: begin
			Mult_op_1 = Y_Reg - 32'd16;
			Mult_op_2 = 32'd76284;//a00
			Mult_op_3 = U_Reg - 32'd128;				
			Mult_op_4 = -32'd25624;//a11	
		end
		CC1_4: begin
			Mult_op_1 = V_Reg - 32'd128;
			Mult_op_2 = 32'd104595;//a02
			Mult_op_3 = V_Reg - 32'd128;
			Mult_op_4 = -32'd53281;//a12	
		end
		CC1_5: begin
			R_O = (R_Reg[31]) ? 8'd0 : ((R_Reg[30:24] == 7'd0) ? R_Reg[23:16] : 8'd255);
			G_O = (G_Reg[31]) ? 8'd0 : ((G_Reg[30:24] == 7'd0) ? G_Reg[23:16] : 8'd255);
			SRAM_write_data = {R_O,G_O};	
			
			Mult_op_1 = U_Reg - 32'd128;
			Mult_op_2 = 32'd132251;//a21
			Mult_op_3 = V_Reg - 32'd128;
			Mult_op_4 = 32'd104595;//a02	
		end
		CC1_6: begin
			Mult_op_1 = Y_Reg - 32'd16;
			Mult_op_2 = 32'd76284;//a00
			Mult_op_3 = U_Reg - 32'd128;				
			Mult_op_4 = -32'd25624;//a11	
		end
		CC1_7: begin
			R_O = (R_Reg[31]) ? 8'd0 : ((R_Reg[30:24] == 7'd0) ? R_Reg[23:16] : 8'd255);
			B_O = (B_buf[31]) ? 8'd0 : ((B_buf[30:24] == 7'd0) ? B_buf[23:16] : 8'd255);

			SRAM_write_data = {B_O,R_O};
			
			Mult_op_1 = U_Reg - 32'd128;
			Mult_op_2 = 32'd132251;//a21
			Mult_op_3 = V_Reg - 32'd128;
			Mult_op_4 = -32'd53281;//a12		
		end
		CC1_8: begin	
			G_O = (G_Reg[31]) ? 8'd0 : ((G_Reg[30:24] == 7'd0) ? G_Reg[23:16] : 8'd255);
			B_O = (B_Reg[31]) ? 8'd0 : ((B_Reg[30:24] == 7'd0) ? B_Reg[23:16] : 8'd255);
			SRAM_write_data = {G_O,B_O};	
		end
		CC2_0: begin
			Mult_op_1 = 32'd21;
			Mult_op_2 = {24'd0,{U_shift_reg[0]}}+{24'd0,{U_shift_reg[5]}}; //adder 1
			Mult_op_3 = 32'd21;
			Mult_op_4 = {24'd0,{V_shift_reg[0]}}+{24'd0,{V_shift_reg[5]}}; //adder 4	
		end
		CC2_1: begin
			Mult_op_1 = -32'd52;
			Mult_op_2 = {24'd0,{U_shift_reg[1]}}+{24'd0,{U_shift_reg[4]}}; //adder 2
			Mult_op_3 = -32'd52;
			Mult_op_4 = {24'd0,{V_shift_reg[1]}}+{24'd0,{V_shift_reg[4]}}; //adder 5	
		end
		CC2_2: begin
			Mult_op_1 = 32'd159;
			Mult_op_2 = {24'd0,{U_shift_reg[2]}}+{24'd0,{U_shift_reg[3]}}; //adder3
			Mult_op_3 = 32'd159;
			Mult_op_4 = {24'd0,{V_shift_reg[2]}}+{24'd0,{V_shift_reg[3]}}; //adder6
		end
		CC2_3: begin
			Mult_op_1 = Y_Reg - 32'd16;
			Mult_op_2 = 32'd76284;//a00
			Mult_op_3 = U_Reg - 32'd128;
			Mult_op_4 = -32'd25624;//a11
		end
		CC2_4: begin
			Mult_op_1 = V_Reg - 32'd128;
			Mult_op_2 = 32'd104595;//a02
			Mult_op_3 = V_Reg - 32'd128;
			Mult_op_4 = -32'd53281;//a12	
		end
		CC2_5: begin
			R_O = (R_Reg[31]) ? 8'd0 : ((R_Reg[30:24] == 7'd0) ? R_Reg[23:16] : 8'd255);
			G_O = (G_Reg[31]) ? 8'd0 : ((G_Reg[30:24] == 7'd0) ? G_Reg[23:16] : 8'd255);
			SRAM_write_data = {R_O,G_O};
			
			Mult_op_1 = U_Reg - 32'd128;
			Mult_op_2 = 32'd132251;//a21
			Mult_op_3 = V_Reg - 32'd128;
			Mult_op_4 = 32'd104595;//a02
		end
		CC2_6: begin
			Mult_op_1 = Y_Reg - 32'd16;
			Mult_op_2 = 32'd76284;//a00
			Mult_op_3 = U_Reg - 32'd128;
			Mult_op_4 = -32'd25624;//a11
		end
		CC2_7: begin
			R_O = (R_Reg[31]) ? 8'd0 : ((R_Reg[30:24] == 7'd0) ? R_Reg[23:16] : 8'd255);
			B_O = (B_buf[31]) ? 8'd0 : ((B_buf[30:24] == 7'd0) ? B_buf[23:16] : 8'd255);
			SRAM_write_data = {B_O,R_O};
			
			Mult_op_1 = U_Reg - 32'd128;
			Mult_op_2 = 32'd132251;//a21
			Mult_op_3 = V_Reg - 32'd128;
			Mult_op_4 = -32'd53281;//a12
		end
		CC2_8: begin
			G_O = (G_Reg[31]) ? 8'd0 : ((G_Reg[30:24] == 7'd0) ? G_Reg[23:16] : 8'd255);
			B_O = (B_Reg[31]) ? 8'd0 : ((B_Reg[30:24] == 7'd0) ? B_Reg[23:16] : 8'd255);
			SRAM_write_data = {G_O,B_O};
		end
	endcase
end
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

endmodule