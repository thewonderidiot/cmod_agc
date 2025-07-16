`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2024 09:46:12 AM
// Design Name: 
// Module Name: cmod_agc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cmod_agc(
    input wire clk,
    input wire rst,
    
    input wire rxd,
    output wire txd,
    
    output wire led0,

    input wire a15_p,
    input wire a15_n,
    input wire a16_p,
    input wire a16_n,

    output wire n25KPPS,
    output wire n3200A,
    output wire n3200B,
    output wire n800SET,
    output wire n800RST,
    output wire CDUCLK,

    input wire cduxm_in,
    input wire cduxp_in,
    input wire cduym_in,
    input wire cduyp_in,
    input wire cduzm_in,
    input wire cduzp_in,
    input wire shaftm_in,
    input wire shaftp_in,
    input wire trnm_in,
    input wire trnp_in,

    output wire CDUXDM,
    output wire CDUXDP,
    output wire CDUYDM,
    output wire CDUYDP,
    output wire CDUZDM,
    output wire CDUZDP,
    output wire SHFTDM,
    output wire SHFTDP,
    output wire TRNDM,
    output wire TRNDP,

    input wire cdufal_in,
    input wire opcdfl_in,
    input wire gcapcl_in,
    input wire ctlsat_in,
    input wire imuopr_in,
    input wire imufal_in,
    input wire imucag_in,
    input wire tempin_in,
    input wire isstor_in,


    output wire COARSE,
    output wire ENERIM,
    output wire ENEROP,
    output wire ZIMCDU,
    output wire ZOPCDU,
    output wire TVCNAB,
    output wire S4BTAK,
    output wire ISSTDC
);

wire rst_n;
assign rst_n = ~rst;


// Propagation delay clock (19.53125ns) and main B8 clock (2.048MHz)
wire prop_clk;
wire prop_locked;
wire agc_clk;
wire mon_clk;

prop_clk_div prop_div(
    .clk_in1(clk),
    .reset(~rst_n),
    .locked(prop_locked),
    .clk_out1(prop_clk),
    .clk_out2(mon_clk)
);

agc_clk_div agc_div(
    .prop_clk(prop_clk),
    .prop_locked(prop_locked),
    .rst_n(rst_n),
    .agc_clk(agc_clk)
);

/*******************************************************************************.
* Monitor                                                                       *
'*******************************************************************************/

wire MSTRT;
wire MSTP;
wire NHALGA;
wire MNHNC;
wire MNHRPT;
wire MSBSTP;
wire MNHSBF;
wire MAMU;
wire MLDCH;
wire MLOAD;
wire MRDCH;
wire MREAD;
wire MTCSAI;
wire MONWBK;
wire MDT01;
wire MDT02;
wire MDT03;
wire MDT04;
wire MDT05;
wire MDT06;
wire MDT07;
wire MDT08;
wire MDT09;
wire MDT10;
wire MDT11;
wire MDT12;
wire MDT13;
wire MDT14;
wire MDT15;
wire MDT16;
wire MONPAR;
wire DBLTST;
wire DOSCAL;
wire NHSTRT1;
wire NHSTRT2;

wire MGOJAM;
wire MSTPIT_n;
wire MIIP;
wire MINHL;
wire MINKL;
wire MNISQ;
wire MONWT;
wire MT01;
wire MT02;
wire MT03;
wire MT04;
wire MT05;
wire MT06;
wire MT07;
wire MT08;
wire MT09;
wire MT10;
wire MT11;
wire MT12;
wire MBR1;
wire MBR2;
wire MST1;
wire MST2;
wire MST3;
wire MSQ10;
wire MSQ11;
wire MSQ12;
wire MSQ13;
wire MSQ14;
wire MSQ16;
wire MSQEXT;
wire MWL01;
wire MWL02;
wire MWL03;
wire MWL04;
wire MWL05;
wire MWL06;
wire MWL07;
wire MWL08;
wire MWL09;
wire MWL10;
wire MWL11;
wire MWL12;
wire MWL13;
wire MWL14;
wire MWL15;
wire MWL16;
wire MSP;
wire MGP_n;
wire MRAG;
wire MRCH;
wire MRGG;
wire MRLG;
wire MRSC;
wire MRULOG;
wire MWAG;
wire MWBBEG;
wire MWBG;
wire MWCH;
wire MWEBG;
wire MWFBG;
wire MWG;
wire MWLG;
wire MWQG;
wire MWSG;
wire MWYG;
wire MWZG;
wire MREQIN;
wire MTCSA_n;
wire MRPTAL_n;
wire MTCAL_n;
wire MVFAIL_n;
wire MWARNF_n;
wire MWATCH_n;
wire MSCAFL_n;
wire MSCDBL_n;
wire MCTRAL_n;
wire MOSCAL_n;
wire MPAL_n;
wire MPIPAL_n;
wire MON800;
wire OUTCOM;

wire [6:1] leds;
wire [6:1] dbg;
wire [16:1] mdt;
wire [16:1] mwl;
wire [12:1] mt;
wire [15:10] msq;
wire [3:1] mst;
wire [2:1] mbr;

assign MDT01 = mdt[1];
assign MDT02 = mdt[2];
assign MDT03 = mdt[3];
assign MDT04 = mdt[4];
assign MDT05 = mdt[5];
assign MDT06 = mdt[6];
assign MDT07 = mdt[7];
assign MDT08 = mdt[8];
assign MDT09 = mdt[9];
assign MDT10 = mdt[10];
assign MDT11 = mdt[11];
assign MDT12 = mdt[12];
assign MDT13 = mdt[13];
assign MDT14 = mdt[14];
assign MDT15 = mdt[15];
assign MDT16 = mdt[16];

assign mwl = {MWL16, MWL15, MWL14, MWL13, MWL12, MWL11, MWL10, MWL09, MWL08, MWL07, MWL06, MWL05, MWL04, MWL03, MWL02, MWL01};
assign mt = {MT12, MT11, MT10, MT09, MT08, MT07, MT06, MT05, MT04, MT03, MT02, MT01};
assign msq = {MSQ16, MSQ14, MSQ13, MSQ12, MSQ11, MSQ10};
assign mst = {MST3, MST2, MST1};
assign mbr = {MBR2, MBR1};

monitor mon(
    .clk(mon_clk),
    .rst_n(rst_n),

    // FT232 UART interface
    .txd(txd),
    .rxd(rxd),

    // AGC signals
    .a15_p(a15_p),
    .a15_n(a15_n),
    .a16_p(a16_p),
    .a16_n(a16_n),

    .mgojam(MGOJAM),
    .mstpit_n(MSTPIT_n),
    .monwt(MONWT),
    .mt(mt),
    .mwl(mwl),

    .miip(MIIP),
    .minhl(MINHL),
    .minkl(MINKL),

    .msqext(MSQEXT),
    .msq(msq),
    .mst(mst),
    .mbr(mbr),

    .mrsc(MRSC),
    .mwag(MWAG),
    .mwlg(MWLG),
    .mwqg(MWQG),
    .mwebg(MWEBG),
    .mwfbg(MWFBG),
    .mwbbeg(MWBBEG),
    .mwzg(MWZG),
    .mwbg(MWBG),
    .mwsg(MWSG),
    .mwg(MWG),
    .mwyg(MWYG),
    .mrulog(MRULOG),
    .mrgg(MRGG),
    .mrch(MRCH),
    .mwch(MWCH),
    .mnisq(MNISQ),
    .msp(MSP),
    .mgp_n(MGP_n),
    .outcom(OUTCOM),

    .mvfail_n(MVFAIL_n),
    .moscal_n(MOSCAL_n),
    .mscafl_n(MSCAFL_n),
    .mscdbl_n(MSCDBL_n),
    .mctral_n(MCTRAL_n),
    .mtcal_n(MTCAL_n),
    .mrptal_n(MRPTAL_n),
    .mpal_n(MPAL_n),
    .mwatch_n(MWATCH_n),
    .mpipal_n(MPIPAL_n),
    .mwarnf_n(MWARNF_n),

    .n800SET(n800SET),
    .n800RST(n800RST),

    .mnhsbf(MNHSBF),
    .mamu(MAMU),
    .mdt(mdt),
    .monpar(MONPAR),

    .mstrt(MSTRT),
    .mstp(MSTP),

    .mnhrpt(MNHRPT),
    .mnhnc(MNHNC),
    .nhalga(NHALGA),
    .nhstrt1(NHSTRT1),
    .nhstrt2(NHSTRT2),
    .doscal(DOSCAL),
    .dbltst(DBLTST),

    .mread(MREAD),
    .mload(MLOAD),
    .mrdch(MRDCH),
    .mldch(MLDCH),
    .mtcsai(MTCSAI),
    .monwbk(MONWBK),
    .mreqin(MREQIN),
    .mtcsa_n(MTCSA_n),

    .atca800SET(n3200A),
    .atca800RST(n3200B),

    .leds(leds),
    .dbg(dbg)
);

// AGC main connector I/O
reg p4VDC = 1;
wire p4VSW;
reg GND = 0;
reg SIM_RST = 1;
reg BLKUPL_n = 1; //input
reg BMGXM = 0; //input
reg BMGXP = 0; //input
reg BMGYM = 0; //input
reg BMGYP = 0; //input
reg BMGZM = 0; //input
reg BMGZP = 0; //input
wire CAURST; //input
wire CDUFAL; //input
wire CDUXM; //input
wire CDUXP; //input
wire CDUYM; //input
wire CDUYP; //input
wire CDUZM; //input
wire CDUZP; //input
wire CTLSAT; //input
wire DKBSNC; //input
wire DKEND; //input
wire DKSTRT; //input
reg FLTOUT = 0;
reg FREFUN = 0; //input
reg GATEX_n = 1; //input
reg GATEY_n = 1; //input
reg GATEZ_n = 1; //input
wire GCAPCL; //input
reg GUIREL = 0; //input
reg HOLFUN = 0; //input
wire IMUCAG; //input
wire IMUFAL; //input
wire IMUOPR; //input
reg IN3008 = 0; //input
reg IN3212 = 0; //input
reg IN3213 = 0; //input
wire IN3214; //input
reg IN3216 = 0; //input
reg IN3301 = 0; //input
wire ISSTOR; //input
reg LEMATT = 0; //input
reg LFTOFF = 0; //input
reg LRIN0 = 0; //input
reg LRIN1 = 0; //input
reg LRRLSC = 0; //input
reg LVDAGD = 0; //input
wire MAINRS; //input
reg MANmP = 0; //input
reg MANmR = 0; //input
reg MANmY = 0; //input
reg MANpP = 0; //input
reg MANpR = 0; //input
reg MANpY = 0; //input
reg MARK = 0; //input
wire MKEY1; //input
wire MKEY2; //input
wire MKEY3; //input
wire MKEY4; //input
wire MKEY5; //input
reg MNIMmP = 0; //input
reg MNIMmR = 0; //input
reg MNIMmY = 0; //input
reg MNIMpP = 0; //input
reg MNIMpR = 0; //input
reg MNIMpY = 0; //input
reg MRKREJ = 0; //input
reg MRKRST = 0; //input
reg MYCLMP = 0;
reg NAVRST = 0; //input
reg NHVFAL = 0; //input
reg NKEY1 = 0; //input
reg NKEY2 = 0; //input
reg NKEY3 = 0; //input
reg NKEY4 = 0; //input
reg NKEY5 = 0; //input
wire OPCDFL; //input
reg OPMSW2 = 0; //input
reg OPMSW3 = 0; //input
reg PCHGOF = 0; //input
wire PIPAXm; //input
wire PIPAXp; //input
wire PIPAYm; //input
wire PIPAYp; //input
wire PIPAZm; //input
wire PIPAZp; //input
reg ROLGOF = 0; //input
reg RRIN0 = 0; //input
reg RRIN1 = 0; //input
reg RRPONA = 1; //input
reg RRRLSC = 0; //input
reg S4BSAB = 0; //input
wire SBYBUT; //input
reg SCAFAL = 0;
wire SHAFTM; //input
wire SHAFTP; //input
reg SIGNX = 0; //input
reg SIGNY = 0; //input
reg SIGNZ = 0; //input
reg SMSEPR = 0; //input
reg SPSRDY = 0; //input
reg STRPRS = 0; //input
wire TEMPIN; //input
reg TRANmX = 0; //input
reg TRANmY = 0; //input
reg TRANmZ = 0; //input
reg TRANpX = 0; //input
reg TRANpY = 0; //input
reg TRANpZ = 0; //input
wire TRNM; //input
wire TRNP; //input
reg TRST10 = 0; //input
reg TRST9 = 0; //input
reg ULLTHR = 0; //input
reg UPL0 = 0; //input
reg UPL1 = 0; //input
reg VFAIL = 0;
reg XLNK0 = 0; //input
reg XLNK1 = 0; //input
reg ZEROP = 0; //input
reg n2FSFAL = 1;
wire n3200A_agc; // output
wire n3200B_agc; // output
wire CLK; //output
wire COMACT; //output
wire DKDATA; //output
wire ELSNCM; //output
wire ELSNCN; //output
wire KYRLS; //output
wire OPEROR; //output
wire PIPASW; //output
wire PIPDAT; //output
wire RESTRT; //output
wire RLYB01; //output
wire RLYB02; //output
wire RLYB03; //output
wire RLYB04; //output
wire RLYB05; //output
wire RLYB06; //output
wire RLYB07; //output
wire RLYB08; //output
wire RLYB09; //output
wire RLYB10; //output
wire RLYB11; //output
wire RYWD12; //output
wire RYWD13; //output
wire RYWD14; //output
wire RYWD16; //output
wire SBYLIT; //output
wire SBYREL_n;
wire TMPCAU; //output
wire UPLACT; //output
wire VNFLSH; //output


// B8 CLOCK output
wire CLOCK;
assign CLOCK = agc_clk;

// Standy power logic
assign p4VSW = (p4VDC && SBYREL_n);

// PIPA 3-3 moding simulation
reg [2:0] moding_counter = 3'b0;
always @(posedge PIPASW) begin
    moding_counter = moding_counter + 3'b1;
    if (moding_counter == 3'd6) begin
        moding_counter = 3'b0;
    end
end

assign PIPAXm = PIPDAT && (moding_counter >= 3'd3);
assign PIPAYm = PIPDAT && (moding_counter >= 3'd3);
assign PIPAZm = PIPDAT && (moding_counter >= 3'd3);
assign PIPAXp = PIPDAT && (moding_counter < 3'd3);
assign PIPAYp = PIPDAT && (moding_counter < 3'd3);
assign PIPAZp = PIPDAT && (moding_counter < 3'd3);

// PCM simulation
reg clk_p;
reg [9:0] pcm_timer;
reg [4:0] pcm_pulse_timer;
reg [5:0] pcm_bit;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        clk_p <= 1'b0;
        pcm_timer <= 15'd1023;
        pcm_pulse_timer <= 5'd0;
        pcm_bit <= 6'd42;
    end else begin
        clk_p <= CLK;
        if (~clk_p && CLK) begin
            if (pcm_pulse_timer < 5'd19) begin
                pcm_pulse_timer <= pcm_pulse_timer + 5'd1;
            end else begin
                pcm_pulse_timer <= 5'd0;
                pcm_timer <= pcm_timer + 10'd1;
                if (pcm_timer == 10'd0) begin
                    pcm_bit <= 6'd0;
                end else if (pcm_bit < 6'd42) begin
                    pcm_bit <= pcm_bit + 6'd1;
                end
            end
        end
    end
end

assign DKSTRT = (pcm_pulse_timer < 5'd4) && (pcm_bit == 6'd0);
assign DKBSNC = (pcm_pulse_timer < 5'd4) && (pcm_bit > 6'd0) && (pcm_bit < 6'd41);
assign DKEND  = (pcm_pulse_timer < 5'd4) && (pcm_bit == 6'd41);

// STRT2 handling
reg STRT2;
reg [18:0] strt2_count;
reg clock_p;
always @(posedge prop_clk or negedge rst_n) begin
    if (~rst_n) begin
        STRT2 <= 1'b1;
        strt2_count <= 19'b0;
        clock_p <= 1'b0;
    end else begin
        clock_p <= CLOCK;
        if (CLOCK && ~clock_p) begin
            if (strt2_count < 19'd409600) begin
                strt2_count <= strt2_count + 1;
            end else begin
                STRT2 <= 1'b0;
            end
        end
    end
end

debounce #(1, 10) db1(prop_clk, rst_n, cduxm_in, CDUXM);
debounce #(1, 10) db2(prop_clk, rst_n, cduxp_in, CDUXP);
debounce #(1, 10) db3(prop_clk, rst_n, cduym_in, CDUYM);
debounce #(1, 10) db4(prop_clk, rst_n, cduyp_in, CDUYP);
debounce #(1, 10) db5(prop_clk, rst_n, cduzm_in, CDUZM);
debounce #(1, 10) db6(prop_clk, rst_n, cduzp_in, CDUZP);
debounce #(1, 10) db7(prop_clk, rst_n, shaftm_in, SHAFTM);
debounce #(1, 10) db8(prop_clk, rst_n, shaftp_in, SHAFTP);
debounce #(1, 10) db9(prop_clk, rst_n, trnm_in, TRNM);
debounce #(1, 10) db10(prop_clk, rst_n, trnp_in, TRNP);
debounce #(1, 10) db11(prop_clk, rst_n, cdufal_in, CDUFAL);
debounce #(1, 10) db12(prop_clk, rst_n, opcdfl_in, OPCDFL);
debounce #(1, 10) db13(prop_clk, rst_n, gcapcl_in, GCAPCL);
debounce #(1, 10) db14(prop_clk, rst_n, ctlsat_in, CTLSAT);
debounce #(1, 10) db15(prop_clk, rst_n, imuopr_in, IMUOPR);
debounce #(1, 10) db16(prop_clk, rst_n, imufal_in, IMUFAL);
debounce #(1, 10) db17(prop_clk, rst_n, imucag_in, IMUCAG);
debounce #(1, 10) db18(prop_clk, rst_n, tempin_in, TEMPIN);
debounce #(1, 10) db19(prop_clk, rst_n, isstor_in, ISSTOR);

assign IN3214 = SBYBUT;

// AGC
fpga_agc agc(p4VDC, p4VSW, GND, ~rst_n, prop_clk, BLKUPL_n, BMGXM, BMGXP, BMGYM, BMGYP, BMGZM, BMGZP, CAURST, CDUFAL, CDUXM, CDUXP, CDUYM, CDUYP, CDUZM, CDUZP, CLOCK, CTLSAT, DBLTST, DKBSNC, DKEND, DKSTRT, DOSCAL, FLTOUT, FREFUN, GATEX_n, GATEY_n, GATEZ_n, GCAPCL, GUIREL, HOLFUN, IMUCAG, IMUFAL, IMUOPR, IN3008, IN3212, IN3213, IN3214, IN3216, IN3301, ISSTOR, LEMATT, LFTOFF, LRIN0, LRIN1, LRRLSC, LVDAGD, MAINRS, MAMU, MANmP, MANmR, MANmY, MANpP, MANpR, MANpY, MARK, MDT01, MDT02, MDT03, MDT04, MDT05, MDT06, MDT07, MDT08, MDT09, MDT10, MDT11, MDT12, MDT13, MDT14, MDT15, MDT16, MKEY1, MKEY2, MKEY3, MKEY4, MKEY5, MLDCH, MLOAD, MNHNC, MNHRPT, MNHSBF, MNIMmP, MNIMmR, MNIMmY, MNIMpP, MNIMpR, MNIMpY, MONPAR, MONWBK, MRDCH, MREAD, MRKREJ, MRKRST, MSTP, MSTRT, MTCSAI, MYCLMP, NAVRST, NHALGA, NHVFAL, NKEY1, NKEY2, NKEY3, NKEY4, NKEY5, OPCDFL, OPMSW2, OPMSW3, PCHGOF, PIPAXm, PIPAXp, PIPAYm, PIPAYp, PIPAZm, PIPAZp, ROLGOF, RRIN0, RRIN1, RRPONA, RRRLSC, S4BSAB, SBYBUT, SCAFAL, SHAFTM, SHAFTP, SIGNX, SIGNY, SIGNZ, SMSEPR, SPSRDY, STRPRS, STRT2, TEMPIN, TRANmX, TRANmY, TRANmZ, TRANpX, TRANpY, TRANpZ, TRNM, TRNP, TRST10, TRST9, ULLTHR, UPL0, UPL1, VFAIL, XLNK0, XLNK1, ZEROP, n2FSFAL, n25KPPS, n3200A_agc, n3200B_agc, n800RST, n800SET, CDUCLK, CDUXDM, CDUXDP, CDUYDM, CDUYDP, CDUZDM, CDUZDP, CLK, COARSE, COMACT, DKDATA, ELSNCM, ELSNCN, ENERIM, ENEROP, ISSTDC, KYRLS, MBR1, MBR2, MCTRAL_n, MGOJAM, MGP_n, MIIP, MINHL, MINKL, MNISQ, MON800, MONWT, MOSCAL_n, MPAL_n, MPIPAL_n, MRAG, MRCH, MREQIN, MRGG, MRLG, MRPTAL_n, MRSC, MRULOG, MSCAFL_n, MSCDBL_n, MSP, MSQ10, MSQ11, MSQ12, MSQ13, MSQ14, MSQ16, MSQEXT, MST1, MST2, MST3, MSTPIT_n, MT01, MT02, MT03, MT04, MT05, MT06, MT07, MT08, MT09, MT10, MT11, MT12, MTCAL_n, MTCSA_n, MVFAIL_n, MWAG, MWARNF_n, MWATCH_n, MWBBEG, MWBG, MWCH, MWEBG, MWFBG, MWG, MWL01, MWL02, MWL03, MWL04, MWL05, MWL06, MWL07, MWL08, MWL09, MWL10, MWL11, MWL12, MWL13, MWL14, MWL15, MWL16, MWLG, MWQG, MWSG, MWYG, MWZG, OPEROR, OUTCOM, PIPASW, PIPDAT, RESTRT, RLYB01, RLYB02, RLYB03, RLYB04, RLYB05, RLYB06, RLYB07, RLYB08, RLYB09, RLYB10, RLYB11, RYWD12, RYWD13, RYWD14, RYWD16, S4BTAK, SBYLIT, SBYREL_n, SHFTDM, SHFTDP, TMPCAU, TRNDM, TRNDP, TVCNAB, UPLACT, VNFLSH, ZIMCDU, ZOPCDU);


assign led0 = COMACT;

endmodule
`default_nettype wire
