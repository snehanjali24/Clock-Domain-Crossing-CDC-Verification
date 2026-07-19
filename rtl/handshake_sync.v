`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.07.2026 15:10:54
// Design Name: 
// Module Name: handshake_sync
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


module handshake_sync #(
    parameter DATA_WIDTH = 8
)(
    // ------------------------- Source Domain --------------------------
    input  wire                  src_clk,
    input  wire                  src_rst_n,
    input  wire                  src_valid,
    input  wire [DATA_WIDTH-1:0] src_data,
    output wire                  src_busy,
    output wire                  src_ready,
 
    // ---------------------- Destination Domain -------------------------
    input  wire                  dst_clk,
    input  wire                  dst_rst_n,
    output reg                   dst_valid,
    output reg  [DATA_WIDTH-1:0] dst_data
);
 
    //=================================================================
    // SOURCE DOMAIN
    //=================================================================
    reg                  req_toggle;   // toggles once per accepted send
    reg [DATA_WIDTH-1:0] data_hold;    // held stable for entire busy window
    reg                  busy;
 
    // 2-flop synchronizer: ack_toggle (destination domain) -> source domain
    reg ack_sync_meta, ack_sync;
    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            ack_sync_meta <= 1'b0;
            ack_sync      <= 1'b0;
        end else begin
            ack_sync_meta <= ack_toggle;
            ack_sync      <= ack_sync_meta;
        end
    end
 
    // Request / busy control (accept new send OR detect completion,
    // never both in the same cycle -- mutually exclusive by construction)
    always @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            req_toggle <= 1'b0;
            data_hold  <= {DATA_WIDTH{1'b0}};
            busy       <= 1'b0;
        end else if (src_valid && !busy) begin
            data_hold  <= src_data;
            req_toggle <= ~req_toggle;
            busy       <= 1'b1;
        end else if (busy && (ack_sync == req_toggle)) begin
            busy <= 1'b0;
        end
    end
 
    assign src_busy  = busy;
    assign src_ready = ~busy;
 
    //=================================================================
    // DESTINATION DOMAIN
    //=================================================================
    reg req_sync_meta, req_sync, req_sync_prev;
    reg ack_toggle;
 
    // 2-flop synchronizer: req_toggle (source domain) -> destination domain
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            req_sync_meta <= 1'b0;
            req_sync      <= 1'b0;
        end else begin
            req_sync_meta <= req_toggle;
            req_sync      <= req_sync_meta;
        end
    end
 
    // Edge (toggle-change) detector on the ALREADY-SYNCHRONIZED signal
    // (no metastability risk here: req_sync is a clean, synchronized value)
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n)
            req_sync_prev <= 1'b0;
        else
            req_sync_prev <= req_sync;
    end
 
    wire req_edge = (req_sync != req_sync_prev);
 
    // Data capture, valid-pulse generation, and acknowledge
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            dst_valid  <= 1'b0;
            dst_data   <= {DATA_WIDTH{1'b0}};
            ack_toggle <= 1'b0;
        end else if (req_edge) begin
            dst_data   <= data_hold;
            dst_valid  <= 1'b1;
            ack_toggle <= ~ack_toggle;
        end else begin
            dst_valid  <= 1'b0;
        end
    end
 
endmodule