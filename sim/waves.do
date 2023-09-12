# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
#add wave UUT/M1_state
add wave -bin UUT/Milestone2_Unit/Reading_Y
add wave -bin UUT/Milestone2_Unit/Reading_U
add wave -bin UUT/Milestone2_Unit/Reading_V
add wave -uns UUT/Milestone2_Unit/M2_state
add wave -uns UUT/Milestone2_Unit/Mega_CT_INNER
#add wave -uns UUT/UART_timer

add wave -divider -height 10 {M2 LIN CT}
add wave -uns UUT/Milestone2_Unit/select1_C
add wave -uns UUT/Milestone2_Unit/select2_C
add wave -uns UUT/Milestone2_Unit/select3_C
add wave -decimal UUT/Milestone2_Unit/C1
add wave -decimal UUT/Milestone2_Unit/C2
add wave -decimal UUT/Milestone2_Unit/C3

add wave -divider -height 10 {M2 LIN CT}
add wave -uns UUT/Milestone2_Unit/CT_address_INC
add wave -uns UUT/Milestone2_Unit/element_count
add wave -uns UUT/Milestone2_Unit/col_count
add wave -uns UUT/Milestone2_Unit/pre_S_buf
add wave -decimal UUT/Milestone2_Unit/T
add wave -decimal UUT/Milestone2_Unit/T_final
add wave -uns UUT/Milestone2_Unit/T_col_count
add wave -hex UUT/Milestone2_Unit/CT_data_buf
add wave -decimal UUT/Milestone2_Unit/S
add wave -decimal UUT/Milestone2_Unit/S_final


add wave -divider -height 10 {M2 LIN CT}
add wave -decimal UUT/Milestone2_Unit/Mult_op_1
add wave -decimal UUT/Milestone2_Unit/Mult_op_2
add wave -decimal UUT/Milestone2_Unit/Mult_op_3
add wave -decimal UUT/Milestone2_Unit/Mult_op_4
add wave -decimal UUT/Milestone2_Unit/Mult_op_5
add wave -decimal UUT/Milestone2_Unit/Mult_op_6
add wave -decimal UUT/Milestone2_Unit/Mult_1_result
add wave -decimal UUT/Milestone2_Unit/Mult_1_result_long
add wave -decimal UUT/Milestone2_Unit/Mult_2_result
add wave -decimal UUT/Milestone2_Unit/Mult_2_result_long
add wave -decimal UUT/Milestone2_Unit/Mult_3_result
add wave -decimal UUT/Milestone2_Unit/Mult_3_result_long

add wave -divider -height 10 {Dual Port RAM 0 Port A}
add wave -uns UUT/Milestone2_Unit/address_0_a
add wave -hex UUT/Milestone2_Unit/write_data_0_a
add wave -bin UUT/Milestone2_Unit/write_enable_0_a
add wave -hex UUT/Milestone2_Unit/read_data_0_a

add wave -divider -height 10 {Dual Port RAM 0 Port B}
add wave -uns UUT/Milestone2_Unit/address_0_b
add wave -hex UUT/Milestone2_Unit/write_data_0_b
add wave -bin UUT/Milestone2_Unit/write_enable_0_b
add wave -hex UUT/Milestone2_Unit/read_data_0_b

add wave -divider -height 10 {Dual Port RAM 1 Port A}
add wave -uns UUT/Milestone2_Unit/address_1_a
add wave -decimal UUT/Milestone2_Unit/write_data_1_a
add wave -bin UUT/Milestone2_Unit/write_enable_1_a
add wave -decimal UUT/Milestone2_Unit/read_data_1_a

add wave -divider -height 10 {Dual Port RAM 1 Port B}
add wave -uns UUT/Milestone2_Unit/address_1_b
add wave -uns UUT/Milestone2_Unit/write_data_1_b
add wave -bin UUT/Milestone2_Unit/write_enable_1_b
add wave -decimal UUT/Milestone2_Unit/read_data_1_b

add wave -divider -height 10 {Dual Port RAM 2 Port A}
add wave -uns UUT/Milestone2_Unit/address_2_a
add wave -uns UUT/Milestone2_Unit/write_data_2_a
add wave -bin UUT/Milestone2_Unit/write_enable_2_a
add wave -decimal UUT/Milestone2_Unit/read_data_2_a

add wave -divider -height 10 {Dual Port RAM 2 Port B}
add wave -uns UUT/Milestone2_Unit/address_2_b
add wave -uns UUT/Milestone2_Unit/write_data_2_b
add wave -bin UUT/Milestone2_Unit/write_enable_2_b
add wave -decimal UUT/Milestone2_Unit/read_data_2_b
###########
add wave -divider -height 10 {M2 Fetch Signals}
add wave -uns UUT/Milestone2_Unit/Read_CSC
add wave -uns UUT/Milestone2_Unit/Read_CBC
add wave -uns UUT/Milestone2_Unit/Read_RBC
add wave -bin UUT/Milestone2_Unit/Read_CS_en
add wave -bin UUT/Milestone2_Unit/Read_Fs_en
add wave -uns UUT/Milestone2_Unit/Read_RA
add wave -uns UUT/Milestone2_Unit/Read_CA
add wave -uns UUT/Milestone2_Unit/Read_address_RA_1
add wave -uns UUT/Milestone2_Unit/Read_address_RA_2
add wave -uns UUT/Milestone2_Unit/Read_address_CA

