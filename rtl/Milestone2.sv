
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif
`include "define_state.h"


module Milestone2(
	input logic CLOCK_50_I,
	input logic resetn,
	
	input logic M2_start,
	input logic [15:0] SRAM_read_data,
	
	output logic [17:0] SRAM_address,
	output logic [15:0] SRAM_write_data,
	output logic SRAM_we_n,
	output logic M2_finish
	
);

	
//~~~~~~~~~~~~~~ Dual Port RAM 1 ~~~~~~~~~~~~~~~~
logic [6:0] address_0_a;
logic [6:0] address_0_b;
logic [31:0] write_data_0_a;
logic [31:0] write_data_0_b;
logic write_enable_0_a;
logic write_enable_0_b;
logic [31:0] read_data_0_a;
logic [31:0] read_data_0_b;


dual_port_RAM0 dual_port_RAM_inst0 (
	.address_a ( address_0_a ),
	.address_b ( address_0_b ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_0_a ),
	.data_b ( write_data_0_b ),
	.wren_a ( write_enable_0_a ),
	.wren_b ( write_enable_0_b ),
	.q_a ( read_data_0_a ),
	.q_b ( read_data_0_b )
);


	
//~~~~~~~~~~~~~~ Dual Port RAM 2 ~~~~~~~~~~~~~~~~
logic [6:0] address_1_a;
logic [6:0] address_1_b;
logic [31:0] write_data_1_a;
logic [31:0] write_data_1_b;
logic write_enable_1_a;
logic write_enable_1_b;
logic [31:0] read_data_1_a;
logic [31:0] read_data_1_b;

dual_port_RAM1 dual_port_RAM_inst1 (
	.address_a ( address_1_a ),
	.address_b ( address_1_b ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_1_a ),
	.data_b ( write_data_1_b ),
	.wren_a ( write_enable_1_a ),
	.wren_b ( write_enable_1_b ),
	.q_a ( read_data_1_a ),
	.q_b ( read_data_1_b )
);


//~~~~~~~~~~~~~~ Dual Port RAM 3 ~~~~~~~~~~~~~~~~
logic [6:0] address_2_a;
logic [6:0] address_2_b;
logic [31:0] write_data_2_a;
logic [31:0] write_data_2_b;
logic write_enable_2_a;
logic write_enable_2_b;
logic [31:0] read_data_2_a;
logic [31:0] read_data_2_b;


dual_port_RAM2 dual_port_RAM_inst2 (
	.address_a ( address_2_a ),
	.address_b ( address_2_b ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_2_a ),
	.data_b ( write_data_2_b ),
	.wren_a ( write_enable_2_a ),
	.wren_b ( write_enable_2_b ),
	.q_a ( read_data_2_a ),
	.q_b ( read_data_2_b )
);


//~~~~~~~~~~~~~~~~~~~~~~ Multiplier Logic ~~~~~~~~~~~~~~~~~~~~~~~~~~
logic signed [63:0] Mult_1_result_long, Mult_2_result_long, Mult_3_result_long;
logic signed [31:0] Mult_1_result, Mult_2_result, Mult_3_result;
logic signed [31:0] Mult_op_1, Mult_op_2, Mult_op_3, Mult_op_4, Mult_op_5, Mult_op_6;

assign Mult_1_result_long = Mult_op_1 * Mult_op_2;
assign Mult_2_result_long = Mult_op_3 * Mult_op_4;
assign Mult_3_result_long = Mult_op_5 * Mult_op_6;

assign Mult_1_result = Mult_1_result_long [31:0];
assign Mult_2_result = Mult_2_result_long [31:0];
assign Mult_3_result = Mult_3_result_long [31:0];


//~~~~~~~~~~~~~~~~~~~~~~ Read Generation Registers ~~~~~~~~~~``
logic [5:0] Read_CSC;		//Sample Counter Count
logic [5:0] Read_CBC;		//Column Block Count
logic [4:0] Read_RBC;		//Row Block Count
logic Read_CS_en, Read_Fs_en;

logic [7:0] Read_RA;
logic [8:0] Read_CA;

logic [17:0] Read_address_RA_1, Read_address_RA_2, Read_address_CA;
logic [17:0] Read_Y_address, Read_UV_address;

logic signed [15:0] Fetch_buf;
logic SPrime_we_en;

logic [2:0] Inter_State_Count;
logic Reading_Y, Reading_U, Reading_V;

M2_state_type M2_state;
Mega_CT_INNER_type Mega_CT_INNER;

//~~~~~~~~~~~~~~~~~~~~ Milestone 2 Logic ~~~~~~~~~~~~~~~~~~~~~~~~~~~
logic unsigned [5:0] select1_C, select2_C, select3_C;
logic signed [31:0] C1, C2, C3;

logic [8:0] matrix_counter;
logic [2:0] i,j,k;
logic [15:0] pre_S_buf;
logic [2:0] col_count;//used to determine the index of a C Matrix
logic [2:0] T_col_count;//used to determine the index of a T Matrix
logic [5:0] element_count;//used to detect the number of elements computed in T matrix
logic signed [31:0] T,T_final;
logic signed [31:0] S,S_final;
logic [5:0] CT_address_INC;

assign k = matrix_counter[2:0];//used for matrix addresses in the computation states
assign j = matrix_counter[5:3];
assign i = matrix_counter[8:6];

logic [2:0] C_Transpose_Count;
logic [31:0] CT_data_buf;
logic first_write;

//~~~~~~~~~~~~~~~~~~~~~~ Write GeneRead_RAtion Register ~~~~~~~~~~``
logic [4:0] Write_CSC;
logic [5:0] Write_CBC;
logic [4:0] Write_RBC;
logic Write_CS_en;

logic [7:0] Write_RA;
logic [7:0] Write_CA;

logic [17:0] Write_address_RA_1, Write_address_RA_2, Write_address_CA;
logic [17:0] Write_Y_address;

logic Writing_Y, Writing_U, Writing_V;

logic [6:0] Write_SRead_INC;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~` TOP FSM SEQUENTIAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

