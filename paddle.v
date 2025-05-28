

// mxn paddle drawing and movement control 

module paddle #(parameter xloc_start=320,
	      parameter yloc_start=240,
	      parameter width=3,
	      parameter height=21)
(
    input	         clk, // 100 MHz system clock
    input	         pixpulse, // every 4 clocks for 25MHz pixel rate
    input	         rst,
    input [9:0]	     hcount, // x-location where we are drawing
    input [9:0]	     vcount, // y-location where we are drawing
    input            up_button,
    input            down_button,
    input	         empty, // is this pixel empty
    input	         move, // signal to update the location of the ball
    input            pass_dir, //the y direction that the ball is pushed
    input            pass_player, //the player that hits the ball
    output reg	     draw_paddle, // is the ball being drawn here?
    output reg [9:0] xloc, // x-location of the ball
    output reg [9:0] yloc // y-location of the ball
);

    reg [height+1:0]	 occupied_lft;
    reg [height+1:0]	 occupied_rgt;
    reg [width+1:0]	 occupied_bot;
    reg [width+1:0]	 occupied_top;
    reg				 ydir;
    reg				 update_neighbors;
    wire				 blk_lft_up, blk_lft_dn, blk_rgt_up, blk_rgt_dn;
    wire				 blk_up_lft, blk_up_rgt, blk_dn_lft, blk_dn_rgt;
    wire				 corner_lft_up, corner_rgt_up, corner_lft_dn, corner_rgt_dn;
   
   // are we pointing at a pixel in the ball?
   // this will make a square ball...
    always @(*)  begin
        if(pass_dir == 0) begin
            draw_paddle = (hcount <= xloc+(width+1)/2) & (hcount >= xloc-(width+1)/2) & (vcount <= yloc) & (vcount >= yloc-(height+1)/2) ?  1 : 0;
        end
        else begin
            draw_paddle = (hcount <= xloc+(width+1)/2) & (hcount >= xloc-(width+1)/2) & (vcount <= yloc+(height+1)/2) & (vcount >= yloc) ?  1 : 0;
        end
    end

   // hcount goes from 0=left to 640=right
   // vcount goes from 0=top to 480=bottom
   
   // keep track of the neighboring pixels to detect a collision
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            occupied_lft <= {height+2{1'b0}};
            occupied_rgt <= {height+2{1'b0}};
            occupied_bot <= {width+2{1'b0}};
            occupied_top <= {width+2{1'b0}};
        end 
	    else if (pixpulse) begin  // only make changes when pixpulse is high
            if (update_neighbors) begin
                occupied_lft <= {height+2{1'b0}};
                occupied_rgt <= {height+2{1'b0}};
                occupied_bot <= {width+2{1'b0}};
                occupied_top <= {width+2{1'b0}};
            end 
            else if (~empty) begin
                if (vcount >= yloc-(height+1)/2 && vcount <= yloc+(height+1)/2) 
                if (hcount == xloc+(width+1)/2)
                    occupied_rgt[(yloc-vcount+(height+1)/2)] <= 1'b1;  // LSB is at bottom
                else if (hcount == xloc-(width+1)/2)
                    occupied_lft[(yloc-vcount+(height+1)/2)] <= 1'b1;
	      
                if (hcount >= xloc-(width+1)/2 && hcount <= xloc+(width+1)/2) 
                if (vcount == yloc+(height+1)/2)
                    occupied_bot[(xloc-hcount+(width+1)/2)] <= 1'b1;  // LSB is at right
                else if (vcount == yloc-(height+1)/2)
                    occupied_top[(xloc-hcount+(width+1)/2)] <= 1'b1;
            end
        end
    end	      

    assign blk_lft_up = |occupied_lft[height:(height+1)/2];  // upper left pixels are blocked
    assign blk_lft_dn = |occupied_lft[(height+1)/2:1];  // lower left pixels are blocked
    assign blk_rgt_up = |occupied_rgt[height:(height+1)/2];  // upper right pixels are blocked
    assign blk_rgt_dn = |occupied_rgt[(height+1)/2:1];  // lower right pixels are blocked

    assign blk_up_lft = |occupied_top[width:(width+1)/2];  // left-side top pixels are blocked
    assign blk_up_rgt = |occupied_top[(width+1)/2:1];  // right-side top pixels are blocked
    assign blk_dn_lft = |occupied_bot[width:(width+1)/2];  // left-side bottom pixels are blocked
    assign blk_dn_rgt = |occupied_bot[(width+1)/2:1];  // right-side bottom pixels are blocked

    assign corner_lft_up = occupied_lft[height+1] & ~blk_up_lft & ~blk_lft_up;   // only left top corner is blocked
    assign corner_rgt_up = occupied_rgt[height+1] & ~blk_up_rgt & ~blk_rgt_up;   // only right top corner is blocked
    assign corner_lft_dn = occupied_lft[0] & ~blk_dn_lft & ~blk_lft_dn;   // only left bottom corner is blocked
    assign corner_rgt_dn = occupied_rgt[0] & ~blk_dn_rgt & ~blk_rgt_dn;   // only right bottom corner is blocked
   
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            xloc <= xloc_start;
            yloc <= yloc_start;
	        ydir <= 0;
	        update_neighbors <= 0;
	    end 
	    else if (pixpulse) begin
            update_neighbors <= 0; // default
            if (move) begin
                case ({up_button, down_button})
                    2'b01: begin  // heading down
                        if (blk_dn_lft | corner_lft_dn | blk_dn_rgt | corner_rgt_dn) begin
                            yloc <= yloc;
                        end 
                        else begin
                            yloc <= yloc + 2;
                        end
                    end
                    2'b10: begin  // heading up
                        if (blk_up_lft | corner_lft_up | blk_up_rgt | corner_rgt_up) begin
                            yloc <= yloc;
                        end 
                        else begin
                            yloc <= yloc - 2;
                        end
                    end
                    1'b00: begin  // no inputs
                        yloc <= yloc;
                    end
                    1'b00: begin  // conflicting inputs
                        yloc <= yloc;
                    end
                endcase 
	      update_neighbors <= 1;
            end 
        end 
    end
   
endmodule // ball