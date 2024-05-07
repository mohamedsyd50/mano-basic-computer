`timescale 1ns / 1ps


module ManoComputer_tb();

reg clk;
wire [11:0] PC;
wire [11:0] AR;
wire [15:0] AC;
wire [15:0] DR;
wire [15:0] IR;
wire [15:0] TR;
wire [3:0] SC;
wire E;

// instantiate device under test
ManoComputer mano_DUT(AR, PC, DR, AC, IR, TR, E, SC, clk);

always begin
	clk = 0; #10; clk = 1; #10;
end

endmodule