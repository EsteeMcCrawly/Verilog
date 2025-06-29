// This module creates a ball that moves in the game. In its current state, the balls are 3x3
// but the module is parameterized to be able to create a ball of any odd number of pixels 

module ball #(parameter xloc_start = 320,
	          parameter yloc_start = 240,
	          parameter xdir_start = 0,
	          parameter ydir_start = 0,
	          parameter size = 3,
	          parameter start_player = 0)
(
    input	    clk,      // 100 MHz system clock
    input	    pixpulse, // every 4 clocks for 25MHz pixel rate
    input	    rst,
    input [9:0]	hcount, // x-location where we are drawing
    input [9:0]	vcount, // y-location where we are drawing
    input	    empty, // is this pixel empty
    input       drawblocks, //this should be the OR of all draw blocks
    input [1:0] paddleUp,
    input [1:0] paddleDown,
    input [1:0] player0,
    input [1:0] player1,
    input	    move, // signal to update the location of the ball
    input       reset,
    output	    draw_ball, // is the ball being drawn here?
    output reg  [9:0] xloc, // x-location of the ball
    output reg  [9:0] yloc, // y-location of the ball
    output reg  player, // the last player paddle to touch the ball
    output reg  broken0,//did the ball break a block for player 0?
    output reg  broken1 //did the ball break a block for player 1?
);

    reg [size + 1:0]	occupied_lft;
    reg [size + 1:0]	occupied_rgt;
    reg [size + 1:0]	occupied_bot;
    reg [size + 1:0]	occupied_top;
    reg				xdir, ydir;
    reg				update_neighbors;

    wire		    blk_lft_up, blk_lft_dn, blk_rgt_up, blk_rgt_dn;
    wire			blk_up_lft, blk_up_rgt, blk_dn_lft, blk_dn_rgt;
    wire			corner_lft_up, corner_rgt_up, corner_lft_dn, corner_rgt_dn;
    reg             sendUp;
    reg             sendDown;
   
    reg             prev_broken0;
    reg             prev_broken1;
   
    // are we pointing at a pixel in the ball?
    // this will make a square ball...
    assign draw_ball = (hcount <= xloc+(size-1)/2) & (hcount >= xloc-(size-1)/2) & (vcount <= yloc+(size-1)/2) & (vcount >= yloc-(size-1)/2) ?  1 : 0;

    // hcount goes from 0=left to 640=right
    // vcount goes from 0=top to 480=bottom
   
    // keep track of the neighboring pixels to detect a collision
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            occupied_lft <= {size+2{1'b0}};
            occupied_rgt <= {size+2{1'b0}};
            occupied_bot <= {size+2{1'b0}};
            occupied_top <= {size+2{1'b0}};
            player <= start_player;
        end 
        else if (pixpulse) begin  // only make changes when pixpulse is high
            broken0 <= 0;
            broken1 <= 0;
            if (update_neighbors) begin
                occupied_lft <= {size+2{1'b0}};
                occupied_rgt <= {size+2{1'b0}};
                occupied_bot <= {size+2{1'b0}};
                occupied_top <= {size+2{1'b0}};
	        end 
	        else if (~empty) begin
                if (vcount >= yloc-(size+1)/2 && vcount <= yloc+(size+1)/2) 
                if (hcount == xloc+(size+1)/2) begin
                    occupied_rgt[(yloc-vcount+(size+1)/2)] <= 1'b1;  // LSB is at bottom
                    if(player1[0]|player1[1]) player <= 1;
                    if(paddleUp) sendUp <= 1;
                    else sendUp <= 0;
                    if(paddleDown) sendDown <= 1;
                    else sendDown <= 0;
                    if(drawblocks & ~player & ~prev_broken0) broken0 <= 1;
                    if(drawblocks & player & ~prev_broken1) broken1 <= 1;
                end
                else if (hcount == xloc-(size+1)/2) begin
                    occupied_lft[(yloc-vcount+(size+1)/2)] <= 1'b1;
                    if(player0[0]|player0[1]) player <= 0;
                    if(paddleUp) sendUp <= 1;
                    else sendUp <= 0;
                    if(paddleDown) sendDown <= 1;
                    else sendDown <= 0;
                    if(drawblocks & ~player & ~prev_broken0) broken0 <= 1;
                    if(drawblocks & player & ~prev_broken1) broken1 <= 1;
                end
	      
                if (hcount >= xloc-(size+1)/2 && hcount <= xloc+(size+1)/2) 
                if (vcount == yloc+(size+1)/2) begin
                    occupied_bot[(xloc-hcount+(size+1)/2)] <= 1'b1;  // LSB is at right
                    if(drawblocks & ~player & ~prev_broken0) broken0 <= 1;
                    if(drawblocks & player & ~prev_broken1) broken1 <= 1;
                end
                else if (vcount == yloc-(size+1)/2) begin
                    occupied_top[(xloc-hcount+(size+1)/2)] <= 1'b1;
                    if(drawblocks & ~player & ~prev_broken0) broken0 <= 1;
                    if(drawblocks & player & ~prev_broken1) broken1 <= 1;
                end
            end
            prev_broken0 = broken0;
            prev_broken1 = broken1;
        end
    end	      

    assign blk_lft_up = |occupied_lft[size:(size+1)/2];  // upper left pixels are blocked
    assign blk_lft_dn = |occupied_lft[(size+1)/2:1];  // lower left pixels are blocked
    assign blk_rgt_up = |occupied_rgt[size:(size+1)/2];  // upper right pixels are blocked
    assign blk_rgt_dn = |occupied_rgt[(size+1)/2:1];  // lower right pixels are blocked

    assign blk_up_lft = |occupied_top[size:(size+1)/2];  // left-side top pixels are blocked
    assign blk_up_rgt = |occupied_top[(size+1)/2:1];  // right-side top pixels are blocked
    assign blk_dn_lft = |occupied_bot[size:(size+1)/2];  // left-side bottom pixels are blocked
    assign blk_dn_rgt = |occupied_bot[(size+1)/2:1];  // right-side bottom pixels are blocked

    assign corner_lft_up = occupied_lft[size+1] & ~blk_up_lft & ~blk_lft_up;   // only left top corner is blocked
    assign corner_rgt_up = occupied_rgt[size+1] & ~blk_up_rgt & ~blk_rgt_up;   // only right top corner is blocked
    assign corner_lft_dn = occupied_lft[0] & ~blk_dn_lft & ~blk_lft_dn;   // only left bottom corner is blocked
    assign corner_rgt_dn = occupied_rgt[0] & ~blk_dn_rgt & ~blk_rgt_dn;   // only right bottom corner is blocked
   
    always @(posedge clk or posedge rst) begin
        if (reset) begin
            xloc <= xloc_start;
            yloc <= yloc_start;
            xdir <= xdir_start;
            ydir <= ydir_start;
        end
        if (rst) begin
            xloc <= xloc_start;
            yloc <= yloc_start;
            xdir <= xdir_start;
            ydir <= ydir_start;
            update_neighbors <= 0;
        end 
        else if (pixpulse) begin 
            update_neighbors <= 0; // default
            if (move) begin

                case ({xdir,ydir})
                    2'b00: begin  // heading to the left and up
                        // if the left side of the ball makes contact the x-direction changes
                        if (blk_lft_up | corner_lft_up) begin
                            xloc <= xloc + 1;
                            xdir <= ~xdir;
                        end 
                        else begin
                        // if the ball makes no contact the ball keeps moving to the left
                            xloc <= xloc - 1;
                        end
                        if (sendUp) begin
                        // if the ball makes contact with the top half of the paddle its direction stays the same
                            yloc <= yloc - 1;
                            ydir <= ydir;
                        end
                        // if the top of the ball makes contact or hits the
                        // bottom half of the paddle the y-direction changes
                        if ((blk_up_lft | corner_lft_up) | sendDown) begin
                            yloc <= yloc + 1;
                            ydir <= ~ydir;
                        end 
                        else begin
                        // if the ball makes no contact the ball keeps moving up
                            yloc <= yloc - 1;
                        end
                    end
                    2'b01: begin  // heading to the left and down
                        // if the left side of ball makes contact the x-direction changes
                        if (blk_lft_dn | corner_lft_dn) begin
                            xloc <= xloc + 1;
                            xdir <= ~xdir;
                        end 
                        else begin
                        // if the ball makes no contact the ball keeps moving to the left
                            xloc <= xloc - 1;
                        end
                        if (sendDown) begin
                        // if the ball makes contact with the bottom half
                        // of the paddle its direction stays the same
                            yloc <= yloc + 1;
                            ydir <= ydir;
                        end
                        else if ((blk_dn_lft | corner_lft_dn)| sendUp) begin
                        // if the bottom of the ball makes contact or hits
                        // the top half of the paddle the y-direction changes
                            yloc <= yloc - 1;
                            ydir <= ~ydir;
                        end
                        else begin
                        // if the ball makes no contact the ball keeps moving down
                            yloc <= yloc + 1;
                        end
                    end
                    2'b10: begin  // heading to the right and up
                        // if the right side of the ball makes contact the x-direction changes
                        if (blk_rgt_up | corner_rgt_up) begin
                            xloc <= xloc - 1;
                            xdir <= ~xdir;
                        end
                        else begin
                        // if the ball makes no contact the ball keeps moving to the right
                            xloc <= xloc + 1;
                        end
                        if (sendUp) begin
                        // if the ball makes contact with the top half
                        // of the paddle its direction stays the same
                            yloc <= yloc - 1;
                            ydir <= ydir;
                        end
                        else if ((blk_up_rgt | corner_rgt_up) | sendDown) begin
                        // if the top half of the ball makes contact or hits
                        // the bottom half of the paddle the y-direction changes
                            yloc <= yloc + 1;
                            ydir <= ~ydir;
                        end
                        else begin
                        // if the ball makes no contact the ball keeps moving up
                            yloc <= yloc - 1;
                        end
                    end
                    2'b11: begin  // heading to the right and down
                        // if the right side of the ball makes contact the x-direction changes
                        if (blk_rgt_dn | corner_rgt_dn) begin
                            xloc <= xloc - 1;
                            xdir <= ~xdir;
                        end
                        else begin
                        // if the ball makes no contact the ball keeps moving to the right
                            xloc <= xloc + 1;
                        end
                        if (sendDown) begin
                        // if the ball makes contact with the bpttom half
                        // of the paddle its direction stays the same
                            yloc <= yloc + 1;
                            ydir <= ydir;
                        end
                        else if ((blk_dn_rgt | corner_rgt_dn) | sendUp) begin
                        // if the bottom half of the ball makes contact or hits
                        // the top half of the paddle the y-direction changes
                            yloc <= yloc - 1;
                            ydir <= ~ydir;
                        end
                        else begin
                        // if the ball makes no contact the ball keeps moving down
                            yloc <= yloc + 1;
                        end
                    end
                endcase 
                update_neighbors <= 1;
            end 
        end 
    end
endmodule // ball
