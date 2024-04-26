`timescale 1ns/1ps
`default_nettype none

module tri_buf(y, a, oe_n);
    parameter delay = 13;
    input wire a;
    input wire oe_n;
    output wire y;

    assign y = (oe_n == 1'b0) ? a : 1'b0;
endmodule
`default_nettype wire
