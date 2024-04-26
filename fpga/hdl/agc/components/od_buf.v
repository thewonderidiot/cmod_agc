`timescale 1ns/1ps
`default_nettype none

module od_buf(y, a);
    parameter delay = 2;
    parameter od_value = 1'b1;
    input wire a;
    output wire y;

    assign y = (od_value == 1'b1) ? a : ~a;
endmodule
`default_nettype wire
