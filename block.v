// This module creates a breakable block used for the game. It uses similar logic to the ball module to check for collisions

module block #(parameter xloc = 120,
	           parameter yloc = 100,
	           parameter xsize_div_2 = 20,
	           parameter ysize_div_2 = 10)
(
    input	    clk,         // 100 MHz system clock
    input	    pixpulse,    // every 4 clocks for 25MHz pixel rate
    input	    rst,         // reset button for the FPGA
    input [9:0]	hcount,      // x-location that is being drawn
    input [9:0]	vcount,      // y-location that is being drawn
    input	    empty,       // tells if the pixel is empty or occupied
    input	    move,        // signal to update the status of the block
    input	    unbreak,     // respawns the block to its original location and state
    output	    draw_block,  // tells where the block being drawn
    output reg	broken       // tells if the block is broken nor unbroken
);

    reg  [ysize_div_2 * 2 : 0] occupied_lft; // used to check if the left side of the block is occupised
    reg  [ysize_div_2 * 2 : 0] occupied_rgt; // used to check if the right side of the block is occupised
    reg  [xsize_div_2 * 2 : 0] occupied_bot; // used to check if the bottom side of the block is occupised
    reg  [xsize_div_2 * 2 : 0] occupied_top; // used to check if the top side of the block is occupised

    wire blk_lft, blk_rgt, blk_up, blk_dn; // used to check if the left, right, top, and bottom pixels are blocked, respectively
    
    // controls where the block is drawn    
    assign draw_block = (hcount <= xloc+xsize_div_2) & (hcount >= xloc-xsize_div_2) & (vcount <= yloc+ysize_div_2) & (vcount >= yloc-ysize_div_2) ?  ~broken : 0;

    // hcount goes from 0=left to 640=right
    // vcount goes from 0=top to 480=bottom
    
    // keep track of the neighboring pixels to detect a collision
    always @(posedge clk or posedge rst) begin
	   if (rst) begin  //reset the occupied values to 0 if the reset button is pressed
           occupied_lft <= 0;
           occupied_rgt <= 0;
           occupied_bot <= 0;
           occupied_top <= 0;
	   end 
	   else if (pixpulse) begin  // only make changes when pixpulse is high (25 MHz instead of 100 MHz)
	       // logic to check if empty
	       if (vcount >= yloc - (ysize_div_2 + 1) && vcount <= yloc + (ysize_div_2 + 1)) 
	       if (hcount == xloc + (xsize_div_2 + 1))
	           occupied_rgt[(yloc - vcount + (ysize_div_2 + 1))] <= ~empty;  // LSB is at bottom
	       else if (hcount == xloc - (xsize_div_2 + 1))
	           occupied_lft[(yloc - vcount + (ysize_div_2 + 1))] <= ~empty;
	      
	       if (hcount >= xloc - (xsize_div_2 + 1) && hcount <= xloc + (xsize_div_2 + 1)) 
	       if (vcount == yloc + (ysize_div_2 + 1))
	           occupied_bot[(xloc - hcount + (xsize_div_2 + 1))] <= ~empty;  // LSB is at right
	       else if (vcount == yloc - (ysize_div_2 + 1))
	           occupied_top[(xloc - hcount + (xsize_div_2 + 1))] <= ~empty;
	   end
    end	      

    assign blk_lft = |occupied_lft;  // upper left pixels are blocked
    assign blk_rgt = |occupied_rgt;  // upper right pixels are blocked

    assign blk_up = |occupied_top;   // left-side top pixels are blocked
    assign blk_dn = |occupied_bot;   // left-side bottom pixels are blocked

    always @(posedge clk or posedge rst) begin
        if (rst) begin  // reset button changes the block to be not broken
	        broken <= 0;
	    end 
        else if (pixpulse) begin
            if (unbreak) begin  // if unbreak is high, the block gets reset
                broken <= 0;
            end
            if (move) begin
                // if the pixels are blocked in any direction, a collision has occurred
                if (blk_lft | blk_dn | blk_up | blk_rgt) begin
                    broken <= 1;		 
                end
            end 
        end 
    end 
   
endmodule 
