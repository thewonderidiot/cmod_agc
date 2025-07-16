`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module cdu_control(
    input wire clk,
    input wire rst_n,

    input wire read_en,
    input wire write_en,
    output reg write_done,
    input wire [15:0] addr,
    input wire [15:0] data_in,
    output wire [15:0] data_out,

    input wire e_cycle_starting,
    input wire [11:1] e_cycle_addr,

    input wire minkl,
    input wire [12:1] mt,
    input wire [16:1] g,

    input wire n800SET,
    input wire n800RST,

    output reg atca800SET,
    output reg atca800RST
);

reg [15:1] cdux;
reg [15:1] cduy;
reg [15:1] cduz;
reg [15:1] cdut;
reg [15:1] cdus;
reg [12:1] target_addr;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cdux <= 15'b0;
        cduy <= 15'b0;
        cduz <= 15'b0;
        cdut <= 15'b0;
        cdus <= 15'b0;
        target_addr <= 12'o0;
    end else begin
        if (target_addr == 12'o0) begin
            if (e_cycle_starting & ((e_cycle_addr >= `CDUX) & (e_cycle_addr <= `CDUS))) begin
                target_addr <= e_cycle_addr;
            end
        end else begin
            if (mt[11]) begin
                case (target_addr)
                `CDUX: cdux <= {g[16], g[14:1]};
                `CDUY: cduy <= {g[16], g[14:1]};
                `CDUZ: cduz <= {g[16], g[14:1]};
                `CDUT: cdut <= {g[16], g[14:1]};
                `CDUS: cdus <= {g[16], g[14:1]};
                endcase
                target_addr <= 12'o0;
            end
        end
    end
end

reg mt7_p;
wire t7_start;
assign t7_start = (~mt7_p) && mt[7];
reg t7_start_p;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mt7_p <= 0;
        t7_start_p <= 1'b0;
    end else begin
        mt7_p <= mt[7];
        t7_start_p <= t7_start;
    end
end

wire cycles_full;
wire oldest;

inkl_cycles inkl_cycles1(
    .clk(clk),
    .srst(~rst_n),

    .full(cycles_full),
    .din(minkl),
    .wr_en(t7_start_p),

    .empty(),
    .dout(oldest),
    .rd_en(cycles_full && t7_start)
);

reg [15:0] tloss;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        tloss <= 17'b0;
    end else begin
        tloss <= tloss;
        if (t7_start && (oldest != minkl)) begin
            if ((tloss < 17'd65535) && minkl) begin
                tloss <= tloss + 16'd1;
            end else if ((tloss > 16'b0) && oldest) begin
                tloss <= tloss - 16'd1;
            end
        end
    end
end


reg [17:0] phase;
reg n800SET_p;
reg n800RST_p;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        n800SET_p <= 1'b0;
        n800RST_p <= 1'b0;
    end else begin
        n800SET_p <= n800SET;
        n800RST_p <= n800RST;
    end
end

reg [17:0] set_counter;
reg [17:0] rst_counter;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        set_counter <= 16'b0;
    end else begin
        if (~n800SET_p && n800SET) begin
            set_counter <= 16'b0;
        end else begin
            set_counter = set_counter + 16'b1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rst_counter <= 16'b0;
    end else begin
        if (~n800RST_p && n800RST) begin
            rst_counter <= 16'b0;
        end else begin
            rst_counter = rst_counter + 16'b1;
        end
    end
end

wire [17:0] phase_end = phase + 18'd376;
always @(*) begin
    if (phase_end < 18'd160000) begin
        atca800SET = (set_counter >= phase) && (set_counter <= phase_end);
        atca800RST = (rst_counter >= phase) && (rst_counter <= phase_end);
    end else begin
        atca800SET = (set_counter >= phase) || (set_counter <= (phase_end - 18'd160000));
        atca800RST = (rst_counter >= phase) || (rst_counter <= (phase_end - 18'd160000));
    end
end


reg [15:0] read_data;
reg read_done;
assign data_out = read_done ? read_data : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        write_done <= 1'b0;
        phase <= 18'b0;
    end else begin
        write_done <= 1'b0;
        phase <= phase;
        if (write_en) begin
            write_done <= 1'b1;
            case (addr)
            `CDU_REG_PHASE: begin
                phase <= {data_in, 2'b0};
            end
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_data <= 16'b0;
        read_done <= 1'b0;
    end else if (read_en) begin
        read_done <= 1'b1;
        case (addr)
        `CDU_REG_CDUX:  read_data <= cdux;
        `CDU_REG_CDUY:  read_data <= cduy;
        `CDU_REG_CDUZ:  read_data <= cduz;
        `CDU_REG_CDUT:  read_data <= cdut;
        `CDU_REG_CDUS:  read_data <= cdus;
        `CDU_REG_TLOSS: read_data <= tloss;
        `CDU_REG_PHASE: read_data <= phase[17:2];
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
