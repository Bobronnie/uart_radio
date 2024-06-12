// -------------------------------------------------------------
// 
// File Name: hdl_prj/hdlsrc/exponent/exponent_block.v
// Created: 2024-05-31 10:33:15
// 
// Generated by MATLAB 9.5 and HDL Coder 3.13
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: exponent_block
// Source Path: exponent/exponent
// Hierarchy Level: 1
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module exponent_block
          (clk,
           kill,
           phase,
           exp_re,
           exp_im);


  input   clk;
  input   kill;
  input   signed [9:0] phase;  // sfix10_En10
  output  signed [11:0] exp_re;  // sfix12_En10
  output  signed [11:0] exp_im;  // sfix12_En10


  wire signed [11:0] Cosine;  // sfix12_En10
  wire signed [11:0] Sine;  // sfix12_En10


  cos_add_1bit1 u_cos_add_1bit1 (.clk(clk),
                                 .kill(kill),
                                 .In1(phase),  // sfix10_En10
                                 .x(Cosine)  // sfix12_En10
                                 );

  assign exp_re = Cosine;

  sin_add_1bit3 u_sin_add_1bit3 (.clk(clk),
                                 .kill(kill),
                                 .In1(phase),  // sfix10_En10
                                 .y(Sine)  // sfix12_En10
                                 );

  assign exp_im = Sine;

endmodule  // exponent_block

