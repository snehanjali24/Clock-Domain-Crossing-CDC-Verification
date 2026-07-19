`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.07.2026 14:22:18
// Design Name: 
// Module Name: sync_2ff
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



// =============================================================================
// Module      : sync_2ff
// File        : sync_2ff.v
// Description : Generic two-flip-flop (double) synchronizer.
//                Synchronizes a signal from an asynchronous / foreign clock
//                domain into the local clock domain, reducing the probability
//                of metastability propagating into downstream logic.
//
//                NOTE ON WIDTH:
//                A 2FF synchronizer is only metastability-SAFE for a single
//                bit (or for multiple bits that are guaranteed to change only
//                one-bit-at-a-time, e.g. Gray-coded pointers). If WIDTH > 1 is
//                used with an ordinary binary bus, different bits can resolve
//                on different clock edges, causing bus incoherency. The WIDTH
//                parameter exists so this module can be reused as the Gray
//                pointer synchronizer inside the Asynchronous FIFO, NOT to
//                encourage synchronizing arbitrary multi-bit binary buses.
//
// Author      : DV Portfolio Project
// Standard    : IEEE 1364-2001 (Verilog-2001)
// Simulator   : Xilinx Vivado Simulator (XSim)
// =============================================================================
 
`timescale 1ns / 1ps
 
module sync_2ff #(
    parameter WIDTH        = 1,   // Signal width (use 1 for scalar CDC signals)
    parameter RESET_VALUE  = 0    // Reset value applied to both flops
) (
    input  wire                 clk,       // Destination domain clock
    input  wire                 rst_n,     // Destination domain async reset, active low
    input  wire [WIDTH-1:0]     async_in,  // Signal coming from the foreign clock domain
    output reg  [WIDTH-1:0]     sync_out   // Signal synchronized to 'clk'
);
 
    // Stage 1 flop: catches the asynchronous input, may go metastable.
    reg [WIDTH-1:0] sync_ff1;
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff1 <= {WIDTH{RESET_VALUE[0]}};
            sync_out <= {WIDTH{RESET_VALUE[0]}};
        end else begin
            sync_ff1 <= async_in;   // Stage 1: capture (may go metastable)
            sync_out <= sync_ff1;   // Stage 2: resolve  (stable output)
        end
    end
 
endmodule
 

