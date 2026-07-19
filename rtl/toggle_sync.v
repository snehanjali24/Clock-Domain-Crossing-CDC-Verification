`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.07.2026 14:38:50
// Design Name: 
// Module Name: toggle_sync
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


`timescale 1ns / 1ps
 
module toggle_sync (
    input  wire dst_clk,
    input  wire dst_rst_n,
    input  wire src_toggle,        // free-running toggle signal, async to dst_clk
    output wire dst_toggle_sync,   // src_toggle synchronized into dst_clk domain
    output wire dst_pulse          // 1 dst_clk-wide pulse on every toggle edge seen
);
 
    // 2FF synchronizer brings the toggling bit safely into dst_clk domain
    sync_2ff #(
        .WIDTH       (1),
        .RESET_VALUE (0)
    ) u_sync (
        .clk      (dst_clk),
        .rst_n    (dst_rst_n),
        .async_in (src_toggle),
        .sync_out (dst_toggle_sync)
    );
 
    // Edge detector: XOR of synchronized value with its own delayed copy
    reg dst_toggle_sync_d;
 
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n)
            dst_toggle_sync_d <= 1'b0;
        else
            dst_toggle_sync_d <= dst_toggle_sync;
    end
 
    assign dst_pulse = dst_toggle_sync ^ dst_toggle_sync_d;
 
endmodule
