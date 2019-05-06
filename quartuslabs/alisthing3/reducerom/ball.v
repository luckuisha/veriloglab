
// Part 2 skeleton 
/*KEY[1] (Plot) is pressed. KEY[2]
should cause the entire screen to be cleared to black (Black). Note that black corresponds to (0,0,0). KEY[0]
should be the system active low Resetn.*/
`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_address_translator.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"
//`include "ROM/Backgrounds/cave/ROM_BG_PONG1.v"

module ball
    (
        SW,
        CLOCK_50,                        //    On Board 50 MHz
        // Your inputs and outputs here
        KEY, 
		HEX0,HEX1, HEX2, HEX3, HEX4, HEX5,
        LEDR,
		  // On Board Keys
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,                           //    VGA Clock
        VGA_HS,                            //    VGA H_SYNC
        VGA_VS,                            //    VGA V_SYNC
        VGA_BLANK_N,                    //    VGA BLANK
        VGA_SYNC_N,                        //    VGA SYNC
        VGA_R,                           //    VGA Red[9:0]
        VGA_G,                             //    VGA Green[9:0]
        VGA_B                           //    VGA Blue[9:0]
    );
    
    input            CLOCK_50;                //    50 MHz
    input    [8:0]   KEY;    
    input     [9:0]  SW;
    output 	[9:0] 	 LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    // Declare your inputs and outputs here
    // Do not change the following outputs
	output            VGA_CLK;                   //    VGA Clock
	output            VGA_HS;                    //    VGA H_SYNC
	output            VGA_VS;                    //    VGA V_SYNC
	output            VGA_BLANK_N;            //    VGA BLANK
	output            VGA_SYNC_N;                //    VGA SYNC
	output    [7:0]    VGA_R;                   //    VGA Red[7:0] Changed from 10 to 8-bit DAC
	output    [7:0]    VGA_G;                     //    VGA Green[7:0]
	output    [7:0]    VGA_B;                   //    VGA Blue[7:0]

	localparam//colour_id

	//////////////////////////begin
	SHAPE_COLOUR_ID		= 5'd0,
	CAVE_COLOUR_ID			= 5'd1,

	BACKGROUND_MAIN_COLOUR_ID		= 5'd2,
	BACKGROUND_1V1_COLOUR_ID		= 5'd3,
	BACKGROUND_TRACKER_COLOUR_ID	= 5'd4,
	BACKGROUND_DRUNK_COLOUR_ID	= 5'd5,
	BACKGROUND_FINALBOSS_COLOUR_ID = 5'd6,

	CHARACTER_DRUNK_COLOUR_ID		= 5'd7,
	CHARACTER_FINALBOSS_COLOUR_ID	= 5'd8,
	CHARACTER_MAIN_COLOUR_ID		= 5'd9,
	TEXT_NOOB_A_COLOUR_ID		= 5'd10,
	TEXT_TRACKER_COLOUR_ID	= 5'd11,
	TEXT_DRUNK_COLOUR_ID		= 5'd12,
	TEXT_FINALBOSS_COLOUR_ID	= 5'd13,
	TEXT_FINAL_COLOUR_ID		= 5'd14;

///////////////////////////end

	wire resetn;
	assign resetn = ~SW[6];
	wire resetGamen;
	assign resetGamen = ~SW[7];
	wire pausen;
	assign pausen = ~SW[1];
	wire [5:0] c_spl,c_spr;
//	assign c[1:0] = {2 {1}};
//	assign c[3:2] = {2{1}};
//	assign c[5:4] = {2{1}};
	wire [8:0] x;  //0-159
	wire [7:0] y;  //0-119
	wire wall, wall_spr, wall_l, wall_r, wall_spr_l, wall_spr_r;
	wire reset,waiting,create,delete,move;
	wire delete_spr,create_spr,move_spr, move_fire_spr , ready_spr;
	wire down_l, down_r, up_l, up_r,speed_l,speed_r,go_l,go_r;
	wire paddle_l,paddle_r,paddle_l_floor, paddle_r_floor,paddle_l_roof, paddle_r_roof;
	wire paddle_spr_l, paddle_spr_r;
	wire resetS, gameOver,main;
	wire writeEn, create_l, create_r, delete_l, delete_r, move_l, move_r; 
	wire [3:0] score_l, score_r;
	wire [8:0] dx, dx_l, dx_r, dx_spr;
	wire [7:0] dy, dy_l, dy_r, dy_spr;
	wire [4:0] counter_ball, counter_spr;
	wire [6:0] counter_paddle_l,counter_paddle_r;
	wire [16:0] counter_background;
	wire [8:0] x_r;
	wire [7:0] y_r;
	wire [5:0] c_o; 	
	wire [2:0] player_id;
	wire [8:0] x_lp, x_rp;
	wire [7:0] y_lp, y_rp;
	wire [7:0] y_diff_left, y_diff_right;
	wire [7:0] y_diff_spr_left, y_diff_spr_right;
	
	wire [1:0] goTime_ai;
	wire [2:0] dy_ai; 
	wire [7:0] dy_spr_ai;
	wire [2:0] ability_rp;
	wire fire;
	wire spr_out;
	
	//assign LEDR[4:0] = current_state_all;
	assign down_l = ~SW[9];
	assign up_l = SW[9];
	//assign down_r = ~SW[0];
	//assign up_r = SW[0];
	//assign go_r = ~KEY[0];
	//assign speed_r = ~KEY[1];
	assign go_l = ~KEY[2];
	assign speed_l = ~KEY[3];
	assign HEX2 = 7'b0111111;
	assign HEX3 = 7'b0111111;
	assign HEX0 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	hex_decoder h1 ( score_r,HEX1 );
	hex_decoder h2 ( score_l,HEX4 );
	
	
	//////////////////////////////////////////////////////////////////////////////begin
	wire [1:0] select;
	assign select = SW[9:8];

	cave_rom lol (
	bg_address ,
	CLOCK_50,
	bg_cave_colour );

/* 	cave_rom lol (
	bg_address ,
	CLOCK_50,
	bg_cave_colour );

	cave_rom lol (
	bg_address ,
	CLOCK_50,
	bg_cave_colour ); 
	
	.
	.
	.
	
	*/
	
	reg [5:0] c_print;
	wire [16:0] bg_address; //wire [16:0] bg_pong1_address;
	wire [14:0] char_address, txt_address;

	wire [5:0] bg_cave_colour;
// FOR INSTANTIATION OF ROMS, USE THESE WIRES
wire [5:0] bg_main_colour;
wire [5:0] bg_1v1_colour;
wire [5:0] bg_tracker_colour;
wire [5:0] bg_drunk_colour;
wire [5:0] bg_finalboss_colour;

wire [5:0] char_drunk_colour;
wire [5:0] char_finalboss_colour;
wire [5:0] char_main_colour;

wire [5:0] txt_noob_a_colour;
wire [5:0] txt_tracker_colour;
wire [5:0] txt_drunk_colour;
wire [5:0] txt_final_colour;
//wire [5:0] txt_
//wire [5:0] txt_add here for more txtboxes
//wire [5:0] txt_
////////////////////////////////////
	wire [4:0] colour_id;
	reg [4:0] colour_id_r;
	wire draw_bg;
	reg [8:0] x_print;
	reg [7:0] y_print;	
	reg writeEn_r;
	reg [5:0] c_o_r; 
	wire plot;
	wire [2:0] background_id;
	wire [1:0] character_id;
	wire [4:0] textbox_id;
	wire draw_txtbox, draw_char;
	wire [8:0]x_char;
	wire [7:0] y_char;
	wire [14:0]counter_character;
	wire [14:0]counter_txtbox;
	reg [3:0]bg_id_r;
	wire [2:0] current_bg_colour_id;
	
	
	always@(posedge CLOCK_50)
	begin
		x_print <= x_r;
		y_print <= y_r;
		c_o_r <= c_o;
		writeEn_r <= writeEn;
		colour_id_r <= colour_id;
		bg_id_r <= background_id;
	end
	

	always @(colour_id_r)
	begin
		case( colour_id_r )
			SHAPE_COLOUR_ID:	c_print = c_o_r;
			CAVE_COLOUR_ID:	c_print = bg_cave_colour;
			CHARACTER_DRUNK_COLOUR_ID: begin
								if( char_finalboss_colour == 6'b001100 )begin
									case ( current_bg_colour_id )
										BACKGROUND_MAIN_COLOUR_ID: 			c_print = bg_main_colour;
										BACKGROUND_1V1_COLOUR_ID:				c_print = bg_1v1_colour;
										BACKGROUND_TRACKER_COLOUR_ID:		c_print = bg_tracker_colour;
										BACKGROUND_DRUNK_COLOUR_ID:			c_print = bg_drunk_colour;
										BACKGROUND_FINALBOSS_COLOUR_ID:	c_print = bg_finalboss_colour;
									endcase
								end
							else c_print = char_finalboss_colour;
						end
			CHARACTER_FINALBOSS_COLOUR_ID: begin
								if( char_finalboss_colour == 6'b001100 )begin
									case ( current_bg_colour_id )
										BACKGROUND_MAIN_COLOUR_ID: 			c_print = bg_main_colour;
										BACKGROUND_1V1_COLOUR_ID:				c_print = bg_1v1_colour;
										BACKGROUND_TRACKER_COLOUR_ID:		c_print = bg_tracker_colour;
										BACKGROUND_DRUNK_COLOUR_ID:			c_print = bg_drunk_colour;
										BACKGROUND_FINALBOSS_COLOUR_ID:	c_print = bg_finalboss_colour;
									endcase
								end
							else c_print = char_finalboss_colour;
						end
			CHARACTER_MAIN_COLOUR_ID: begin
									if( char_finalboss_colour == 6'b001100 )begin
									case ( current_bg_colour_id )
										BACKGROUND_MAIN_COLOUR_ID: 			c_print = bg_main_colour;
										BACKGROUND_1V1_COLOUR_ID:				c_print = bg_1v1_colour;
										BACKGROUND_TRACKER_COLOUR_ID:		c_print = bg_tracker_colour;
										BACKGROUND_DRUNK_COLOUR_ID:			c_print = bg_drunk_colour;
										BACKGROUND_FINALBOSS_COLOUR_ID:	c_print = bg_finalboss_colour;
									endcase
								end
							else c_print = char_finalboss_colour;
						end
			BACKGROUND_MAIN_COLOUR_ID:						c_print = bg_main_colour;
			BACKGROUND_1V1_COLOUR_ID:							c_print = bg_1v1_colour;
			BACKGROUND_TRACKER_COLOUR_ID:					c_print = bg_tracker_colour;
			BACKGROUND_DRUNK_COLOUR_ID:						c_print = bg_drunk_colour;
			BACKGROUND_FINALBOSS_COLOUR_ID:				c_print = bg_finalboss_colour;
			TEXT_NOOB_A_COLOUR_ID:								c_print = txt_noob_a_colour;
			TEXT_TRACKER_COLOUR_ID:								c_print = txt_tracker_colour;
			TEXT_DRUNK_COLOUR_ID:									c_print = txt_drunk_colour;
			TEXT_FINALBOSS_COLOUR_ID:							c_print = txt_final_colour;
			TEXT_FINAL_COLOUR_ID:									c_print = txt_final_colour;
			default:	c_print = bg_cave_colour;
	endcase
	end 
	//////////////////////////////////////////////////////////////////////////////end
	
	bosses b0(	CLOCK_50,	
				paddle_l, paddle_r,
				x, dx, x_lp, x_rp, 
				y, dy, y_lp, y_rp, dy_l,
				player_id, 
				SW[0], ~SW[0], ~KEY[0], ~KEY[1],
				score_l, score_r,
				resetn,
				ready_spr,
				go_r, speed_r, up_r, down_r, 
				goTime_ai, 
				dy_ai, 
				LEDR[4:0], ability_rp, fire, dy_spr_ai);
				
    control c0(
			 ability_rp,
				CLOCK_50, down_l, down_r, up_l, up_r,speed_l,speed_r,go_l,go_r,
				goTime_ai,
				dy_ai,
				dy_spr_ai,
				fire,
				resetn, resetGamen, pausen,
				paddle_l,paddle_r,
				paddle_spr_l, paddle_spr_r,
				paddle_l_floor, paddle_r_floor,
				paddle_l_roof, paddle_r_roof, 
				wall, wall_spr, wall_l, wall_r, wall_spr_l, wall_spr_r, 
				y_diff_left , y_diff_spr_left, y_diff_right , y_diff_spr_right,
				dx, dx_l, dx_r, dx_spr, 
				dy, dy_l, dy_r, dy_spr,
				reset, resetS, gameOver,main,
				plot,waiting,create,create_l, create_r, 
				counter_ball, counter_spr,
				counter_paddle_l,counter_paddle_r, 
				counter_background,
				delete, delete_l, delete_r,move, move_l, move_r, 
				delete_spr,create_spr,move_spr, move_fire_spr , ready_spr,
				score_l, score_r,
				draw_bg,
				spr_out,
				c_spl,c_spr,
				//////////////////////////////////////////////////////////////////////////////begin
				select,
				background_id, 
				character_id, 
				textbox_id,
				draw_txtbox, draw_char, 
				player_id,
				x_char,
				y_char, 
				counter_character,
				counter_txtbox
				
				//////////////////////////////////////////////////////////////////////////////end
				);
				
	datapath d0(
				CLOCK_50,
				dx, dx_l,dx_r, dx_spr,
				dy,dy_l,dy_r, dy_spr,
				reset,resetS, gameOver,main,
				plot,waiting,create,delete,move, 
				create_l,delete_l, move_l, 
				create_r, delete_r, move_r,
				delete_spr,create_spr,move_spr, move_fire_spr ,
				spr_out,
				counter_ball, counter_spr,
				counter_paddle_l, counter_paddle_r,
				counter_background,
				c_spl,c_spr,
				draw_bg,
				x_r,
				y_r,
				writeEn,
				bg_address,
				c_o,
				colour_id,
				wall, wall_spr,
				wall_l, wall_spr_l,
				wall_r, wall_spr_r,
				paddle_l,paddle_r, paddle_spr_l, paddle_spr_r,
				paddle_l_floor, paddle_r_floor,
				paddle_l_roof, paddle_r_roof,
				x, x_lp, x_rp,
				y, y_lp, y_rp,
				y_diff_left , y_diff_spr_left,
				y_diff_right, y_diff_spr_right,
				//////////////////////////////////////////////////////////////////////////////begin
				background_id, 
				character_id, 
				textbox_id, 
				draw_txtbox, draw_char,
				x_char,
				y_char,
				counter_character, counter_txtbox, 
				current_bg_colour_id, 
				char_address, txt_address
				//////////////////////////////////////////////////////////////////////////////end
				);   
	//////////////////////////////////////////////////////////////////////////////begin
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour( c_print ),
            .x(x_print),
            .y(y_print),
            .plot(writeEn_r),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "320x240";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 2;
        defparam VGA.BACKGROUND_IMAGE = "main2bit.mif";
		//////////////////////////////////////////////////////////////////////////////end
    
endmodule

module control(	input [2:0] ability_rp ,
				input  clk,down_l,down_r,up_l,up_r,speed_l,speed_r,go_l,go_r,
				input [1:0] goTime_ai, //0-3
				input [2:0] dy_ai, //0-5
				input [7:0] dy_spr_ai,
				input fire,
				input resetn, resetGamen, pausen,
				input paddle_l,paddle_r, 
				input paddle_spr_l, paddle_spr_r, 
				input paddle_l_floor, paddle_r_floor, 
				input paddle_l_roof, paddle_r_roof,
				input wall, wall_spr, wall_l, wall_r, wall_spr_l, wall_spr_r,
				input [7:0] y_diff_left, y_diff_spr_left, y_diff_right, y_diff_spr_right,
				output reg [8:0] dx, dx_l, dx_r, dx_spr, 
				output reg [7:0]dy,dy_l,dy_r, dy_spr, 
				output reg reset,resetS,gameOver,main,
				output reg plot,waiting,create,create_l,create_r,
				output reg [4:0] counter_ball, counter_spr,
				output reg [6:0] counter_paddle_l,counter_paddle_r, 
				output reg [16:0] counter_background,
				output reg delete,delete_l,delete_r,move,move_l,move_r,
				output reg delete_spr,create_spr,move_spr, move_fire_spr , ready_spr,
				output reg [3:0] score_l, score_r,
				output reg draw_bg,
				output reg spr_out,
				output reg [5:0] c_spl,c_spr,
				//////////////////////////////////////////////////////////////////////////////begin
				input [1:0] sel,
				output reg [2:0] background_id,
				output reg [1:0] character_id,
				output reg [4:0] textbox_id,
				output reg draw_txtbox, draw_char,
				output reg [2:0] player_id,
				output reg [8:0] x_char,
				output reg [7:0] y_char,
				output reg [14:0]counter_character,
				output reg [14:0]counter_txtbox
					//////////////////////////////////////////////////////////////////////////////end
				);
    
	//////////////////////////////////////////////////////////////////////////////begin localparam
localparam // select
	IDLE = 3'd0,
	PLAY_1V1 = 3'd1,
	STORY = 3'd2,
	STAGES = 3'd3;

localparam // Game SCENARIO
		SCENARIO_STORY_NOOB		= 4'd0,
		SCENARIO_STORY_TRACKER	= 4'd1,
		SCENARIO_STORY_DRUNK	= 4'd2,
		SCENARIO_STORY_FINALBOSS= 4'd3,
		SCENARIO_STORY_FINAL	= 4'd4,
		SCENARIO_PONG_1V1		= 4'd5,
		SCENARIO_PONG_NOOB		= 4'd6,
		SCENARIO_PONG_TRACKER	= 4'd7,
		SCENARIO_PONG_DRUNK		= 4'd8,
		SCENARIO_PONG_FINALBOSS	= 4'd9,
		SCENARIO_MAIN			= 4'd10,
		SCENARIO_SELECT			= 4'd11;

	localparam // Current background ID
		BACKGROUND_MAIN		= 3'd0,
		BACKGROUND_1V1		= 3'd1,
		BACKGROUND_TRACKER	= 3'd2,
		BACKGROUND_DRUNK	= 3'd3,
		BACKGROUND_FINALBOSS= 3'd4;

	localparam // Current character ID	
		CHARACTER_DRUNK		= 2'd0,
		CHARACTER_FINALBOSS	= 2'd1,
		CHARACTER_MAIN		= 2'd2;
	
	localparam // Current Text Box ID
		TEXT_NOOB_A		= 5'd0,
		TEXT_TRACKER	= 5'd1,
		TEXT_DRUNK		= 5'd2,
		TEXT_FINALBOSS	= 5'd3,
		TEXT_FINAL		= 5'd4,
		TEXT_SELECT		= 5'd5;

	localparam // Current player ID
		PLAYER_IDLE		= 3'd0,
		PLAYER_1V1		= 3'd1,
		PLAYER_NOOB		= 3'd2,
		PLAYER_TRACKER	= 3'd3,
		PLAYER_DRUNK	= 3'd4,
		PLAYER_FINALBOSS= 3'd5;

	//////////////////////////////////////////////////////////////////////////////end


	localparam // Game Debuff
		DEBUFF_SLOW			= 3'd1,
		DEBUFF_FREEZE		= 3'd2;
	
	localparam // Ability_rp
		ABILITY_OFF			= 3'd0,
		ABILITY_GREEN		= 3'd1,
		ABILITY_YELLOW		= 3'd2,
		ABILITY_BLUE		= 3'd3,
		ABILITY_RED			= 3'd4;

	
	localparam  //Game Cycles
		GAME_CYCLE_MAIN			= 5'd0,
		
		PONG_CYCLE_START		= 5'd1,
		PONG_CYCLE_START_WAIT	= 5'd2,//NEWwwwwwwwwwwwwwww
		B_CYCLE_D				= 5'd3,
		B_CYCLE_X				= 5'd4,
		B_CYCLE_M				= 5'd5,
		B_CYCLE_C				= 5'd6,
		PONG_CYCLE_WAIT			= 5'd7,
		
		PL_CYCLE_D				= 5'd8,
		PL_CYCLE_X				= 5'd9,
		PL_CYCLE_M				= 5'd10,
		PL_CYCLE_C				= 5'd11,	

		PR_CYCLE_D				= 5'd12,
		PR_CYCLE_X				= 5'd13,
		PR_CYCLE_M				= 5'd14,
		PR_CYCLE_C				= 5'd15,

		PONG_CYCLE_DELETE		= 5'd16,
		PONG_CYCLE_SCORE		= 5'd17,
		PONG_CYCLE_PAUSE		= 5'd18,
		
		PONG_CYCLE_GAMEOVER		= 5'd19,
		GAME_CYCLE_DRAWBG 		= 5'd20,
		
		SPR_CYCLE_D				= 5'd21,
		SPR_CYCLE_C				= 5'd22,
		SPR_CYCLE_M				= 5'd23,
		SPR_CYCLE_FIRE			= 5'd24,
		SPR_CYCLE_X				= 5'd25,

		/////////////////////////////BEGIN

		GAME_CYCLE_SCENARIO		= 5'd26,
		GAME_CYCLE_X			= 5'd27,
		GAME_CYCLE_CHAR			= 5'd28,
		GAME_CYCLE_TXTBOX		= 5'd29,
		GAME_USER_WAIT			= 5'd30,
		GAME_CYCLE_CHOOSE		= 5'd31;

		///////////////////////////////END
		
	reg frame;
	reg [23:0] go_count_ball;
	reg [23:0] go_count_lp;
	reg [23:0] go_count_rp;
	reg [4:0] go_count_spr_debuff;
	reg resetGame,pause;
	reg [4:0]  current_state_all, next_state_all;
/* 	reg [2:0] current_state_left, next_state_left;
	reg [2:0] current_state_right, next_state_right; */	
	reg deleteAll;
	reg check,check_l,check_r;
	reg goTime_ball,goTime_lp,goTime_rp;
	reg [1:0] debuffed_lp; //1 is frozen
	reg goTime_lp_r;
	reg button;
	reg score;
	
	reg [7:0] dy_spr_ai_r;
	reg [2:0] ability_rp_r;

	//////////////////////////////////////////////////////////////////////////////begin
	reg [1:0] sel_r;
	reg [2:0] done;
	reg [3:0] game_scenario_id;
	reg toggle_ability;

	//////////////////////////////////////////////////////////////////////////////end


    always@(*)
        begin: ball_states
			case (current_state_all)
				PL_CYCLE_D:					next_state_all = ( ( counter_paddle_l==7'd64 ) ? ( deleteAll ? PR_CYCLE_D : PL_CYCLE_X ): PL_CYCLE_D );
				PL_CYCLE_X:					next_state_all = PL_CYCLE_M;
				PL_CYCLE_M:					next_state_all = PL_CYCLE_C;
				PL_CYCLE_C:					next_state_all = ( counter_paddle_l==7'd64 ) ? PONG_CYCLE_WAIT : PL_CYCLE_C;
				//PR_CYCLE_WAIT:			next_state_left =!resetGame ? ( ( goTime_ball ) ? ( PL_CYCLE_ d): PL_CYCLE_WAIT ) : PONG_CYCLE_DELETE;
				
				PR_CYCLE_D:					next_state_all = ( ( counter_paddle_r==7'd64 ) ? ( deleteAll ?( ability_rp_r!=0 ? SPR_CYCLE_D : ( score ? PONG_CYCLE_SCORE : PONG_CYCLE_START ) ): PR_CYCLE_X ): PR_CYCLE_D );
				PR_CYCLE_X:					next_state_all = PR_CYCLE_M;
				PR_CYCLE_M:					next_state_all = PR_CYCLE_C;
				PR_CYCLE_C:					next_state_all = ( counter_paddle_r==7'd64 ) ?  ( ( ready_spr == 1 && ability_rp_r != 0 ) ? SPR_CYCLE_D : PONG_CYCLE_WAIT ): PR_CYCLE_C;
				//PR_CYCLE_WAIT:			next_state_all = !resetGame ? ( ( goTime_ball ) ? ( PR_CYCLE_ d): PR_CYCLE_WAIT ) : PONG_CYCLE_DELETE;
				
				B_CYCLE_D:					next_state_all = ( counter_ball==5'd5 ) ? ( deleteAll ? PL_CYCLE_D : B_CYCLE_X ) : B_CYCLE_D;
				B_CYCLE_X:					next_state_all = score ? PONG_CYCLE_WAIT :B_CYCLE_M;
				B_CYCLE_M:					next_state_all = B_CYCLE_C;
				B_CYCLE_C:					next_state_all = ( counter_ball==5'd5 ) ? ( (!ready_spr ) ? SPR_CYCLE_D : PONG_CYCLE_WAIT ) : B_CYCLE_C;
				
				SPR_CYCLE_D:				next_state_all = ( ( counter_spr==5'd5 ) ? ( deleteAll ? ( score ? PONG_CYCLE_SCORE : PONG_CYCLE_START ) : spr_out ? PONG_CYCLE_WAIT : (!ready_spr) ? SPR_CYCLE_X : SPR_CYCLE_M ):  SPR_CYCLE_D );
				SPR_CYCLE_X:				next_state_all = SPR_CYCLE_FIRE;
				SPR_CYCLE_FIRE:				next_state_all = SPR_CYCLE_C;
				SPR_CYCLE_M:				next_state_all = SPR_CYCLE_C;
				SPR_CYCLE_C:				next_state_all = ( counter_spr==5'd5 ) ? PONG_CYCLE_WAIT : SPR_CYCLE_C;
				
				PONG_CYCLE_WAIT:  			next_state_all = (score_r == 4'd11 || score_l == 4'd11) ? PONG_CYCLE_GAMEOVER :( !(score || resetGame) ? ( pause ? PONG_CYCLE_PAUSE :( ( goTime_ball ) ? ( B_CYCLE_D ): ( ( goTime_lp ) ? PL_CYCLE_D : ( ( goTime_rp ) ? PR_CYCLE_D : PONG_CYCLE_WAIT ) ) ) ): PONG_CYCLE_DELETE );
				PONG_CYCLE_DELETE: 			next_state_all = B_CYCLE_D;
				PONG_CYCLE_SCORE:			next_state_all = button ? PONG_CYCLE_WAIT : PONG_CYCLE_SCORE;
				PONG_CYCLE_START:  			next_state_all = PONG_CYCLE_START_WAIT;
				PONG_CYCLE_START_WAIT:		next_state_all = !resetGame ? PONG_CYCLE_WAIT : PONG_CYCLE_START_WAIT;
				PONG_CYCLE_PAUSE:			next_state_all = pause ? PONG_CYCLE_PAUSE : PONG_CYCLE_WAIT ;
				

			//////////////////////////////////////////////////////////////////////////////begin

				GAME_CYCLE_SCENARIO:		next_state_all = GAME_CYCLE_X;
				
				GAME_CYCLE_CHOOSE:			next_state_all = button ? GAME_CYCLE_X : GAME_CYCLE_CHOOSE;

				GAME_CYCLE_MAIN:			case (sel_r) 
												PLAY_1V1:	next_state_all = button ? GAME_CYCLE_X : GAME_CYCLE_MAIN ;
												STORY:	next_state_all = button ? GAME_CYCLE_X : GAME_CYCLE_MAIN;
												STAGES:	next_state_all = button ? GAME_CYCLE_X : GAME_CYCLE_MAIN;
												IDLE:	next_state_all = GAME_CYCLE_MAIN;
											endcase
															
				GAME_CYCLE_X:				case (game_scenario_id)
												SCENARIO_STORY_NOOB:		case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = GAME_CYCLE_TXTBOX;
																				3'd2: next_state_all = GAME_USER_WAIT;
																				3'd3: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd4: next_state_all = PONG_CYCLE_START;
																			endcase
												SCENARIO_STORY_TRACKER:		case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = GAME_CYCLE_TXTBOX;
																				3'd2: next_state_all = GAME_USER_WAIT;
																				3'd3: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd4: next_state_all = PONG_CYCLE_START;
																			endcase
												SCENARIO_STORY_DRUNK:		case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = GAME_CYCLE_CHAR;
																				3'd2: next_state_all = GAME_CYCLE_CHAR;
																				3'd3: next_state_all = GAME_CYCLE_TXTBOX;
																				3'd4: next_state_all = GAME_USER_WAIT;
																				3'd5: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd6: next_state_all = PONG_CYCLE_START;
																				endcase
												SCENARIO_STORY_FINALBOSS:	case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = GAME_CYCLE_CHAR;
																				3'd2: next_state_all = GAME_CYCLE_CHAR;
																				3'd3: next_state_all = GAME_CYCLE_TXTBOX;
																				3'd4: next_state_all = GAME_USER_WAIT;
																				3'd5: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd6: next_state_all = PONG_CYCLE_START;
																			endcase
												SCENARIO_STORY_FINAL:		case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = GAME_CYCLE_CHAR;
																				3'd2: next_state_all = GAME_CYCLE_CHAR;
																				3'd3: next_state_all = GAME_CYCLE_TXTBOX;
																				3'd4: next_state_all = GAME_CYCLE_SCENARIO;
																			endcase
												SCENARIO_PONG_1V1:			case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = PONG_CYCLE_START;
																			endcase
												SCENARIO_PONG_NOOB:			case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = PONG_CYCLE_START;
																			endcase
												SCENARIO_PONG_TRACKER:		case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = PONG_CYCLE_START;
																			endcase
												SCENARIO_PONG_DRUNK:		case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = PONG_CYCLE_START;
																			endcase
												SCENARIO_PONG_FINALBOSS:	case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = PONG_CYCLE_START;
																			endcase
												SCENARIO_MAIN:				case (done)
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = GAME_CYCLE_MAIN;
																			endcase
												SCENARIO_SELECT:			case ( done )
																				3'd0: next_state_all = GAME_CYCLE_DRAWBG;
																				3'd1: next_state_all = GAME_CYCLE_CHOOSE;
																			endcase
											endcase

				GAME_CYCLE_DRAWBG:			next_state_all = ( counter_background == 17'd76799 ) ? GAME_CYCLE_X /*GAME_CYCLE_CHAR*/ : GAME_CYCLE_DRAWBG;
				GAME_CYCLE_CHAR:			next_state_all = ( counter_character == 15'b100011011001101) ? GAME_CYCLE_X /*GAME_CYCLE_TXTBOX*/ : GAME_CYCLE_CHAR;
				GAME_CYCLE_TXTBOX:			next_state_all = ( counter_txtbox == 15'b101010011000100) ? GAME_CYCLE_X /*GAME_CYCLE_TXT*/ : GAME_CYCLE_TXTBOX;
				GAME_USER_WAIT:				next_state_all = (sel_r && button) ? PONG_CYCLE_START : (!sel_r && button ? PONG_CYCLE_START : GAME_USER_WAIT );

				PONG_CYCLE_GAMEOVER:		next_state_all = button ? GAME_CYCLE_SCENARIO : PONG_CYCLE_GAMEOVER;
								
				default:				next_state_all= GAME_CYCLE_MAIN ;
			//////////////////////////////////////////////////////////////////////////////end
			endcase
        end // state_table
	

		
	
    always @ (posedge clk)
    begin//Go time
		if( current_state_all == B_CYCLE_X )begin
		//go_count_ball <= 24'b11001011011100110110 			//1 frame (60fps) 50M/60
		//go_count_ball <= 24'b1100101101110011011000  			//15 frames ( 1/15 sec)
		//go_count_ball <= 24'b10111110101111000010000000 		//1 second
		
		//go_count_ball <= 24'b101111101011111000101101;		// 1/4 second
		//go_count_ball <= 24'b100011110000111010100010 + 24'd1;//9375394 +1
		//go_count_ball <= 24'b010111110101111100010111;
		//go_count_ball <= 24'b001111111001010010111010;
		go_count_ball <= 24'b001011111010111110001011; // 1/16 sec
		end
		if(go_count_ball != 0) begin
		go_count_ball <= go_count_ball-1;
		goTime_ball <=0;
		end
		else begin
		goTime_ball <=1;
		end
		//		  if(count1 != 0 && frame==1) begin
		//        count1 <= count1-1;
		//        goTime_ball <=1;
		//        end
		//        else begin
		//        count1 <= 4'd14;
		//        goTime_ball <=0;
		//        end
        
    end
	
	always @ (posedge clk)
    begin//Go time left paddle
		if( current_state_all == PL_CYCLE_X )begin
			//go_count_lp <= 24'b101111101011111000101101;//Frame +35 clocks
			//go_count_lp <= 24'b100011110000111010100010;//9375394
			//go_count_lp <= 24'b010111110101111100010111 + 24'd1;
			//go_count_lp <= 24'b001111111001010010111010;
			go_count_lp <= 24'b001011111010111110001011;
		end
		if(go_count_lp != 0) begin
		go_count_lp <= go_count_lp-1;
		goTime_lp <=0;
		end
		else begin
		goTime_lp <=1;
		end
		
        if(go_count_lp == 1) goTime_lp_r <= 1;
		else goTime_lp_r <=0;
    end
	
	always @ (posedge clk)
    begin//Go time right paddle
		if( current_state_all == PR_CYCLE_X )begin
			if ( goTime_ai == 2'd0 ) go_count_rp <= 24'b100011110000111010100010;//1/5
			else if ( goTime_ai == 2'd1 ) go_count_rp <= 24'b010111110101111100010111;//1/8 secs
			else if ( goTime_ai == 2'd2 ) go_count_rp <= 24'b001111111001010010111010;// 1/12 secs
			else if ( goTime_ai == 2'd3 ) go_count_rp <= 24'b001011111010111110001011; //1/16 secs

			//go_count_rp <= 24'b101111101011111000101101  + 24'd1;//Frame +35 clocks
			//go_count_rp <= 24'b100011110000111010100010;//9375394
			//go_count_rp <= 24'b010111110101111100010111;
			//go_count_rp <= 24'b001111111001010010111010;
			//go_count_rp <= 24'b001011111010111110001011;
		end
		if(go_count_rp != 0) begin
		go_count_rp <= go_count_rp-1;
		goTime_rp <=0;
		end
		else begin
		goTime_rp <=1;
		end
        
    end
	
	always @ (posedge clk)
    begin//Go time spr_debuff
		if ( go_count_spr_debuff == 0 ) begin
			debuffed_lp <=0;
		end
		
		if( paddle_spr_l )begin
			if( ability_rp_r == ABILITY_GREEN && paddle_spr_l) begin
				go_count_spr_debuff <= 5'd24; //24/16 secs
				debuffed_lp <= DEBUFF_SLOW;
			end
			else
				if ( ability_rp_r == ABILITY_BLUE && paddle_spr_l )begin
					go_count_spr_debuff <= 5'd12; //12/16 secs
					debuffed_lp <= DEBUFF_FREEZE;
				end
				//else debuffed_lp <= 0; can remove debuff if yellow or red ball hit
		end
		
		if( goTime_lp != 0 &&  go_count_spr_debuff != 0) begin //decrements each time left paddle had a go time
			go_count_spr_debuff <= go_count_spr_debuff-1;	
		end
	end

    always @(*)
    begin//Flags and signals for ball
		delete		=1'b0;
		create		=1'b0;
		move		=1'b0;
		check		=1'b0;
		
		delete_l	=1'b0;
		create_l	=1'b0;
		move_l		=1'b0;
		check_l		=1'b0;

		
		delete_r	=1'b0;
		create_r	=1'b0;
		move_r		=1'b0;
		check_r		=1'b0;
		
		delete_spr	=1'b0;
		create_spr	=1'b0;
		move_spr	=1'b0;
		move_fire_spr=1'b0;
		
		
		waiting		=1'b0;
		reset		=1'b0;
		resetS		=1'b0;
		
	//////////////////////////////////////////////////////////////////////////////begin
		main		=1'b0;
		gameOver	=1'b0;
		draw_bg		=1'b0;
		plot		=1'b0;

		draw_char	=1'b0;
		draw_txtbox	=1'b0;
	//////////////////////////////////////////////////////////////////////////////end

		case (current_state_all)
		
		B_CYCLE_D: begin // delete
			delete=1;
			plot=1;
		end
		B_CYCLE_X: begin // Do A <- A * x 
			check=1;//local
		end
		B_CYCLE_M: begin //Move
			move = 1 ;		
		end
		B_CYCLE_C: begin // create
			create=1;
			plot=1; 
		end
		
		PL_CYCLE_D: begin // delete
			delete_l=1;
			plot=1;		
		end
		PL_CYCLE_X: begin // Do A <- A * x 
			check_l=1;//local
		end
		PL_CYCLE_M: begin //Move	
			move_l = 1 ;		
		end
		PL_CYCLE_C: begin // create
			create_l=1;
			plot=1; 
		end
		
		PR_CYCLE_D: begin // delete
			delete_r = 1;
			plot = 1;				
		end
		PR_CYCLE_X: begin // Do A <- A * x 
			check_r = 1;//local
		end
		PR_CYCLE_M: begin //Move
			move_r = 1 ;		
		end
		PR_CYCLE_C: begin // create
			create_r=1;
			plot=1; 
		end
		
		SPR_CYCLE_D: begin // delete
			delete_spr=1;
			plot=1;
		end
		SPR_CYCLE_M: begin //Move
			move_spr = 1 ;		
		end
		SPR_CYCLE_FIRE: begin //when in air
			move_fire_spr = 1;
		end	
		SPR_CYCLE_C: begin // create
			create_spr=1;
			plot=1; 
		end
		
		PONG_CYCLE_WAIT: begin //Wait and show off all
			waiting=1;
		end
		PONG_CYCLE_START:begin
			reset=1;
		end	
		PONG_CYCLE_SCORE:begin
			resetS=1;
		end	
		
		PONG_CYCLE_DELETE:begin//Deletes everything;
		
		end
		//////////////////////////////////////////////////////////////////////////////begin
		GAME_CYCLE_MAIN: begin
			main=1;
		end

		PONG_CYCLE_GAMEOVER:begin
			gameOver=1;
		end
		GAME_CYCLE_DRAWBG:begin
			draw_bg=1;
			plot=1;
		end	

		GAME_CYCLE_CHAR:begin
			draw_char=1;
			plot=1;
		end	

		GAME_CYCLE_TXTBOX:begin
			draw_txtbox=1;
			plot=1;
		end	

		//////////////////////////////////////////////////////////////////////////////end
		endcase
	end // enable_signals

	always@(posedge clk)
		begin: state_FFs	
			if( current_state_all == PONG_CYCLE_START_WAIT )
				deleteAll <=0;
			
			if( current_state_all == PONG_CYCLE_START ) begin
				deleteAll 	<=0;
				resetGame	<=0;
				pause 		<=0;
				dx			<= 9'b111111100; //-4
				dy			<= 8'b00000101; //-3
				dx_l		<= 9'b000000000;
				dy_l		<= 8'b00000000;//should turn to 0
				dx_r		<= 9'b000000000;
				dy_r 		<= 8'b00000000;//should turn to 0
				score 		<= 0;
				score_r 	<= 0;
				score_l 	<= 0;
				
				
				ability_rp_r <= 0;
				ready_spr	<= 1;
				spr_out		<= 0;
				dx_spr 	<= 9'b111111111; //-1 to prevent paddle_spr_r in beginning
				dy_spr	<= 0;
			end
			
			if (resetGamen) resetGame <= 0;
			else resetGame <= 1;
			
			if (pausen) pause <= 0;
			else pause <= 1;
			
			if( current_state_all == PONG_CYCLE_SCORE ) begin
				deleteAll <=0;
				dx		<= 9'b111111100; //-4
				dy		<= 8'b00000101; //-3
				dx_l	<= 9'b000000000;
				dy_l	<= 8'b00000000;
				dx_r	<= 9'b000000000;
				dy_r 	<= 8'b00000000;
				score 	<= 0;
				
				ability_rp_r <= 0;
				ready_spr	<= 1;
				spr_out		<= 0;
				dx_spr 	<= 9'b111111111; //-1 to prevent paddle_spr_r in beginning
				dy_spr	<= 0;
			end
			
			if( current_state_all == PONG_CYCLE_DELETE ) begin 
				deleteAll <=1;
			end
			
			//Counters to draw:
			if( current_state_all == GAME_CYCLE_DRAWBG ) counter_background <= counter_background + 17'd1;
			else counter_background <= 17'd0;
			
			if( current_state_all == B_CYCLE_C || current_state_all ==B_CYCLE_D ) counter_ball <= counter_ball + 5'd1;
			else counter_ball <= 5'd0;
			
			if( current_state_all == SPR_CYCLE_C || current_state_all == SPR_CYCLE_D ) counter_spr <= counter_spr + 5'd1;
			else counter_spr <= 5'd0;
			
			if( current_state_all == PL_CYCLE_C || current_state_all ==PL_CYCLE_D ) counter_paddle_l <= counter_paddle_l + 7'd1;
			else counter_paddle_l <= 7'd0;
			
			if( current_state_all == PR_CYCLE_C || current_state_all ==PR_CYCLE_D ) counter_paddle_r <= counter_paddle_r + 7'd1;
			else counter_paddle_r <= 7'd0;
			//
			
			if( current_state_all == B_CYCLE_X ) begin
				
				if(wall) begin
					dy <= -dy;
				end
				if(wall_l) begin
					score <= 1;
					score_r <= score_r + 1;
				end
				if(wall_r) begin
					score <= 1;
					score_l <= score_l + 1;
				end
				
				if( paddle_l ) begin
					dx <= -dx;
					
					if( 8'b11111101 <= y_diff_left && y_diff_left <= 8'd3 ) // && dy <= 8'b01111111 
						dy <= dy ;
						
					if( 8'd4 <= y_diff_left && y_diff_left <= 8'd7 )begin 
						dy <= dy + 8'd1;
					end
					if( 8'b11111100/*-4*/ >= y_diff_left && y_diff_left >= 8'b11111001 /*-7*/ )begin
						dy <= dy - 8'd1;
					end
						
					if( 8'd8 <= y_diff_left && y_diff_left <= 8'd11 )begin
						
						if ( dy > 8'b01111111 && dy + 8'd2 <= 8'b01111111 )
							dy <= 8'b11111111;
						else dy <= dy + 8'd2;
						
					end
					if( 8'b11111000/*-8*/ >= y_diff_left && y_diff_left >= 8'b11110101 /*-11*/ )begin //1010=10
						
						if ( dy <= 8'b01111111 && dy - 8'd2 > 8'b01111111 )
							dy <= 8'd1;
						else dy <= dy - 8'd2;
						
					end
						
					if( 8'd12 <= y_diff_left && y_diff_left <= 8'd15 ) begin
						
						if ( dy > 8'b01111111 && dy + 8'd3 <= 8'b01111111 )
							dy <= 8'b11111111;
						else dy <= dy + 8'd3;
						
					end
					if( 8'b11110100 >= y_diff_left/*-12*/ && y_diff_left >= 8'b11110001 /*-15*/ )begin
						
						if ( dy <= 8'b01111111 && dy - 8'd3 > 8'b01111111 )
							dy <= 8'd1;
						else dy <= dy - 8'd3;
						
					end
					
					if ( y_diff_left <= 8'b01111111 && y_diff_left > 8'd15 ) begin
						
						if ( dy > 8'b01111111 && dy + 8'd5 <= 8'b01111111 )
							dy <= 8'b11111111;
						else dy <= dy + 8'd5;
						
					end
					if(y_diff_left > 8'b01111111 && y_diff_left < 8'b11110001 ) begin
						
						if ( dy <= 8'b01111111 && dy - 8'd5 > 8'b01111111 )
							dy <= 8'd1;
						else dy <= dy - 8'd5;
						
					end
						
					if ( dy <= 8'b01111111 && dy > 8'd9 )begin
						dy <= 8'd9;
					end
					if ( dy > 8'b01111111 && dy < 8'b11110111 )begin
						dy <= 8'b11110111;
					end	
				end	
				
				if( paddle_r ) begin
					dx <= -dx;
					
					if( 8'b11111101 <= y_diff_right && y_diff_right <= 8'd3 ) // && dy <= 8'b01111111 
						dy <= dy ;
						
					if( 8'd4 <= y_diff_right && y_diff_right <= 8'd7 )begin 
						dy <= dy + 8'd1;
					end
					if( 8'b11111100/*-4*/ >= y_diff_right && y_diff_right >= 8'b11111001 /*-7*/ )begin
						dy <= dy - 8'd1;
					end
						
					if( 8'd8 <= y_diff_right && y_diff_right <= 8'd11 )begin
						
						if ( dy > 8'b01111111 && dy + 8'd2 <= 8'b01111111 )
							dy <= 8'b11111111;
						else dy <= dy + 8'd2;
						
					end
					if( 8'b11111000/*-8*/ >= y_diff_right && y_diff_right >= 8'b11110101 /*-11*/ )begin //1010=10
						
						if ( dy <= 8'b01111111 && dy - 8'd2 > 8'b01111111 )
							dy <= 8'd1;
						else dy <= dy - 8'd2;
						
					end
						
					if( 8'd12 <= y_diff_right && y_diff_right <= 8'd15 ) begin
						
						if ( dy > 8'b01111111 && dy + 8'd3 <= 8'b01111111 )
							dy <= 8'b11111111;
						else dy <= dy + 8'd3;
						
					end
					if( 8'b11110100 >= y_diff_right/*-12*/ && y_diff_right >= 8'b11110001 /*-15*/ )begin
						
						if ( dy <= 8'b01111111 && dy - 8'd3 > 8'b01111111 )
							dy <= 8'd1;
						else dy <= dy - 8'd3;
						
					end
					
					if ( y_diff_right <= 8'b01111111 && y_diff_right > 8'd15 ) begin
						
						if ( dy > 8'b01111111 && dy + 8'd5 <= 8'b01111111 )
							dy <= 8'b11111111;
						else dy <= dy + 8'd5;
						
					end
					if(y_diff_right > 8'b01111111 && y_diff_right < 8'b11110001 )
					begin
						
						if ( dy <= 8'b01111111 && dy - 8'd5 > 8'b01111111 )
							dy <= 8'd1;
						else dy <= dy - 8'd5;
						
					end
						
					if ( dy <= 8'b01111111 && dy > 8'd9 )begin
						dy <= 8'd9;
					end
					if ( dy > 8'b01111111 && dy < 8'b11110111 )begin
						dy <= 8'b11110111;
					end	
				end
			
			end
			
			if( current_state_all == PL_CYCLE_X ) begin
				if(paddle_l_floor && down_l)
					dy_l <= 0;
					else 
					if(paddle_l_roof && up_l)
						dy_l <= 0;
					else begin
						if( debuffed_lp == DEBUFF_FREEZE )begin
							dy_l <= 0;
						end
						else begin
							if(down_l && go_l) dy_l <= 8'b00000010;
							if(down_l && go_l && speed_l) dy_l <= 8'b00000011;
							if(up_l && go_l) dy_l <= 8'b11111110;
							if(up_l && go_l && speed_l) dy_l <= 8'b11111101;
							if( !go_l ) dy_l <= 0;
							if( debuffed_lp == DEBUFF_SLOW )begin
								dy_l <= dy_l/2;
							end
						end
					end
			end
			
			if( current_state_all == PR_CYCLE_X ) begin
				if(paddle_r_floor && down_r)
					dy_r <= 0;
				else 
					if(paddle_r_roof && up_r)
						dy_r <= 0;
					else begin
						if(down_r && go_r) dy_r <= 8'd2+dy_ai;
						if(down_r && go_r && speed_r) dy_r <= 8'd3 + dy_ai + dy_ai;
						if(up_r && go_r) dy_r <= 8'b11111110-dy_ai;
						if(up_r && go_r && speed_r) dy_r <= 8'b111111101 - dy_ai - dy_ai ;
						if( !go_r ) dy_r <= 0;
					end
			end
			
			if( current_state_all == SPR_CYCLE_D ) begin //spr_out 
				if(wall_spr_l) begin
					spr_out <=1;
				end
				if(wall_spr_r) begin
					spr_out <= 1;
				end
				if( paddle_spr_l ) begin
					if ( ability_rp_r != ABILITY_YELLOW )begin
						spr_out  <= 1;
					end
				end
				if( paddle_spr_r ) begin
					spr_out  <= 1;
				end
			end
			
			if( current_state_all == SPR_CYCLE_X ) begin
				if ( wall_spr ) begin
					dy_spr <= -dy_spr;
				end
				
				if ( wall_spr_l ) begin
					if ( ability_rp_r == ABILITY_YELLOW )begin
						score_r <= score_r +1;
					end
				end
				
				if ( paddle_spr_l ) begin
					if ( ability_rp_r == ABILITY_YELLOW )begin
						dx <= -dx;
						
						if( 8'b11111101 <= y_diff_spr_left && y_diff_spr_left <= 8'd3 ) // && dy_spr <= 8'b01111111 
							dy_spr <= dy_spr ;
							
						if( 8'd4 <= y_diff_spr_left && y_diff_spr_left <= 8'd7 )begin 
							dy_spr <= dy_spr + 8'd1;
						end
						if( 8'b11111100/*-4*/ >= y_diff_spr_left && y_diff_spr_left >= 8'b11111001 /*-7*/ )begin
							dy_spr <= dy_spr - 8'd1;
						end
							
						if( 8'd8 <= y_diff_spr_left && y_diff_spr_left <= 8'd11 )begin
							
							if ( dy_spr > 8'b01111111 && dy_spr + 8'd2 <= 8'b01111111 )
								dy_spr <= 8'b11111111;
							else dy_spr <= dy_spr + 8'd2;
							
						end
						if( 8'b11111000/*-8*/ >= y_diff_spr_left && y_diff_spr_left >= 8'b11110101 /*-11*/ )begin //1010=10
							
							if ( dy_spr <= 8'b01111111 && dy_spr - 8'd2 > 8'b01111111 )
								dy_spr <= 8'd1;
							else dy_spr <= dy_spr - 8'd2;
							
						end
							
						if( 8'd12 <= y_diff_spr_left && y_diff_spr_left <= 8'd15 ) begin
							
							if ( dy_spr > 8'b01111111 && dy_spr + 8'd3 <= 8'b01111111 )
								dy_spr <= 8'b11111111;
							else dy_spr <= dy_spr + 8'd3;
							
						end
						if( 8'b11110100 >= y_diff_spr_left/*-12*/ && y_diff_spr_left >= 8'b11110001 /*-15*/ )begin
							
							if ( dy_spr <= 8'b01111111 && dy_spr - 8'd3 > 8'b01111111 )
								dy_spr <= 8'd1;
							else dy_spr <= dy_spr - 8'd3;
							
						end
						
						if ( y_diff_spr_left <= 8'b01111111 && y_diff_spr_left > 8'd15 ) begin
							
							if ( dy_spr > 8'b01111111 && dy_spr + 8'd5 <= 8'b01111111 )
								dy_spr <= 8'b11111111;
							else dy_spr <= dy_spr + 8'd5;
							
						end
						if(y_diff_spr_left > 8'b01111111 && y_diff_spr_left < 8'b11110001 )
						begin
							
							if ( dy_spr <= 8'b01111111 && dy_spr - 8'd5 > 8'b01111111 )
								dy_spr <= 8'd1;
							else dy_spr <= dy_spr - 8'd5;
							
						end
							
						if ( dy_spr <= 8'b01111111 && dy_spr > 8'd9 )begin
							dy_spr <= 8'd9;
						end
						if ( dy_spr > 8'b01111111 && dy_spr < 8'b11110111 )begin
							dy_spr <= 8'b11110111;
						end	
						c_spr 	<= 6'b110000; //red
					end
					
					if ( ability_rp_r == ABILITY_RED ) begin 
						score_l <= score_l - 1;
					end
				end
				
				if ( paddle_spr_r )begin
					if ( ability_rp_r == ABILITY_YELLOW )
						score_r <= score_r - 1 ;
				end
			end	
			
			if( current_state_all == PONG_CYCLE_WAIT ) begin
				if ( spr_out )
					spr_out <= 0;		
			end
			
			if ( ability_rp_r == 0 ) begin
				ability_rp_r <= ability_rp;
				ready_spr <= 1;
			end
			else begin
			dy_spr	<= dy_spr_ai_r;
			end
			
			if ( ability_rp_r == ABILITY_GREEN ) begin//slow
				dx_spr 	<= 9'b111111010; //-6
				c_spr 	<= 6'b011100; //greenish
			end				
			if ( ability_rp_r == ABILITY_YELLOW ) begin//yellow
				dx_spr 	<= 9'b111111110; //-2
				c_spr 	<= 6'b111100; //yelowish
			end	
			if ( ability_rp_r == ABILITY_BLUE ) begin//freeze
				dx_spr 	<= 9'b111111100; //-4
				c_spr 	<= 6'b001111; //cyan
			end	
			if ( ability_rp_r == ABILITY_RED ) begin//red
				dx_spr 	<= 9'b111111111; //-1
				c_spr 	<= 6'b110000; //red
			end	
			
			if ( spr_out && PONG_CYCLE_WAIT ) begin
				ability_rp_r <= 0;
				ready_spr <= 1;
				spr_out <= 0;
				dx_spr 	<= 9'b111111111; //-1 to prevent paddle_spr_r in beginning
				dy_spr	<= 0;
			end
			
			if ( fire && ability_rp_r != 0 )begin
				ready_spr <=0;
				dy_spr_ai_r <= dy_spr_ai;
			end

			//////////////////////////////////////////////////////////////////////////////begin
			if( go_l ) button <=1;//Go r?
			else button <= 0;
			
			if ( current_state_all == GAME_CYCLE_MAIN ) begin 
				sel_r <=sel; // sw[9:8] determines which line of story to go to
				case ( sel_r )
														2'b01: begin
															game_scenario_id <= SCENARIO_PONG_1V1;
														end
														2'b10: begin
															game_scenario_id <= SCENARIO_STORY_NOOB;
														end
														2'b11: begin
															game_scenario_id <= SCENARIO_SELECT;
														end
			endcase
			end

			if ( current_state_all == GAME_CYCLE_CHOOSE ) begin
				sel_r <= sel;
					case ( sel_r )
						2'b00: begin
							game_scenario_id <= SCENARIO_PONG_NOOB;
						end
						2'b01: begin
							game_scenario_id <= SCENARIO_PONG_TRACKER;
						end
						2'b10: begin
							game_scenario_id <= SCENARIO_PONG_DRUNK;
						end
						2'b11: begin
							game_scenario_id <= SCENARIO_PONG_FINALBOSS;
						end
						endcase
			end

			if ( current_state_all == GAME_CYCLE_X ) begin
				case (game_scenario_id)
					SCENARIO_STORY_NOOB:		case (done)
													3'd0: begin
														background_id <= BACKGROUND_1V1;
														player_id <= PLAYER_NOOB;
														end
													3'd2: begin
														 done <= done + 1; end
													3'd3: begin
														textbox_id <= TEXT_NOOB_A;
														done <= done + 1; end
													3'd4: begin
														background_id <= BACKGROUND_1V1;
														done <= 0; end
												endcase
					SCENARIO_STORY_TRACKER:		case (done)
													3'd0: begin
														background_id <= BACKGROUND_TRACKER;
														player_id <= PLAYER_TRACKER;
														done <= done + 1;
														end
													3'd2: begin
														done <= done + 1; end
													3'd3: begin
														textbox_id <= TEXT_TRACKER;
														done <= done + 1; end
													3'd4: begin
														background_id <= BACKGROUND_TRACKER;
														done <= 0; end
												endcase
					SCENARIO_STORY_DRUNK:		case (done)
													3'd0: begin
														background_id <= BACKGROUND_DRUNK;
														player_id <= PLAYER_DRUNK;
														done <= done + 1;
														end
													3'd1: begin 
														x_char <= 9'd175 ;
														y_char <= 8'd15 ;
														character_id <= CHARACTER_DRUNK;
														done <= done + 1; end
													3'd2: begin 
														x_char <= 8'd20;
														y_char <= 8'd15;
														character_id <= CHARACTER_MAIN;
														done <= done + 1; end
													3'd3: begin 
														textbox_id <= TEXT_DRUNK;
														done <= done + 1; end
													3'd4: begin 
														done <= done + 1; end
													3'd5: begin 
														background_id <= BACKGROUND_DRUNK;
														done <= done + 1; end
													3'd6: begin 
														done <= 0; end
												endcase
					SCENARIO_STORY_FINALBOSS:	case (done)
													3'd0: begin
														toggle_ability <= 1;
														background_id <= BACKGROUND_FINALBOSS;
														player_id <= PLAYER_FINALBOSS;
														done <= done + 1;
														end
													3'd1: begin 
														x_char <= 9'd175 ;
														y_char <= 8'd15 ;
														character_id <= CHARACTER_FINALBOSS;
														done <= done + 1; end
													3'd2: begin 
														x_char <= 8'd20;
														y_char <= 8'd15;
														character_id <= CHARACTER_MAIN;
														done <= done + 1; end
													3'd3: begin 
														textbox_id <= TEXT_FINALBOSS;
														done <= done + 1; end
													3'd4: begin 
														done <= done + 1; end
													3'd5: begin 
														background_id <= BACKGROUND_FINALBOSS;
														done <= done + 1; end
													3'd6: begin 
														done <= 0; end
												endcase
					SCENARIO_STORY_FINAL:		case (done)
													3'd0: begin 
														background_id <= BACKGROUND_FINALBOSS;
														done <= done + 1; end
													3'd1: begin 
														x_char <= 8'd20;
														y_char <= 8'd15;
														character_id <= CHARACTER_MAIN;
														done <= done + 1; end
													3'd2: begin 
														x_char <= 9'd175 ;
														y_char <= 8'd15 ;
														character_id <= CHARACTER_FINALBOSS;
														done <= done + 1; end
													3'd3: begin 
														textbox_id <= TEXT_FINAL;
														done <= done + 1; end
													3'd4: begin
														done <= 0; end
												endcase
					SCENARIO_PONG_1V1:			case (done)
													3'd0: begin 
														toggle_ability <= 1;
														background_id <= BACKGROUND_1V1;
														player_id <= PLAYER_1V1;
														end
													3'd1: begin done <= 0; end
												endcase
					SCENARIO_PONG_NOOB:			case (done)
													3'd0: begin
														toggle_ability <= 1;
														background_id <= BACKGROUND_1V1;
														player_id <= PLAYER_NOOB;
													end
													3'd1: begin done <= 0; end
												endcase
					SCENARIO_PONG_TRACKER:		case (done)
													3'd0: begin
														toggle_ability <= 1;
														background_id <= BACKGROUND_TRACKER;
														player_id <= PLAYER_TRACKER;
													end
													3'd1: begin done <= 0; end
												endcase
					SCENARIO_PONG_DRUNK:		case (done)
													3'd0: begin
														toggle_ability <= 1;
														background_id <= BACKGROUND_DRUNK;
														player_id <= PLAYER_DRUNK;
														end
													3'd1: begin done <= 0; end
												endcase
					SCENARIO_PONG_FINALBOSS:	case (done)
													3'd0: begin
														toggle_ability <= 1;
														background_id <= BACKGROUND_FINALBOSS;
														player_id <= PLAYER_FINALBOSS;
														done <= done +1;
														end
													3'd1: begin done <= 0; end
												endcase
					SCENARIO_MAIN:				case (done)
												3'd0: begin
													toggle_ability <= 0;
													background_id <= BACKGROUND_MAIN;
													done <= done +1;
												end
												3'd1: done<=0;
												endcase
					SCENARIO_SELECT:			case (done)
												3'd0: begin
													textbox_id <= TEXT_SELECT;
													done <= done +1;
												end
												3'd1: 
													begin
															done <= 0;
														end
													endcase
												
					
				endcase
			end

			if( current_state_all == GAME_CYCLE_CHAR ) counter_character <= counter_character + 15'd1;
			else counter_character <= 15'd0;

			if( current_state_all == GAME_CYCLE_TXTBOX ) counter_txtbox <= counter_txtbox + 15'd1;
			else counter_txtbox <= 15'd0;

			if (current_state_all == GAME_CYCLE_MAIN)
			begin
				toggle_ability <= 0;
				case (sel_r) 
					PLAY_1V1: game_scenario_id <= SCENARIO_PONG_1V1;
					STORY: game_scenario_id <= SCENARIO_STORY_NOOB;
					STAGES: game_scenario_id <= SCENARIO_SELECT;										
				endcase
			end

			if (current_state_all == GAME_CYCLE_SCENARIO)
			begin
				if ( game_scenario_id <= SCENARIO_STORY_FINAL )
				begin
					if (score_r == 4'd11)
						game_scenario_id <= game_scenario_id;
					else game_scenario_id <= game_scenario_id + 1;
					if (game_scenario_id == SCENARIO_PONG_1V1 )
						game_scenario_id <= SCENARIO_MAIN;
				end
				else 
				game_scenario_id <= SCENARIO_MAIN;
			end
			
			current_state_all <= next_state_all;
			//////////////////////////////////////////////////////////////////////////////end
		end
		
	endmodule
                
                        
module datapath(
    input clk,
	input [8:0] dx, dx_l, dx_r, dx_spr,
	input [7:0] dy, dy_l, dy_r, dy_spr,
	input reset,resetS,gameOver,main,
	input plot,waiting,create,delete,move,
	input create_l,delete_l,move_l,
	input create_r,delete_r,move_r,
	input delete_spr,create_spr,move_spr, move_fire_spr,
	input spr_out,
	input [4:0] counter_ball, counter_spr,
	input [6:0] counter_paddle_l,counter_paddle_r,
	input [16:0] counter_background,
	input [5:0] c_spl,c_spr,
	input draw_bg,
	output reg [8:0] x_r,
	output reg [7:0] y_r,
	output reg writeEn,
	output reg [16:0] bg_address,
	output reg [5:0] c_o,
	output reg [1:0] colour_id,
	output reg wall, wall_spr,
	output reg wall_l, wall_spr_l,
	output reg wall_r, wall_spr_r,
	output reg paddle_l,paddle_r, paddle_spr_l, paddle_spr_r,
	output reg paddle_l_floor, paddle_r_floor,
	output reg paddle_l_roof, paddle_r_roof,
	output reg [8:0] x, x_lp, x_rp,
	output reg [7:0] y, y_lp, y_rp,
	output reg [7:0] y_diff_left, y_diff_spr_left,
	output reg [7:0] y_diff_right, y_diff_spr_right,
	//////////////////////////////////////////////////////////////////////////////begin
	input [2:0] background_id,
	input [1:0] character_id, 
	input [4:0] textbox_id,
	input draw_txtbox, draw_char, 
	input [8:0] x_char,
	input [7:0] y_char,
	input [14:0]counter_character, counter_txtbox,
	output reg [2:0] current_bg_colour_id,
	output reg [14:0] char_address, txt_address
	//////////////////////////////////////////////////////////////////////////////end
    );
	reg [8:0] x_spr;
	reg [7:0] y_spr;

	//////////////////////////////////////////////////////////////////////////////begin
	
	localparam
		BACKGROUND_MAIN		= 3'd0,
		BACKGROUND_1V1		= 3'd1,
		BACKGROUND_TRACKER	= 3'd2,
		BACKGROUND_DRUNK	= 3'd3,
		BACKGROUND_FINALBOSS	= 3'd4;
	
	localparam//colour_id

		SHAPE_COLOUR_ID		= 5'd0,
		CAVE_COLOUR_ID			= 5'd1,

		BACKGROUND_MAIN_COLOUR_ID		= 5'd2,
		BACKGROUND_1V1_COLOUR_ID		= 5'd3,
		BACKGROUND_TRACKER_COLOUR_ID	= 5'd4,
		BACKGROUND_DRUNK_COLOUR_ID	= 5'd5,
		BACKGROUND_FINALBOSS_COLOUR_ID = 5'd6,
		BACKGROUND_SELECT_COLOUR_ID	= 5'd7,

		CHARACTER_DRUNK_COLOUR_ID		= 5'd8,
		CHARACTER_FINALBOSS_COLOUR_ID	= 5'd9,
		CHARACTER_MAIN_COLOUR_ID		= 5'd10,
		TEXT_NOOB_A_COLOUR_ID		= 5'd11,
		TEXT_TRACKER_COLOUR_ID	= 5'd12,
		TEXT_DRUNK_COLOUR_ID		= 5'd13,
		TEXT_FINALBOSS_COLOUR_ID	= 5'd14,
		TEXT_FINAL_COLOUR_ID		= 5'd15,
		TEXT_SELECT_COLOUR_ID		= 5'd16;

	//////////////////////////////////////////////////////////////////////////////end
	
    always@(posedge clk) begin
		//////////////////////////////////////////////////////////////////////////////begin
			case(background_id)
					BACKGROUND_MAIN: current_bg_colour_id <= BACKGROUND_MAIN_COLOUR_ID; //main
					BACKGROUND_1V1:	current_bg_colour_id <= BACKGROUND_1V1_COLOUR_ID; //1v1 and noob
					BACKGROUND_TRACKER:	current_bg_colour_id <= BACKGROUND_TRACKER_COLOUR_ID; //tracker
					BACKGROUND_DRUNK:	current_bg_colour_id <= BACKGROUND_DRUNK_COLOUR_ID; //drunk
					BACKGROUND_FINALBOSS:	current_bg_colour_id <= BACKGROUND_FINALBOSS_COLOUR_ID; //finalboss
				endcase
		
		if(main)begin
			bg_address <=0;
		end
		if ( plot ) writeEn <=1;
		else writeEn <= 0;
		if(resetS)
		begin
			wall_l <= 0;
			wall_r <= 0;
			wall <= 0;
			x <= 9'd159;
			y <= 8'd118;
			
			x_spr <= 9'd159;
			y_spr <= 8'd0;

			x_lp <= 9'd2;
			y_lp <= 8'd101;
			
			x_rp <= 9'd316;
			y_rp <= 8'd101;
			
			y_diff_left 	<= 0; //Distance from center
			y_diff_right 	<= 0;
			
			paddle_l_floor <= 0;
			paddle_r_floor <= 0;
			paddle_l_roof <= 0;
			paddle_r_roof <= 0;
			paddle_l <= 0;
			paddle_r <= 0;
			
			wall_spr		<=0;
			wall_spr_l		<=0;
			wall_spr_r		<=0;
			paddle_spr_l	<=0;
			paddle_spr_r	<=0;
			y_diff_spr_left	<=0;
			y_diff_spr_right<=0;
		end
		
		if (gameOver)
		begin
		
		end

		if(draw_bg)//draws the background
			begin
						colour_id <= current_bg_colour_id;
						if( counter_background == 17'b11111111111111111 )begin 
							x_r <= 0; 
							y_r <= 0;			
						end
						else x_r <= x_r + 9'd1;
						if( x_r == 9'd320 )begin
							x_r <= 0;
							y_r <= y_r + 8'd1;
						end
						bg_address <= 9'd320*y_r + x_r;
		end

			
		if (draw_char)begin
			case(character_id)
					2'd0: colour_id <= CHARACTER_MAIN_COLOUR_ID; //main
					2'd1:	colour_id <= CHARACTER_DRUNK_COLOUR_ID; //drunk
					2'd2:	colour_id <= CHARACTER_FINALBOSS_COLOUR_ID; //final
				endcase
					//bg_address <= counter_background[16:0];
						if( counter_character == 15'b100011011001101 )begin 
							x_r <= x_char; 
							y_r <= y_char;			
						end
						else x_r <= x_r + 9'd1;
						if( x_r == 9'd125 )begin
							x_r <= 0;
							y_r <= y_r + 8'd1;
						end
						char_address <= 9'd125*y_r + x_r;
		end

		
		if (draw_txtbox)begin
				case(textbox_id)
					5'd0: colour_id <= TEXT_NOOB_A_COLOUR_ID; //main
					5'd1:	colour_id <= TEXT_TRACKER_COLOUR_ID; //1v1
					5'd2:	colour_id <= TEXT_DRUNK_COLOUR_ID; //noob
					5'd3:	colour_id <= TEXT_FINALBOSS_COLOUR_ID; //tracker
					5'd4:	colour_id <= TEXT_FINAL_COLOUR_ID; //drunk
					5'd5: colour_id <= TEXT_SELECT_COLOUR_ID; // selection textbox
					// 5'd5:	colour_id <= 1; //finalboss
					// 5'd6:	colour_id <= 1; //final
					// 5'd7:	colour_id <= 1; //select
					// 5'd8:	colour_id <= 1; //select
					// 5'd8:	colour_id <= 1; //select
					// 5'd10:	colour_id <= 1; //select
					// 5'd11:	colour_id <= 1; //select
					// 5'd12:	colour_id <= 1; //select
					// 5'd13:	colour_id <= 1; //select
					// 5'd14:	colour_id <= 1; //select
					// 5'd15:	colour_id <= 1; //select
					// 5'd16:	colour_id <= 1; //select
					// 5'd17:	colour_id <= 1; //select
					// 5'd18:	colour_id <= 1; //select
					// 5'd19:	colour_id <= 1; //select
					// 5'd20:	colour_id <= 1; //select
					// 5'd21:	colour_id <= 1; //select
					// 5'd22:	colour_id <= 1; //select
					// 5'd23:	colour_id <= 1; //select
					// 5'd24:	colour_id <= 1; //select
					// 5'd25:	colour_id <= 1; //select
				endcase
					//bg_address <= counter_background[16:0];
						if( counter_txtbox == 15'b101010011000100 )begin 
							x_r <= 9'd5; 
							y_r <= 8'd70;
						end
						else x_r <= x_r + 9'd1;
						if( x_r == 9'd310 )begin
							x_r <= 0;
							y_r <= y_r + 8'd1;
						end
						txt_address <= 9'd310*y_r + x_r;
		end
		
		

		//////////////////////////////////////////////////////////////////////////////end
		
		if(delete)//delete
		begin
			if( (y == 8'd237 && dy <= 8'b01111111) || (y == 8'd0 && dy > 8'b01111111)) wall <= 1; 
			if (x == 9'd318 && dx <= 9'b011111111) wall_r <= 1;
			if (x == 9'd0 && dx > 9'b011111111)  wall_l <= 1;
			//if ( x + dx > x_lp && x + dx < x_lp+1+1+1+1 && (y_lp+1+1+1+1) > y && y_lp <= y) paddle_l <= 1;  //Better code is to remove dx
			//if ( x + dx > x_rp && x + dx < x_rp+1+1+1+1 && (y_rp+1+1+1+1) > y && y_rp <= y) paddle_r <= 1;  //Better code is to remove dx
			if ( x == x_lp + 9'd2 && dx >  9'b011111111 && (y_lp+8'd31) >= y &&  y_lp <= y+8'd2) paddle_l <= 1;
			if ( x == x_rp + 9'b111111110/*-2*/ && dx <= 9'b011111111 && (y_rp+8'd31) >= y && y_rp <= y+8'd2) paddle_r <= 1; 
			x_r <= x + counter_ball[0];
			y_r <= y + counter_ball[2:1];
			//bg_address <= 9'd320*y_r + x_r;
			bg_address <= 9'd320*( y + counter_ball[2:1] ) + x + counter_ball[0];
			c_o <= 0;
			colour_id <= 1;
		end 
        //There is a state in control path that changes dx and dy here.
		if(move)//Move
		begin
		if(/*0*/-dy>y && dy > 8'b01111111)
				y <=8'd0;
			else 
				if( 8'd237-dy<y  && dy <= 8'b01111111)
					y <= 8'd237; // please note it is 119 -1-1-1-1
				else
					y <= y+dy;
			if( x_lp+9'd2 - dx > x && dx > 9'b011111111 &&  y_lp  <= y +8'd1 && y_lp +8'd31  >= y  )
				x <= x_lp +9'd2;
			else
				if( x_rp - 9'd1 - dx < x +9'd1 && dx <= 9'b011111111 &&  y_rp  <= y +8'd1 && y_rp +8'd31  >= y  )
					x <= x_rp + 9'b111111110; //-2
				else
					if( /*0*/ - dx > x && dx > 9'b011111111)
						x <= 9'd0;
					else
						if( 9'd318 - dx < x && dx <= 9'b011111111)
							x <= 9'd318;
						else
							x <= x+dx;
			wall_l <= 0;
			wall_r <= 0;
			wall <= 0;
			paddle_l <= 0;
			paddle_r <= 0;
		end
		
		if(create)//create
		begin
			x_r <= x + counter_ball[0];
			y_r <= y + counter_ball[2:1];
			y_diff_left 	<= y-y_lp - 8'd15; //Distance from center
			y_diff_right 	<= y-y_rp - 8'd15;
			c_o <= 6'b111111;
			colour_id <= 0;
		end
		
		//Game:
	 	if(waiting)
		begin
			if( y_lp == 8'd208	&& dy_l <= 8'b01111111) 
				paddle_l_floor <= 1; 
			else 
				paddle_l_floor <= 0;
			if( y_lp == 8'd0 && dy_l > 8'b01111111 ) 
				paddle_l_roof <= 1;
			else 
				paddle_l_roof <= 0;
			if( y_rp == 8'd208	&& dy_r <= 8'b01111111) 
				paddle_r_floor <= 1; 
			else 
				paddle_r_floor <=0;
			if( y_rp == 8'd0 && dy_r > 8'b01111111 ) 
				paddle_r_roof <= 1;
			else 
				paddle_r_roof <=0;
		end 
		
		if(reset)
		begin
			wall_l <= 0;
			wall_r <= 0;
			wall <= 0;
			x <= 9'd159;
			y <= 8'd118;
			
			x_spr <= 9'd159;
			y_spr <= 8'd0;
			
			x_lp <= 9'd2;
			y_lp <= 8'd101;
			
			x_rp <= 9'd316;
			y_rp <= 8'd101;
			
			y_diff_left 	<= 0; //Distance from center
			y_diff_right 	<= 0;
			
			paddle_l_floor <= 0;
			paddle_r_floor <= 0;
			paddle_l_roof <= 0;
			paddle_r_roof <= 0;
			paddle_l <= 0;
			paddle_r <= 0;
			
			wall_spr		<=0;
			wall_spr_l		<=0;
			wall_spr_r		<=0;
			paddle_spr_l	<=0;
			paddle_spr_r	<=0;
			y_diff_spr_left	<=0;
			y_diff_spr_right<=0;
		end
		
		
		//Left paddle
		if(delete_l)//delete
		begin
			//if((y_l >= 7'd116 && dy_l <= 7'b0111111) || (y_l <= 7'd0 && dy_l > 7'b0111111)) paddle_l_roof <= 1; 
			x_r <= x_lp + counter_paddle_l[0];
			y_r <= y_lp + counter_paddle_l[5:1];
			c_o <= 0;
			//bg_address <= 9'd320*y_r + x_r;
			bg_address <= 9'd320*( y_lp + counter_paddle_l[5:1] ) + x_lp + counter_paddle_l[0];
			colour_id <= 1;
		end 
        
		if(move_l)//Move
		begin
			if( y_lp < /*0*/ - dy_l && dy_l > 8'b01111111 )
				y_lp <= 8'd0;
			else 
				if( y_lp > 8'd208 - dy_l && dy_l <= 8'b01111111 )
					y_lp <= 8'd208;
				else
					y_lp <= y_lp+dy_l;
			paddle_l_roof <= 0;
			//x_lp <= x_lp+dx_l;
		end
		
		if(create_l)//create
		begin
			x_r <= x_lp + counter_paddle_l[0];
			y_r <= y_lp + counter_paddle_l[5:1];
			c_o <= 6'b111111;
			colour_id <= 0;
		end
		
		//Right Paddle:
		if(delete_r)//delete
		begin
			//if((y_r >= 7'd116 && dy_r <= 7'b0111111) || (y_r <= 7'd0 && dy_r > 7'b0111111)) paddle_r_roof <= 1; 
			x_r <= x_rp + counter_paddle_r[0];
			y_r <= y_rp + counter_paddle_r[5:1];
			c_o <= 0;
			//bg_address <= 9'd320*y_r + x_r;
			bg_address <= 9'd320*( y_rp + counter_paddle_r[5:1] ) + x_rp + counter_paddle_r[0];
			colour_id <= 1;
		end 
        
		if(move_r)//Move
		begin
			if( y_rp <  8'd0 - dy_r && dy_r > 8'b01111111 )
				begin
					y_rp <= 8'd0;
				end
			else 
				begin
					if( y_rp > 8'd208- dy_r && dy_r <= 8'b01111111 )
						y_rp <= 8'd208;
					else
						y_rp <= y_rp+dy_r;
				end 
			paddle_r_roof <= 1'd0;
		end
		
		if(create_r)//create
		begin
			x_r <= x_rp + counter_paddle_r[0];
			y_r <= y_rp + counter_paddle_r[5:1];
			c_o <= 6'b111111;
			colour_id <= 0;
		end
		
		
		if(delete_spr)//delete
		begin
			if( (y_spr == 8'd237 && dy_spr <= 8'b01111111) || (y_spr == 8'd0 && dy_spr > 8'b01111111)) wall_spr <= 1;
			if ( x_spr == 9'd0 && dx_spr > 9'b011111111)  wall_spr_l <= 1;
			if ( x_spr == x_lp + 9'd2 && dx_spr >  9'b011111111 && (y_lp+8'd31) >= y_spr &&  y_lp <= y_spr+8'd2) paddle_spr_l <= 1;
			if ( x_spr == x_rp + 9'b111111110/*-2*/ && dx_spr <= 9'b011111111 && (y_rp+8'd31) >= y_spr && y_rp <= y_spr+8'd2) paddle_spr_r <= 1; 
			x_r <= x_spr + counter_spr[0];
			y_r <= y_spr + counter_spr[2:1];
			bg_address <= 9'd320*( y_spr + counter_spr[2:1] ) + x_spr + counter_spr[0];
			c_o <= 0;
			colour_id <= 0;
		end 
		
		if ( spr_out )
		begin
			wall_spr		<=0;
			wall_spr_l		<=0;
			wall_spr_r		<=0;
			paddle_spr_l	<=0;
			paddle_spr_r	<=0;
			y_diff_spr_left	<=0;
			y_diff_spr_right<=0;
		end
			
		if(move_spr)//Move
		begin
			y_spr <= y_rp + 8'd15;
			x_spr <= 9'd314;
		end
		
		if(move_fire_spr)//Move
		begin
		if(/*0*/-dy_spr>y_spr && dy_spr > 8'b01111111)
				y_spr <=8'd0;
			else 
				if( 8'd237-dy_spr<y_spr  && dy_spr <= 8'b01111111)
					y_spr <= 8'd237; // please note it is 119 -1-1-1-1
				else
					y_spr <= y_spr+dy_spr;
			if( x_lp+9'd2 - dx_spr > x_spr && dx_spr > 9'b011111111 &&  y_lp  <= y_spr +8'd1 && y_lp +8'd31  >= y_spr  )
				x_spr <= x_lp +9'd2;
			else
				if( x_rp - 9'd1 - dx_spr < x_spr +9'd1 && dx_spr <= 9'b011111111 &&  y_rp  <= y_spr +8'd1 && y_rp +8'd31  >= y_spr  )
					x_spr <= x_rp + 9'b111111110; //-2
				else
					if( /*0*/ - dx_spr > x_spr && dx_spr > 9'b011111111)
						x_spr <= 9'd0;
					else
						if( 9'd318 - dx_spr < x_spr && dx_spr <= 9'b011111111)
							x_spr <= 9'd318;
						else
							x_spr <= x_spr+dx_spr;
			wall_spr_l <= 0;
			wall_spr <= 0;
			paddle_spr_l <= 0;
			paddle_spr_r <= 0;
		end
		
		if(create_spr)//create
		begin
			x_r <= x_spr + counter_spr[0];
			y_r <= y_spr + counter_spr[2:1];
			y_diff_spr_left 	<= y_spr - y_lp - 8'd15; //Distance from center
			y_diff_spr_right 	<= y_spr - y_rp - 8'd15; //Distance from center
			c_o <= 0;
			if ( counter_spr == 3'b000 || counter_spr == 3'b100 )begin colour_id <= 1;
				bg_address <= 9'd320*( y_spr + counter_spr[2:1] ) + x_spr + counter_spr[0];
			end
			else colour_id <= 0;
		end
		
		
		/* if(check)

		begin
			if( (y >= 7'd116 && dy <= 7'b0111111) || (y <= 7'd0 && dy > 7'b0111111)) wall <= 1; 
			if (x >= 8'd156 && dx <= 8'b01111111) wall_r <= 1;
			if (x <= 8'd0 && dx > 8'b01111111)  wall_l <= 1;

		end */
	
	end
endmodule

module bosses (	input clk,
				input paddle_l, paddle_r,
				input [8:0] x, dx, x_lp, x_rp, 
				input [7:0] y, dy, y_lp, y_rp, dy_l,
				input [2:0] player_id, 
				input up_button, down_button, go_button, speed_button,
				input [3:0]score_l, score_r,
				input resetn,
				input ready_spr,
				output reg go_r, speed_r, up_r, down_r, 
				output reg [1:0] goTime_ai, // 0-5
				output reg [2:0] dy_ai,	//0-3
				output reg [4:0] current_state_ai,
				output reg [2:0] ability_rp, output reg fire, output reg [7:0]dy_spr_ai); 

	wire [7:0]random;
	lfsr_counter r0 (clk, ~resetn, random);
	reg [4:0] start_state_ai,  next_state_ai;
	reg [7:0] hold_y_lp;
	
	localparam 
		AI_IDEL			= 3'd0, //000
		AI_ONEVONE		= 3'd1, //001
		AI_NOOB			= 3'd2, //010
		AI_TRACK		= 3'd3, //011
		AI_DRUNK		= 3'd4, //100
		AI_FINALBOSS	= 3'd5; //101
		
	localparam
		IDEL_WAIT		= 5'd0,
	
		ONEVONE_START	= 5'd1,
		ONEVONE_LOOP	= 5'd2,		
	
		NOOB_START		= 5'd3,
		NOOB_MIDDLE		= 5'd4,
		NOOB_OPPOSITE	= 5'd5,
		NOOB_FOLLOW		= 5'd6,
		NOOB_WAIT		= 5'd7,
		
		TRACK_START		= 5'd8,
		TRACK_FOLLOW 	= 5'd9,
		TRACK_WAIT		= 5'd10,
		
		DRUNK_START		= 5'd11,
		DRUNK_FOLLOW	= 5'd12,
		DRUNK_SPEED /*(BECOMES SOBER AND OP)*/ = 5'd13,
		DRUNK_ABILITY_GREEN = 5'd14,
		DRUNK_WAIT		= 5'd15,
		
		FINAL_START		= 5'd16,
		FINAL_FOLLOW_BALL	= 5'd17,
		FINAL_SPEED 	= 5'd18,
		FINAL_ABILITY_GREEN = 5'd19,
		FINAL_ABILITY_YELLOW = 5'd20,
		FINAL_ABILITY_BLUE = 5'd21,
		FINAL_ABILITY_RED = 5'd22,
		FINAL_ABILITY = 5'd23,
		FINAL_HIT = 5'd24,
		FINAL_WAIT		= 5'd25;
	
	always @(*)
	begin
		case ( player_id )
			AI_IDEL:			start_state_ai = IDEL_WAIT;
			AI_ONEVONE: 		start_state_ai = ONEVONE_START;
			AI_NOOB:			start_state_ai = NOOB_START;
			AI_TRACK:			start_state_ai = TRACK_START;
			AI_DRUNK:			start_state_ai = DRUNK_START;
			AI_FINALBOSS:		start_state_ai = FINAL_START;
			
			default: 			start_state_ai = IDEL_WAIT;
		endcase
	end
	
	always @ (*)
	begin
		case ( current_state_ai)
			IDEL_WAIT: 				next_state_ai = start_state_ai;
			
			ONEVONE_START:			next_state_ai = ( player_id == 3'd1 ) ? ONEVONE_LOOP: IDEL_WAIT;
			ONEVONE_LOOP:			next_state_ai = ( player_id == 3'd0 || score_l == 4'd11 ) ? IDEL_WAIT : ONEVONE_LOOP;
			
			NOOB_START:				next_state_ai = ( player_id == 3'd2 ) ? NOOB_MIDDLE : IDEL_WAIT;
			NOOB_MIDDLE:			next_state_ai = (player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd2) ? IDEL_WAIT : ((dx <= 9'b011111111 && x > 9'd180) ? NOOB_FOLLOW : ( paddle_l ? NOOB_OPPOSITE :NOOB_MIDDLE ));
			NOOB_OPPOSITE:			next_state_ai = (player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd2) ? IDEL_WAIT : ((y_rp + 8'd16 <= 8'd40  || y_rp + 8'd16 >= 8'd200  || (hold_y_lp < 8'd160 && hold_y_lp > 8'd80 && y_rp + 8'd16 < 8'd160 && y_rp + 8'd16 > 8'd80)) ? NOOB_WAIT : ((dx <= 9'b011111111 && x > 9'd180) ? NOOB_FOLLOW : NOOB_OPPOSITE));
			NOOB_WAIT:				next_state_ai = (player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd2) ? IDEL_WAIT : ((dx <= 9'b011111111 && x > 9'd180) ? NOOB_FOLLOW : NOOB_WAIT );  
			NOOB_FOLLOW:			next_state_ai = (player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd2) ? IDEL_WAIT : ((dx > 9'b011111111 ) ? NOOB_MIDDLE : NOOB_FOLLOW);
			
			TRACK_START:			next_state_ai = ( player_id == 3'd3 ) ? TRACK_FOLLOW : IDEL_WAIT;
			TRACK_FOLLOW: 			next_state_ai = (player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd3) ? IDEL_WAIT : ( (y == y_rp) ? TRACK_WAIT : TRACK_FOLLOW );
			TRACK_WAIT:				next_state_ai = ( y != y_rp) ? TRACK_FOLLOW : TRACK_WAIT;
			
			DRUNK_START:			next_state_ai = ( player_id == 3'd4 ) ? DRUNK_FOLLOW : IDEL_WAIT;
			DRUNK_FOLLOW:			next_state_ai = ( player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd4) ? IDEL_WAIT : ((dx <= 9'b011111111 & x >= 8'd140) ? DRUNK_FOLLOW : ((score_l <4'd6) ? DRUNK_WAIT : DRUNK_ABILITY_GREEN)); 
			DRUNK_SPEED:			next_state_ai = (score_l >= 4'd8) ? DRUNK_ABILITY_GREEN : DRUNK_FOLLOW;
			DRUNK_ABILITY_GREEN:	next_state_ai = (player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd4) ? IDEL_WAIT : ((dx > 9'b011111111) ? DRUNK_ABILITY_GREEN : DRUNK_FOLLOW);
			DRUNK_WAIT:				next_state_ai = (player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd4) ? IDEL_WAIT : (( score_l < 4'd6 && dx > 9'b011111111) ? DRUNK_WAIT : ((score_l >= 4'd6) ? DRUNK_SPEED : DRUNK_FOLLOW));
			
			FINAL_START:			next_state_ai = ( player_id == 3'd5 ) ? FINAL_WAIT : IDEL_WAIT;
			FINAL_FOLLOW_BALL:		next_state_ai = ( player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd5) ? IDEL_WAIT : ((dx <= 9'b011111111 ) ? FINAL_FOLLOW_BALL : (score_l < 4'd6) ? FINAL_WAIT : FINAL_ABILITY_GREEN);
			FINAL_SPEED:			next_state_ai = ( score_l >= 4'd5 && dx > 9'b011111111 ) ? FINAL_ABILITY_GREEN : FINAL_FOLLOW_BALL;
			FINAL_ABILITY_GREEN:	next_state_ai = ( player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd5 ) ? IDEL_WAIT :(( score_l == 4'd6 ) ? FINAL_ABILITY_YELLOW : (( score_l == 4'd5 && dx > 9'b011111111 ) ? FINAL_ABILITY_GREEN : FINAL_FOLLOW_BALL));
			FINAL_ABILITY_YELLOW: 	next_state_ai = ( player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd5 ) ? IDEL_WAIT :(( score_l == 4'd7 ) ? FINAL_ABILITY_BLUE : (( score_l == 4'd6 && dx > 9'b011111111 ) ? FINAL_ABILITY_YELLOW : FINAL_FOLLOW_BALL));
			FINAL_ABILITY_BLUE: 	next_state_ai = ( player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd5 ) ? IDEL_WAIT :(( score_l == 4'd8 ) ? FINAL_ABILITY_RED : (( score_l == 4'd7 && dx > 9'b011111111 ) ? FINAL_ABILITY_BLUE : FINAL_FOLLOW_BALL));
			FINAL_ABILITY_RED:		next_state_ai = ( player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd5 ) ? IDEL_WAIT :(( score_l == 4'd9 ) ? FINAL_ABILITY : (( score_l == 4'd8 && dx > 9'b011111111 ) ? FINAL_ABILITY_RED : FINAL_FOLLOW_BALL));
			FINAL_ABILITY:			next_state_ai = ( player_id == 3'd0 || score_l == 4'd11 || player_id != 3'd5 ) ? IDEL_WAIT :(( score_l >= 4'd9 && dx > 9'b011111111 ) ? FINAL_ABILITY : FINAL_FOLLOW_BALL);
			FINAL_HIT:				next_state_ai = FINAL_FOLLOW_BALL;
			FINAL_WAIT:				next_state_ai = ( score_l >= 4'd4 ) ? FINAL_SPEED : ((x > 9'd6) ? FINAL_FOLLOW_BALL : FINAL_WAIT);
			
			default: 				next_state_ai = IDEL_WAIT; 
			
			
		endcase
	end
	
	always @(posedge clk)
	begin
		if (current_state_ai == IDEL_WAIT)
			begin
				go_r <=0;
				speed_r <=0;
				up_r <= 0;
				down_r <= 1;
				hold_y_lp <=0;
				dy_ai <= 3'd0;
				goTime_ai <= 2'd3;
				ability_rp <= 3'd0;
				fire <= 0;
			end
			
			
		
		if (current_state_ai == ONEVONE_START)
			begin
				dy_ai <= 3'd0;
				goTime_ai <= 2'd3;
				ability_rp <= 3'd0;
				fire <= 0;
			end			
		if (current_state_ai == ONEVONE_LOOP)
			begin
				up_r <= up_button ;
				down_r <= down_button;
				go_r <= go_button;
				speed_r <= speed_button ;
			end
			
			
			
		if (current_state_ai == NOOB_START)
			begin
				dy_ai <= 3'd0;
				goTime_ai <= 2'd3;
				ability_rp <= 3'd0;
				fire <= 0;
			end
			
		if (current_state_ai == NOOB_MIDDLE)
			begin
				if (dx > 9'b011111111 && y_rp < 8'd100)
					begin
						go_r <=1;
						up_r <= 0;
						down_r <= 1;
						speed_r <= 1;
					end
				else if (dx > 9'b011111111 && y_rp > 8'd140)
					begin
						go_r <=1;
						up_r <= 1;
						down_r <= 0;
						speed_r <= 1;
					end
				else 
					begin
						go_r <=0;
						up_r <= 1;
						down_r <= 0;
						speed_r <= 1;
					end
			end		
		if (current_state_ai == NOOB_OPPOSITE)
			begin
				if (paddle_l == 1)
					hold_y_lp <= y_lp +8'd16;
				if (hold_y_lp >= 8'd160 && y_rp + 8'd16 > 8'd40 )
					begin
						go_r <=1;
						up_r <= 1;
						down_r <= 0;
						speed_r <= 1;
					end
				else if (hold_y_lp <= 8'd80 && y_rp + 8'd16 < 8'd200 )
					begin
						go_r <=1;
						up_r <= 0;
						down_r <= 1;
						speed_r <= 1;
					end
			end
		if (current_state_ai == NOOB_FOLLOW)
			begin
				if ( y < y_rp + 8'd16)
					begin
						go_r <=1;
						up_r <= 1;
						down_r <= 0;
						if (x >= 9'd305)
							speed_r <= 0;
						else speed_r <= 1;
					end
				if ( y > y_rp + 8'd16 )
					begin
						go_r <=1;
						up_r <= 0;
						down_r <= 1;
						if (x >= 9'd305)
							speed_r <= 0;
						else speed_r <= 1;
					end	
			end
		if (current_state_ai == NOOB_WAIT)
			begin
				go_r <=0;
				speed_r <=0;
				up_r <= 1;
				down_r <= 0;
			end	

			
		if (current_state_ai == TRACK_START)
			begin
				dy_ai <= 3'd3;
				goTime_ai <= 2'd2;
				ability_rp <= 3'd0;
				fire <= 0;
			end
			
		if (current_state_ai == TRACK_FOLLOW)
			begin
				if ( y < y_rp + 8'd16)
					begin
						go_r <=1;
						up_r <= 1;
						down_r <= 0;
						if (x >= 9'd309)
							speed_r <= 0;
						else speed_r <= 1;
					end
				if ( y > y_rp + 8'd16)
					begin
						go_r <=1;
						up_r <= 0;
						down_r <= 1;
						if (x >= 9'd309)
							speed_r <= 0;
						else speed_r <= 1;
					end	
			end
			
		
		if (current_state_ai == DRUNK_START)
			begin
				dy_ai <= 3'd3;
				goTime_ai <= 2'd1;
				ability_rp <= 3'd0;
				fire <= 0;
			end
		
		if (current_state_ai == DRUNK_FOLLOW)
			begin
				ability_rp <= 3'd0;
				fire <= 0;
				if (score_l >= 4'd6)
				begin
					dy_ai <= 3'd7;
					goTime_ai <= 2'd1;
				end
				else
				begin
					dy_ai <= 3'd3;
					goTime_ai <= 2'd1;
				end
					
				if ( dy_ai == 3'd2 )
				begin
					if ( y - random [6:0] < y_rp + 8'd16)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							if (x >= 9'd309)
								speed_r <= 0;
							else speed_r <= 1;
						end
					if ( y + random [6:0] > y_rp + 8'd16)
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							if (x >= 9'd309)
								speed_r <= 0;
							else speed_r <= 1;
						end	
				end
				else
				begin
					if ( y - random [3:0] < y_rp + 8'd16)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							if (x >= 9'd309)
								speed_r <= 0;
							else speed_r <= 1;
						end
					if ( y + random [3:0] > y_rp + 8'd16)
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							if (x >= 9'd309)
								speed_r <= 0;
							else speed_r <= 1;
						end	
				end
			end	
		if (current_state_ai == DRUNK_SPEED)
			begin
				dy_ai <= 3'd7;
				goTime_ai <= 2'd1;
				ability_rp <= 3'd0;
				fire <= 0;
			end	
		if (current_state_ai == DRUNK_ABILITY_GREEN)
			begin
			if ( y_lp - random [5:0] < y_rp)
					begin
						go_r <=1;
						up_r <= 1;
						down_r <= 0;
						speed_r <= 1;
						ability_rp <= 3'd1;
						if ( y_rp % 8'd10 == 0 && ready_spr == 1)
							begin
							if (dy > 8'b011111111)
								dy_spr_ai <= random[7:0]%21;
							else dy_spr_ai <= -(random[7:0]%21);
								fire <= 1;
								ability_rp <=0;
							end
						if (fire == 1)
							fire <=0;
					end
				if ( y_lp + random [5:0] > y_rp)
					begin
						go_r <=1;
						up_r <= 0;
						down_r <= 1;
						speed_r <= 1;
						ability_rp <= 3'd1;
						if ( y_rp % 8'd10 == 0 && ready_spr == 1)
							begin
							if (dy > 8'b011111111)
								dy_spr_ai <= random[7:0]%21;
							else dy_spr_ai <= -(random[7:0]%21);
								fire <= 1;
								ability_rp<=0;
							end
						if (fire == 1)
							fire <=0;
					end	
			end
		if (current_state_ai == DRUNK_WAIT)
			begin
				ability_rp <= 3'd0;
				fire <= 0;
				dy_ai <= 3'd7;
				goTime_ai <= 2'd3;
				if (y_rp + 8'd16 < 8'd120 + random[5:0])
					begin
						go_r <=1;
						up_r <= 0;
						down_r <= 1;
						speed_r <= 1;
					end
				else if (y_rp + 8'd16 > 8'd120 + random[5:0])
					begin
						go_r <=1;
						up_r <= 1;
						down_r <= 0;
						speed_r <= 1;
					end
			end	
			
			
		if (current_state_ai == FINAL_START)
			begin
				dy_ai <= 3'd1;
				goTime_ai <= 2'd2;
				ability_rp <= 3'd0;
				fire <= 0;
			end
		if (current_state_ai == FINAL_FOLLOW_BALL)
			begin
				ability_rp <= 3'd0;
				fire <= 0;
				if (( dy >= 8'd1 && dy <=8'd3 )|| ( dy <= 8'b11111111 && dy >= 8'b11111101))
				begin
					if ( y < y_rp + 8'd16)
					begin
						go_r <=1;
						up_r <= 1;
						down_r <= 0;
						if (x >= 9'd309)
							speed_r <= 0;
						else speed_r <= 1;
					end
					if ( y > y_rp + 8'd16)
					begin
						go_r <=1;
						up_r <= 0;
						down_r <= 1;
						if (x >= 9'd309)
							speed_r <= 0;
						else speed_r <= 1;
					end	
				end
				
				
				if (( dy > 8'd3 && dy <=8'd5 )|| ( dy < 8'b11111101 && dy >= 8'b11111011))
				begin
					begin
					if ( y < y_rp + 8'd16 && x >= 8'd290)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							speed_r <= 1;
						end
					else if ( y > y_rp + 8'd16 && x >= 8'd290)
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							speed_r <= 1;
						end	
					else if (dy > 8'b01111111)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							speed_r <= 1;
						end
					else if (dy <= 8'b01111111)
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							speed_r <= 1;
						end
					end
				end
				
				if (( dy > 8'd5 && dy <=8'd7 )|| ( dy < 8'b11111011 && dy >= 8'b11111001))
				begin
					begin
					if ( y < y_rp + 8'd16 && x >= 8'd300)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							speed_r <= 1;
						end
					else if ( y > y_rp + 8'd16 && x >= 8'd300)
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							speed_r <= 1;
						end	
					else if (dy > 8'b01111111)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							speed_r <= 1;
						end
					else if (dy <= 8'b01111111)
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							speed_r <= 1;
						end
					end
				end
				
				if ( dy > 8'd7 || dy < 8'b11111001 )
				begin
					if ( y < y_rp + 8'd16 && x >= 8'd310)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							speed_r <= 1;
						end
					else if ( y > y_rp + 8'd16 && x >= 8'd310)
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							speed_r <= 1;
						end	
					else if (dy > 8'b01111111)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							speed_r <= 1;
						end
					else if (dy <= 8'b01111111)
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							speed_r <= 1;
						end
				end
			end
	
		if (current_state_ai == FINAL_SPEED)
			begin
				dy_ai <= 3'd4;
				goTime_ai <= 2'd1;
				ability_rp <= 3'd0;
				fire <= 0;
			end	
		if (current_state_ai == FINAL_ABILITY_GREEN)
			begin
				if (y_rp < 0)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							speed_r <= 1;
						end
				else if ( y_rp + 8'd33 != 8'd240 )
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							speed_r <= 0;
							ability_rp <= 3'd1;
							if ( ready_spr == 1 && ( y_rp + 8'd16 == 8'd40 || y_rp + 8'd16 == 8'd80 || y_rp + 8'd16 == 8'd120  || y_rp + 8'd16 == 8'd160  || y_rp + 8'd16 == 8'd200))
								begin
									dy_spr_ai<=0;
									fire <= 1;
									ability_rp <= 3'd0;
								end
							if (fire == 1) fire <=0;
						end	
			end	
		if (current_state_ai == FINAL_ABILITY_YELLOW)
			begin
				if (random [7:0] < y_rp + 8'd16)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							speed_r <= 1;
							ability_rp <= 3'd2;
						end
				if (random [7:0] > y_rp + 8'd16)
						begin
							go_r <=1;
							up_r <= 0;
							down_r <= 1;
							speed_r <= 1;
							ability_rp <= 3'd2;
						end	
				if ( y_rp%8'd12 == 0 && ready_spr == 1 )
						begin
							dy_spr_ai <= dy;
							fire <= 1;
							ability_rp <= 3'd0;
						end
				if (fire == 1)
						fire <= 0;
			end	
		if (current_state_ai == FINAL_ABILITY_BLUE)
			begin
				if ( dy_l > 8'b01111111 &&  y_lp + dy_l - 5'd5 < y_rp)
							begin
								go_r <=1;
								up_r <= 1;
								down_r <= 0;
								speed_r <= 1;
								ability_rp <= 3'd3;
								if ( y_lp + dy_l  < y_rp )
									speed_r <= 0;
								if ( y_lp + dy_l - 5'd5 == y_rp && ready_spr == 1)
									begin
										dy_spr_ai <= 0;
										fire <= 1;
										ability_rp <= 3'd0;
									end
								if (fire == 1) fire <= 0;
							end
						if ( dy_l <= 8'b01111111 &&  y_lp + dy_l + 5'd5 > y_rp)
							begin
								go_r <=1;
								up_r <= 0;
								down_r <= 1;
								speed_r <= 1;
								ability_rp <= 3'd3;
								if ( y_lp + dy_l  < y_rp )
									speed_r <= 0;
								if ( y_lp + dy_l + 5'd5 == y_rp && ready_spr == 1)
									begin
										dy_spr_ai <= 0;
										fire <= 1;
										ability_rp <= 3'd0;
									end
								if (fire == 1) fire <= 0;
							end	
			end	
		if (current_state_ai == FINAL_ABILITY_RED)
			begin
				if (dy > 8'b01111111 &&  y + dy < y_rp + 8'd16)
					begin
						go_r <=1;
						up_r <= 1;
						down_r <= 0;
						ability_rp <= 3'd4;
						if (y_rp == y + dy && ready_spr == 1 && x <= 9'd10 + x_lp)
							begin
								if (random [6] == 0)
									dy_spr_ai <= 8'd4;
								else dy_spr_ai <= 8'b11111100;
								fire <= 1;
								ability_rp <= 3'd0;
							end
						if (fire == 1) fire <= 0;
					end
				if ( dy <= 8'b01111111 && y + dy > y_rp + 8'd16)
					begin
						go_r <=1;
						up_r <= 0;
						down_r <= 1;
						ability_rp <= 3'd4;
						if (y_rp == y + dy && ready_spr == 1 && x <= 9'd10 + x_lp)
							begin
								if (random [6] == 0)
									dy_spr_ai <= 8'd4;
								else dy_spr_ai <= 8'b11111100;
								fire <= 1;
								ability_rp <= 3'd0;
							end
						if (fire == 1) fire <= 0;
					end	
			end
		if (current_state_ai == FINAL_ABILITY)
			begin
				ability_rp <= random[2:0]%3'd5;
				if (ability_rp == 3'd0)
					ability_rp <= 3'd4;
				if (dy > 8'b01111111 &&  y + dy < y_rp + 8'd16 && ability_rp != 3'd2)
					begin
						go_r <=1;
						up_r <= 1;
						down_r <= 0;
						if (y_rp == y + dy && ready_spr == 1 && x <= 9'd10 + x_lp)
							begin
								if (ability_rp == 3'd1)
									dy_spr_ai <= random[7:0]%20;
								if (ability_rp == 3'd3)
									dy_spr_ai <= random[7:0]%14;
								else
									dy_spr_ai <= random[7:0]%3;
								fire <= 1;
								ability_rp <= 3'd0;
							end
						if (fire == 1) fire <= 0;
					end
				if ( dy <= 8'b01111111 && y + dy > y_rp + 8'd16 && ability_rp != 3'd2)
					begin
						go_r <=1;
						up_r <= 0;
						down_r <= 1;
						if (y_rp == y + dy && ready_spr == 1 && x <= 9'd10 + x_lp)
							begin
								if (ability_rp == 3'd1)
									dy_spr_ai <= -random[7:0]%20;
								if (ability_rp == 3'd3)
									dy_spr_ai <= -random[7:0]%14;
								else
									dy_spr_ai <= -random[7:0]%3;
								fire <= 1;
								ability_rp <= 3'd0;
							end
						if (fire == 1) fire <= 0;
					end				
				if (ability_rp == 3'd2)
				begin
					if ( y_lp + 8'd16 >= 8'd120)
							begin
								go_r <=1;
								up_r <= 1;
								down_r <= 0;
								speed_r <= 1;
								if ( y_rp == 8'd0)
									begin
										dy_spr_ai <= random[7:0]%8;
										fire <= 1;
										ability_rp <= 3'd0;
									end
								if (fire == 1) fire <= 0;
							end
					if ( y_lp + 8'd16 < 8'd120)
						begin
							go_r <=1;
							up_r <= 1;
							down_r <= 0;
							speed_r <= 1;
							if ( y_rp == 8'd208)
								begin
									dy_spr_ai <= random[7:0]%8;
									fire <= 1;
									ability_rp <= 3'd0;
								end
							if (fire == 1) fire <= 0;
						end
				end	
			end


			if (current_state_ai == FINAL_WAIT)
			begin
				go_r <=0;
				speed_r <=0;
				up_r <= 1;
				down_r <= 0;
			end	
			
		current_state_ai <= next_state_ai;
	end	
endmodule


module lfsr_counter(
    input clk,
	input reset,
    output reg [7:0] lfsr);
	
wire d0,lfsr_equal;
reg lfsr_done;
xnor(d0,lfsr[7],lfsr[5],lfsr[4],lfsr[3]);
assign lfsr_equal = (lfsr == 8'h80);

always @(posedge clk,posedge reset) begin
    if(reset) begin
        lfsr <= 0;
        lfsr_done <= 0;
    end
    else begin
        lfsr <= lfsr_equal ? 8'h0 : {lfsr[6:0],d0};
        lfsr_done <= lfsr_equal;
    end
end
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