add wave -divider -height 10 {M2 Fetch Signals}
add wave -uns UUT/Milestone2_Unit/Read_Y_address
add wave -uns UUT/Milestone2_Unit/Read_UV_address
add wave -hex UUT/Milestone2_Unit/Fetch_buf
add wave -hex UUT/Milestone2_Unit/Inter_State_Count
add wave -uns UUT/Milestone2_Unit/SPrime_we_en

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
#add wave -uns UUT/SRAM_address_Y
#add wave -uns UUT/SRAM_address_U
#add wave -uns UUT/SRAM_address_V
#add wave -uns UUT/SRAM_address_RGB
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

add wave -divider -height 10 {M2 Fetch Signals}
add wave -uns UUT/Milestone2_Unit/Write_SRead_INC
add wave -uns UUT/Milestone2_Unit/Write_CSC
add wave -uns UUT/Milestone2_Unit/Write_CBC
add wave -uns UUT/Milestone2_Unit/Write_RBC
add wave -bin UUT/Milestone2_Unit/Write_CS_en
add wave -bin UUT/Milestone2_Unit/first_write
add wave -uns UUT/Milestone2_Unit/Write_RA
add wave -uns UUT/Milestone2_Unit/Write_CA
add wave -uns UUT/Milestone2_Unit/Write_address_RA_1
add wave -uns UUT/Milestone2_Unit/Write_address_RA_2
add wave -uns UUT/Milestone2_Unit/Write_address_CA
add wave -uns UUT/Milestone2_Unit/Write_Y_address

add wave -divider -height 10 {M2 Wiritn}
add wave -uns UUT/Milestone2_Unit/Writing_Y
add wave -uns UUT/Milestone2_Unit/Writing_U
add wave -uns UUT/Milestone2_Unit/Writing_V

add wave -divider -height 10 {M2 LIN CT}
#add wave -uns UUT/Milestone2_Unit/element_count
#add wave -uns UUT/Milestone2_Unit/matrix_counter
#add wave -uns UUT/Milestone2_Unit/col_count
#add wave -uns UUT/Milestone2_Unit/pre_S_buf
#add wave -decimal UUT/Milestone2_Unit/T
#add wave -decimal UUT/Milestone2_Unit/T_final
#add wave -uns UUT/Milestone2_Unit/i
#add wave -uns UUT/Milestone2_Unit/j
#add wave -uns UUT/Milestone2_Unit/k
####################
#add wave -divider -height 10 {Counters}
#add wave -uns UUT/col_count
#add wave -uns UUT/row_count
#add wave -uns UUT/M1_start
#add wave -uns UUT/M1_finish

#add wave -divider -height 10 {Mult}
#add wave -uns UUT/Mult_1_result
#add wave -uns UUT/Mult_2_result
#add wave -uns UUT/Mult_1_result_long
#add wave -uns UUT/Mult_2_result_long
#add wave -uns UUT/Mult_op_1
#add wave -uns UUT/Mult_op_2
#add wave -uns UUT/Mult_op_3
#add wave -uns UUT/Mult_op_4

#add wave -divider -height 10 {Mult}
#add wave -hex UUT/Mult_1_result
#add wave -hex UUT/Mult_2_result
#add wave -hex UUT/Mult_1_result_long
#add wave -hex UUT/Mult_2_result_long
#add wave -hex UUT/Mult_op_1
#add wave -hex UUT/Mult_op_2
#add wave -hex UUT/Mult_op_3
#add wave -hex UUT/Mult_op_4

#add wave -divider -height 10 {YUV Signals}
#add wave -hex UUT/Y_Reg
#add wave -hex UUT/U_Reg
#add wave -hex UUT/V_Reg
#add wave -hex UUT/Y_buf
#add wave -hex UUT/U_buf
#add wave -hex UUT/V_buf

#add wave -divider -height 10 {YUV Signals}
#add wave -hex UUT/R_Reg
#add wave -hex UUT/G_Reg
#add wave -hex UUT/B_Reg
#add wave -hex UUT/B_buf
#add wave -hex UUT/R_O
#add wave -hex UUT/G_O
#add wave -hex UUT/B_O

#add wave -divider -height 10 {UV Signals}
#add wave -hex UUT/U_ACC
#add wave -hex UUT/U_shift_reg
#add wave -hex UUT/V_ACC
#add wave -hex UUT/V_shift_reg

add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue

