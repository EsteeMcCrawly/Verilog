
module top_vga(
    input wire	      clk, // 100 MHz board clock on Nexys A7
    input wire	      rst, // Active-high reset
    input wire [2:1]  up,
    input wire [2:1]  down,
    input wire        select,
    // VGA outputs
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire	      hsync,
    output wire	      vsync
);

    reg rst_score;
    wire [9:0]   hcount;
    wire [9:0]   vcount;
    wire	     hblank;
    wire	     vblank;
    wire	     pixpulse;
    wire	     is_a_wall;
    wire         empty;
    wire [1:0]   draw_ball;
    wire [1:0]   player_ball;
    wire [119:0] draw_block;
    wire [3:0]   draw_paddle;
    wire	     move;
    reg [11:0]   current_pixel;
    reg          vblank_d1;
    reg          unbreak;
    reg [7:0]    score0; //player scores
    reg [7:0]    score1;
    wire [1:0]   broken0; //the current blocks broken by a player
    wire [1:0]   broken1;
    reg [1:0]    prev_broken0, prev_broken1; //the previous state of broken(s)
    reg [7:0]    add0; //the current amount to add to each score
    reg [7:0]    add1;
    wire [1:0]   draw_score;
    wire [6:0]   draw_idle;      
    wire [11:0]  draw_win;
    wire         draw_p0;
    wire         draw_p1;
    wire [11:0]  broken;
    wire [1:0]   player0;
    wire [1:0]   player1;
    wire [1:0]   paddleDown;
    wire [1:0]   paddleUp;
    
    reg [1:0]    state;
    reg [1:0]    next_state;
    reg [7:0]    coins;
    reg          prev_coin; //coin debounce

    localparam WALL_COLOR = 12'h00A;
    localparam BALL_COLOR = 12'h83F;
    localparam EMPTY_COLOR = 12'hBFF;
    localparam BLOCK_COLOR = 12'hACF;
    localparam PLAYER0_COLOR = 12'hB11;
    localparam PLAYER1_COLOR = 12'h5E1;
   
   //---------------------------------------------
   // VGA Timing Generator
   //---------------------------------------------
    vga_timing vga_gen (
        .clk      (clk),
        .pixpulse (pixpulse),
        .rst      (rst),  //active high
        .hcount   (hcount[9:0]),
        .vcount   (vcount[9:0]),
        .hsync    (hsync),
        .vsync    (vsync),
        .hblank   (hblank),
        .vblank   (vblank)
	);

//Idle Screen Text and Score (Coins)

    char #(280, 244) idle_C ( 
		.clk	   (clk),
		.pixpulse  (pixpulse),
		.rst	   (rst),
		.hcount	   (hcount[9:0]),
		.vcount	   (vcount[9:0]),
		.char      (2),
		.draw_char (draw_idle[0])
	);

    char #(288, 244) idle_O ( 
		  .clk		 (clk),
		  .pixpulse  (pixpulse),
		  .rst		 (rst),
		  .hcount	 (hcount[9:0]),
		  .vcount	 (vcount[9:0]),
		  .char      (14),
		  .draw_char (draw_idle[1])
    );

    char #(296, 244) idle_I ( 
		  .clk		 (clk),
		  .pixpulse  (pixpulse),
		  .rst		 (rst),
		  .hcount	 (hcount[9:0]),
		  .vcount	 (vcount[9:0]),
		  .char      (8),
		  .draw_char (draw_idle[2])
    );

    char #(304, 244) idle_N ( 
		  .clk		 (clk),
		  .pixpulse  (pixpulse),
		  .rst		 (rst),
		  .hcount	 (hcount[9:0]),
		  .vcount	 (vcount[9:0]),
		  .char      (13),
		  .draw_char (draw_idle[3])
	);

    char #(312, 244) idle_S ( 
		  .clk		 (clk),
		  .pixpulse  (pixpulse),
		  .rst		 (rst),
		  .hcount	 (hcount[9:0]),
		  .vcount	 (vcount[9:0]),
		  .char      (18),
		  .draw_char (draw_idle[4])
	);

    char #(320, 244) idle_colon ( 
		  .clk		 (clk),
		  .pixpulse  (pixpulse),
		  .rst		 (rst),
		  .hcount	 (hcount[9:0]),
		  .vcount	 (vcount[9:0]),
		  .char      (29),
		  .draw_char (draw_idle[5])
	);
		  
    score #(336, 244) idle_coins ( 
		  .clk		  (clk),
		  .pixpulse   (pixpulse),
		  .rst		  (rst),
		  .hcount	  (hcount[9:0]),
		  .vcount	  (vcount[9:0]),
		  .score      (coins),
		  .draw_score (draw_idle[6])
	);
		  

//    char #(320, 240) u_char_0 ( 
//		  .clk			(clk),
//		  .pixpulse     (pixpulse),
//		  .rst			(rst),
//		  .hcount		(hcount[9:0]),
//		  .vcount		(vcount[9:0]),
//		  .char         (20),
//		  .draw_char    (draw_score[2]));


//Game Screen Objects

    score #(12, 12) u_score_0 ( 
        .clk		  (clk),
		.pixpulse     (pixpulse),
	    .rst		  (rst),
		.hcount		  (hcount[9:0]),
		.vcount		  (vcount[9:0]),
		.score        (score0),
		.draw_score   (draw_score[0]));
		  
    score #(604, 12) u_score_1 ( 
		.clk		  (clk),
		.pixpulse     (pixpulse),
		.rst		  (rst),
		.hcount		  (hcount[9:0]),
		.vcount		  (vcount[9:0]),
		.score        (score1),
		.draw_score   (draw_score[1]));
		  
    paddle #(10,250,5,41) u_paddle_1a ( 
		// Outputs
        .draw_paddle  (draw_paddle[0]),
		.up_button    (up[2]),
        .down_button  (down[1]),
		.xloc		  (),
		.yloc		  (),
		// Inputs
		.clk		  (clk),
		.pixpulse     (pixpulse),
		.rst		  (rst),
		.hcount		  (hcount[9:0]),
		.vcount		  (vcount[9:0]),
		.empty		  (empty),
		.move		  ((up[1]|down[1])& move),
		.pass_dir     (0),
		.pass_player  (0));
		  
    paddle #(10,250,5,41) u_paddle_1b ( 
		 // Outputs
        .draw_paddle  (draw_paddle[1]),
        .up_button    (up[1]),
        .down_button  (down[1]),
        .xloc		  (),
        .yloc		  (),
        // Inputs
        .clk		  (clk),
        .pixpulse     (pixpulse),
        .rst		  (rst),
        .hcount		  (hcount[9:0]),
        .vcount		  (vcount[9:0]),
        .empty		  (empty),
        .move		  ((up[1]|down[1])& move),
        .pass_dir     (1),
        .pass_player  (0));
		  
    paddle #(630,250,5,41) u_paddle_2a ( 
        // Outputs
        .draw_paddle  (draw_paddle[2]),
        .up_button    (up[2]),
        .down_button  (down[2]),
        .xloc		  (),
        .yloc		  (),
        // Inputs
        .clk		  (clk),
        .pixpulse     (pixpulse),
        .rst		  (rst),
        .hcount		  (hcount[9:0]),
        .vcount		  (vcount[9:0]),
        .empty		  (empty),
        .move		  ((up[2]|down[2])& move),
        .pass_dir     (0),
        .pass_player  (1));
        
    paddle #(630,250,5,41) u_paddle_2b ( 
        // Outputs
        .draw_paddle  (draw_paddle[3]),
        .up_button    (up[2]),
        .down_button  (down[2]),
        .xloc		  (),
        .yloc		  (),
        // Inputs
        .clk		  (clk),
        .pixpulse     (pixpulse),
        .rst		  (rst),
        .hcount		  (hcount[9:0]),
        .vcount		  (vcount[9:0]),
        .empty		  (empty),
        .move		  ((up[2]|down[2])& move),
        .pass_dir     (1),
        .pass_player  (1));

    genvar i;
        generate
            for (i = 0; i < 2; i = i + 1) begin : ball_gen

                ball #(335+10*i,240,i,1,3,i) u_ball_1 ( 
                    // Outputs
                    .draw_ball	  (draw_ball[i]),
                    .xloc		  (),
                    .yloc		  (),
                    // Inputs
                    .clk		  (clk),
                    .pixpulse     (pixpulse),
                    .rst		  (rst),
                    .hcount		  (hcount[9:0]),
                    .vcount		  (vcount[9:0]),
                    .empty		  (empty & ~|(draw_ball & ~(1 << i)) & ~|(draw_paddle) & ~(|draw_block)),
                    .move		  (move),
                    .reset        (unbreak),
                    .paddleUp     (paddleUp),
                    .paddleDown   (paddleDown),
                    .player0      (player0),
                    .player1      (player1),
                    .player       (player_ball[i]),
                    .drawblocks   (|draw_block),
                    .broken0      (broken0[i]),
                    .broken1      (broken1[i]));
                    
            end
        endgenerate
            
		  
    genvar j;
        generate
            for (j = 0; j < 60; j = j + 5) begin : block_gen_top

                block #(100+8*j, 140, 11, 5) u_block_1 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[j]),
                    .broken      (broken[j]));
                      
                block #(100+8*j, 120, 11, 5) u_block_2 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[j+1]),
                    .broken      (broken[j+1]));
                      
                block #(100+8*j, 100, 11, 5) u_block_3 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[j+2]),
                    .broken      (broken[j+2]));
                      
                block #(100+8*j, 80, 11, 5) u_block_4 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[j+3]),
                    .broken      (broken[j+3]));
                      
                block #(100+8*j, 60, 11, 5) u_block_5 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[j+4]),
                    .broken      (broken[j+4]));
                    
            end
        endgenerate
            
    genvar k;
        generate
            for (k = 60; k < 120; k = k + 5) begin : block_gen_bottom

                block #(100+8*(k-60), 420, 11, 5) u_block_6 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[k]),
                    .broken      (broken[k]));
                      
               block #(100+8*(k-60), 400, 11, 5) u_block_7 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[k+1]),
                    .broken      (broken[k+1]));
                      
               block #(100+8*(k-60), 380, 11, 5) u_block_8 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[k+2]),
                    .broken      (broken[k+2]));
                      
               block #(100+8*(k-60), 360, 11, 5) u_block_9 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[k+3]),
                    .broken      (broken[k+3]));
                      
               block #(100+8*(k-60), 340, 11, 5) u_block_10 ( 
                    .clk		 (clk),
                    .pixpulse    (pixpulse),
                    .rst		 (rst),
                    .hcount		 (hcount[9:0]),
                    .vcount		 (vcount[9:0]),
                    .empty		 (empty & ~|(draw_ball) & ~|(draw_paddle)),
                    .move		 (move),
                    .unbreak     (unbreak),
                    .draw_block  (draw_block[k+4]),
                    .broken      (broken[k+4]));
                    
            end
        endgenerate
   
    assign is_a_wall = ((hcount < 5) | (hcount > 635) | (vcount < 5) | (vcount > 475) | ((vcount > 300 & vcount < 315) & (hcount > 150 & hcount < 490)) | ((vcount > 180 & vcount < 195) & (hcount > 150 & hcount < 490)));

    assign empty = ~is_a_wall;
   
    assign player0 = draw_paddle[0] || draw_paddle[1];
    assign player1 = draw_paddle[2] || draw_paddle[3];
   
    assign paddleUp = draw_paddle[0] || draw_paddle[2];
    assign paddleDown = draw_paddle[1] || draw_paddle[3];

    assign move = (vblank & ~vblank_d1);  // move balls at start of vertical blanking

