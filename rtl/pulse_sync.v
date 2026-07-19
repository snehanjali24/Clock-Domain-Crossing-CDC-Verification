`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.07.2026 14:34:33
// Design Name: 
// Module Name: pulse_sync
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
 
module pulse_sync (
    // Source domain
    input  wire src_clk,
    input  wire src_rst_n,
    input  wire src_pulse,   // single-cycle pulse request, ignored while src_busy=1
    output wire src_busy,    // 1 = previous pulse still in flight, do not pulse again
 
    // Destination domain
    input  wire dst_clk,
    input  wire dst_rst_n,
    output wire dst_pulse    // single dst_clk-cycle pulse output
);
 
    // -------------------------------------------------------------------
    // Source domain: toggle flip-flop
    // -------------------------------------------------------------------
    reg toggle_src;
 
    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n)
            toggle_src <= 1'b0;
        else if (src_pulse && !src_busy)
            toggle_src <= ~toggle_src;
    end
 
    // -------------------------------------------------------------------
    // Forward path: src -> dst  (2FF synchronizer, safe: single toggling bit)
    // -------------------------------------------------------------------
    wire toggle_dst_sync;
 
    sync_2ff #(
        .WIDTH       (1),
        .RESET_VALUE (0)
    ) u_sync_fwd (
        .clk      (dst_clk),
        .rst_n    (dst_rst_n),
        .async_in (toggle_src),
        .sync_out (toggle_dst_sync)
    );
 
    // Edge detector in destination domain -> single-cycle dst_pulse
    reg toggle_dst_sync_d;
 
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n)
            toggle_dst_sync_d <= 1'b0;
        else
            toggle_dst_sync_d <= toggle_dst_sync;
    end
 
    assign dst_pulse = toggle_dst_sync ^ toggle_dst_sync_d;
 
    // -------------------------------------------------------------------
    // Return path: dst -> src (2FF synchronizer) so the source domain
    // knows when the destination domain has registered the toggle.
    // -------------------------------------------------------------------
    wire toggle_ack_src;
 
    sync_2ff #(
        .WIDTH       (1),
        .RESET_VALUE (0)
    ) u_sync_ret (
        .clk      (src_clk),
        .rst_n    (src_rst_n),
        .async_in (toggle_dst_sync),
        .sync_out (toggle_ack_src)
    );
 
    // Busy while the toggle we generated has not yet been acknowledged
    assign src_busy = (toggle_src != toggle_ack_src);
 
endmodule