always_ff @ ( posedge CLOCK_50_I or negedge resetn) begin
	if (~resetn) begin
		Read_CSC <= 6'd0;
		Read_CBC <= 6'd0;
		Read_RBC <= 5'd0;
		Read_CS_en <= 1'd0;
		Read_Fs_en <= 1'd0;
		
		address_1_a <= 7'd0;
		address_2_a <= 7'd0;
		address_0_a <= 7'd0;//address assigned in the next cc --> read available in 2 cc
		address_0_b <= 7'd1;
		
		write_enable_0_a <= 1'b0;
		write_enable_0_b <= 1'b0;
		write_enable_1_b <= 1'b0;
		
		SRAM_address <= 18'd0;
		SRAM_we_n <= 1'b1;
		
		SPrime_we_en <= 1'b0;
		Inter_State_Count <= 3'd0;
		
		Reading_Y <= 1'b1;
		Reading_U <= 1'b0;
		Reading_V <= 1'b0;
		
		element_count <= 6'd0;
		col_count <= 3'd0;
		T <= 32'd0;
		CT_address_INC <= 6'd0;
		
		T_col_count <= 3'd0;
		C_Transpose_Count <= 3'd0;
		S <= 32'd0;
		
		Write_CSC <= 5'd0;
		Write_CBC <= 6'd0;
		Write_RBC <= 5'd0;
		Write_CS_en <= 1'd1;
		Write_SRead_INC <= 7'd0;
		first_write <= 1'd0;
		Writing_Y <= 1'b1;
		Writing_U <= 1'b0;
		Writing_V <= 1'b0;
		
		Mega_CT_INNER <= INNER_Mega_CT_PREP;
		M2_state <= M2_IDLE;
		M2_finish <= 1'b0;
		
	end
	else begin
		case (M2_state)
			M2_IDLE: begin
				M2_state <= M2_IDLE;
				if((M2_start) && (!M2_finish)) begin
					M2_state <= M2_LIN_Fetch;
					Read_CS_en <= 1'b1;
				end
				
			end
			
			M2_LIN_Fetch: begin
				
				if(Read_CS_en) begin					//Main Fetch and Write area
					Read_CSC <= Read_CSC + 6'd1;
					if(Read_CSC == 6'd63) begin
						Read_CBC <= Read_CBC + 6'd1;
						
						if(Read_CBC == 6'd39) begin
							Read_CBC <= 6'd0;
						end
						Read_CS_en <= 1'b0;
						
					end
					
					if((Read_CBC == 6'd39) && (Read_CSC == 6'd63)) begin
						Read_RBC <= Read_RBC + 5'd1;
						if(Read_RBC == 5'd30) begin
							Read_RBC <= 5'd0;
						end
					end
					
					SRAM_address <= Read_Y_address;	//Pass Calculated Y Address
					
					//Writing
					if((Read_CSC > 6'd2) ) begin									//When first value is in SRAM_read_data
						Fetch_buf <= SRAM_read_data; 								//buffer first value
						SPrime_we_en <= ~SPrime_we_en;							//Toggle write_en to write every 2cc
						if((!SPrime_we_en) && (Read_CSC != 6'd3)) begin		//Increment address if reading
							address_0_a <= address_0_a + 7'd1;
						end
						
							write_enable_0_a <= ~write_enable_0_a;
					end
				end

				else begin		//Extra CCs for writing last values
					//State Transition conditions
					Inter_State_Count <= Inter_State_Count + 3'd1;
					if(Inter_State_Count == 3'd2) begin
						M2_state <= M2_LIN_CT_PREP;
						Inter_State_Count <= 3'd0;
					end
					
					//Writing 
					Fetch_buf <= SRAM_read_data;
					SPrime_we_en <= ~SPrime_we_en;
					if(!SPrime_we_en) begin
						address_0_a <= address_0_a + 7'd1;
					end
						
					if(address_0_a == 6'd31) begin
						write_enable_0_a <= 1'b0;	//At end of block reset back to reading
						address_0_a <= 7'd0;
					end
					else
						write_enable_0_a <= ~write_enable_0_a;
					
				end

			end
			
			M2_LIN_CT_PREP: begin
				address_0_a <= address_0_a + 7'd2;
				address_0_b <= address_0_b + 7'd2;
				
				M2_state <= M2_LIN_CT_0;
			end
			M2_LIN_CT_0: begin
				pre_S_buf <= read_data_0_b [15:0];
				if(col_count == 3'd7) begin
					CT_address_INC <= CT_address_INC + 6'd4;
				end
				
				T <= Mult_1_result + Mult_2_result + Mult_3_result;
				M2_state <= M2_LIN_CT_1;
			end
			M2_LIN_CT_1: begin
				address_0_a <= 7'd0 + CT_address_INC;
				address_0_b <= 7'd1 + CT_address_INC;
				
				write_enable_1_a <= 1'd1;
				write_enable_2_a <= 1'd1;
				
				T <= T + Mult_1_result + Mult_2_result + Mult_3_result;
				M2_state <= M2_LIN_CT_2;
			end

			M2_LIN_CT_2: begin
				address_0_a <= address_0_a + 7'd2 ;
				address_0_b <= address_0_b + 7'd2 ;
				
				address_1_a <= address_1_a + 7'd1;
				address_2_a <= address_2_a + 7'd1;
				
				write_enable_1_a <= 1'd0;
				write_enable_2_a <= 1'd0;

				element_count <= element_count + 6'd1;
				
				if(col_count == 3'd7) begin
					col_count <= 3'd0;
				end
				else col_count <= col_count + 3'd1;
				
				if (element_count == 6'd63) begin
					M2_state <= M2_Mega_CS_PREP;
					Read_CS_en <= 1'b1;			//Enable for reading next block data from Pre-IDCT
					Read_Fs_en <= 1'b1;
					address_0_a <= 7'd0;
					address_0_b <= 7'd0;
					element_count <= 6'd0;
					CT_address_INC <= 6'd0;
					
					address_1_a <= 7'd0;//prepares addresses for reads in the mega Cs state
					address_1_b <= 7'd8;
					address_2_a <= 7'd16;
					
				end
				else if (element_count < 6'd63) M2_state <= M2_LIN_CT_0;
				
			end
			M2_Mega_CS_PREP: begin
				
				address_1_a <= 7'd24;	//Reading 3 T values
				address_1_b <= 7'd32;
				address_2_a <= 7'd40;
				
				address_0_b <= 7'd64;	//For writing S
				
				M2_state <= M2_Mega_CS_0;
			end
			M2_Mega_CS_0: begin
				
				address_1_a <= 7'd48 + T_col_count;
				address_1_b <= 7'd56 + T_col_count;
				
				if (T_col_count == 3'd7) T_col_count <= 3'd0;
				else T_col_count <= T_col_count + 3'd1;
				
				S <= Mult_1_result + Mult_2_result + Mult_3_result;
				
				M2_state <= M2_Mega_CS_1;
				
			end
			M2_Mega_CS_1: begin
				
				address_1_a <= 7'd0 + T_col_count;
				address_1_b <= 7'd8 + T_col_count;
				address_2_a <= 7'd16 + T_col_count;
				
				write_enable_0_b <= 1'b1;//enabling write to write in the next cc
				
				S <= S + Mult_1_result + Mult_2_result + Mult_3_result;
				
				M2_state <= M2_Mega_CS_2;
			end
			M2_Mega_CS_2: begin
				
				write_enable_0_b <= 1'b0;
				
				element_count <= element_count + 6'd1;
				
				if(col_count == 3'd7) begin
					col_count <= 3'd0;
					C_Transpose_Count <= C_Transpose_Count + 3'd1;
				end
				else col_count <= col_count + 3'd1;
				
				if (element_count == 6'd63) begin //Transitions to the next mega state
					element_count <= 6'd0;
					M2_state <= M2_Mega_CT;
					Mega_CT_INNER <= INNER_Mega_CT_PREP;
					address_0_a <= 7'd0;
					address_0_b <= 7'd1;
					address_1_a <= 7'd0;
					address_1_b <= 7'd0;
					address_2_a <= 7'd0;
				end
				else if (element_count < 6'd63) begin
				
					address_0_b <= address_0_b + 7'd1;//incrementing address for the next S
					address_1_a <= 7'd24 + T_col_count;
					address_1_b <= 7'd32 + T_col_count;
					address_2_a <= 7'd40 + T_col_count;
					
					
					M2_state <= M2_Mega_CS_0;//continues computing the S block
				end
				
				//~~~~~~~~~~~~~~~~~~~ Cs Reading Condition ~~~~~~~~~~~~~`
				if(Write_RBC == 5'd30) begin			//END OF READING For Y/U/V 
					if(Writing_Y) begin					//If Y finished, start U
						Writing_Y <= 1'b0;
						Writing_U <= 1'b1;
						Write_RBC <= 5'd0;
					end	
					else begin
						if(Writing_U) begin
							Writing_U <= 1'b0;
							Writing_V <= 1'b1;
							Write_RBC <= 5'd0;
						end
						else begin
							if(Writing_V) begin			//Y/U/V done, Leadout
								Writing_V <= 1'b0;
								Write_RBC <= 5'd0;		//Temp until we figure out leadout
								M2_state <= M2_LOUT_WS;
							end
						end
					end
				end
				
			end
			M2_Mega_CT: begin
				
				
				case(Mega_CT_INNER)
					INNER_Mega_CT_PREP: begin
						address_0_a <= address_0_a + 7'd2;
						address_0_b <= address_0_b + 7'd2;
						
						if((Read_CBC > 6'd2) || (Read_RBC > 6'd0) || (Reading_U) || (Reading_V)
							|| (Writing_V)) begin
							first_write <= 1'b1;
						end
						
						Mega_CT_INNER <= INNER_Mega_CT_0;
					end
					INNER_Mega_CT_0: begin
						
						if(Write_SRead_INC < 7'd64) begin
							address_0_a <=  Write_SRead_INC + 7'd64;
							address_0_b <= Write_SRead_INC + 7'd65;
							Write_SRead_INC <= Write_SRead_INC + 7'd2;
						end
						
						if(((Write_SRead_INC < 7'd64) && (element_count > 6'd0))
								|| (first_write)) begin
							Write_CS_en <= 1'b1;
							first_write <= 1'b0;
						end
						
						pre_S_buf <= read_data_0_b [15:0];
						if(col_count == 3'd7) begin
							CT_address_INC <= CT_address_INC + 6'd4;
						end
						
						T <= Mult_1_result + Mult_2_result + Mult_3_result;
								
						Mega_CT_INNER <= INNER_Mega_CT_1;
					end
					INNER_Mega_CT_1: begin
						address_0_a <= 7'd0 + CT_address_INC;
						address_0_b <= 7'd1 + CT_address_INC;
						
						write_enable_1_a <= 1'd1;
						write_enable_2_a <= 1'd1;
						
						CT_data_buf <= read_data_0_b;
						
						T <= T + Mult_1_result + Mult_2_result + Mult_3_result;
						
						//Writing to SRAM
						if(element_count < 6'd32) begin
							SRAM_we_n <= 1'b0;
							SRAM_address <= Write_Y_address;
						end
						
						Mega_CT_INNER <= INNER_Mega_CT_2;
					end
					INNER_Mega_CT_2: begin
						
						address_0_a <= address_0_a + 7'd2 ;
						address_0_b <= address_0_b + 7'd2 ;
						
						address_1_a <= address_1_a + 7'd1;
						address_2_a <= address_2_a + 7'd1;
						
						write_enable_1_a <= 1'd0;
						write_enable_2_a <= 1'd0;

						element_count <= element_count + 6'd1;
						
						SRAM_we_n <= 1'b1;
						
						if(col_count == 3'd7) begin
							col_count <= 3'd0;
						end
						else col_count <= col_count + 3'd1;
						
						if (element_count == 6'd63) begin
							
							//(Writing_V) && (Write_CSC == 5'd31) && (Write_CBC == 6'd19) && (Writing_RBC == 5'd29)
							if((SRAM_address == 18'd76799) && (Writing_V)) begin
								M2_state <= M2_LOUT_WS;
							end
							else begin
								if(Read_UV_address != 18'd230400) begin
									M2_state <= M2_Mega_CS_PREP;	
								end
							end
							
							Read_CS_en <= 1'b1;			//Enable for reading next block data from Pre-IDCT
							Read_Fs_en <= 1'b1;
							address_0_a <= 7'd0;
							address_0_b <= 7'd0;
							element_count <= 6'd0;
							CT_address_INC <= 6'd0;
							
							address_1_a <= 7'd0;//prepares addresses for reads in the mega Cs state
							address_1_b <= 7'd8;
							address_2_a <= 7'd16;
							
							Write_SRead_INC <= 6'd0;
							
						end
						else if (element_count < 6'd63) Mega_CT_INNER <= INNER_Mega_CT_0;
				
						
					end
				endcase
				
				//~~~~~~~~~~~~~~~~~~~~~~ Writing K-1 ~~~~~~~~~~~~~~~~~~~~~~
				if(Write_CS_en) begin
					if(Writing_Y) begin
						Write_CS_en <= 1'b0;
						Write_CSC <= Write_CSC + 5'd1;
						if(Write_CSC == 6'd31) begin
							Write_CBC <= Write_CBC + 6'd1;
							if(Write_CBC == 6'd39) begin
								Write_CBC <= 6'd0;
							end
						end
						if((Write_CBC == 6'd39) && (Write_CSC == 6'd31)) begin
							Write_RBC <= Write_RBC + 5'd1;
							if(Write_RBC == 5'd30) begin
								Write_RBC <= 5'd0;
							end
						end
					end
					else begin
						if(Writing_U || Writing_V) begin
							Write_CS_en <= 1'b0;
							Write_CSC <= Write_CSC + 5'd1;
							if(Write_CSC == 6'd31) begin
								Write_CBC <= Write_CBC + 6'd1;
								if(Write_CBC == 6'd19) begin
									Write_CBC <= 6'd0;
								end
							end
							if((Write_CBC == 6'd19) && (Write_CSC == 6'd31)) begin
								Write_RBC <= Write_RBC + 5'd1;
								if(Write_RBC == 5'd30) begin
									Write_RBC <= 5'd0;
								end
							end
						end
					end
				end
				
				//~~~~~~~~~~~~~~~~~~~ Cs Reading Condition ~~~~~~~~~~~~~`
				if(Read_RBC == 5'd30) begin			//END OF READING For Y/U/V 
					if(Reading_Y) begin					//If Y finished, start U
						Reading_Y <= 1'b0;
						Reading_U <= 1'b1;
						Read_RBC <= 5'd0;
					end	
					else begin
						if(Reading_U) begin
							Reading_U <= 1'b0;
							Reading_V <= 1'b1;
							Read_RBC <= 5'd0;
						end
						else begin
							if(Reading_V) begin			//Y/U/V done, Leadout
								Reading_V <= 1'b0;
								Read_RBC <= 5'd0;
							end
						end
					end
				end
				
			end
			M2_LOUT_WS: begin
				
				M2_finish <= 1'b1;
				M2_state <= M2_IDLE;
			end
		
		endcase
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ READING Fs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if((M2_state == M2_Mega_CS_2) || (M2_state == M2_Mega_CS_1) 
			|| (M2_state == M2_Mega_CS_0)) begin
			
			if(Read_Fs_en) begin
				if(Read_CS_en) begin					//Main Fetch and Write area
						
					if(Reading_Y) begin				// ~~~~~~~ 8x8 Block Read F(k+1) For Y ~~~~~~~~
						Read_CSC <= Read_CSC + 6'd1;
						if(Read_CSC == 6'd63) begin
							Read_CBC <= Read_CBC + 6'd1;
							
							if(Read_CBC == 6'd39) begin
								Read_CBC <= 6'd0;
							end
							Read_CS_en <= 1'b0;
							
						end
						
						if((Read_CBC == 6'd39) && (Read_CSC == 6'd63)) begin
							Read_RBC <= Read_RBC + 5'd1;
							if(Read_RBC == 5'd30) begin
								Read_RBC <= 5'd0;
							end
						end
						
						SRAM_address <= Read_Y_address;	//Pass Calculated Y Address
					end
					else begin							// ~~~~~~~ 8x8 Block Read F(k+1) For Y ~~~~~~~~
						if(Reading_U || Reading_V) begin		
							Read_CSC <= Read_CSC + 6'd1;
							if(Read_CSC == 6'd63) begin
								Read_CBC <= Read_CBC + 6'd1;
								
								if(Read_CBC == 6'd19) begin
									Read_CBC <= 6'd0;
								end
								Read_CS_en <= 1'b0;
								
							end
							
							if((Read_CBC == 6'd19) && (Read_CSC == 6'd63)) begin
								Read_RBC <= Read_RBC + 5'd1;
								if(Read_RBC == 5'd30) begin
									Read_RBC <= 5'd0;
								end
							end
							
							SRAM_address <= Read_UV_address;	//Pass Calculated UV Address
						end
					end
						
					//Writing
					if((Read_CSC > 6'd2) ) begin									//When first value is in SRAM_read_data
						Fetch_buf <= SRAM_read_data; 								//buffer first value
						SPrime_we_en <= ~SPrime_we_en;							//Toggle write_en to write every 2cc
						if((!SPrime_we_en) && (Read_CSC != 6'd3)) begin		//Increment address if reading
							address_0_a <= address_0_a + 7'd1;
						end
						
						write_enable_0_a <= ~write_enable_0_a;
					end
					
				end
				else begin		//Extra CCs for writing last values
					//State Transition conditions
					Inter_State_Count <= Inter_State_Count + 3'd1;
					if(Inter_State_Count == 3'd2) begin
						//M2_state <= M2_Mega_CT;			//XX
						Inter_State_Count <= 3'd0;
					end
					
					//Writing 
					Fetch_buf <= SRAM_read_data;
					SPrime_we_en <= ~SPrime_we_en;
					if(!SPrime_we_en) begin
						address_0_a <= address_0_a + 7'd1;
					end
						
					if(address_0_a == 6'd31) begin	//END OF BLOCK
						write_enable_0_a <= 1'b0;	//reset back to reading
						address_0_a <= 7'd0;
						Read_Fs_en <= 1'b0;
					end
					else
						write_enable_0_a <= ~write_enable_0_a;
					
				end
			end
				
		end
		
	end

end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~` TOP FSM COMBINATIONAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

always_comb begin
	Read_RA = 8'd0;
	Read_CA = 9'd0;
	Read_address_RA_1 = 18'd0;
	Read_address_RA_2 = 18'd0;
	Read_address_CA = 18'd0;
	Read_Y_address = 18'd0;
	Read_UV_address = 18'd0;
	
	select1_C = 6'd0;
	select2_C = 6'd0;
	select3_C = 6'd0;
	Mult_op_1 = 32'd0;
	Mult_op_2 = 32'd0;
	Mult_op_3 = 32'd0;
	Mult_op_4 = 32'd0;
	Mult_op_5 = 32'd0;
	Mult_op_6 = 32'd0;
	
	write_data_0_a = 32'd0;
	write_data_0_b = 32'd0;
	write_data_1_a = 32'd0;
	write_data_2_a = 32'd0;
	T_final = 32'd0;
	S_final = 32'd0;
	
	Write_RA = 8'd0;
	Write_CA = 8'd0;
	Write_address_RA_1 = 18'd0;
	Write_address_RA_2 = 18'd0;
	Write_address_CA = 18'd0;
	Write_Y_address = 18'd0;
	
	SRAM_write_data = 16'd0;
	
	//~~~~~~~~~~~ Milestone 2 Cases ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	case (M2_state)
			M2_IDLE: begin
			end
			M2_LIN_Fetch: begin
			
				Read_RA = {Read_RBC,Read_CSC[5:3]};
				Read_CA = {Read_CBC,Read_CSC[2:0]};
				
				Read_address_RA_1 = {2'd0,Read_RA,8'd0};
				Read_address_RA_2 = {4'd0,Read_RA,6'd0};
				Read_address_CA = {9'd0,Read_CA};
				
				Read_Y_address = Read_address_RA_1 + Read_address_RA_2 + Read_address_CA + 17'd76800;
					
				
				if(SPrime_we_en) begin	//2 values fetched --> write to RAM0
					write_data_0_a = {Fetch_buf,SRAM_read_data};
				end
				
			end
			
			M2_LIN_CT_0: begin
				select1_C = 6'd0 + {3'd0, col_count};
				Mult_op_1 = {{16{read_data_0_a[31]}}, read_data_0_a [31:16]};
				Mult_op_2 = C1;
				
				select2_C = 6'd8 + {3'd0, col_count};
				Mult_op_3 = {{16{read_data_0_a[15]}}, read_data_0_a [15:0]};
				Mult_op_4 = C2;
				
				select3_C = 6'd16 + {3'd0, col_count};
				Mult_op_5 = {{16{read_data_0_b[31]}}, read_data_0_b [31:16]};
				Mult_op_6 = C3;
				
			end
			M2_LIN_CT_1: begin
			
				select1_C = 6'd24 + {3'd0, col_count};
				Mult_op_1 = {{16{pre_S_buf[15]}}, pre_S_buf};
				Mult_op_2 = C1;
				
				select2_C = 6'd32 + {3'd0, col_count};
				Mult_op_3 = {{16{read_data_0_a[31]}}, read_data_0_a [31:16]};
				Mult_op_4 = C2;
				
				select3_C = 6'd40 + {3'd0, col_count};
				Mult_op_5 = {{16{read_data_0_a[15]}}, read_data_0_a [15:0]};
				Mult_op_6 = C3;
				
			end
			
			M2_LIN_CT_2: begin
				
				select1_C = 6'd48 + {3'd0, col_count};
				Mult_op_1 = {{16{read_data_0_b[31]}}, read_data_0_b [31:16]};
				Mult_op_2 = C1;
				
				select2_C = 6'd56 + {3'd0, col_count};
				Mult_op_3 = {{16{read_data_0_b[15]}}, read_data_0_b [15:0]};
				Mult_op_4 = C2;
				
				T_final = T + Mult_1_result + Mult_2_result;
				write_data_1_a = {{8{T_final[31]}}, T_final[31:8]};
				write_data_2_a = {{8{T_final[31]}}, T_final[31:8]};
			end
			
			M2_Mega_CS_0: begin
				
				select1_C = 6'd0 + {3'd0, C_Transpose_Count};
				Mult_op_1 = read_data_1_a;
				Mult_op_2 = C1;
				
				select2_C = 6'd8 + {3'd0, C_Transpose_Count};
				Mult_op_3 = read_data_1_b;
				Mult_op_4 = C2;
				
				select3_C = 6'd16 + {3'd0, C_Transpose_Count};
				Mult_op_5 = read_data_2_a;
				Mult_op_6 = C3;
			end
			M2_Mega_CS_1: begin
				
				select1_C = 6'd24 + {3'd0, C_Transpose_Count};
				Mult_op_1 = read_data_1_a;
				Mult_op_2 = C1;
				
				select2_C = 6'd32 + {3'd0, C_Transpose_Count};
				Mult_op_3 = read_data_1_b;
				Mult_op_4 = C2;
				
				select3_C = 6'd40 + {3'd0, C_Transpose_Count};
				Mult_op_5 = read_data_2_a;
				Mult_op_6 = C3;
			end
			M2_Mega_CS_2: begin
				
				select1_C = 6'd48 + {3'd0, C_Transpose_Count};
				Mult_op_1 = read_data_1_a;
				Mult_op_2 = C1;
				
				select2_C = 6'd56 + {3'd0, C_Transpose_Count};
				Mult_op_3 = read_data_1_b;
				Mult_op_4 = C2;
				
				S_final = S + Mult_1_result + Mult_2_result;
				
				write_data_0_b = (S_final[31]) ? 32'd0: ((S_final[30:24] == 7'd0) ? S_final[23:16] : 8'd255);
			end
			M2_Mega_CT: begin
				
				case(Mega_CT_INNER)
					/*
					INNER_Mega_CT_PREP: begin
					
					end*/
					INNER_Mega_CT_0: begin
						select1_C = 6'd0 + {3'd0, col_count};
						Mult_op_1 = {{16{read_data_0_a[31]}}, read_data_0_a [31:16]};
						Mult_op_2 = C1;
				
						select2_C = 6'd8 + {3'd0, col_count};
						Mult_op_3 = {{16{read_data_0_a[15]}}, read_data_0_a [15:0]};
						Mult_op_4 = C2;
				
						select3_C = 6'd16 + {3'd0, col_count};
						Mult_op_5 = {{16{read_data_0_b[31]}}, read_data_0_b [31:16]};
						Mult_op_6 = C3;
					end
					INNER_Mega_CT_1: begin
						
						select1_C = 6'd24 + {3'd0, col_count};
						Mult_op_1 = {{16{pre_S_buf[15]}}, pre_S_buf};
						Mult_op_2 = C1;
						
						select2_C = 6'd32 + {3'd0, col_count};
						Mult_op_3 = {{16{read_data_0_a[31]}}, read_data_0_a [31:16]};
						Mult_op_4 = C2;
						
						select3_C = 6'd40 + {3'd0, col_count};
						Mult_op_5 = {{16{read_data_0_a[15]}}, read_data_0_a [15:0]};
						Mult_op_6 = C3;
						
					end
					INNER_Mega_CT_2: begin
					
						select1_C = 6'd48 + {3'd0, col_count};
						Mult_op_1 = {{16{CT_data_buf[31]}}, CT_data_buf [31:16]};
						Mult_op_2 = C1;
						
						select2_C = 6'd56 + {3'd0, col_count};
						Mult_op_3 = {{16{CT_data_buf[15]}}, CT_data_buf [15:0]};
						Mult_op_4 = C2;
						
						T_final = T + Mult_1_result + Mult_2_result;
						write_data_1_a = {{8{T_final[31]}}, T_final[31:8]};
						write_data_2_a = {{8{T_final[31]}}, T_final[31:8]};
						
						
						SRAM_write_data = {read_data_0_a[7:0], read_data_0_b[7:0]};
						
					end
				endcase
				
				if(Write_CS_en) begin
					if(Writing_Y) begin
						Write_RA = {Write_RBC,Write_CSC[4:2]};
						Write_CA = {Write_CBC,Write_CSC[1:0]};
						
						Write_address_RA_1 = {3'd0,Write_RA,7'd0};
						Write_address_RA_2 = {5'd0,Write_RA,5'd0};
						Write_address_CA = {10'd0,Write_CA};
						
						Write_Y_address = Write_address_RA_1 + Write_address_RA_2 + Write_address_CA;
					end
					else begin
						if(Writing_U || Writing_V) begin
							Write_RA = {Write_RBC,Write_CSC[4:2]};
							Write_CA = {Write_CBC,Write_CSC[1:0]};
							
							Write_address_RA_1 = {4'd0,Write_RA,6'd0};
							Write_address_RA_2 = {6'd0,Write_RA,4'd0};
							Write_address_CA = {10'd0,Write_CA};
							
							if(Writing_U) 
								Write_Y_address = Write_address_RA_1 + Write_address_RA_2 + Write_address_CA + 16'd38400;
							else if(Writing_V)
								Write_Y_address = Write_address_RA_1 + Write_address_RA_2 + Write_address_CA + 16'd57600;
						end
						
					end
				end
				
			end
			M2_LOUT_WS: begin
			end
		
		
	endcase
	
	if((M2_state == M2_Mega_CS_2) || (M2_state == M2_Mega_CS_1) 
			|| (M2_state == M2_Mega_CS_0)) begin
			// ~~~~~~~ Read F(k+1) For Y ~~~~~~~~
			
			if(Read_Fs_en) begin
				if(Reading_Y) begin
					Read_RA = {Read_RBC,Read_CSC[5:3]};
					Read_CA = {Read_CBC,Read_CSC[2:0]};
					
					Read_address_RA_1 = {2'd0,Read_RA,8'd0};
					Read_address_RA_2 = {4'd0,Read_RA,6'd0};
					Read_address_CA = {9'd0,Read_CA};
					
					Read_Y_address = Read_address_RA_1 + Read_address_RA_2 + Read_address_CA + 17'd76800;
					
					
					if(SPrime_we_en) begin	//2 values fetched --> write to RAM0
						write_data_0_a = {Fetch_buf,SRAM_read_data};
					end
				end
				else begin	// ~~~~~~~ Read F(k+1) For U/V ~~~~~~~~
					if(Reading_U || Reading_V) begin
						Read_RA = {Read_RBC,Read_CSC[5:3]};
						Read_CA = {Read_CBC,Read_CSC[2:0]};
						
						Read_address_RA_1 = {3'd0,Read_RA,7'd0};
						Read_address_RA_2 = {5'd0,Read_RA,5'd0};
						Read_address_CA = {9'd0,Read_CA};
						
						if(Reading_U)
							Read_UV_address = Read_address_RA_1 + Read_address_RA_2 + Read_address_CA + 18'd153600;
						else if (Reading_V)
							Read_UV_address = Read_address_RA_1 + Read_address_RA_2 + Read_address_CA + 18'd192000;
						
						if(SPrime_we_en) begin	//2 values fetched --> write to RAM0
							write_data_0_a = {Fetch_buf,SRAM_read_data};
						end
					end
				end
			end
	end
	
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~ MUX for C Matrix ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
always_comb begin
	case (select1_C)
		6'd0: C1 = 32'd1448;
		6'd1: C1 = 32'd1448;
		6'd2: C1 = 32'd1448;
		6'd3: C1 = 32'd1448;
		6'd4: C1 = 32'd1448;
		6'd5: C1 = 32'd1448;
		6'd6: C1 = 32'd1448;
		6'd7: C1 = 32'd1448;
		6'd8: C1 = 32'd2008;
		6'd9: C1 = 32'd1702;
		6'd10: C1 = 32'd1137;
		6'd11: C1 = 32'd399;
		6'd12: C1 = -32'd399;
		6'd13: C1 = -32'd1137;
		6'd14: C1 = -32'd1702;
		6'd15: C1 = -32'd2008;
		6'd16: C1 = 32'd1892;
		6'd17: C1 = 32'd783;
		6'd18: C1 = -32'd783;
		6'd19: C1 = -32'd1892;
		6'd20: C1 = -32'd1892;
		6'd21: C1 = -32'd783;
		6'd22: C1 = 32'd783;
		6'd23: C1 = 32'd1892;
		6'd24: C1 = 32'd1702;
		6'd25: C1 = -32'd399;
		6'd26: C1 = -32'd2008;
		6'd27: C1 = -32'd1137;
		6'd28: C1 = 32'd1137;
		6'd29: C1 = 32'd2008;
		6'd30: C1 = 32'd399;
		6'd31: C1 = -32'd1702;
		6'd32: C1 = 32'd1448;
		6'd33: C1 = -32'd1448;
		6'd34: C1 = -32'd1448;
		6'd35: C1 = 32'd1448;
		6'd36: C1 = 32'd1448;
		6'd37: C1 = -32'd1448;
		6'd38: C1 = -32'd1448;
		6'd39: C1 = 32'd1448;
		6'd40: C1 = 32'd1137;
		6'd41: C1 = -32'd2008;
		6'd42: C1 = 32'd399;
		6'd43: C1 = 32'd1702;
		6'd44: C1 = -32'd1702;
		6'd45: C1 = -32'd399;
		6'd46: C1 = 32'd2008;
		6'd47: C1 = -32'd1137;
		6'd48: C1 = 32'd783;
		6'd49: C1 = -32'd1892;
		6'd50: C1 = 32'd1892;
		6'd51: C1 = -32'd783;
		6'd52: C1 = -32'd783;
		6'd53: C1 = 32'd1892;
		6'd54: C1 = -32'd1892;
		6'd55: C1 = 32'd783;
		6'd56: C1 = 32'd399;
		6'd57: C1 = -32'd1137;
		6'd58: C1 = 32'd1702;
		6'd59: C1 = -32'd2008;
		6'd60: C1 = 32'd2008;
		6'd61: C1 = -32'd1702;
		6'd62: C1 = 32'd1137;
		6'd63: C1 = -32'd399;
	endcase
	case (select2_C)
		6'd0: C2 = 32'd1448;
		6'd1: C2 = 32'd1448;
		6'd2: C2 = 32'd1448;
		6'd3: C2 = 32'd1448;
		6'd4: C2 = 32'd1448;
		6'd5: C2 = 32'd1448;
		6'd6: C2 = 32'd1448;
		6'd7: C2 = 32'd1448;
		6'd8: C2 = 32'd2008;
		6'd9: C2 = 32'd1702;
		6'd10: C2 = 32'd1137;
		6'd11: C2 = 32'd399;
		6'd12: C2 = -32'd399;
		6'd13: C2 = -32'd1137;
		6'd14: C2 = -32'd1702;
		6'd15: C2 = -32'd2008;
		6'd16: C2 = 32'd1892;
		6'd17: C2 = 32'd783;
		6'd18: C2 = -32'd783;
		6'd19: C2 = -32'd1892;
		6'd20: C2 = -32'd1892;
		6'd21: C2 = -32'd783;
		6'd22: C2 = 32'd783;
		6'd23: C2 = 32'd1892;
		6'd24: C2 = 32'd1702;
		6'd25: C2 = -32'd399;
		6'd26: C2 = -32'd2008;
		6'd27: C2 = -32'd1137;
		6'd28: C2 = 32'd1137;
		6'd29: C2 = 32'd2008;
		6'd30: C2 = 32'd399;
		6'd31: C2 = -32'd1702;
		6'd32: C2 = 32'd1448;
		6'd33: C2 = -32'd1448;
		6'd34: C2 = -32'd1448;
		6'd35: C2 = 32'd1448;
		6'd36: C2 = 32'd1448;
		6'd37: C2 = -32'd1448;
		6'd38: C2 = -32'd1448;
		6'd39: C2 = 32'd1448;
		6'd40: C2 = 32'd1137;
		6'd41: C2 = -32'd2008;
		6'd42: C2 = 32'd399;
		6'd43: C2 = 32'd1702;
		6'd44: C2 = -32'd1702;
		6'd45: C2 = -32'd399;
		6'd46: C2 = 32'd2008;
		6'd47: C2 = -32'd1137;
		6'd48: C2 = 32'd783;
		6'd49: C2 = -32'd1892;
		6'd50: C2 = 32'd1892;
		6'd51: C2 = -32'd783;
		6'd52: C2 = -32'd783;
		6'd53: C2 = 32'd1892;
		6'd54: C2 = -32'd1892;
		6'd55: C2 = 32'd783;
		6'd56: C2 = 32'd399;
		6'd57: C2 = -32'd1137;
		6'd58: C2 = 32'd1702;
		6'd59: C2 = -32'd2008;
		6'd60: C2 = 32'd2008;
		6'd61: C2 = -32'd1702;
		6'd62: C2 = 32'd1137;
		6'd63: C2 = -32'd399;
	endcase
	case (select3_C)
		6'd0: C3 = 32'd1448;
		6'd1: C3 = 32'd1448;
		6'd2: C3 = 32'd1448;
		6'd3: C3 = 32'd1448;
		6'd4: C3 = 32'd1448;
		6'd5: C3 = 32'd1448;
		6'd6: C3 = 32'd1448;
		6'd7: C3 = 32'd1448;
		6'd8: C3 = 32'd2008;
		6'd9: C3 = 32'd1702;
		6'd10: C3 = 32'd1137;
		6'd11: C3 = 32'd399;
		6'd12: C3 = -32'd399;
		6'd13: C3 = -32'd1137;
		6'd14: C3 = -32'd1702;
		6'd15: C3 = -32'd2008;
		6'd16: C3 = 32'd1892;
		6'd17: C3 = 32'd783;
		6'd18: C3 = -32'd783;
		6'd19: C3 = -32'd1892;
		6'd20: C3 = -32'd1892;
		6'd21: C3 = -32'd783;
		6'd22: C3 = 32'd783;
		6'd23: C3 = 32'd1892;
		6'd24: C3 = 32'd1702;
		6'd25: C3 = -32'd399;
		6'd26: C3 = -32'd2008;
		6'd27: C3 = -32'd1137;
		6'd28: C3 = 32'd1137;
		6'd29: C3 = 32'd2008;
		6'd30: C3 = 32'd399;
		6'd31: C3 = -32'd1702;
		6'd32: C3 = 32'd1448;
		6'd33: C3 = -32'd1448;
		6'd34: C3 = -32'd1448;
		6'd35: C3 = 32'd1448;
		6'd36: C3 = 32'd1448;
		6'd37: C3 = -32'd1448;
		6'd38: C3 = -32'd1448;
		6'd39: C3 = 32'd1448;
		6'd40: C3 = 32'd1137;
		6'd41: C3 = -32'd2008;
		6'd42: C3 = 32'd399;
		6'd43: C3 = 32'd1702;
		6'd44: C3 = -32'd1702;
		6'd45: C3 = -32'd399;
		6'd46: C3 = 32'd2008;
		6'd47: C3 = -32'd1137;
		6'd48: C3 = 32'd783;
		6'd49: C3 = -32'd1892;
		6'd50: C3 = 32'd1892;
		6'd51: C3 = -32'd783;
		6'd52: C3 = -32'd783;
		6'd53: C3 = 32'd1892;
		6'd54: C3 = -32'd1892;
		6'd55: C3 = 32'd783;
		6'd56: C3 = 32'd399;
		6'd57: C3 = -32'd1137;
		6'd58: C3 = 32'd1702;
		6'd59: C3 = -32'd2008;
		6'd60: C3 = 32'd2008;
		6'd61: C3 = -32'd1702;
		6'd62: C3 = 32'd1137;
		6'd63: C3 = -32'd399;
	endcase	

end


endmodule


