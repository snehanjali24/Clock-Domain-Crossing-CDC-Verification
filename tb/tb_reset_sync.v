`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.07.2026 14:59:53
// Design Name: 
// Module Name: tb_reset_sync
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
 
module tb_reset_sync;
 
    //-------------------------------------------------------------------
    // Test control parameters
    //-------------------------------------------------------------------
    parameter NUM_RANDOM_TESTS = 60;
    parameter GLOBAL_TIMEOUT   = 50000; // ns
 
    // Clock periods (ns) - deliberately non-integer-multiple ratios
    parameter PERIOD_A = 10; // 100 MHz, SYNC_STAGES = 2 (baseline)
    parameter PERIOD_B = 7;  // ~142 MHz, SYNC_STAGES = 3
    parameter PERIOD_C = 33; // ~30 MHz,  SYNC_STAGES = 2 (slow clock)
    parameter PERIOD_D = 3;  // ~333 MHz, SYNC_STAGES = 4 (fast clock, deep chain)
 
    //-------------------------------------------------------------------
    // DUT interconnect
    //-------------------------------------------------------------------
    reg  async_rst_n;
    reg  clkA, clkB, clkC, clkD;
    wire sync_rst_nA, sync_rst_nB, sync_rst_nC, sync_rst_nD;
 
    //-------------------------------------------------------------------
    // Scoreboard
    //-------------------------------------------------------------------
    integer error_count;
    integer check_count;
 
    //-------------------------------------------------------------------
    // DUT instances
    //-------------------------------------------------------------------
    reset_sync #(.SYNC_STAGES(2)) dutA (
        .clk         (clkA),
        .async_rst_n (async_rst_n),
        .sync_rst_n  (sync_rst_nA)
    );
 
    reset_sync #(.SYNC_STAGES(3)) dutB (
        .clk         (clkB),
        .async_rst_n (async_rst_n),
        .sync_rst_n  (sync_rst_nB)
    );
 
    reset_sync #(.SYNC_STAGES(2)) dutC (
        .clk         (clkC),
        .async_rst_n (async_rst_n),
        .sync_rst_n  (sync_rst_nC)
    );
 
    reset_sync #(.SYNC_STAGES(4)) dutD (
        .clk         (clkD),
        .async_rst_n (async_rst_n),
        .sync_rst_n  (sync_rst_nD)
    );
 
    //-------------------------------------------------------------------
    // Clock generation
    //-------------------------------------------------------------------
    initial clkA = 1'b0;
    always #(PERIOD_A/2.0) clkA = ~clkA;
 
    initial clkB = 1'b0;
    always #(PERIOD_B/2.0) clkB = ~clkB;
 
    initial clkC = 1'b0;
    always #(PERIOD_C/2.0) clkC = ~clkC;
 
    initial clkD = 1'b0;
    always #(PERIOD_D/2.0) clkD = ~clkD;
 
    //-------------------------------------------------------------------
    // Helper function: bounded non-negative pseudo-random delay
    //-------------------------------------------------------------------
    function integer rand_range;
        input integer max_val;
        integer r;
        begin
            r = $random % (max_val + 1);
            if (r < 0) r = -r;
            rand_range = r;
        end
    endfunction
 
    //=====================================================================
    // CHECKER SET - Domain A (SYNC_STAGES = 2)
    //=====================================================================
    always @(negedge async_rst_n) begin
        #1;
        check_count = check_count + 1;
        if (sync_rst_nA !== 1'b0) begin
            error_count = error_count + 1;
            $display("[FAIL][%0t] Domain A: sync_rst_n did not assert immediately", $time);
        end
    end
 
    always @(posedge async_rst_n) begin
        fork
            begin : main_check_A
                integer i;
                for (i = 1; i <= 2; i = i + 1)
                    @(posedge clkA);
                #1;
                check_count = check_count + 1;
                if (sync_rst_nA !== 1'b1) begin
                    error_count = error_count + 1;
                    $display("[FAIL][%0t] Domain A: sync_rst_n did not deassert on expected edge", $time);
                end
                disable watch_reassert_A;
            end
            begin : watch_reassert_A
                @(negedge async_rst_n);
                disable main_check_A;
            end
        join
    end
 
    //=====================================================================
    // CHECKER SET - Domain B (SYNC_STAGES = 3)
    //=====================================================================
    always @(negedge async_rst_n) begin
        #1;
        check_count = check_count + 1;
        if (sync_rst_nB !== 1'b0) begin
            error_count = error_count + 1;
            $display("[FAIL][%0t] Domain B: sync_rst_n did not assert immediately", $time);
        end
    end
 
    always @(posedge async_rst_n) begin
        fork
            begin : main_check_B
                integer i;
                for (i = 1; i <= 3; i = i + 1)
                    @(posedge clkB);
                #1;
                check_count = check_count + 1;
                if (sync_rst_nB !== 1'b1) begin
                    error_count = error_count + 1;
                    $display("[FAIL][%0t] Domain B: sync_rst_n did not deassert on expected edge", $time);
                end
                disable watch_reassert_B;
            end
            begin : watch_reassert_B
                @(negedge async_rst_n);
                disable main_check_B;
            end
        join
    end
 
    //=====================================================================
    // CHECKER SET - Domain C (SYNC_STAGES = 2, slow clock)
    //=====================================================================
    always @(negedge async_rst_n) begin
        #1;
        check_count = check_count + 1;
        if (sync_rst_nC !== 1'b0) begin
            error_count = error_count + 1;
            $display("[FAIL][%0t] Domain C: sync_rst_n did not assert immediately", $time);
        end
    end
 
    always @(posedge async_rst_n) begin
        fork
            begin : main_check_C
                integer i;
                for (i = 1; i <= 2; i = i + 1)
                    @(posedge clkC);
                #1;
                check_count = check_count + 1;
                if (sync_rst_nC !== 1'b1) begin
                    error_count = error_count + 1;
                    $display("[FAIL][%0t] Domain C: sync_rst_n did not deassert on expected edge", $time);
                end
                disable watch_reassert_C;
            end
            begin : watch_reassert_C
                @(negedge async_rst_n);
                disable main_check_C;
            end
        join
    end
 
    //=====================================================================
    // CHECKER SET - Domain D (SYNC_STAGES = 4, fast clock)
    //=====================================================================
    always @(negedge async_rst_n) begin
        #1;
        check_count = check_count + 1;
        if (sync_rst_nD !== 1'b0) begin
            error_count = error_count + 1;
            $display("[FAIL][%0t] Domain D: sync_rst_n did not assert immediately", $time);
        end
    end
 
    always @(posedge async_rst_n) begin
        fork
            begin : main_check_D
                integer i;
                for (i = 1; i <= 4; i = i + 1)
                    @(posedge clkD);
                #1;
                check_count = check_count + 1;
                if (sync_rst_nD !== 1'b1) begin
                    error_count = error_count + 1;
                    $display("[FAIL][%0t] Domain D: sync_rst_n did not deassert on expected edge", $time);
                end
                disable watch_reassert_D;
            end
            begin : watch_reassert_D
                @(negedge async_rst_n);
                disable main_check_D;
            end
        join
    end
 
    //-------------------------------------------------------------------
    // Global timeout watchdog
    //-------------------------------------------------------------------
    initial begin
        #GLOBAL_TIMEOUT;
        $display("[FAIL] TIMEOUT: simulation did not complete in time");
        $display("=====================================================");
        $display(" RESULT: FAIL (TIMEOUT)");
        $display("=====================================================");
        $finish;
    end
 
    //-------------------------------------------------------------------
    // Main stimulus
    //-------------------------------------------------------------------
    integer test_idx;
    integer delay_val, width_val;
 
    initial begin
        error_count = 0;
        check_count = 0;
 
        $display("=====================================================");
        $display(" Reset Synchronizer Testbench - Starting");
        $display("=====================================================");
 
        // ---------------------------------------------------------------
        // Phase 0: Power-on reset hold
        // ---------------------------------------------------------------
        async_rst_n = 1'b0;
        #97; // hold well past all domains' clock periods
        async_rst_n = 1'b1;
        #200;
 
        // ---------------------------------------------------------------
        // Phase 1: Randomized assert/deassert traffic across all domains
        // ---------------------------------------------------------------
        for (test_idx = 0; test_idx < NUM_RANDOM_TESTS; test_idx = test_idx + 1) begin
            delay_val = rand_range(80) + 5;   // stable (deasserted) period
            #delay_val;
 
            async_rst_n = 1'b0;
            width_val = rand_range(40) + 2;   // reset assertion width
            #width_val;
            async_rst_n = 1'b1;
        end
 
        #200;
 
        // ---------------------------------------------------------------
        // Phase 2: Sub-clock-period glitch pulses (tests async assert path
        // with pulses shorter than the fastest destination clock period)
        // ---------------------------------------------------------------
        for (test_idx = 0; test_idx < 10; test_idx = test_idx + 1) begin
            #(rand_range(15) + 5);
            async_rst_n = 1'b0;
            #1; // 1ns glitch, shorter than PERIOD_D (3ns)
            async_rst_n = 1'b1;
        end
 
        #200;
 
        // ---------------------------------------------------------------
        // Phase 3: Rapid back-to-back reassertion bursts (stress test for
        // the deassert-checker's abort/restart logic)
        // ---------------------------------------------------------------
        for (test_idx = 0; test_idx < 8; test_idx = test_idx + 1) begin
            async_rst_n = 1'b0;
            #2;
            async_rst_n = 1'b1;
            #2;
            async_rst_n = 1'b0;
            #2;
            async_rst_n = 1'b1;
            #(rand_range(10) + 1);
        end
 
        #200;
 
        // ---------------------------------------------------------------
        // Phase 4: Final clean reset/release, then settle
        // ---------------------------------------------------------------
        async_rst_n = 1'b0;
        #100;
        async_rst_n = 1'b1;
 
        // Allow slowest domain (PERIOD_C, 2 stages) plenty of margin to
        // finish its final synchronization and checker to complete
        #500;
 
        // ---------------------------------------------------------------
        // Final report
        // ---------------------------------------------------------------
        $display("=====================================================");
        $display(" Reset Synchronizer Testbench - Complete");
        $display(" Total checks performed : %0d", check_count);
        $display(" Total errors detected  : %0d", error_count);
        if (error_count == 0) begin
            $display(" RESULT: PASS");
        end else begin
            $display(" RESULT: FAIL");
        end
        $display("=====================================================");
        $finish;
    end
 
endmodule
