`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.07.2026 14:57:47
// Design Name: 
// Module Name: reset_sync
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
 
module reset_sync #(
    parameter SYNC_STAGES = 2   // Number of synchronizer FF stages (>= 1)
)(
    input  wire clk,            // Destination clock domain
    input  wire async_rst_n,    // Asynchronous active-low reset input
    output wire sync_rst_n      // Synchronized active-low reset output
);
 
    // Synchronizer flip-flop chain. Bit 0 is the first stage (closest to the
    // asynchronous source), bit (SYNC_STAGES-1) is the final, output stage.
    reg [SYNC_STAGES-1:0] sync_ff;
 
    genvar stage_idx;
    generate
        for (stage_idx = 0; stage_idx < SYNC_STAGES; stage_idx = stage_idx + 1) begin : SYNC_CHAIN
 
            if (stage_idx == 0) begin : FIRST_STAGE
                // First stage: asynchronously cleared, synchronously sets
                // to '1' once the async reset source has been released.
                always @(posedge clk or negedge async_rst_n) begin
                    if (!async_rst_n)
                        sync_ff[stage_idx] <= 1'b0;
                    else
                        sync_ff[stage_idx] <= 1'b1;
                end
            end else begin : NEXT_STAGE
                // Subsequent stages: asynchronously cleared, synchronously
                // shift in the value of the previous stage.
                always @(posedge clk or negedge async_rst_n) begin
                    if (!async_rst_n)
                        sync_ff[stage_idx] <= 1'b0;
                    else
                        sync_ff[stage_idx] <= sync_ff[stage_idx-1];
                end
            end
 
        end
    endgenerate
 
    // Final stage output is the synchronized reset used by destination logic
    assign sync_rst_n = sync_ff[SYNC_STAGES-1];
 
endmodule
 