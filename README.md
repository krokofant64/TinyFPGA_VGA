# K16 CPU

K16 is a homebrew 16-bit computer in Verilog. It runs on a [TinyFPGA BX](https://github.com/tinyfpga/TinyFPGA-BX/) board (Lattice iCE40 LP8K) and has:

- a 640 x 480 VGA output
- a front panel with switches and LEDs, like a classic minicomputer
- a sound chip like the AY-3-8910 on one output pin

The computer has a JavaScript emulator, an assembler and a C compiler, all in the browser: [krokofant.net/code/K16/K16.html](https://krokofant.net/code/K16/K16.html). Its Help tab documents the instruction set, the front panel and the C compiler.

## The computer

[doc/K16Architecture.md](doc/K16Architecture.md) shows the modules and their interfaces, the memory map, the state diagrams of the CPU for each instruction type and for the front panel, and the clock cycles of each instruction.

- **CPU:** 16-bit words, word addressing (64K words), one-word instructions.
  - **Registers:** 8 of them. R0 .. R5 are for general use, R6 is the stack pointer (SP) and R7 the program counter (PC).
  - **Flags:**
    - Carry (C), Zero (Z), Negative (N) and Overflow (O)
    - Interrupt enable (I)
- **Instructions:**
  - **ALU:** ADD, ADC, SUB, SBC, AND, OR, XOR, NOT
  - **Increment, decrement, compare:** INC, DEC (by 1 .. 8), CMP
  - **Shifts and rotations:** SHL, ASHL, SHR, ASHR, ROL, ROR, by 1 .. 8 bits in one instruction
  - **Register loads:** LD, LDL, LDH, SWP
  - **Immediate loads:** LDL, LDH, LDLZ, LDHZ
  - **Memory:** LD and STO with `[register + offset]`
  - **Stack:** PSH, POP, PSF, POF
  - **Branches:** BCS/BCC, BZS/BZC, BNS/BNC, BOS/BOC
  - **Jumps and calls:** JMP, JSR, RET, RTI (return from interrupt, keeps the flags)
  - **Flags:** CLC, SEC, CLI, SEI
  - **Stop:** HLT
- **ROM library:** 1024 words of routines for C and assembler: arithmetic, strings, text, scrolling, graphics, sprites, sound, time and interrupts.
- **Clock:** 25 MHz, from the PLL out of the board's 16 MHz oscillator.
- **Video:**
  - **Text:** 40 x 30 characters in 8 colors. Characters 0 .. 127 are fixed, the program can change characters 128 .. 255.
  - **Start screen:** the frame buffer and the changeable characters hold a frame with the krokofant logo after power-up.
  - **Pixel graphics:** each frame buffer word can hold 4 pixels instead of a character, which gives 80 x 60 pixels.
  - **Sprites:** 8 sprites of 16 x 16 points (one point is 2 x 2 screen pixels), with transparency.
  - **Interrupt:** one at the start of every vertical blanking.
- **Front panel:**
  - **Switches:** address switches and a register knob.
  - **LEDs:** address and data LEDs.
  - **Commands:** EXAMINE, DEPOSIT (each also NEXT and register), START, STOP, CONTINUE, INST STEP and RESET.
  - **Status LED:** green while the CPU runs, red while it is stopped.
- **Sound:** a sound chip like the AY-3-8910 at 1.7734 MHz, with three tone channels, noise, a mixer, 16 volume levels and the envelope, plus the square wave of the SOUND register.
  - **Output:** both are mixed and output on the one sound pin with a sigma-delta DAC at 25 MHz.
  - **RESET:** switches all sound off (SOUND = 0, all sound chip registers 0).
  - **Filter:** put a low-pass filter in front of the amplifier, e.g. 1 kΩ in series and 10 nF to ground (cut-off about 16 kHz).

### Memory map

| Address | Size | Content |
|---|---|---|
| `0x0000 .. 0x0FFF` | 4096 words | RAM. The stack starts at 0x0FFE; 0x0FFF holds the interrupt vector |
| `0x8000 .. 0x87FF` | 2048 words | Frame buffer. 0x8000 .. 0x84AF is the 40 x 30 screen, 0x8500 .. 0x8504 the variables of the ROM library, 0x8600 .. 0x87FF the sprite images |
| `0x8800 .. 0x89FF` | 512 words | Changeable characters 128 .. 255, write only: 4 words per character |
| `0xF000 .. 0xF3FF` | 1024 words | ROM library |
| `0xFFD0 .. 0xFFDF` | 16 words | Sound chip: the AY's registers R0 .. R13 (0xFFDE and 0xFFDF read 0) |
| `0xFFE8 .. 0xFFF7` | 16 words | Sprite registers: X (bit 15 = enable) and Y of each sprite |
| `0xFFF8 .. 0xFFFF` | 8 words | I/O, see below |

The I/O registers are:

- **0xFFF8 .. 0xFFFC:** address switches, control switches, address LEDs, data LEDs, and register knob plus current command.
- **0xFFFD / 0xFFFE:** 32-bit clock cycle counter, high and low word.
- **0xFFFF:** sound divisor (frequency = 25 MHz / (64 * divisor)), a square wave that plays together with the sound chip.

0xFFE0 .. 0xFFE7 are free (planned for a serial port).

Unmapped addresses read as 0x9FFF, which is the HLT instruction.

## Verilog files

| File | Content |
|---|---|
| `top.v` | `K16Computer`, the top-level module. It holds the PLL (16 MHz to 25 MHz), the address decoder for the memory map, and the instances of CPU, RAM, ROM, frame buffer, video, I/O and sound chip. It also shares the frame buffer's read port between video and CPU: the CPU waits (`hold`) while the video reads. |
| `K16Cpu.v` | The CPU: a state machine for fetch, decode and execute, the interrupt entry, and the front panel commands (examine, deposit, start, step). |
| `K16Alu.v` | The ALU: arithmetic, logic, shifts and rotations by 1 .. 8 bits, with the C, Z, N and O flags. |
| `K16Ram.v` | `K16SinglePortRam` is the 4096-word RAM; its default program is the example "C: ROM library with custom characters". The CPU waits for START, so the start screen stays until then. `K16FrameBufferRam` is the 2048-word frame buffer, with a write port for the CPU and a read port for video and CPU. `K16CharacterRam` holds the changeable characters. |
| `K16BootFrame.vh`, `K16BootChars.vh` | Generated by `tests/BuildBootScreen.ps1`: the start screen in the frame buffer and the changeable characters. |
| `K16Rom.v` | The 1024-word ROM library. Generated by `tests/BuildRom.ps1` from `K16Rom.asm` of the emulator; its documentation is in the emulator's Help tab. |
| `K16Video.v` | The video: characters and pixel blocks from the frame buffer, plus the 8 sprites. During the horizontal blanking it reads the sprite rows for the next line. It also holds the sprite registers and makes the vertical blanking interrupt. |
| `K16HvsyncGenerator.v` | VGA timing for 640 x 480 at 60 Hz: 800 clocks per line, 525 lines per frame. |
| `K16CharRom.v` | The fixed 8 x 8 characters 0 .. 127, including block and line graphics. |
| `K16Io.v` | The I/O registers. It scans the front panel's switches and LEDs (multiplexed with `io_clk` and `io_addr`) and holds the cycle counter, the square wave generator, and the sigma-delta DAC for the sound pin. |
| `K16Psg.v` | The sound chip, like the AY-3-8910: registers R0 .. R13, three tone channels, noise (17-bit LFSR), mixer, logarithmic volume and the envelope with all 16 shapes. A phase accumulator makes its clock (1.7734 MHz / 8) from the 25 MHz clock. It uses no block RAM. |
| `K16Trace.vh` | Switches the simulation trace (`$display`) on or off: compile with `-DK16_NO_TRACE` to turn it off. |
| `pins.pcf` | Pin assignments of the TinyFPGA BX: VGA, front panel, sound and status LED. |
| `apio.ini` | apio project settings (board TinyFPGA-BX). |
| `K16Cpu_tb.v`, `K16Computer_tb.v` | Testbenches: the CPU running a program, and the complete computer with frame buffer sharing between CPU and video. |
| `doc/` | [K16Architecture.md](doc/K16Architecture.md): module diagram, memory map, CPU state diagrams, and clock cycles (Mermaid). |

### Tests (`tests/`)

| File | Content |
|---|---|
| `RunTests.ps1` | Runs all testbenches with Icarus Verilog from the apio packages. With `-Emulator`, it also runs `CompareWithEmulator.ps1`. |
| `K16Alu_tb.v` | The ALU: all operations and flags. |
| `K16CpuTiming_tb.v`, `K16CpuInterrupt_tb.v`, `K16CpuPanel_tb.v` | The CPU: clock cycles per instruction, interrupts, and the front panel commands. |
| `K16Io_tb.v` | The I/O registers, switch scanning, the cycle counter, the square wave and the sigma-delta DAC. |
| `K16Psg_tb.v` | The sound chip: register widths, the clock, tone periods, noise, mixer, volume levels, and all 16 envelope shapes against a reference. |
| `K16MemoryMap_tb.v` | The complete computer: reads and writes at the boundaries of every memory region. |
| `K16Video_tb.v` | The video: VGA timing, the interrupt, the frame buffer reads, and every pixel of a frame, with and without sprites. |
| `K16Test.vh` | Check helpers for the testbenches (`check`, `check_equal`, `test_done`). |
| `K16CpuBench.vh` | The CPU on its own, with 64K words of memory and the front panel I/O registers. The CPU testbenches use it. |
| `CompareWithEmulator.ps1`, `K16Emulate.js`, `K16Compare_tb.v` | These run each program in `tests/programs` in the JavaScript emulator and in the Verilog simulation. Registers, flags, RAM, frame buffer, sprite registers and changeable characters must be the same. They need the emulator's JavaScript files: `K16Cpu.js`, `K16Memory.js`, `K16RomImage.js`, `K16Assembler.js` and the C compiler. |
| `BuildRom.ps1`, `K16BuildRom.js` | Assemble the emulator's `K16Rom.asm` into `K16Rom.v` and the emulator's `K16RomImage.js`. With `-Check`, they only check that these files are up to date. |
| `BuildBootScreen.ps1` | Makes the start screen from the two logo images of the website: `K16BootFrame.vh`, `K16BootChars.vh` and the emulator's `K16BootScreen.js`. It also has `-Check`, and `-Preview` writes a picture. |
| `programs/` | Test programs: `*.asm` in assembler and `*.c` in C. |

## Building

The FPGA tools are the open-source [apio](https://github.com/FPGAwars/apio) toolchain: Yosys, nextpnr and IceStorm. `install_apio.bat` (Windows) or `install_apio.sh` installs it, plus `tinyprog` for uploading.

```
apio build      # synthesis, place and route -> hardware.bin
apio upload     # program the TinyFPGA BX over USB
```

The design uses about 64% of the logic cells and 30 of the 32 block RAMs of the iCE40 LP8K. It reaches 31 to 35 MHz, depending on the placement, against the 25 MHz it needs.

After a change of the ROM library or the logo:

```
.\tests\BuildRom.ps1         # K16Rom.asm -> K16Rom.v and K16RomImage.js
.\tests\BuildBootScreen.ps1  # logo images -> start screen files
```

## Tests

```
.\tests\RunTests.ps1              # all testbenches
.\tests\RunTests.ps1 -Filter Alu  # only the matching ones
.\tests\RunTests.ps1 -Emulator    # also compare with the JavaScript emulator
```

`RunTests.ps1` fails if the generated ROM or start screen files are out of date.
