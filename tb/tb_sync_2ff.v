`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.07.2026 14:28:35
// Design Name: 
// Module Name: tb_sync_2ff
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
 
module tb_sync_2ff;
 
    // -------------------------------------------------------------------
    // Parameters / DUT signals
    // -------------------------------------------------------------------
    reg         src_clk;
    reg         dst_clk;
    reg         dst_rst_n;
    reg         src_data;      // data generated in the "source" domain
    wire        sync_out;
 
    integer     src_period;    // dynamically adjustable clock periods
    integer     dst_period;
 
    integer     error_count;
    integer     check_count;
    integer     i;
 
    // History buffer used by the TB to model expected 2-cycle latency.
    // hist[0] = value sampled at current dst_clk edge
    // hist[1] = value sampled 1 dst_clk edge ago
    // Expected sync_out (after the flop updates) = hist[1] value from
    // the PREVIOUS edge, i.e. the value that was in async_in two edges back.
    reg hist0;
 
    // -------------------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------------------
    sync_2ff #(
        .WIDTH       (1),
        .RESET_VALUE (0)
    ) DUT (
        .clk       (dst_clk),
        .rst_n     (dst_rst_n),
        .async_in  (src_data),
        .sync_out  (sync_out)
    );
 
    // -------------------------------------------------------------------
    // Clock generation - periods are variables so we can change frequency
    // mid-simulation to model different source/destination clock ratios.
    // -------------------------------------------------------------------
    initial begin
        src_clk = 0;
        forever #(src_period/2) src_clk = ~src_clk;
    end
 
    initial begin
        dst_clk = 0;
        forever #(dst_period/2) dst_clk = ~dst_clk;
    end
 
    // -------------------------------------------------------------------
    // Source domain stimulus: data toggles/changes only on src_clk edges,
    // completely asynchronous with respect to dst_clk. Uses $random so
    // change points are unpredictable relative to the destination clock.
    // -------------------------------------------------------------------
    reg gen_enable;
    initial begin
        src_data   = 1'b0;
        gen_enable = 1'b0;
    end
 
    always @(posedge src_clk) begin
        if (gen_enable) begin
            if (($random % 3) == 0)          // ~33% chance to change each src edge
                src_data <= ~src_data;
        end
    end
 
    // -------------------------------------------------------------------
    // Golden reference model: independently reproduces the two-stage
    // capture/resolve pipeline (stage1 = hist0, stage2 = expected_sync_out)
    // so the DUT's actual latency (exactly 2 dst_clk edges from the value
    // present at the input to it appearing at the output) can be checked.
    // -------------------------------------------------------------------
    reg expected_sync_out;
    reg [1:0] valid_shift; // tracks how many valid samples we have post-reset
 
    always @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            hist0             <= 1'b0;
            expected_sync_out <= 1'b0;
            valid_shift       <= 2'b00;
        end else begin
            hist0             <= src_data;       // mirrors DUT stage-1 (sync_ff1)
            expected_sync_out <= hist0;           // mirrors DUT stage-2 (sync_out)
            valid_shift       <= {valid_shift[0], 1'b1};
        end
    end
 
    // -------------------------------------------------------------------
    // Checker: compares DUT sync_out to expected_sync_out after each
    // dst_clk edge has fully settled (small delta delay).
    // -------------------------------------------------------------------
    always @(posedge dst_clk) begin
        #1; // allow all nonblocking updates (DUT + model) to settle
        if (dst_rst_n && valid_shift[1]) begin
            check_count = check_count + 1;
            if (sync_out !== expected_sync_out) begin
                error_count = error_count + 1;
                $display("[%0t] ERROR: sync_out=%b expected=%b (src_data=%b)",
                          $time, sync_out, expected_sync_out, src_data);
            end
        end
    end
 
    // -------------------------------------------------------------------
    // Reset behavior checker (separate, explicit check)
    // -------------------------------------------------------------------
    task apply_reset;
        begin
            dst_rst_n  = 1'b0;
            gen_enable = 1'b0;
            repeat (3) @(posedge dst_clk);
            #1;
            if (sync_out !== 1'b0) begin
                error_count = error_count + 1;
                $display("[%0t] ERROR: sync_out not 0 during reset (=%b)", $time, sync_out);
            end else begin
                $display("[%0t] INFO : Reset check PASSED (sync_out held at 0)", $time);
            end
            repeat (2) @(posedge dst_clk);
            dst_rst_n = 1'b1;
        end
    endtask
 
    // -------------------------------------------------------------------
    // Main test sequence
    // -------------------------------------------------------------------
    initial begin
        error_count = 0;
        check_count = 0;
        dst_rst_n   = 1'b0;
 
        // Scenario 1: destination clock FASTER than source clock (10ns vs 30ns)
        src_period = 30;
        dst_period = 10;
        $display("\n=== SCENARIO 1: src_clk=%0dns  dst_clk=%0dns (dst faster) ===", src_period, dst_period);
        apply_reset;
        gen_enable = 1'b1;
        repeat (300) @(posedge dst_clk);
 
        // Scenario 2: destination clock SLOWER than source clock (37ns vs 9ns)
        gen_enable = 1'b0;
        src_period = 9;
        dst_period = 37;
        $display("\n=== SCENARIO 2: src_clk=%0dns  dst_clk=%0dns (dst slower) ===", src_period, dst_period);
        apply_reset;
        gen_enable = 1'b1;
        repeat (150) @(posedge dst_clk);
 
        // Scenario 3: near-equal, odd-ratio frequencies + mid-test async reset pulse
        gen_enable = 1'b0;
        src_period = 11;
        dst_period = 13;
        $display("\n=== SCENARIO 3: src_clk=%0dns  dst_clk=%0dns (near-equal) ===", src_period, dst_period);
        apply_reset;
        gen_enable = 1'b1;
        repeat (100) @(posedge dst_clk);
 
        // Assert an asynchronous reset in the middle of random activity
        $display("[%0t] INFO : Applying mid-test asynchronous reset pulse", $time);
        apply_reset;
        repeat (200) @(posedge dst_clk);
 
        gen_enable = 1'b0;
 
        // -------------------------------------------------------------------
        // Final PASS/FAIL summary
        // -------------------------------------------------------------------
        $display("\n=====================================================");
        $display(" TB_SYNC_2FF : Total Checks = %0d, Errors = %0d", check_count, error_count);
        if (error_count == 0 && check_count > 0)
            $display(" RESULT: *** PASS ***");
        else
            $display(" RESULT: *** FAIL ***");
        $display("=====================================================\n");
 
        $finish;
    end
 
    // Safety timeout
    initial begin
        #200000;
        $display("ERROR: TB TIMEOUT - simulation did not finish");
        $finish;
    end
 
    // Waveform dump
    initial begin
        $dumpfile("tb_sync_2ff.vcd");
        $dumpvars(0, tb_sync_2ff);
    end
 
endmodule
 
