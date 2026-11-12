# K16 architecture

This document describes the Verilog design of the K16 computer: the modules and their interfaces, the memory map, and the state machine of the CPU, for each instruction type and for the front panel. The instruction set itself is documented in the Help tab of the [emulator](https://krokofant.net/code/K16/K16.html).

In the diagrams, `←` is a register assignment that takes effect at the end of the clock (`<=` in Verilog), and `R[d]`, `R[s]` are the destination and source registers of the instruction.

## Modules

```mermaid
flowchart TB
    pins_clk(["clk_16: 16 MHz oscillator"])
    pins_vga(["VGA: vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B"])
    pins_panel(["Front panel: io_led0..3, io_clk, io_addr0..2, sw_col1..4, sw_reg1..3"])
    pins_sound(["sound"])
    pins_status(["statusR, statusG, statusB"])

    pll["SB_PLL40_CORE: 16 to 25 MHz"]
    decoder["Address decoder (always block in top.v)"]

    subgraph cpu_box ["K16Cpu"]
        cpu["State machine, registers R0..R7, flags"]
        alu["K16Alu"]
        cpu -->|"operand1, operand2, carryIn, operationType, operation, shiftCount"| alu
        alu -->|"result, carryOut, zeroOut, negativeOut, overflowOut"| cpu
    end

    subgraph video_box ["K16Video"]
        hv["K16HvsyncGenerator"]
        chrom["K16CharRom: characters 0..127"]
        chram["K16CharacterRam: characters 128..255"]
        sprites["Sprite registers and sprite row buffers"]
        pixel["Pixel logic and color output register"]
    end

    ram["K16SinglePortRam: 4096 words"]
    fb["K16FrameBufferRam: 2048 words"]
    rom["K16Rom: 1024 words"]
    io["K16Io: I/O and sigma-delta DAC"]
    psg["K16Psg: sound chip"]

    pins_clk --> pll
    pll -->|"clk (25 MHz)"| cpu_box
    pll -->|"clk"| video_box
    cpu -->|"address[15:0], data_out[15:0], write"| decoder
    decoder -->|"data_in[15:0]"| cpu
    decoder -->|"addr[11:0], din, write_en"| ram
    ram -->|"dout"| decoder
    decoder -->|"waddr[10:0], din, write_en"| fb
    fb -->|"dout (shared read port)"| decoder
    decoder -->|"addr[9:0]"| rom
    rom -->|"dout"| decoder
    decoder -->|"addr[2:0], din, write_en"| io
    io -->|"dout"| decoder
    decoder -->|"addr[3:0], din[7:0], write_en"| psg
    psg -->|"dout[7:0]"| decoder
    psg -->|"level[9:0]"| io
    decoder -->|"reg_addr[3:0], reg_din, reg_write, char_addr[8:0], char_din, char_write"| video_box
    video_box -->|"reg_dout"| decoder
    video_box -->|"frame_buffer_addr[10:0], want_read_frame_buffer"| fb
    fb -->|"frame_buffer_data[15:0]"| video_box
    video_box -->|"interrupt"| cpu
    decoder -->|"hold"| cpu
    io -->|"stop, reset"| cpu
    io -->|"reset"| video_box
    video_box --> pins_vga
    io <--> pins_panel
    io --> pins_sound
    cpu --> pins_status
```

| Module | File | Interface | Task |
|---|---|---|---|
| `K16Computer` | `top.v` | the board pins | Top level: PLL, address decoder, and the sharing of the frame buffer read port. |
| `K16Cpu` | `K16Cpu.v` | `clk`, `reset`, `stop`, `interrupt`, `hold`; `address[15:0]`, `data_in[15:0]`, `data_out[15:0]`, `write`; `busy`, `statusR/G/B` | The CPU: one state machine for fetch, decode, execute, interrupt entry, and the front panel commands. |
| `K16Alu` | `K16Alu.v` | `operand1`, `operand2`, `carryIn`, `operationType[1:0]`, `operation[2:0]`, `shiftCount[2:0]`; `result`, `carryOut`, `zeroOut`, `negativeOut`, `overflowOut` | Combinational ALU: arithmetic, logic, shifts and rotations by 1 .. 8, and the byte loads. |
| `K16Video` | `K16Video.v` | `clk`, `reset`; `frame_buffer_addr`, `want_read_frame_buffer`, `frame_buffer_data`; `reg_addr`, `reg_din`, `reg_write`, `reg_dout`; `char_addr`, `char_din`, `char_write`; `interrupt`, `hsync`, `vsync`, `vga_R/G/B` | 640 x 480 VGA: characters and pixel blocks from the frame buffer, 8 sprites, the vertical blanking interrupt. |
| `K16HvsyncGenerator` | `K16HvsyncGenerator.v` | `clk`; `hpos`, `vpos`, `display_on`, `vga_h_sync`, `vga_v_sync` | 800 x 525 counters and the sync pulses. |
| `K16CharRom` | `K16CharRom.v` | `character[6:0]`, `line`; `bits[7:0]` | The fixed font, characters 0 .. 127. |
| `K16CharacterRam` | `K16Ram.v` | write port for the CPU, read port for the video | Characters 128 .. 255 (block RAM); at power-up the logo tiles of the start screen. |
| `K16FrameBufferRam` | `K16Ram.v` | write port for the CPU, one read port for video and CPU | 2048 words: text, pixel blocks, sprite images; at power-up the start screen. |
| `K16SinglePortRam` | `K16Ram.v` | `addr[11:0]`, `din`, `write_en`, `dout` | The 4096-word RAM with the default program. |
| `K16Rom` | `K16Rom.v` | `addr[9:0]`, `dout` | The 1024-word ROM library (generated from `K16Rom.asm`). |
| `K16Io` | `K16Io.v` | `addr[2:0]`, `din`, `write_en`, `dout`; panel pins; `psg_level[9:0]`; `stop`, `reset`, `sound` | Front panel scanning (switches and LEDs), clock counter, sound divider, the sigma-delta DAC for the sound pin (sound chip plus square wave), and the STOP and RESET keys. |
| `K16Psg` | `K16Psg.v` | `addr[3:0]`, `din[7:0]`, `write_en`, `dout[7:0]`; `level[9:0]` | The sound chip like the AY-3-8910: three tone channels, noise, mixer, volume, envelope; `level` is the sum of the channels (0 .. 765). |

All block RAMs have a registered output: the data of an address appears one clock after the address. This is why the CPU has a wait state after every memory address it sets.

### Memory map and address decoder

| Address | Decoder pattern | Device |
|---|---|---|
| `0x0000 .. 0x0FFF` | `0000 xxxx xxxx xxxx` | RAM; `0x0FFF` holds the interrupt vector |
| `0x8000 .. 0x87FF` | `1000 0xxx xxxx xxxx` | Frame buffer (`0x8600 .. 0x87FF` are the sprite images) |
| `0x8800 .. 0x89FF` | `1000 100x xxxx xxxx` | Changeable characters, write only |
| `0xF000 .. 0xF3FF` | `1111 00xx xxxx xxxx` | ROM |
| `0xFFD0 .. 0xFFDF` | `1111 1111 1101 xxxx` | Sound chip registers R0 .. R15 (R14, R15 read 0) |
| `0xFFE8 .. 0xFFF7` | `1111 1111 1110 1xxx`, `1111 1111 1111 0xxx` | Sprite registers |
| `0xFFF8 .. 0xFFFF` | `1111 1111 1111 1xxx` | I/O: address switches, control switches, address LEDs, data LEDs, register switches, counter high, counter low, sound |
| all others | | read as `0x9FFF` (HLT), writes are ignored |

The frame buffer has only one read port. The video uses it for 2 of every 16 clocks to fetch a character, and during the horizontal blanking for the sprite rows. In the other clocks the CPU can read. When the CPU reads the frame buffer while the data is not valid, the decoder sets `hold`, and the CPU waits.

## CPU state machine

### Conditions before the state machine

The `always` block of `K16Cpu` checks these conditions first. Each of them replaces the state machine for one clock:

| Condition | Effect |
|---|---|
| `reset` | `state ← RESET`, `running ← 0`, `key_valid ← 1` |
| `stop` | `running ← 0`, `key_valid ← 1`; the CPU finishes the instruction and then goes to the front panel |
| `interrupt && enableInterrupt` | `handleInterrupt ← 1`; the state machine waits one clock |
| `hold` | the state machine waits (frame buffer data not valid yet) |

### Fetch, decode, and interrupt entry

Every instruction starts with the same three clocks. `FETCH_INSTR` puts the PC on the address bus and lets the ALU calculate PC + 1, `WAIT_INSTR` waits for the memory and stores the new PC, and `DECODE_INSTR` decodes `data_in` and prepares the ALU for the instruction.

```mermaid
stateDiagram-v2
    [*] --> RESET
    RESET --> FETCH_INSTR : registers ← 0, SP ← 0x0FFE, flags ← 0, running ← 0
    FETCH_INSTR --> WAIT_INSTR : running and no interrupt / address ← PC, ALU ← PC + 1
    FETCH_INSTR --> INTERRUPT_WAIT_WRITE_STACK : running and handleInterrupt and enableInterrupt / I ← 0, mem[SP] ← PC, ALU ← SP - 1
    FETCH_INSTR --> PANEL_FETCH_DATA : not running
    WAIT_INSTR --> DECODE_INSTR : PC ← PC + 1
    DECODE_INSTR --> Execute : decode data_in
    Execute --> FETCH_INSTR
    INTERRUPT_WAIT_WRITE_STACK --> INTERRUPT_WAIT_ADDRESS : SP ← SP - 1, handleInterrupt ← 0, address ← 0x0FFF
    INTERRUPT_WAIT_ADDRESS --> INTERRUPT_STORE_ADDRESS
    INTERRUPT_STORE_ADDRESS --> FETCH_INSTR : PC ← mem[0x0FFF]
    PANEL_FETCH_DATA --> STOPPED : see Front panel
    note right of Execute
        One of the instruction types below
    end note
```

The interrupt entry takes 4 clocks. It saves only the PC; the handler saves the flags with PSF and returns with RTI.

### ALU instructions: ADD, ADC, SUB, SBC, AND, OR, XOR, NOT

`000 ddd sss ttt 0ooo`. ADD, ADC, SUB, and SBC also set C and O; AND, OR, XOR, and NOT only Z and N. 4 clocks.

```mermaid
stateDiagram-v2
    DECODE_INSTR --> STORE_RESULT_AND_CARRY : 000 ddd sss ttt 00oo (ADD, ADC, SUB, SBC) / ALU ← R[s] op R[t]
    DECODE_INSTR --> STORE_RESULT : 000 ddd sss ttt 01oo (AND, OR, XOR, NOT) / ALU ← R[s] op R[t]
    STORE_RESULT_AND_CARRY --> FETCH_INSTR : R[d] ← result, C, Z, N, O ← ALU flags
    STORE_RESULT --> FETCH_INSTR : R[d] ← result, Z, N ← ALU flags
```

### Shift instructions: SHR, SHL, ASHR, ROR, ROL

`001 ddd sss nnn 0ooo`, shift by `nnn + 1` (1 .. 8) bits. C is the last bit shifted out; ROR and ROL rotate the 17 bits of C and the register. O is not changed. 4 clocks.

```mermaid
stateDiagram-v2
    DECODE_INSTR --> STORE_RESULT_AND_CARRY : 001 ddd sss nnn 0ooo / ALU ← shift R[s] by nnn + 1
    STORE_RESULT_AND_CARRY --> FETCH_INSTR : R[d] ← result, C, Z, N ← ALU flags
```

### Register loads, immediate loads, INC, DEC

- **Register loads:** `000 ddd sss xxx 10oo` (LD, LDL, LDH, SWP).
- **Immediate loads:** `011 ddd oo iiiiiiii` (LDL, LDH, LDLZ, LDHZ).
- **INC and DEC:** `000 ddd sss nnn 11oo`, with `nnn + 1` as the step (1 .. 8).

All of them set Z and N and take 4 clocks.

```mermaid
stateDiagram-v2
    DECODE_INSTR --> STORE_RESULT : 000 ddd sss xxx 10oo (LD, LDL, LDH, SWP) / ALU ← byte operation on R[s], R[d]
    DECODE_INSTR --> STORE_RESULT : 011 ddd oo iiiiiiii (LDL, LDH, LDLZ, LDHZ imm8) / ALU ← byte operation on R[d], imm8
    DECODE_INSTR --> STORE_RESULT : 000 ddd sss nnn 1100 (INC) / ALU ← R[s] + nnn + 1
    DECODE_INSTR --> STORE_RESULT : 000 ddd sss nnn 1111 (DEC) / ALU ← R[s] - (nnn + 1)
    STORE_RESULT --> FETCH_INSTR : R[d] ← result, Z, N ← ALU flags
```

### CMP

`000 xxx sss ttt 1110`: the flags of R[s] - R[t], without storing the result. 4 clocks.

```mermaid
stateDiagram-v2
    DECODE_INSTR --> STORE_FLAGS : 000 xxx sss ttt 1110 / ALU ← R[s] - R[t]
    STORE_FLAGS --> FETCH_INSTR : C, Z, N, O ← ALU flags
```

### Flag instructions: CLC, SEC, CLI, SEI

`001 xxx xxx xxx 10oo`. Executed in the decode clock: 3 clocks.

```mermaid
stateDiagram-v2
    DECODE_INSTR --> FETCH_INSTR : 001 ... 100o (CLC, SEC) / C ← o
    DECODE_INSTR --> FETCH_INSTR : 001 ... 101o (CLI, SEI) / I ← o, CLI also clears handleInterrupt
```

### Branches: BCS, BCC, BZS, BZC, BNS, BNC, BOS, BOC

`010 ccc bbb ooooooo`: if condition `ccc` is true, PC ← R[b] + offset7. 3 clocks if not taken, 4 if taken.

```mermaid
stateDiagram-v2
    state condition <<choice>>
    DECODE_INSTR --> condition : 010 ccc bbb ooooooo
    condition --> JUMP : condition true / ALU ← R[b] + offset7
    condition --> FETCH_INSTR : condition false
    JUMP --> FETCH_INSTR : PC ← result
```

### JMP and JSR

- **JMP:** `100 bbb oooooooooo`, PC ← R[b] + offset10. 4 clocks.
- **JSR:** `101 bbb oooooooooo`, pushes the PC first. 5 clocks.

```mermaid
stateDiagram-v2
    DECODE_INSTR --> JUMP : 100 bbb oooooooooo (JMP) / ALU ← R[b] + offset10
    DECODE_INSTR --> JSR_WAIT_WRITE_STACK : 101 bbb oooooooooo (JSR) / mem[SP] ← PC, ALU ← SP - 1
    JSR_WAIT_WRITE_STACK --> JUMP : SP ← SP - 1, ALU ← R[b] + offset10
    JUMP --> FETCH_INSTR : PC ← result
```

### HLT

`1001 1111 1111 1111` (JMP with all offset bits set). 3 clocks until the CPU is in the front panel loop.

```mermaid
stateDiagram-v2
    DECODE_INSTR --> PANEL_FETCH_DATA : 1001111111111111 / running ← 0
    PANEL_FETCH_DATA --> STOPPED : see Front panel
```

### LD and STO with memory

- **LD:** `110 ddd bbb ooooooo`, R[d] ← mem[R[b] + offset7], sets Z and N. 6 clocks.
- **STO:** `111 sss bbb ooooooo`, mem[R[b] + offset7] ← R[s]. 5 clocks.

```mermaid
stateDiagram-v2
    DECODE_INSTR --> LD_CALC_MEM_ADDR : 110 ddd bbb ooooooo (LD) / ALU ← R[b] + offset7
    LD_CALC_MEM_ADDR --> WAIT_READ_MEM : address ← result
    WAIT_READ_MEM --> STORE_READ_MEM
    STORE_READ_MEM --> FETCH_INSTR : R[d] ← data_in, Z, N from data_in
    DECODE_INSTR --> STO_CALC_MEM_ADDR : 111 sss bbb ooooooo (STO) / ALU ← R[b] + offset7
    STO_CALC_MEM_ADDR --> WAIT_WRITE_MEM : address ← result, data_out ← R[s], write ← 1
    WAIT_WRITE_MEM --> FETCH_INSTR
```

### Stack: PSH, PSF, POP, RET, RTI, POF

- **PSH and PSF:** `001 sss xxxxxx 1100` and `... 1110`, push a register or the flags. 4 clocks.
- **POP:** `001 ddd xxxxx0 1101`, sets Z and N. 6 clocks.
- **RET:** POP into the PC, `0x3C0D`. It also sets Z and N from the return address. 6 clocks.
- **RTI:** `0x3C1D`, POP into the PC with bit 4 set. It enables interrupts and leaves the flags unchanged. 6 clocks.
- **POF:** `001 xxx xxxxxx 1111`, pops the flags. 6 clocks.

```mermaid
stateDiagram-v2
    DECODE_INSTR --> PSH_WAIT_WRITE_STACK : 001 sss ... 1100 (PSH) or 1110 (PSF) / mem[SP] ← R[s] or flags, ALU ← SP - 1
    PSH_WAIT_WRITE_STACK --> FETCH_INSTR : SP ← SP - 1
    DECODE_INSTR --> POP_CALCULATE_SP : 001 ddd ... 1101 (POP, RET, RTI) / ALU ← SP + 1, returnFromInterrupt ← bit 4
    POP_CALCULATE_SP --> WAIT_READ_MEM : SP ← SP + 1, address ← SP + 1
    WAIT_READ_MEM --> STORE_READ_MEM
    STORE_READ_MEM --> FETCH_INSTR : R[d] ← data_in, then RTI - I ← 1, others - Z, N from data_in
    DECODE_INSTR --> POF_CALCULATE_SP : 001 ... 1111 (POF) / ALU ← SP + 1
    POF_CALCULATE_SP --> POF_WAIT_READ_MEM : SP ← SP + 1, address ← SP + 1
    POF_WAIT_READ_MEM --> POF_STORE_READ_MEM
    POF_STORE_READ_MEM --> FETCH_INSTR : flags ← low 4 bits of data_in
```

### Clock cycles

From one instruction fetch to the next, at 25 MHz (one clock = 40 ns). They are checked by `tests/K16CpuTiming_tb.v`.

| Instructions | Clocks |
|---|---|
| ADD, ADC, SUB, SBC, AND, OR, XOR, NOT, CMP | 4 |
| LD, LDL, LDH, SWP (registers), LDL, LDH, LDLZ, LDHZ (immediate), INC, DEC | 4 |
| SHR, SHL, ASHR, ROR, ROL (any count) | 4 |
| CLC, SEC, CLI, SEI | 3 |
| Branches | 3 if not taken, 4 if taken |
| JMP | 4 |
| JSR | 5 |
| LD from memory | 6 |
| STO | 5 |
| PSH, PSF | 4 |
| POP, POF, RET, RTI | 6 |
| HLT | 3 (until the CPU is in the front panel loop) |
| Interrupt entry | 4 |

**Extra clocks:**
- **Frame buffer reads:** a read waits while the video uses the read port (`hold`), up to 2 clocks.
- **Interrupt request:** the clock in which a request is latched adds one clock to the instruction that is running.

## Front panel

When the CPU is not running (after power-up, HLT, STOP, or a single step), it stays in a loop that reads the command and register switches (`0xFFFC`). Bits 6 .. 3 are the command key. `key_valid` makes sure that a key that is held down is executed only once: a new command is accepted after the switches showed no key (`NONE`). Each command ends by showing the data at `0xFFFB` (data LEDs) and the PC at `0xFFFA` (address LEDs).

```mermaid
stateDiagram-v2
    state key <<choice>>
    PANEL_FETCH_DATA --> PANEL_WAIT_DATA : address ← PC
    PANEL_WAIT_DATA --> PANEL_SHOW_DATA
    PANEL_SHOW_DATA --> PANEL_SHOW_ADDR : DATA_LEDS ← data_in
    PANEL_SHOW_ADDR --> STOPPED : ADDR_LEDS ← PC
    STOPPED --> PANEL_WAIT_CTRL_SWITCHES : address ← 0xFFFC
    PANEL_WAIT_CTRL_SWITCHES --> PANEL_DECODE_CTRL_SWITCHES
    PANEL_DECODE_CTRL_SWITCHES --> key
    key --> STOPPED : no valid key / key_valid ← (key == NONE)

    key --> PANEL_START_WAIT_ADDR : START / address ← 0xFFF8
    PANEL_START_WAIT_ADDR --> PANEL_START_SET_ADDR
    PANEL_START_SET_ADDR --> WAIT_INSTR : PC ← address switches, address ← switches, ALU ← switches + 1, running ← 1
    key --> WAIT_INSTR : CONTINUE / running ← 1, address ← PC, ALU ← PC + 1
    key --> WAIT_INSTR : INST_STEP / address ← PC, ALU ← PC + 1, running stays 0

    key --> PANEL_EXAMINE_WAIT_ADDR : EXAMINE / address ← 0xFFF8
    PANEL_EXAMINE_WAIT_ADDR --> PANEL_EXAMINE_SET_ADDR
    PANEL_EXAMINE_SET_ADDR --> PANEL_WAIT_DATA : PC ← address switches
    key --> PANEL_EXAMINE_WAIT_NEXT : EXAMINE_NEXT / ALU ← PC + 1
    PANEL_EXAMINE_WAIT_NEXT --> PANEL_WAIT_DATA : PC ← PC + 1

    key --> PANEL_DEPOSIT_WAIT_DATA : DEPOSIT / address ← 0xFFF8
    PANEL_DEPOSIT_WAIT_DATA --> PANEL_DEPOSIT_WRITE_DATA
    key --> PANEL_DEPOSIT_WAIT_NEXT : DEPOSIT_NEXT / address ← 0xFFF8, ALU ← PC + 1
    PANEL_DEPOSIT_WAIT_NEXT --> PANEL_DEPOSIT_WRITE_DATA : PC ← PC + 1
    PANEL_DEPOSIT_WRITE_DATA --> PANEL_FETCH_DATA : mem[PC] ← address switches

    key --> PANEL_EXAMINE_REG_WAIT_REG : EXAMINE_REGISTER / address ← 0xFFFC
    PANEL_EXAMINE_REG_WAIT_REG --> PANEL_SHOW_REG
    PANEL_SHOW_REG --> PANEL_SHOW_ADDR : DATA_LEDS ← R[register switches]

    key --> PANEL_DEPOSIT_REG_WAIT_REG : DEPOSIT_REGISTER / address ← 0xFFFC
    PANEL_DEPOSIT_REG_WAIT_REG --> PANEL_DEPOSIT_REG_FETCH_DATA
    PANEL_DEPOSIT_REG_FETCH_DATA --> PANEL_DEPOSIT_REG_WAIT_DATA : d ← register switches, address ← 0xFFF8
    PANEL_DEPOSIT_REG_WAIT_DATA --> PANEL_DEPOSIT_REG_WRITE_DATA
    PANEL_DEPOSIT_REG_WRITE_DATA --> PANEL_SHOW_ADDR : R[d] ← address switches, DATA_LEDS ← address switches
```

- **Single step:** INST_STEP runs one instruction with `running` still 0, so the next `FETCH_INSTR` returns to `PANEL_FETCH_DATA`.
- **HLT:** it also goes to `PANEL_FETCH_DATA`, so the LEDs show the PC and the word there.
- **Unused state:** `PANEL_DEPOSIT_WAIT_WRITE_MEM` is declared in `K16Cpu.v` but never entered.
