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

    input wire bplssw_p,
    input wire bplssw_n,
    input wire p4sw_p,
    input wire p4sw_n,
    input wire p3v3io_p,
    input wire p3v3io_n,
    input wire mtemp_p,
    input wire mtemp_n,

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

reg [15:0] adc_temp = 16'b0;
reg [15:0] adc_vccint = 16'b0;
reg [15:0] adc_vccaux = 16'b0;
reg [15:0] adc_bplssw = 16'b0;
reg [15:0] adc_p4sw = 16'b0;
reg [15:0] adc_p3v3io = 16'b0;
reg [15:0] adc_mtemp = 16'b0;

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
        `STATUS_REG_MON_P3V3IO: read_data <= adc_p3v3io;
        `STATUS_REG_AGC_TEMP:   read_data <= adc_mtemp;
        `STATUS_REG_AGC_BPLSSW: read_data <= adc_bplssw;
        `STATUS_REG_AGC_P4SW:   read_data <= adc_p4sw;
        `STATUS_REG_MM_ADDR:    read_data <= mismatch_faddr;
        `STATUS_REG_MM_DATA:    read_data <= mismatch_data;
        endcase
    end else begin
        read_done <= 1'b0;
    end
end

endmodule
`default_nettype wire
