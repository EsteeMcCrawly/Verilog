

// 3 digit score module, 8x8 pixel digits

module char #(parameter xloc=40,
	      parameter yloc=40)
(
    input	clk, // 100 MHz system clock
    input	pixpulse, // every 4 clocks for 25MHz pixel rate
    input	rst,
    input [9:0]	hcount, // x-location where we are drawing
    input [9:0]	vcount, // y-location where we are drawing
    input [4:0]	char,
    output	draw_char 
);

    reg [2:0]	row;
   
    (*rom_style = "block" *) reg [7:0] chr_pix;
   
    always @(posedge clk) begin
        case ({char,row})  // each digit is 8 rows, 8 bits each row
            // Letter: A
            8'h00: chr_pix <= 8'b00011000;
            8'h01: chr_pix <= 8'b00100100;
            8'h02: chr_pix <= 8'b01000010;
            8'h03: chr_pix <= 8'b01000010;
            8'h04: chr_pix <= 8'b01111110;
            8'h05: chr_pix <= 8'b01000010;
            8'h06: chr_pix <= 8'b01000010;
            8'h07: chr_pix <= 8'b01000010;
            // Letter: B
            8'h08: chr_pix <= 8'b01111100;
            8'h09: chr_pix <= 8'b01000010;
            8'h0a: chr_pix <= 8'b01000010;
            8'h0b: chr_pix <= 8'b01111100;
            8'h0c: chr_pix <= 8'b01000010;
            8'h0d: chr_pix <= 8'b01000010;
            8'h0e: chr_pix <= 8'b01000010;
            8'h0f: chr_pix <= 8'b01111100;
            // Letter: C
            8'h10: chr_pix <= 8'b00111100;
            8'h11: chr_pix <= 8'b01000010;
            8'h12: chr_pix <= 8'b01000000;
            8'h13: chr_pix <= 8'b01000000;
            8'h14: chr_pix <= 8'b01000000;
            8'h15: chr_pix <= 8'b01000000;
            8'h16: chr_pix <= 8'b01000010;
            8'h17: chr_pix <= 8'b00111100;
            // Letter: D
            8'h18: chr_pix <= 8'b01111000;
            8'h19: chr_pix <= 8'b01000100;
            8'h1a: chr_pix <= 8'b01000010;
            8'h1b: chr_pix <= 8'b01000010;
            8'h1c: chr_pix <= 8'b01000010;
            8'h1d: chr_pix <= 8'b01000010;
            8'h1e: chr_pix <= 8'b01000100;
            8'h1f: chr_pix <= 8'b01111000;
            // Letter: E
            8'h20: chr_pix <= 8'b01111110;
            8'h21: chr_pix <= 8'b01000000;
            8'h22: chr_pix <= 8'b01000000;
            8'h23: chr_pix <= 8'b01111100;
            8'h24: chr_pix <= 8'b01000000;
            8'h25: chr_pix <= 8'b01000000;
            8'h26: chr_pix <= 8'b01000000;
            8'h27: chr_pix <= 8'b01111110;
            // Letter: F
            8'h28: chr_pix <= 8'b01111110;
            8'h29: chr_pix <= 8'b01000000;
            8'h2a: chr_pix <= 8'b01000000;
            8'h2b: chr_pix <= 8'b01111100;
            8'h2c: chr_pix <= 8'b01000000;
            8'h2d: chr_pix <= 8'b01000000;
            8'h2e: chr_pix <= 8'b01000000;
            8'h2f: chr_pix <= 8'b01000000;
            // Letter: G
            8'h30: chr_pix <= 8'b00111100;
            8'h31: chr_pix <= 8'b01000010;
            8'h32: chr_pix <= 8'b01000000;
            8'h33: chr_pix <= 8'b01000000;
            8'h34: chr_pix <= 8'b01001110;
            8'h35: chr_pix <= 8'b01000010;
            8'h36: chr_pix <= 8'b01000010;
            8'h37: chr_pix <= 8'b00111100;
            // Letter: H
            8'h38: chr_pix <= 8'b01000010;
            8'h39: chr_pix <= 8'b01000010;
            8'h3a: chr_pix <= 8'b01000010;
            8'h3b: chr_pix <= 8'b01111110;
            8'h3c: chr_pix <= 8'b01000010;
            8'h3d: chr_pix <= 8'b01000010;
            8'h3e: chr_pix <= 8'b01000010;
            8'h3f: chr_pix <= 8'b01000010;
            // Letter: I
            8'h40: chr_pix <= 8'b00111100;
            8'h41: chr_pix <= 8'b00010000;
            8'h42: chr_pix <= 8'b00010000;
            8'h43: chr_pix <= 8'b00010000;
            8'h44: chr_pix <= 8'b00010000;
            8'h45: chr_pix <= 8'b00010000;
            8'h46: chr_pix <= 8'b00010000;
            8'h47: chr_pix <= 8'b00111100;
            // Letter: J
            8'h48: chr_pix <= 8'b00011110;
            8'h49: chr_pix <= 8'b00000100;
            8'h4a: chr_pix <= 8'b00000100;
            8'h4b: chr_pix <= 8'b00000100;
            8'h4c: chr_pix <= 8'b00000100;
            8'h4d: chr_pix <= 8'b01000100;
            8'h4e: chr_pix <= 8'b01000100;
            8'h4f: chr_pix <= 8'b00111000;
            // Letter: K
            8'h50: chr_pix <= 8'b01000010;
            8'h51: chr_pix <= 8'b01000100;
            8'h52: chr_pix <= 8'b01001000;
            8'h53: chr_pix <= 8'b01110000;
            8'h54: chr_pix <= 8'b01001000;
            8'h55: chr_pix <= 8'b01000100;
            8'h56: chr_pix <= 8'b01000010;
            8'h57: chr_pix <= 8'b01000010;
            // Letter: L
            8'h58: chr_pix <= 8'b01000000;
            8'h59: chr_pix <= 8'b01000000;
            8'h5a: chr_pix <= 8'b01000000;
            8'h5b: chr_pix <= 8'b01000000;
            8'h5c: chr_pix <= 8'b01000000;
            8'h5d: chr_pix <= 8'b01000000;
            8'h5e: chr_pix <= 8'b01000000;
            8'h5f: chr_pix <= 8'b01111110;
            // Letter: M
            8'h60: chr_pix <= 8'b01000010;
            8'h61: chr_pix <= 8'b01100110;
            8'h62: chr_pix <= 8'b01011010;
            8'h63: chr_pix <= 8'b01011010;
            8'h64: chr_pix <= 8'b01000010;
            8'h65: chr_pix <= 8'b01000010;
            8'h66: chr_pix <= 8'b01000010;
            8'h67: chr_pix <= 8'b01000010;
            // Letter: N
            8'h68: chr_pix <= 8'b01000010;
            8'h69: chr_pix <= 8'b01100010;
            8'h6a: chr_pix <= 8'b01010010;
            8'h6b: chr_pix <= 8'b01001010;
            8'h6c: chr_pix <= 8'b01000110;
            8'h6d: chr_pix <= 8'b01000010;
            8'h6e: chr_pix <= 8'b01000010;
            8'h6f: chr_pix <= 8'b01000010;
            // Letter: O
            8'h70: chr_pix <= 8'b00111100;
            8'h71: chr_pix <= 8'b01000010;
            8'h72: chr_pix <= 8'b01000010;
            8'h73: chr_pix <= 8'b01000010;
            8'h74: chr_pix <= 8'b01000010;
            8'h75: chr_pix <= 8'b01000010;
            8'h76: chr_pix <= 8'b01000010;
            8'h77: chr_pix <= 8'b00111100;
            // Letter: P
            8'h78: chr_pix <= 8'b01111100;
            8'h79: chr_pix <= 8'b01000010;
            8'h7a: chr_pix <= 8'b01000010;
            8'h7b: chr_pix <= 8'b01111100;
            8'h7c: chr_pix <= 8'b01000000;
            8'h7d: chr_pix <= 8'b01000000;
            8'h7e: chr_pix <= 8'b01000000;
            8'h7f: chr_pix <= 8'b01000000;
            // Letter: Q
            8'h80: chr_pix <= 8'b00111100;
            8'h81: chr_pix <= 8'b01000010;
            8'h82: chr_pix <= 8'b01000010;
            8'h83: chr_pix <= 8'b01000010;
            8'h84: chr_pix <= 8'b01000010;
            8'h85: chr_pix <= 8'b01001010;
            8'h86: chr_pix <= 8'b01000100;
            8'h87: chr_pix <= 8'b00111010;
            // Letter: R
            8'h88: chr_pix <= 8'b01111100;
            8'h89: chr_pix <= 8'b01000010;
            8'h8a: chr_pix <= 8'b01000010;
            8'h8b: chr_pix <= 8'b01111100;
            8'h8c: chr_pix <= 8'b01001000;
            8'h8d: chr_pix <= 8'b01000100;
            8'h8e: chr_pix <= 8'b01000010;
            8'h8f: chr_pix <= 8'b01000010;
            // Letter: S
            8'h90: chr_pix <= 8'b00111110;
            8'h91: chr_pix <= 8'b01000000;
            8'h92: chr_pix <= 8'b01000000;
            8'h93: chr_pix <= 8'b00111100;
            8'h94: chr_pix <= 8'b00000010;
            8'h95: chr_pix <= 8'b00000010;
            8'h96: chr_pix <= 8'b01000010;
            8'h97: chr_pix <= 8'b00111100;
            // Letter: T
            8'h98: chr_pix <= 8'b01111110;
            8'h99: chr_pix <= 8'b00010000;
            8'h9a: chr_pix <= 8'b00010000;
            8'h9b: chr_pix <= 8'b00010000;
            8'h9c: chr_pix <= 8'b00010000;
            8'h9d: chr_pix <= 8'b00010000;
            8'h9e: chr_pix <= 8'b00010000;
            8'h9f: chr_pix <= 8'b00010000;
            // Letter: U
            8'ha0: chr_pix <= 8'b01000010;
            8'ha1: chr_pix <= 8'b01000010;
            8'ha2: chr_pix <= 8'b01000010;
            8'ha3: chr_pix <= 8'b01000010;
            8'ha4: chr_pix <= 8'b01000010;
            8'ha5: chr_pix <= 8'b01000010;
            8'ha6: chr_pix <= 8'b01000010;
            8'ha7: chr_pix <= 8'b00111100;
            // Letter: V
            8'ha8: chr_pix <= 8'b01000010;
            8'ha9: chr_pix <= 8'b01000010;
            8'haa: chr_pix <= 8'b01000010;
            8'hab: chr_pix <= 8'b01000010;
            8'hac: chr_pix <= 8'b01000010;
            8'had: chr_pix <= 8'b00100100;
            8'hae: chr_pix <= 8'b00100100;
            8'haf: chr_pix <= 8'b00011000;
            // Letter: W
            8'hb0: chr_pix <= 8'b01000010;
            8'hb1: chr_pix <= 8'b01000010;
            8'hb2: chr_pix <= 8'b01000010;
            8'hb3: chr_pix <= 8'b01000010;
            8'hb4: chr_pix <= 8'b01011010;
            8'hb5: chr_pix <= 8'b01011010;
            8'hb6: chr_pix <= 8'b01100110;
            8'hb7: chr_pix <= 8'b01000010;
            // Letter: X
            8'hb8: chr_pix <= 8'b01000010;
            8'hb9: chr_pix <= 8'b01000010;
            8'hba: chr_pix <= 8'b00100100;
            8'hbb: chr_pix <= 8'b00011000;
            8'hbc: chr_pix <= 8'b00011000;
            8'hbd: chr_pix <= 8'b00100100;
            8'hbe: chr_pix <= 8'b01000010;
            8'hbf: chr_pix <= 8'b01000010;
            // Letter: Y
            8'hc0: chr_pix <= 8'b01000010;
            8'hc1: chr_pix <= 8'b01000010;
            8'hc2: chr_pix <= 8'b00100100;
            8'hc3: chr_pix <= 8'b00011000;
            8'hc4: chr_pix <= 8'b00010000;
            8'hc5: chr_pix <= 8'b00010000;
            8'hc6: chr_pix <= 8'b00010000;
            8'hc7: chr_pix <= 8'b00010000;
            // Letter: Z
            8'hc8: chr_pix <= 8'b01111110;
            8'hc9: chr_pix <= 8'b00000010;
            8'hca: chr_pix <= 8'b00000100;
            8'hcb: chr_pix <= 8'b00001000;
            8'hcc: chr_pix <= 8'b00010000;
            8'hcd: chr_pix <= 8'b00100000;
            8'hce: chr_pix <= 8'b01000000;
            8'hcf: chr_pix <= 8'b01111110;
            // Space
            8'hd0: chr_pix <= 8'b00000000;
            8'hd1: chr_pix <= 8'b00000000;
            8'hd2: chr_pix <= 8'b00000000;
            8'hd3: chr_pix <= 8'b00000000;
            8'hd4: chr_pix <= 8'b00000000;
            8'hd5: chr_pix <= 8'b00000000;
            8'hd6: chr_pix <= 8'b00000000;
            8'hd7: chr_pix <= 8'b00000000;
            // Number 1
            8'hd8: chr_pix <= 8'b00110000;
            8'hd9: chr_pix <= 8'b01010000;
            8'hda: chr_pix <= 8'b00010000;
            8'hdb: chr_pix <= 8'b00010000;
            8'hdc: chr_pix <= 8'b00010000;
            8'hdd: chr_pix <= 8'b00010000;
            8'hde: chr_pix <= 8'b00010000;
            8'hdf: chr_pix <= 8'b01111100;
            //Number 2
            8'he0: chr_pix <= 8'b00111100;
            8'he1: chr_pix <= 8'b01000010;
            8'he2: chr_pix <= 8'b01000100;
            8'he3: chr_pix <= 8'b00001000;   
            8'he4: chr_pix <= 8'b00010000;
            8'he5: chr_pix <= 8'b00100000;
            8'he6: chr_pix <= 8'b01000000;
            8'he7: chr_pix <= 8'b01111110;
            //Colon (:)
            8'he8: chr_pix <= 8'b00000000;
            8'he9: chr_pix <= 8'b00011000;
            8'hea: chr_pix <= 8'b00011000;
            8'heb: chr_pix <= 8'b00000000;   
            8'hec: chr_pix <= 8'b00000000;
            8'hed: chr_pix <= 8'b00011000;
            8'hee: chr_pix <= 8'b00011000;
            8'hef: chr_pix <= 8'b00000000;
	  
        endcase // case ({digit,row})
    end
     
    assign draw_char = (vcount <= yloc && vcount >= yloc - 7 && hcount >= xloc && hcount <= xloc+7) ? (chr_pix[7-hcount-xloc]) : 0;

    // hcount goes from 0=left to 640=right
    // vcount goes from 0=top to 480=bottom
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row <= 0;
        end 
        else if (pixpulse) begin  // only make changes when pixpulse is high
	        if (vcount >= yloc-7 && vcount <= yloc) begin
	        // update row and digit as we scan through the region that has the score
                row <= 7 - (yloc - vcount); 
            end
        end
    end	      
endmodule // score