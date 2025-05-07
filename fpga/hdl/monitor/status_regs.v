`timescale 1ns / 1ps
`default_nettype none

`include "monitor_defs.v"

module status_regs(
    input wire clk,
    input wire rst_n,

    input wire read_en,
    input wire write_en,
    input wire [15:0] addr,
    input wire [15:0] data_in,
    output wire [15:0] data_out,

    input wire a15_p,
    input wire a15_n,
    input wire a16_p,
    input wire a16_n,

    input wire mt05,
    input wire mt08,

    input wire mvfail_n,
    input wire moscal_n,
    input wire mscafl_n,
    input wire mscdbl_n,
    input wire mctral_n,
    input wire mtcal_n,
    input wire mrptal_n,
    input wire mpal_n,
    input wire mwatch_n,
    input wire mpipal_n,
    input wire mwarnf_n,

    input wire mnhsbf,
    input wire mamu,
    input wire mload,
    input wire mldch,
    input wire mread,
    input wire mrdch,

    input wire [16:1] mismatch_faddr,
    input wire [16:1] mismatch_data
);

wire [4:0] adc_channel;
wire [6:0] adc_daddr;
assign adc_daddr = {2'b0, adc_channel};
wire adc_eoc;
wire [15:0] adc_do;
wire adc_drdy;

mon_adc adc(
    .daddr_in(adc_daddr),
    .dclk_in(clk),
    .den_in(adc_eoc),
    .di_in(16'b0),
    .dwe_in(1'b0),
    .reset_in(~rst_n),
    .vauxp4(a15_p),
    .vauxn4(a15_n),
    .vauxp12(a16_p),
    .vauxn12(a16_n),
    .busy_out(),
    .channel_out(adc_channel),
    .do_out(adc_do),
    .drdy_out(adc_drdy),
    .eoc_out(adc_eoc),
    .eos_out(),
    .alarm_out(),
    .vp_in(1'b0),
    .vn_in(1'b0)
);

reg [15:0] adc_temp = 16'b0;
reg [15:0] adc_vccint = 16'b0;
reg [15:0] adc_vccaux = 16'b0;
reg [15:0] adc_a15 = 16'b0;
reg [15:0] adc_a16 = 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        adc_temp <= 16'b0;
        adc_vccint <= 16'b0;
        adc_vccaux <= 16'b0;
        adc_a15 <= 16'b0;
        adc_a16 <= 16'b0;
    end else if (adc_drdy) begin
        case (adc_channel)
        `ADC_CHAN_TEMP:   adc_temp <= adc_do;
        `ADC_CHAN_VCCINT: adc_vccint <= adc_do;
        `ADC_CHAN_VCCAUX: adc_vccaux <= adc_do;
        `ADC_CHAN_VAUX4:  adc_a15 <= adc_do;
        `ADC_CHAN_VAUX12: adc_a16 <= adc_do;
        endcase
    end
end

localparam VFAIL = 0,
           OSCAL = 1,
           SCAFL = 2,
           SCDBL = 3,
           CTRAL = 4,
           TCAL  = 5,
           RPTAL = 6,
           FPAL  = 7,
           EPAL  = 8,
           WATCH = 9,
           PIPAL = 10,
           WARN  = 11;

reg [11:0] alarms;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        alarms <= 12'b0;
    end else begin
        if (write_en) begin
            alarms <= alarms & ~(data_in[11:0]);
        end else begin
            if (~mvfail_n) begin
                alarms[VFAIL] <= 1'b1;
            end

            if (~moscal_n) begin
                alarms[OSCAL] <= 1'b1;
            end

            if (~mscafl_n) begin
                alarms[SCAFL] <= 1'b1;
            end

            if (~mscdbl_n) begin
                alarms[SCDBL] <= 1'b1;
            end

            if (~mctral_n) begin
                alarms[CTRAL] <= 1'b1;
            end

            if (~mtcal_n) begin
                alarms[TCAL] <= 1'b1;
            end

            if (~mrptal_n) begin
                alarms[RPTAL] <= 1'b1;
            end

            if (~mpal_n & mt08) begin
                alarms[FPAL] <= 1'b1;
            end

            if (~mpal_n & mt05) begin
                alarms[EPAL] <= 1'b1;
            end

            if (~mwatch_n) begin
                alarms[WATCH] <= 1'b1;
            end

            if (~mpipal_n) begin
                alarms[PIPAL] <= 1'b1;
            end

            if (~mwarnf_n) begin
                alarms[WARN] <= 1'b1;
            end
        end
    end
end


reg [15:0] read_data;
reg read_done;

assign data_out = read_done ? read_data : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_data <= 16'b0;
        read_done <= 1'b0;
    end else if (read_en) begin
        read_done <= 1'b1;
        case (addr)
        `STATUS_REG_ALARMS:     read_data <= {4'b0, alarms};
        `STATUS_REG_SIMULATION: read_data <= {10'b0, mrdch, mread, mldch, mload, mamu, mnhsbf};
        `STATUS_REG_MON_TEMP:   read_data <= adc_temp;
        `STATUS_REG_MON_VCCINT: read_data <= adc_vccint;
        `STATUS_REG_MON_VCCAUX: read_data <= adc_vccaux;
        `STATUS_REG_AGC_A15:    read_data <= adc_a15;
        `STATUS_REG_AGC_A16:    read_data <= adc_a16;
        `STATUS_REG_MM_ADDR:    read_data <= mismatch_faddr;
        `STATUS_REG_MM_DATA:    read_data <= mismatch_data;
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