//Player Win Condition

    char #(268, 244) p0_P ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (15),
        .draw_char  (draw_win[0]));
		  
    char #(276, 244) p0_L ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (11),
        .draw_char  (draw_win[1]));
		  
	char #(284, 244) p0_A ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (0),
        .draw_char  (draw_win[2]));

	char #(292, 244) p0_Y ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (24),
        .draw_char  (draw_win[3]));

	char #(300, 244) p0_E ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (4),
        .draw_char  (draw_win[4]));
        
	char #(308, 244) p0_R ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (17),
        .draw_char  (draw_win[5]));
		  
	char #(316, 244) p0_space1 ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (26),
        .draw_char  (draw_win[6]));	  		  
		  
	char #(332, 244) p0_space2 ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (26),
        .draw_char  (draw_win[7]));
		  
	char #(340, 244) p0_W ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (22),
        .draw_char  (draw_win[8]));
		  
	char #(348, 244) p0_I ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (8),
        .draw_char  (draw_win[9]));		  
		  
	char #(356, 244) p0_N ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (13),
        .draw_char  (draw_win[10]));
		  
	char #(364, 244) p0_S ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (18),
        .draw_char  (draw_win[11]));
		  
//Player 1 Win Condition
	  
    char #(324, 244) p0_1 ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (27),
        .draw_char  (draw_p0));		
		  
