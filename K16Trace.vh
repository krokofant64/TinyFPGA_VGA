`ifndef K16_TRACE_VH
`define K16_TRACE_VH

// Simulation trace ($display) of the CPU, the ALU, and the I/O module.
// Compile with -DK16_NO_TRACE to switch it off, which makes simulations
// much faster. Synthesis ignores $display anyway.
`ifdef K16_NO_TRACE
`define K16_TRACE 1'b0
`else
`define K16_TRACE 1'b1
`endif

`endif
