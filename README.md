# K16 CPU

K16 is a homebrew 16-bit computer in Verilog. It runs on a [TinyFPGA BX](https://github.com/tinyfpga/TinyFPGA-BX/) board (Lattice iCE40 LP8K) and has:

- a 640 x 480 VGA output
- a front panel with switches and LEDs, like a classic minicomputer
- a sound output

The computer has a JavaScript emulator, an assembler and a C compiler, all in the browser: [krokofant.net/code/K16/K16.html](https://krokofant.net/code/K16/K16.html). Its Help tab documents the instruction set, the front panel and the C compiler.

## The computer

- **CPU:** 16-bit words, word addressing (64K words), one-word instructions.
  - **Registers:** 8 of them. R0 .. R5 are for general use, R6 is the stack pointer (SP) and R7 the program counter (PC).
  - **Flags:**
    - Carry (C), Zero (Z), Negative (N) and Overflow (O)
    - Interrupt enable (I)
- **Instructions:**
  - **ALU:** ADD, ADC, SUB, SBC, AND, OR, XOR, NOT
  - **Increment, decrement, compare:** INC, DEC, CMP
  - **Shifts and rotations:** SHL, ASHL, SHR, ASHR, ROL, ROR
  - **Register loads:** LD, LDL, LDH, SWP
  - **Immediate loads:** LDL, LDH, LDLZ, LDHZ
  - **Memory:** LD and STO with `[register + offset]`
  - **Stack:** PSH, POP, PSF, POF
  - **Branches:** BCS/BCC, BZS/BZC, BNS/BNC, BOS/BOC
  - **Jumps and calls:** JMP, JSR, RET
  - **Flags:** CLC, SEC, CLI, SEI
  - **Stop:** HLT
- **Clock:** 25 MHz, from the PLL out of the board's 16 MHz oscillator.
- **Video:**
  - **Text:** 40 x 30 characters in 8 colors.
  - **Pixel graphics:** each frame buffer word can hold 4 pixels instead of a character, which gives 80 x 60 pixels.
  - **Sprites:** 8 sprites of 16 x 16 points (one point is 2 x 2 screen pixels), with transparency.
  - **Interrupt:** one at the start of every vertical blanking.
- **Front panel:**
  - **Switches:** address switches and a register knob.
  - **LEDs:** address and data LEDs.
  - **Commands:** EXAMINE, DEPOSIT (each also NEXT and register), START, STOP, CONTINUE, INST STEP and RESET.
  - **Status LED:** green while the CPU runs, red while it is stopped.

### Memory map

| Address | Size | Content |
|---|---|---|
| `0x0000 .. 0x0FFF` | 4096 words | RAM. The stack starts at 0x0FFE; 0x0FFF holds the interrupt vector |
| `0x8000 .. 0x87FF` | 2048 words | Frame buffer. 0x8000 .. 0x84AF is the 40 x 30 screen, 0x8600 .. 0x87FF the sprite images |
| `0xF000 .. 0xF1FF` | 512 words | ROM with library routines |
| `0xFFE8 .. 0xFFF7` | 16 words | Sprite registers: X (bit 15 = enable) and Y of each sprite |
| `0xFFF8 .. 0xFFFF` | 8 words | I/O, see below |

The I/O registers are:

- **0xFFF8 .. 0xFFFC:** address switches, control switches, address LEDs, data LEDs, and register knob plus current command.
- **0xFFFD / 0xFFFE:** 32-bit clock cycle counter, high and low word.
- **0xFFFF:** sound divisor (frequency = 25 MHz / (64 * divisor)).

Unmapped addresses read as 0x9FFF, which is the HLT instruction.

## Verilog files

| File | Content |
|---|---|
| `top.v` | `K16Computer`, the top-level module. It holds the PLL (16 MHz to 25 MHz), the address decoder for the memory map, and the instances of CPU, RAM, ROM, frame buffer, video and I/O. It also shares the frame buffer's read port between video and CPU: the CPU waits (`hold`) while the video reads. |
| `K16Cpu.v` | The CPU: a state machine for fetch, decode and execute, the interrupt entry, and the front panel commands (examine, deposit, start, step). |
| `K16Alu.v` | The ALU: arithmetic, logic, shifts and rotations, with the C, Z, N and O flags. |
| `K16Ram.v` | `K16SinglePortRam` is the 4096-word RAM; its initial content is a demo program. `K16DualPortRam` is the 2048-word frame buffer, with a write port for the CPU and a read port for video and CPU. |
| `K16Rom.v` | The 512-word ROM with library routines: Sleep, Multiply, Divide, screen filling, hex and string output, cursor position, and drawing horizontal/vertical lines and pixels. |
| `K16Video.v` | The video: characters and pixel blocks from the frame buffer, plus the 8 sprites. During the horizontal blanking it reads the sprite rows for the next line. It also holds the sprite registers and makes the vertical blanking interrupt. |
| `K16HvsyncGenerator.v` | VGA timing for 640 x 480 at 60 Hz: 800 clocks per line, 525 lines per frame. |
| `K16CharRom.v` | The 8 x 8 character set: 128 characters, including block and line graphics. |
| `K16Io.v` | The I/O registers. It scans the front panel's switches and LEDs (multiplexed with `io_clk` and `io_addr`) and holds the cycle counter and the sound generator. |
| `K16Trace.vh` | Switches the simulation trace (`$display`) on or off: compile with `-DK16_NO_TRACE` to turn it off. |
| `pins.pcf` | Pin assignments of the TinyFPGA BX: VGA, front panel, sound and status LED. |
| `apio.ini` | apio project settings (board TinyFPGA-BX). |
| `K16Cpu_tb.v`, `K16Computer_tb.v` | Testbenches: the CPU running a program, and the complete computer with frame buffer sharing between CPU and video. |
| `doc/` | PlantUML state diagrams of some instructions. |

### Tests (`tests/`)

| File | Content |
|---|---|
| `RunTests.ps1` | Runs all testbenches with Icarus Verilog from the apio packages. With `-Emulator`, it also runs `CompareWithEmulator.ps1`. |
| `K16Alu_tb.v` | The ALU: all operations and flags. |
| `K16CpuTiming_tb.v`, `K16CpuInterrupt_tb.v`, `K16CpuPanel_tb.v` | The CPU: clock cycles per instruction, interrupts, and the front panel commands. |
| `K16Io_tb.v` | The I/O registers, switch scanning, the cycle counter and the sound output. |
| `K16MemoryMap_tb.v` | The complete computer: reads and writes at the boundaries of every memory region. |
| `K16Video_tb.v` | The video: VGA timing, the interrupt, the frame buffer reads, and every pixel of a frame, with and without sprites. |
| `K16Test.vh` | Check helpers for the testbenches (`check`, `check_equal`, `test_done`). |
| `K16CpuBench.vh` | The CPU on its own, with 64K words of memory and the front panel I/O registers. The CPU testbenches use it. |
| `CompareWithEmulator.ps1`, `K16Emulate.js`, `K16Compare_tb.v` | These run each program in `tests/programs` in the JavaScript emulator and in the Verilog simulation. Registers, flags, RAM, frame buffer and sprite registers must be the same. They need the emulator's JavaScript files: `K16Cpu.js`, `K16Memory.js`, `K16Assembler.js` and the C compiler. |
| `programs/` | Test programs: `*.asm` in assembler and `*.c` in C. |

## Building

The FPGA tools are the open-source [apio](https://github.com/FPGAwars/apio) toolchain: Yosys, nextpnr and IceStorm. `install_apio.bat` (Windows) or `install_apio.sh` installs it, plus `tinyprog` for uploading.

```
apio build      # synthesis, place and route -> hardware.bin
apio upload     # program the TinyFPGA BX over USB
```

The design uses about 60% of the logic cells and 26 of the 32 block RAMs of the iCE40 LP8K. It reaches about 32 MHz, against the 25 MHz it needs.

## Tests

```
.\tests\RunTests.ps1              # all testbenches
.\tests\RunTests.ps1 -Filter Alu  # only the matching ones
.\tests\RunTests.ps1 -Emulator    # also compare with the JavaScript emulator
```
