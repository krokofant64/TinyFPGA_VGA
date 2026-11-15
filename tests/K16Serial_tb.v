// ----------------------------------------------------------------------------
// K16Serial: the serial port. The bus is driven with the CPU's timing (a read
// keeps the address for 3 clocks, a write writes for 2 clocks). TX is looped
// back to RX, or RX is driven by the testbench.
//
// Checks: register values after reset, CONTROL read back, bit times at 115200,
// 9600, and 300 baud, bytes in order, one byte per (2-clock) write, the
// 16-byte buffer and overrun, a framing error, reading an empty buffer, the
// interrupt level and INT_CAUSE, the frame flag (also a frame during a read),
// and RESET.
// ----------------------------------------------------------------------------

`timescale 1 ns/10 ps

`include "K16Serial.v"

module K16Serial_tb();
`include "K16Test.vh"

  reg clk = 0;
  always #20 clk = ~clk; // 25 MHz

  reg         reset = 0;
  reg         select = 0;
  reg  [1:0]  addr = 0;
  reg         write = 0;
  reg  [15:0] din = 0;
  wire [15:0] dout;
  reg         frame = 0;
  wire        irq;
  wire        tx;
  reg         loop = 1;                // RX = TX
  reg         rx_tb = 1;
  wire        rx = loop ? tx : rx_tb;

  K16Serial serial(.clk(clk), .reset(reset), .select(select), .addr(addr), .write(write), .din(din), .dout(dout),
                   .frame(frame), .irq(irq), .rx(rx), .tx(tx));

  localparam DATA = 0, STATUS = 1, CONTROL = 2, CAUSE = 3;

  // Like the CPU's STO: address, data, and write for 2 clocks, then a fetch
  task bus_write;
    input [1:0]  register;
    input [15:0] value;
    begin
      @(negedge clk);
      select = 1; addr = register; write = 1; din = value;
      @(negedge clk);
      @(negedge clk);
      select = 0; write = 0;
      @(negedge clk);
    end
  endtask

  // Like the CPU's LD: the address for 3 clocks, the data is taken at the
  // third clock edge
  reg [15:0] read_value;
  task bus_read;
    input [1:0] register;
    begin
      @(negedge clk);
      select = 1; addr = register; write = 0;
      @(negedge clk);
      @(negedge clk);
      read_value = dout;
      @(negedge clk);
      select = 0;
      @(negedge clk);
    end
  endtask

  task check_read;
    input [1:0]  register;
    input [15:0] value;
    input [8*120-1:0] text;
    begin
      bus_read(register);
      check_equal(read_value, value, text);
    end
  endtask

  // Waits until a byte can be read (at most theClocks clocks)
  integer waited;
  task wait_rx_ready;
    input integer theClocks;
    begin
      waited = 0;
      read_value = 0;
      while (!(read_value & 1) && waited < theClocks)
        begin
          bus_read(STATUS);
          waited = waited + 5;
        end
    end
  endtask

  task send;
    input [7:0] value;
    begin
      read_value = 0;
      while (!(read_value & 2))
        bus_read(STATUS);
      bus_write(DATA, value);
    end
  endtask

  // Bit time: clocks of the first start bit after start_bit = 0 (the bytes
  // sent for it begin with a 1 bit)
  integer tx_fall = 0, start_bit = 0;
  reg tx_before = 1;
  always @(posedge clk)
    begin
      if (tx_before && !tx)
        tx_fall = $time / 40;
      if (!tx_before && tx && start_bit == 0)
        start_bit = $time / 40 - tx_fall;
      tx_before = tx;
    end

  integer i;

  initial
    begin
      test_section("Serial: registers after power-up");
      check_read(STATUS, 16'h0006, "STATUS: TX_READY and TX_IDLE");
      check_read(CONTROL, 16'h0000, "CONTROL: 115200, interrupts off");
      check_read(CAUSE, 16'h0000, "INT_CAUSE");
      check_equal(irq, 0, "no interrupt");
      check_equal(tx, 1, "TX idle high");
      bus_write(CONTROL, 16'hFFE5);
      check_read(CONTROL, 16'h0025, "CONTROL keeps bits 5..0");
      bus_write(CONTROL, 0);

      test_section("Serial: one byte at 115200");
      start_bit = 0;
      send(8'h55);
      wait_rx_ready(4000);
      check_equal(start_bit, 217, "start bit lasts 217 clocks");
      check_equal(read_value, 16'h0003, "STATUS: RX_READY, TX_READY (the stop bit is still being sent)");
      repeat (200) @(negedge clk);
      check_read(STATUS, 16'h0007, "STATUS: RX_READY, TX_READY, TX_IDLE");
      check_read(DATA, 16'h0055, "received byte");
      check_read(STATUS, 16'h0006, "the byte is removed by the read");
      check_read(DATA, 16'h0000, "DATA of an empty buffer");
      check_read(STATUS, 16'h0006, "reading an empty buffer changes nothing (and one 2-clock write sent one byte)");

      test_section("Serial: 20 bytes, 16-byte buffer, overrun");
      for (i = 0; i < 20; i = i + 1)
        send(8'hA0 + i);
      repeat (217 * 24) @(negedge clk);         // The last 2 bytes are sent and received (no STATUS reads: they clear OVERRUN)
      check_read(STATUS, 16'h000F, "STATUS: RX_READY, TX_READY, TX_IDLE, OVERRUN");
      check_read(STATUS, 16'h0007, "reading STATUS clears OVERRUN");
      for (i = 0; i < 16; i = i + 1)
        check_read(DATA, 8'hA0 + i, "buffer in order");
      check_read(STATUS, 16'h0006, "buffer empty after 16 reads");

      test_section("Serial: framing error");
      loop = 0;
      rx_tb = 0;
      repeat (217 * 12) @(negedge clk);         // A break: no stop bit
      rx_tb = 1;
      repeat (300) @(negedge clk);
      check_read(STATUS, 16'h0016, "STATUS: FRAMING, no byte");
      check_read(STATUS, 16'h0006, "reading STATUS clears FRAMING");
      loop = 1;

      test_section("Serial: interrupts");
      bus_write(CONTROL, 16'h0010);             // Receive interrupt
      check_equal(irq, 0, "receive interrupt: none while the buffer is empty");
      send(8'h3C);
      wait_rx_ready(4000);
      check_equal(irq, 1, "receive interrupt while a byte is there");
      check_read(CAUSE, 16'h0002, "INT_CAUSE: receive pending");
      check_read(DATA, 16'h003C, "byte");
      check_equal(irq, 0, "no interrupt after the read");
      bus_write(CONTROL, 16'h0020);             // Transmit interrupt
      check_equal(irq, 1, "transmit interrupt while a byte can be written");
      check_read(CAUSE, 16'h0004, "INT_CAUSE: transmit pending");
      read_value = 0;
      while (!(read_value & 4))                 // TX_IDLE: the last byte is sent
        bus_read(STATUS);
      bus_write(DATA, 16'h0001);
      bus_write(DATA, 16'h0002);                // The holding register is full now
      check_equal(irq, 0, "no transmit interrupt while the holding register is full");
      bus_write(CONTROL, 0);
      repeat (217 * 22) @(negedge clk);
      check_read(DATA, 16'h0001, "first byte");
      check_read(DATA, 16'h0002, "second byte");

      test_section("Serial: frame flag in INT_CAUSE");
      @(negedge clk); frame = 1; @(negedge clk); frame = 0;
      check_read(CAUSE, 16'h0001, "FRAME after a vertical blanking");
      check_read(CAUSE, 16'h0000, "reading clears FRAME");
      // A frame in the second clock of a read: the read gets 0, the flag stays
      @(negedge clk);
      select = 1; addr = CAUSE; write = 0;
      @(negedge clk);
      frame = 1;
      @(negedge clk);
      frame = 0;
      read_value = dout;
      @(negedge clk);
      select = 0;
      @(negedge clk);
      check_equal(read_value, 16'h0000, "the read started before the frame");
      check_read(CAUSE, 16'h0001, "the frame is not lost");

      test_section("Serial: 9600 and 300 baud");
      bus_write(CONTROL, 16'h0004);
      start_bit = 0;
      send(8'hC3);
      wait_rx_ready(30000);
      check_equal(start_bit, 2604, "9600: start bit lasts 2604 clocks");
      check_read(DATA, 16'h00C3, "9600: received byte");
      bus_write(CONTROL, 16'h0008);
      start_bit = 0;
      send(8'h81);
      wait_rx_ready(900000);
      check_equal(start_bit, 83333, "300: start bit lasts 83333 clocks");
      check_read(DATA, 16'h0081, "300: received byte");

      test_section("Serial: RESET");
      bus_write(CONTROL, 16'h0013);
      loop = 0;
      rx_tb = 0; repeat (1200) @(negedge clk); rx_tb = 1;  // Part of a byte at 38400 (651 clocks per bit)
      bus_write(DATA, 16'h00FF);
      @(negedge clk); frame = 1; @(negedge clk); frame = 0;
      @(negedge clk); reset = 1; @(negedge clk); reset = 0;
      check_read(CONTROL, 16'h0000, "CONTROL 0 (115200, interrupts off)");
      check_read(STATUS, 16'h0006, "STATUS: buffer empty, nothing to send");
      check_read(CAUSE, 16'h0000, "INT_CAUSE 0");
      check_equal(tx, 1, "TX idle high");
      repeat (8000) @(negedge clk);
      check_read(STATUS, 16'h0006, "the byte that was being received is dropped");
      loop = 1;

      test_done;
    end

  initial
    begin
      #200000000;
      $fdisplay(32'h8000_0002, "FAIL: timeout");
      $finish;
    end
endmodule
