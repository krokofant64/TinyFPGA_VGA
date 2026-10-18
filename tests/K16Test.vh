// ----------------------------------------------------------------------------
// Check helpers for the K16 testbenches. Include inside the testbench module.
//
// Results go to stderr, because the CPU trace goes to stdout. A testbench
// ends with test_done, which prints "PASS: ..." or "FAIL: ..." as the last
// line (RunTests.ps1 looks for it).
// ----------------------------------------------------------------------------

integer test_checks = 0;
integer test_errors = 0;
reg [8*120-1:0] test_message;

// Fails if the condition is not 1 (also if it is x or z)
task check;
  input condition;
  input [8*120-1:0] message;
  begin
    test_checks = test_checks + 1;
    if (condition !== 1'b1)
      begin
        test_errors = test_errors + 1;
        if (test_errors <= 25)
          $fdisplay(32'h8000_0002, "  failed: %0s", message);
      end
  end
endtask

// Fails if the values differ (also if the actual value contains x or z)
task check_equal;
  input [31:0] actual;
  input [31:0] expected;
  input [8*120-1:0] message;
  begin
    test_checks = test_checks + 1;
    if (actual !== expected)
      begin
        test_errors = test_errors + 1;
        if (test_errors <= 25)
          $fdisplay(32'h8000_0002, "  failed: %0s: expected %0d (0x%0h), got %0d (0x%0h)", message, expected, expected, actual, actual);
      end
  end
endtask

task test_section;
  input [8*120-1:0] name;
  begin
    $fdisplay(32'h8000_0002, "%0s", name);
  end
endtask

task test_done;
  begin
    if (test_errors == 0)
      $fdisplay(32'h8000_0002, "PASS: %0d checks", test_checks);
    else
      $fdisplay(32'h8000_0002, "FAIL: %0d of %0d checks failed", test_errors, test_checks);
    $finish;
  end
endtask