//Player 2 Win Condition
	  
	char #(324, 244) p1_2 ( 
        .clk		(clk),
        .pixpulse   (pixpulse),
        .rst		(rst),
        .hcount		(hcount[9:0]),
        .vcount		(vcount[9:0]),
        .char       (28),
        .draw_char  (draw_p1));  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            vblank_d1 <= 0;
        end 
        else if (pixpulse) begin
            vblank_d1 <= vblank;
        end
    end
   
    reg [7:0] next_coins;
    reg next_prev_coin;
    reg prev_select;
   
    // Register the current pixel
    always @(posedge clk) begin
        if (pixpulse) begin
            // Deal with state machine
            state <= next_state;
            coins <= next_coins;
            prev_coin <= next_prev_coin;
            prev_select = select;
        end 
    end

    always @(*) begin
        // Deal with state machine
        next_state = state;
        next_coins = coins;
        next_prev_coin = 0;
        unbreak = 0;

        if(state == 0) begin //Idle state
            next_state = 0;
            if(up[1] & ~prev_coin) next_coins = coins + 1;
            if((select & ~prev_select) & coins > 0) begin
                next_coins = coins - 1;
                next_state = 1;
                unbreak = 1;
            end
            next_prev_coin = up[1];
            
        end 
        else if(state == 1) begin //Game State
            unbreak = 0;
            if(score0 > 49) next_state = 2;
            else if(score0 > 49 & score1 > 49) next_state = 2; //remote chance of tie :(
            else if(score1 > 49) next_state = 3;
            else if(rst) next_state = 0;
            else next_state = 1;
        end 
        else if(state == 2) begin //Player 1 wins
            if(select) next_state = 0;
            else if(rst) next_state = 0;
            else next_state = 2;
        end 
        else if(state == 3) begin //Player 2 wins
            if(select) next_state = 0;
            else if(rst) next_state = 0;
            else next_state = 3;
        end 
        else next_state = 0; //If not in a state --> go to idle

        if(&(broken)) begin 
            unbreak = 1; 
        end
        
    end

    always @(posedge clk) begin
        if (pixpulse) begin
            // Deal with screen colors
            if(state == 0) begin //Idle Screen
                if(|draw_idle) current_pixel <= WALL_COLOR;
                else current_pixel <= EMPTY_COLOR; 
            end
            else if(state == 1) begin //Game Screen
                if(is_a_wall|draw_score) current_pixel <= WALL_COLOR;
                else if(|(draw_ball&(~player_ball))) current_pixel <= PLAYER0_COLOR;
                else if(|(draw_ball&player_ball)) current_pixel <= PLAYER1_COLOR;
                else if(|draw_block) current_pixel <= BLOCK_COLOR;
                else if(draw_paddle[0] | draw_paddle[1]) current_pixel <= PLAYER0_COLOR;
                else if(draw_paddle[2] | draw_paddle[3]) current_pixel <= PLAYER1_COLOR;
                else current_pixel <= EMPTY_COLOR; 
            end
            else if(state == 2) begin //Player 1 Wins
                if(|draw_win|draw_p0) current_pixel <= WALL_COLOR;
                else current_pixel <= EMPTY_COLOR; 
            end
            else if(state == 3) begin //Player 2 Wins
                if(|draw_win|draw_p1) current_pixel <= WALL_COLOR;
                else current_pixel <= EMPTY_COLOR; 
            end
            else current_pixel <= EMPTY_COLOR; //Default case (after all ifs)
        end
    end
   
    integer s;
    always @(posedge clk) begin
        if (pixpulse) begin
            add0 <= 0;
            add1 <= 0;
            for (s = 0; s < 2; s = s + 1) begin
                if (broken0[s] && !prev_broken0[s])
                    add0 <= add0 + 1;
                if (broken1[s] && !prev_broken1[s])
                    add1 <= add1 + 1;
            end
        prev_broken0 <= broken0;
        prev_broken1 <= broken1;

        score0 <= score0 + add0;
        score1 <= score1 + add1;
        end
    
        if(rst_score | unbreak) begin
            score0 = 0;
            score1 = 0;
        end
        if(rst) rst_score = 1;
        else rst_score = 0;
    end

    // Map 12-bit to 4:4:4
    assign vgaRed   = (~hblank && ~vblank) ? current_pixel[11:8] : 4'b0;
    assign vgaGreen = (~hblank && ~vblank) ? current_pixel[7:4] : 4'b0;
    assign vgaBlue  = (~hblank && ~vblank) ? current_pixel[3:0] : 4'b0;
   
endmodule
   
