`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
	S_IDLE,
	S_UART_RX,
	S_Milestone1,
	S_Milestone2
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

typedef enum logic [5:0] {
	M1_IDLE,	//0
	L_IN_0, 	//1
	L_IN_1, 	//2
	L_IN_2, 	//3
	L_IN_3, 	//4
	L_IN_4, 	//5
	L_IN_5, 	
	L_IN_6, 
	L_IN_7, 
	L_IN_8, 
	L_IN_9, 
	L_IN_10,
	L_IN_11, 
	L_IN_12,
	L_IN_13,	//14
	CC1_0, 	//15
	CC1_1, 
	CC1_2,
	CC1_3,	
	CC1_4, 
	CC1_5, 
	CC1_6, 
	CC1_7, 
	CC1_8, 	//23
	CC2_0,	//24
	CC2_1,
	CC2_2,
	CC2_3,
	CC2_4,
	CC2_5,
	CC2_6,
	CC2_7,
	CC2_8	//32
} M1_state_type;

typedef enum logic [5:0] {
	M2_IDLE,
	M2_LIN_Fetch,
	M2_LIN_CT_PREP,
	M2_LIN_CT_0,
	M2_LIN_CT_1,
	M2_LIN_CT_2,
	M2_Mega_CS_PREP,
	M2_Mega_CS_0,
	M2_Mega_CS_1,
	M2_Mega_CS_2,
	M2_Mega_CT,
	M2_LOUT_WS
} M2_state_type;

typedef enum logic [1:0] {
	INNER_Mega_CT_PREP,
	INNER_Mega_CT_0,
	INNER_Mega_CT_1,
	INNER_Mega_CT_2
} Mega_CT_INNER_type;

parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif
