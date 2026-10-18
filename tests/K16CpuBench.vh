// ----------------------------------------------------------------------------
// Test bench for the K16 CPU on its own. Include inside the testbench module,
// after K16Test.vh.
//
// - 64K words of memory with a registered read port, like the block RAMs
// - The front panel I/O registers 0xFFF8 .. 0xFFFC, like K16Io: switches set
//   by the testbench, LEDs written by the CPU
// - The CPU inputs reset, stop, interrupt, and hold, driven by the testbench
// ----------------------------------------------------------------------------

reg clk = 0;
always #20 clk = ~clk; // 25 MHz

reg reset = 0;
reg stop = 0;
reg interrupt = 0;
reg hold = 0;

wire [15:0] address;
wire [15:0] data_out;
wire        write;
wire        busy;
wire        statusR;
wire        statusG;
wire        statusB;
reg  [15:0] data_in;

reg [15:0] mem[0:65535];

// Front panel
reg [15:0] addr_switches = 0;
reg [15:0] ctrl_switches = 0;
reg [3:0]  panel_command = 0;   // `NONE, `START, ... (K16Cpu.v)
reg [2:0]  register_knob = 0;
reg [15:0] addr_leds = 0;
reg [15:0] data_leds = 0;

always @(posedge clk)
  begin
    if (write)
      begin
        if (address == `ADDR_LEDS)
          addr_leds <= data_out;
        else if (address == `DATA_LEDS)
          data_leds <= data_out;
        else if (address < 16'hFFF8)
          mem[address] <= data_out;
      end
    case (address)
      `ADDR_SWITCHES:        data_in <= addr_switches;
      `CTRL_SWITCHES:        data_in <= ctrl_switches;
      `ADDR_LEDS:            data_in <= addr_leds;
      `DATA_LEDS:            data_in <= data_leds;
      `CMD_AND_REG_SWITCHES: data_in <= {9'b0, panel_command, register_knob};
      default:               data_in <= mem[address];
    endcase
  end

K16Cpu cpu(.clk(clk), .reset(reset), .stop(stop), .interrupt(interrupt), .hold(hold), .busy(busy),
           .address(address), .data_in(data_in), .data_out(data_out), .write(write),
           .statusR(statusR), .statusG(statusG), .statusB(statusB));

integer cycles = 0;
always @(posedge clk)
  cycles <= cycles + 1;

integer bench_i;

task clear_memory;
  begin
    for (bench_i = 0; bench_i < 65536; bench_i = bench_i + 1)
      mem[bench_i] = 16'h0000;
  end
endtask

// Reset the CPU; afterwards it waits for front panel commands
task reset_cpu;
  begin
    @(negedge clk);
    reset = 1;
    repeat (3) @(negedge clk);
    reset = 0;
    repeat (20) @(negedge clk);
  end
endtask

// Start a program directly (without the front panel)
task start_at;
  input [15:0] start_address;
  begin
    @(negedge clk);
    cpu.register[7] = start_address;
    cpu.running = 1;
    cpu.state = cpu.FETCH_INSTR;
  end
endtask

// Wait until the CPU executed HLT (or was stopped); halted = 0 on timeout
reg halted;
task wait_halt;
  input integer max_cycles;
  integer start_cycle;
  begin
    start_cycle = cycles;
    @(negedge clk);
    while (cpu.running && cycles - start_cycle < max_cycles)
      @(negedge clk);
    halted = !cpu.running;
  end
endtask

// Press a front panel switch long enough for the CPU to see it, then release
// it until the CPU accepts the next command
task press;
  input [3:0] command;
  begin
    @(negedge clk);
    panel_command = command;
    repeat (40) @(negedge clk);
    panel_command = `NONE;
    repeat (40) @(negedge clk);
  end
endtask
