`timescale 1ns / 1ps

module doubdab_8bits(
    input [7:0] b_in,
    output [11:0] bcd_out
    );

//
// Fill in the connections and wires to implement the double-dabble algorithm
//  
//   
    wire [3:0] u1_out;
    wire [3:0] u2_out;
    wire [3:0] u3_out;
    wire [3:0] u4_out;
    wire [3:0] u5_out;
    wire [3:0] u6_out;
    wire [3:0] u7_out;

    dd_add3 u1 ({1'b0, b_in[7:5]}, u1_out);
    
    dd_add3 u2 ({u1_out[2:0], b_in[4]}, u2_out);

    dd_add3 u3 ({u2_out[2:0], b_in[3]}, u3_out);
    
    dd_add3 u4 ({u3_out[2:0], b_in[2]}, u4_out);
    dd_add3 u6 ({1'b0, u1_out[3], u2_out[3], u3_out[3]}, u6_out);
    
    dd_add3 u5 ({u4_out[2:0], b_in[1]}, u5_out);
    dd_add3 u7 ({u6_out[2:0], u4_out[3]}, u7_out);
    
    assign bcd_out = {2'b00, u6_out[3], u7_out, u5_out, b_in[0]};
     
endmodule
