`ifndef K16ROM_V
`define K16ROM_V

// Generated from K16Rom.asm by tests\BuildRom.ps1. Do not edit.
module K16Rom (addr, clk, dout);// 1536x16
  parameter addr_width = 11;
  parameter data_width = 16;
  input [addr_width-1:0] addr;
  input clk;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout; // Register for output.
  reg [data_width-1:0] rom [1535:0];
  always @(posedge clk)
    begin
      dout <= rom[addr]; // Output register controlled by clock.
    end
  initial
    begin
    // ;------------------------------------------------------------------------------
    // ; K16 ROM library 0xF000 .. 0xF3FF, and the monitor 0xF400 .. 0xF5FF
    // ;
    // ; This file is the source of the ROM. tests\BuildRom.ps1 in the Verilog repository
    // ; assembles it into K16Rom.v (hardware) and K16RomImage.js (emulator).
    // ;
    // ; Calling convention (the one of the C compiler):
    // ;   Arguments 1 and 2 are in R0 and R1. Further arguments are on the stack: the
    // ;   caller pushes them, the last one first, and removes them after the call.
    // ;   At the entry of a routine, argument 3 is at [SP +2], argument 4 at [SP +3], ...
    // ;   The result is in R0.
    // ;   R0, R1, and R3 can change. R2, R4, R5, and SP do not change.
    // ;
    // ; A label without "_" is a public routine: the C header k16lib.h declares it and the
    // ; assembler knows it as $Name. Call it from assembler with
    // ;   LDL R3 $Name.L
    // ;   LDH R3 $Name.H
    // ;   JSR [R3]
    // ;
    // ; Variables are in the unused part of the frame buffer. Their power-up value 0 is valid.
    // ;------------------------------------------------------------------------------
    // .define $VarsHigh     0x85    ; High byte of the address of the variables
    // .define $VarCursor    0       ; Cursor position: 40 * row + column
    // .define $VarColor     1       ; Text color (high byte), XOR 0x0700: 0 = white on black
    // .define $VarSeed      2       ; State of the random number generator
    // .define $VarFrames    3       ; Number of vertical blankings
    // .define $VarInterrupt 4       ; Function that is called in the vertical blanking
    // .define $VarSerial    5       ; Function that is called at a serial port interrupt
    // 
    // .define $FrameHigh    0x80    ; High byte of the frame buffer address
    // .define $Cells        1200    ; 40 * 30 characters
    // .define $Vector       0x0FFF  ; Interrupt vector
    // .define $CounterLo    0xFFFE  ; Clock counter (25 MHz), low word
    // .define $Sound        0xFFFF  ; Frequency = 25000000 / (64 * value), 0 = off
    // .define $SerialNot    0x1F    ; NOT of the low byte of 0xFFE0: the serial port (DATA, +1 STATUS, +2 CONTROL, +3 INT_CAUSE)
    // 
    // .org 0xF000
    // 
    // ; JSR reaches 512 words, so the routines are in an order where the common routines
    // ; (runtime, memory, screen addresses) are close to all of their callers.
    // 
    // ;------------------------------------------------------------------------------
    // ; Sound and time
    // ;------------------------------------------------------------------------------
    // 
    // ; void PlayNote(unsigned note)
    // ; Plays a note until the next call: 60 is middle C (C4), + 1 per semitone like in MIDI.
    // ; Notes below 12 switch the sound off.
rom[0] = 16'h660c; // PlayNote:     LDLZ R1 12
rom[1] = 16'hbded; //               JSR RtUDiv
rom[2] = 16'h6c11; //               LDL R3 PlayNote_Table.L
rom[3] = 16'h6df0; //               LDH R3 PlayNote_Table.H
rom[4] = 16'h0d90; //               ADD R3 R3 R1
rom[5] = 16'hc580; //               LD R1 [R3]
rom[6] = 16'h0008; //               LD R0 R0
rom[7] = 16'h4b84; //               BZS PlayNote_Off
rom[8] = 16'h000f; // PlayNote_Octave: DEC R0 R0
rom[9] = 16'h4b83; //               BZS PlayNote_Store
rom[10] = 16'h2480; //               SHR R1 R1
rom[11] = 16'h9ffc; //               JMP PlayNote_Octave
rom[12] = 16'h6600; // PlayNote_Off: LDLZ R1 0
rom[13] = 16'h6e00; // PlayNote_Store: LDLZ R3 0
rom[14] = 16'h0d87; //               NOT R3 R3
rom[15] = 16'he580; //               STO R1 [R3]
rom[16] = 16'h3c0d; //               RET
    // ; Sound values of the notes C0 .. B0
rom[17] = 16'h5d51; // .data 23889, 22548, 21283, 20088, 18961, 17897
rom[18] = 16'h5814;
rom[19] = 16'h5323;
rom[20] = 16'h4e78;
rom[21] = 16'h4a11;
rom[22] = 16'h45e9;
rom[23] = 16'h41fc; // .data 16892, 15944, 15049, 14205, 13407, 12655
rom[24] = 16'h3e48;
rom[25] = 16'h3ac9;
rom[26] = 16'h377d;
rom[27] = 16'h345f;
rom[28] = 16'h316f;
    // 
    // ; Waits until the clock counter is at least R1 higher than now. Changes R0 and R3.
rom[29] = 16'h6cfe; // Sleep_Clocks: LDL R3 $CounterLo.L
rom[30] = 16'h6dff; //               LDH R3 $CounterLo.H
rom[31] = 16'hc180; //               LD R0 [R3]
rom[32] = 16'h6cfe; // Sleep_Wait:   LDL R3 $CounterLo.L
rom[33] = 16'h6dff; //               LDH R3 $CounterLo.H
rom[34] = 16'hcd80; //               LD R3 [R3]
rom[35] = 16'h0d82; //               SUB R3 R3 R0
rom[36] = 16'h019e; //               CMP R3 R1
rom[37] = 16'h43fa; //               BCS Sleep_Wait
rom[38] = 16'h3c0d; //               RET
    // 
    // ; void SleepMs(unsigned milliseconds)
rom[39] = 16'h280c; // SleepMs:      PSH R2
rom[40] = 16'h0808; //               LD R2 R0
rom[41] = 16'h4b85; //               BZS SleepMs_Done
rom[42] = 16'h64a8; // SleepMs_Loop: LDL R1 25000.L
rom[43] = 16'h6561; //               LDH R1 25000.H
rom[44] = 16'hbff0; //               JSR Sleep_Clocks
rom[45] = 16'h090f; //               DEC R2 R2
rom[46] = 16'h4ffb; //               BZC SleepMs_Loop
rom[47] = 16'h280d; // SleepMs_Done: POP R2
rom[48] = 16'h3c0d; //               RET
    // 
    // ; void SleepUs(unsigned microseconds)
rom[49] = 16'h280c; // SleepUs:      PSH R2
rom[50] = 16'h300c; //               PSH R4
rom[51] = 16'h0808; //               LD R2 R0
rom[52] = 16'h70d0; //               LDL R4 2000.L
rom[53] = 16'h7107; //               LDH R4 2000.H
rom[54] = 16'h014e; // SleepUs_Long: CMP R2 R4
rom[55] = 16'h4385; //               BCS SleepUs_Short
rom[56] = 16'h0942; //               SUB R2 R2 R4
rom[57] = 16'h6450; //               LDL R1 50000.L
rom[58] = 16'h65c3; //               LDH R1 50000.H
rom[59] = 16'hbfe1; //               JSR Sleep_Clocks
rom[60] = 16'h9ff9; //               JMP SleepUs_Long
rom[61] = 16'h0108; // SleepUs_Short: LD R0 R2
rom[62] = 16'h6619; //               LDLZ R1 25
rom[63] = 16'hbda6; //               JSR RtMul
rom[64] = 16'h0408; //               LD R1 R0
rom[65] = 16'hbfdb; //               JSR Sleep_Clocks
rom[66] = 16'h300d; //               POP R4
rom[67] = 16'h280d; //               POP R2
rom[68] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Random numbers
    // ;------------------------------------------------------------------------------
    // 
    // ; unsigned Random(void)
    // ; Returns a number 0 .. 65535. Every number comes once in 65536 calls.
rom[69] = 16'h6f85; // Random:       LDHZ R3 $VarsHigh
rom[70] = 16'hc182; //               LD R0 [R3 +$VarSeed]
rom[71] = 16'h6455; //               LDL R1 25173.L
rom[72] = 16'h6562; //               LDH R1 25173.H
rom[73] = 16'hbd9c; //               JSR RtMul
rom[74] = 16'h6419; //               LDL R1 13849.L
rom[75] = 16'h6536; //               LDH R1 13849.H
rom[76] = 16'h0010; //               ADD R0 R0 R1
rom[77] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[78] = 16'he182; //               STO R0 [R3 +$VarSeed]
rom[79] = 16'h000b; //               SWP R0 R0
rom[80] = 16'h3c0d; //               RET
    // 
    // ; void SetSeed(unsigned seed)
rom[81] = 16'h6f85; // SetSeed:      LDHZ R3 $VarsHigh
rom[82] = 16'he182; //               STO R0 [R3 +$VarSeed]
rom[83] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Interrupts: the vertical blanking (59.5 times per second) and the serial port
    // ;------------------------------------------------------------------------------
    // 
    // ; INT_CAUSE tells why: bit 0 a vertical blanking (counts the frames and calls the
    // ; function of SetInterrupt), bits 1 and 2 the serial port (calls the function of
    // ; SetSerialInterrupt)
rom[84] = 16'h200e; // Interrupt_Handler: PSF
rom[85] = 16'h200c; //               PSH R0
rom[86] = 16'h240c; //               PSH R1
rom[87] = 16'h2c0c; //               PSH R3
rom[88] = 16'h6e1f; //               LDLZ R3 $SerialNot
rom[89] = 16'h0d87; //               NOT R3 R3
rom[90] = 16'hc183; //               LD R0 [R3 +3]               ; INT_CAUSE; reading it clears bit 0
rom[91] = 16'h200c; //               PSH R0
rom[92] = 16'h2000; //               SHR R0 R0
rom[93] = 16'h4787; //               BCC Interrupt_Serial
rom[94] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[95] = 16'hc183; //               LD R0 [R3 +$VarFrames]
rom[96] = 16'h000c; //               INC R0 R0
rom[97] = 16'he183; //               STO R0 [R3 +$VarFrames]
rom[98] = 16'hcd84; //               LD R3 [R3 +$VarInterrupt]
rom[99] = 16'h4b81; //               BZS Interrupt_Serial
rom[100] = 16'hac00; //               JSR [R3]
rom[101] = 16'h200d; // Interrupt_Serial: POP R0
rom[102] = 16'h6606; //               LDLZ R1 6
rom[103] = 16'h0014; //               AND R0 R0 R1
rom[104] = 16'h4b84; //               BZS Interrupt_Done
rom[105] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[106] = 16'hcd85; //               LD R3 [R3 +$VarSerial]
rom[107] = 16'h4b81; //               BZS Interrupt_Done
rom[108] = 16'hac00; //               JSR [R3]
rom[109] = 16'h2c0d; // Interrupt_Done: POP R3
rom[110] = 16'h240d; //               POP R1
rom[111] = 16'h200d; //               POP R0
rom[112] = 16'h200f; //               POF
rom[113] = 16'h3c1d; //               RTI
    // 
    // ; void SetInterrupt(void (*function)(void))
    // ; Calls function in every vertical blanking, and enables interrupts. It is an ordinary
    // ; C function, or an assembler routine that keeps R2, R4, and R5. 0: no function.
rom[114] = 16'h6f85; // SetInterrupt: LDHZ R3 $VarsHigh
rom[115] = 16'he184; //               STO R0 [R3 +$VarInterrupt]
    // ; Installs the library's interrupt handler and enables interrupts
rom[116] = 16'h6054; // Interrupt_Install: LDL R0 Interrupt_Handler.L
rom[117] = 16'h61f0; //               LDH R0 Interrupt_Handler.H
rom[118] = 16'h6cff; //               LDL R3 $Vector.L
rom[119] = 16'h6d0f; //               LDH R3 $Vector.H
rom[120] = 16'he180; //               STO R0 [R3]
rom[121] = 16'h200b; //               SEI
rom[122] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Serial port interrupt (the other serial port routines are at the end of the ROM)
    // ;------------------------------------------------------------------------------
    // 
    // ; void SetSerialInterrupt(void (*function)(void), unsigned events)
    // ; Calls function while an event of events is pending: SERIAL_RX_INT (0x10, a byte can
    // ; be read), SERIAL_TX_INT (0x20, a byte can be written), or both; 0 = none. The function
    // ; must read the byte or write one (or switch the event off), else it is called again at
    // ; once. Keeps the bit rate, and enables interrupts. Like SetInterrupt, the function is
    // ; an ordinary C function, or an assembler routine that keeps R2, R4, and R5.
rom[123] = 16'h6f85; // SetSerialInterrupt: LDHZ R3 $VarsHigh
rom[124] = 16'he185; //               STO R0 [R3 +$VarSerial]
rom[125] = 16'h6e30; //               LDLZ R3 0x30
rom[126] = 16'h04b4; //               AND R1 R1 R3
rom[127] = 16'h6e1f; //               LDLZ R3 $SerialNot
rom[128] = 16'h0d87; //               NOT R3 R3
rom[129] = 16'hc182; //               LD R0 [R3 +2]               ; CONTROL: keep the bit rate
rom[130] = 16'h6e0f; //               LDLZ R3 0x0F
rom[131] = 16'h0034; //               AND R0 R0 R3
rom[132] = 16'h0015; //               OR R0 R0 R1
rom[133] = 16'h6e1f; //               LDLZ R3 $SerialNot
rom[134] = 16'h0d87; //               NOT R3 R3
rom[135] = 16'he182; //               STO R0 [R3 +2]
rom[136] = 16'h9feb; //               JMP Interrupt_Install
    // 
    // ; void WaitFrame(void)
    // ; Waits for the next vertical blanking. Enables interrupts, and starts the library's
    // ; interrupt handler if it is not active yet.
rom[137] = 16'h6cff; // WaitFrame:    LDL R3 $Vector.L
rom[138] = 16'h6d0f; //               LDH R3 $Vector.H
rom[139] = 16'hc180; //               LD R0 [R3]
rom[140] = 16'h6454; //               LDL R1 Interrupt_Handler.L
rom[141] = 16'h65f0; //               LDH R1 Interrupt_Handler.H
rom[142] = 16'h001e; //               CMP R0 R1
rom[143] = 16'h4b82; //               BZS WaitFrame_Active
rom[144] = 16'h6200; //               LDLZ R0 0
rom[145] = 16'hbfe0; //               JSR SetInterrupt
rom[146] = 16'h200b; // WaitFrame_Active: SEI
rom[147] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[148] = 16'hc183; //               LD R0 [R3 +$VarFrames]
rom[149] = 16'hc583; // WaitFrame_Loop: LD R1 [R3 +$VarFrames]
rom[150] = 16'h001e; //               CMP R0 R1
rom[151] = 16'h4bfd; //               BZS WaitFrame_Loop
rom[152] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Graphics with four-pixel blocks: 80 x 60 pixels, colors 0 .. 7
    // ;------------------------------------------------------------------------------
    // 
    // ; void FillPixels(unsigned color)
rom[153] = 16'h6449; // FillPixels:   LDL R1 0x0249.L
rom[154] = 16'h6502; //               LDH R1 0x0249.H
rom[155] = 16'hbd4a; //               JSR RtMul
rom[156] = 16'h6780; //               LDHZ R1 0x80
rom[157] = 16'h0415; //               OR R1 R0 R1
rom[158] = 16'h6380; //               LDHZ R0 $FrameHigh
rom[159] = 16'h6cb0; //               LDL R3 $Cells.L
rom[160] = 16'h6d04; //               LDH R3 $Cells.H
rom[161] = 16'h9dde; //               JMP MemFill_Core
    // 
    // ; C = 1 if pixel R0, R1 is not on the screen. Otherwise R3 = address of its block
    // ; and R1 = its number in the block. Changes R0.
rom[162] = 16'h6e50; // Pixel_Find:   LDLZ R3 80
rom[163] = 16'h003e; //               CMP R0 R3
rom[164] = 16'h478e; //               BCC Pixel_Off
rom[165] = 16'h6e3c; //               LDLZ R3 60
rom[166] = 16'h00be; //               CMP R1 R3
rom[167] = 16'h478b; //               BCC Pixel_Off
rom[168] = 16'h6e00; //               LDLZ R3 0
rom[169] = 16'h2480; //               SHR R1 R1
rom[170] = 16'h2d84; //               ROL R3 R3
rom[171] = 16'h2000; //               SHR R0 R0
rom[172] = 16'h2d84; //               ROL R3 R3
rom[173] = 16'h2c0c; //               PSH R3
rom[174] = 16'hbd30; //               JSR Cell_Address
rom[175] = 16'h0c08; //               LD R3 R0
rom[176] = 16'h240d; //               POP R1
rom[177] = 16'h2008; //               CLC
rom[178] = 16'h3c0d; //               RET
rom[179] = 16'h2009; // Pixel_Off:    SEC
rom[180] = 16'h3c0d; //               RET
    // 
    // ; void DrawPixel(unsigned x, unsigned y, unsigned color)
    // ; Pixels that are not on the screen are ignored. A character becomes a black block first.
rom[181] = 16'hbfec; // DrawPixel:    JSR Pixel_Find
rom[182] = 16'h4391; //               BCS DrawPixel_Off
rom[183] = 16'h280c; //               PSH R2
rom[184] = 16'hcb03; //               LD R2 [SP +3]
rom[185] = 16'h6207; //               LDLZ R0 7
rom[186] = 16'h0904; //               AND R2 R2 R0
rom[187] = 16'h048f; // DrawPixel_Shift: DEC R1 R1
rom[188] = 16'h5383; //               BNS DrawPixel_Store
rom[189] = 16'h2021; //               SHL R0 R0 3
rom[190] = 16'h2921; //               SHL R2 R2 3
rom[191] = 16'h9ffb; //               JMP DrawPixel_Shift
rom[192] = 16'h0007; // DrawPixel_Store: NOT R0 R0
rom[193] = 16'hc580; //               LD R1 [R3]
rom[194] = 16'h5381; //               BNS DrawPixel_Block
rom[195] = 16'h6780; //               LDHZ R1 0x80
rom[196] = 16'h0484; // DrawPixel_Block: AND R1 R1 R0
rom[197] = 16'h04a5; //               OR R1 R1 R2
rom[198] = 16'he580; //               STO R1 [R3]
rom[199] = 16'h280d; //               POP R2
rom[200] = 16'h3c0d; // DrawPixel_Off: RET
    // 
    // ; int GetPixel(unsigned x, unsigned y)
    // ; Returns the color of a pixel, or -1 if it is not on the screen. The pixels of a
    // ; cell with a character have no meaning.
rom[201] = 16'hbfd8; // GetPixel:     JSR Pixel_Find
rom[202] = 16'h4388; //               BCS GetPixel_Off
rom[203] = 16'hc180; //               LD R0 [R3]
rom[204] = 16'h048f; // GetPixel_Shift: DEC R1 R1
rom[205] = 16'h5382; //               BNS GetPixel_Done
rom[206] = 16'h2020; //               SHR R0 R0 3
rom[207] = 16'h9ffc; //               JMP GetPixel_Shift
rom[208] = 16'h6e07; // GetPixel_Done: LDLZ R3 7
rom[209] = 16'h0034; //               AND R0 R0 R3
rom[210] = 16'h3c0d; //               RET
rom[211] = 16'h6200; // GetPixel_Off: LDLZ R0 0
rom[212] = 16'h0007; //               NOT R0 R0
rom[213] = 16'h3c0d; //               RET
    // 
    // ; R1 = abs(R1), R3 = sign of R1 (1 or -1)
rom[214] = 16'h6e01; // Line_Abs:     LDLZ R3 1
rom[215] = 16'h0488; //               LD R1 R1
rom[216] = 16'h5784; //               BNC Line_AbsDone
rom[217] = 16'h0487; //               NOT R1 R1
rom[218] = 16'h048c; //               INC R1 R1
rom[219] = 16'h0d87; //               NOT R3 R3
rom[220] = 16'h0d8c; //               INC R3 R3
rom[221] = 16'h3c0d; // Line_AbsDone: RET
    // 
    // ; void DrawLine(int x0, int y0, int x1, int y1, unsigned color)
    // ; The part of the line that is on the screen is drawn. Coordinates can be negative.
rom[222] = 16'h280c; // DrawLine:     PSH R2
rom[223] = 16'h300c; //               PSH R4
rom[224] = 16'h340c; //               PSH R5
rom[225] = 16'h1008; //               LD R4 R0
rom[226] = 16'h1488; //               LD R5 R1
rom[227] = 16'hc705; //               LD R1 [SP +5]
rom[228] = 16'h04c2; //               SUB R1 R1 R4
rom[229] = 16'hbff0; //               JSR Line_Abs
rom[230] = 16'h2c0c; //               PSH R3
rom[231] = 16'h240c; //               PSH R1
rom[232] = 16'hc708; //               LD R1 [SP +8]
rom[233] = 16'h04d2; //               SUB R1 R1 R5
rom[234] = 16'hbfeb; //               JSR Line_Abs
rom[235] = 16'h2c0c; //               PSH R3
rom[236] = 16'h0487; //               NOT R1 R1
rom[237] = 16'h048c; //               INC R1 R1
rom[238] = 16'h240c; //               PSH R1
    //               ; Frame: [1] -dy, [2] sy, [3] dx, [4] sx, [5] R5, [6] R4, [7] R2, [8] return,
    //               ;        [9] x1, [10] y1, [11] color. R4, R5 = x, y. R2 = error.
rom[239] = 16'hc303; //               LD R0 [SP +3]
rom[240] = 16'h0810; //               ADD R2 R0 R1
rom[241] = 16'hc30b; // DrawLine_Loop: LD R0 [SP +11]
rom[242] = 16'h200c; //               PSH R0
rom[243] = 16'h0208; //               LD R0 R4
rom[244] = 16'h0688; //               LD R1 R5
rom[245] = 16'hbfbf; //               JSR DrawPixel
rom[246] = 16'h1b0c; //               INC SP SP
rom[247] = 16'hc309; //               LD R0 [SP +9]
rom[248] = 16'h004e; //               CMP R0 R4
rom[249] = 16'h4f83; //               BZC DrawLine_Step
rom[250] = 16'hc30a; //               LD R0 [SP +10]
rom[251] = 16'h005e; //               CMP R0 R5
rom[252] = 16'h4b8e; //               BZS DrawLine_End
rom[253] = 16'h2d01; // DrawLine_Step: SHL R3 R2
rom[254] = 16'hc701; //               LD R1 [SP +1]
rom[255] = 16'h0192; //               SUB R0 R3 R1
rom[256] = 16'h5383; //               BNS DrawLine_NotX
rom[257] = 16'h0910; //               ADD R2 R2 R1
rom[258] = 16'hc304; //               LD R0 [SP +4]
rom[259] = 16'h1200; //               ADD R4 R4 R0
rom[260] = 16'hc703; // DrawLine_NotX: LD R1 [SP +3]
rom[261] = 16'h00b2; //               SUB R0 R1 R3
rom[262] = 16'h53ea; //               BNS DrawLine_Loop
rom[263] = 16'h0910; //               ADD R2 R2 R1
rom[264] = 16'hc302; //               LD R0 [SP +2]
rom[265] = 16'h1680; //               ADD R5 R5 R0
rom[266] = 16'h9fe6; //               JMP DrawLine_Loop
rom[267] = 16'h6e04; // DrawLine_End: LDLZ R3 4
rom[268] = 16'h1b30; //               ADD SP SP R3
rom[269] = 16'h340d; //               POP R5
rom[270] = 16'h300d; //               POP R4
rom[271] = 16'h280d; //               POP R2
rom[272] = 16'h3c0d; //               RET
    // 
    // ; After PSH R2, R4, R5 in DrawRect and FillRect, with R0 = x, R1 = y:
    // ; R4, R5 = x, y and R2 = last column, and h becomes the last row.
    // ; C = 1 if the rectangle is empty.
rom[273] = 16'h1008; // Rect_Begin:   LD R4 R0
rom[274] = 16'h1488; //               LD R5 R1
rom[275] = 16'hcb06; //               LD R2 [SP +6]
rom[276] = 16'h4b89; //               BZS Rect_Empty
rom[277] = 16'h0940; //               ADD R2 R2 R4
rom[278] = 16'h090f; //               DEC R2 R2
rom[279] = 16'hcf07; //               LD R3 [SP +7]
rom[280] = 16'h4b85; //               BZS Rect_Empty
rom[281] = 16'h0dd0; //               ADD R3 R3 R5
rom[282] = 16'h0d8f; //               DEC R3 R3
rom[283] = 16'hef07; //               STO R3 [SP +7]
rom[284] = 16'h2008; //               CLC
rom[285] = 16'h3c0d; //               RET
rom[286] = 16'h2009; // Rect_Empty:   SEC
rom[287] = 16'h3c0d; //               RET
    // 
    // ; Line from R0, R1 to R2, R3 in the color of the rectangle
rom[288] = 16'h200c; // Rect_Line:    PSH R0
rom[289] = 16'hc309; //               LD R0 [SP +9]
rom[290] = 16'h200c; //               PSH R0
rom[291] = 16'h2c0c; //               PSH R3
rom[292] = 16'h280c; //               PSH R2
rom[293] = 16'hc304; //               LD R0 [SP +4]
rom[294] = 16'hbfb7; //               JSR DrawLine
rom[295] = 16'h6e04; //               LDLZ R3 4
rom[296] = 16'h1b30; //               ADD SP SP R3
rom[297] = 16'h3c0d; //               RET
    // 
    // ; void DrawRect(int x, int y, unsigned width, unsigned height, unsigned color)
rom[298] = 16'h280c; // DrawRect:     PSH R2
rom[299] = 16'h300c; //               PSH R4
rom[300] = 16'h340c; //               PSH R5
rom[301] = 16'hbfe3; //               JSR Rect_Begin
rom[302] = 16'h4391; //               BCS Rect_End
rom[303] = 16'h0208; //               LD R0 R4
rom[304] = 16'h0688; //               LD R1 R5
rom[305] = 16'h0e88; //               LD R3 R5
rom[306] = 16'hbfed; //               JSR Rect_Line
rom[307] = 16'hcf06; //               LD R3 [SP +6]
rom[308] = 16'h0208; //               LD R0 R4
rom[309] = 16'h0588; //               LD R1 R3
rom[310] = 16'hbfe9; //               JSR Rect_Line
rom[311] = 16'hcf06; //               LD R3 [SP +6]
rom[312] = 16'h0108; //               LD R0 R2
rom[313] = 16'h0688; //               LD R1 R5
rom[314] = 16'hbfe5; //               JSR Rect_Line
rom[315] = 16'hcf06; //               LD R3 [SP +6]
rom[316] = 16'h0208; //               LD R0 R4
rom[317] = 16'h0688; //               LD R1 R5
rom[318] = 16'h0a08; //               LD R2 R4
rom[319] = 16'hbfe0; //               JSR Rect_Line
rom[320] = 16'h340d; // Rect_End:     POP R5
rom[321] = 16'h300d; //               POP R4
rom[322] = 16'h280d; //               POP R2
rom[323] = 16'h3c0d; //               RET
    // 
    // ; void FillRect(int x, int y, unsigned width, unsigned height, unsigned color)
rom[324] = 16'h280c; // FillRect:     PSH R2
rom[325] = 16'h300c; //               PSH R4
rom[326] = 16'h340c; //               PSH R5
rom[327] = 16'hbfc9; //               JSR Rect_Begin
rom[328] = 16'h43f7; //               BCS Rect_End
rom[329] = 16'h0208; // FillRect_Row: LD R0 R4
rom[330] = 16'h0688; //               LD R1 R5
rom[331] = 16'h0e88; //               LD R3 R5
rom[332] = 16'hbfd3; //               JSR Rect_Line
rom[333] = 16'hc306; //               LD R0 [SP +6]
rom[334] = 16'h028e; //               CMP R5 R0
rom[335] = 16'h4bf0; //               BZS Rect_End
rom[336] = 16'h168c; //               INC R5 R5
rom[337] = 16'h9ff7; //               JMP FillRect_Row
    // 
    // ; void DrawEllipse(int x, int y, unsigned rx, unsigned ry, unsigned color)
    // ; Radii up to 255. Two arcs: one with steps in x, one with steps in y, so that the
    // ; steep and the flat parts have no gaps.
rom[338] = 16'h240c; // DrawEllipse:  PSH R1
rom[339] = 16'h200c; //               PSH R0
rom[340] = 16'h280c; //               PSH R2
rom[341] = 16'h300c; //               PSH R4
rom[342] = 16'h340c; //               PSH R5
    //               ; Frame: [1] R5, [2] R4, [3] R2, [4] x, [5] y, [6] return, [7] rx, [8] ry, [9] color
rom[343] = 16'hd307; //               LD R4 [SP +7]
rom[344] = 16'hd708; //               LD R5 [SP +8]
rom[345] = 16'h6200; //               LDLZ R0 0
rom[346] = 16'hbc09; //               JSR Ellipse_Arc
rom[347] = 16'hd308; //               LD R4 [SP +8]
rom[348] = 16'hd707; //               LD R5 [SP +7]
rom[349] = 16'h6201; //               LDLZ R0 1
rom[350] = 16'hbc05; //               JSR Ellipse_Arc
rom[351] = 16'h340d; //               POP R5
rom[352] = 16'h300d; //               POP R4
rom[353] = 16'h280d; //               POP R2
rom[354] = 16'h1b1c; //               INC SP SP 2
rom[355] = 16'h3c0d; //               RET
    // 
    // ; For i = 0 .. R4: j = sqrt(R5 * R5 - R5 * R5 * i * i / (R4 * R4)), and a point in all four
    // ; quadrants at distance (i, j), or (j, i) if R0 != 0
rom[356] = 16'h200c; // Ellipse_Arc:  PSH R0
rom[357] = 16'h6a00; //               LDLZ R2 0
rom[358] = 16'h0288; // Ellipse_Loop: LD R0 R5
rom[359] = 16'h0908; //               LD R2 R2
rom[360] = 16'h4b90; //               BZS Ellipse_Plot
rom[361] = 16'h0688; //               LD R1 R5
rom[362] = 16'hbc7b; //               JSR RtMul
rom[363] = 16'h200c; //               PSH R0
rom[364] = 16'h0208; //               LD R0 R4
rom[365] = 16'h0608; //               LD R1 R4
rom[366] = 16'hbc77; //               JSR RtMul
rom[367] = 16'h200c; //               PSH R0
rom[368] = 16'h0108; //               LD R0 R2
rom[369] = 16'h0508; //               LD R1 R2
rom[370] = 16'hbc73; //               JSR RtMul
rom[371] = 16'hc702; //               LD R1 [SP +2]
rom[372] = 16'hbcdf; //               JSR MulDiv
rom[373] = 16'h1b0c; //               INC SP SP
rom[374] = 16'h240d; //               POP R1
rom[375] = 16'h0082; //               SUB R0 R1 R0
rom[376] = 16'hbcdf; //               JSR Sqrt
rom[377] = 16'hcf01; // Ellipse_Plot: LD R3 [SP +1]
rom[378] = 16'h4f83; //               BZC Ellipse_Swap
rom[379] = 16'h200c; //               PSH R0
rom[380] = 16'h280c; //               PSH R2
rom[381] = 16'h9c02; //               JMP Ellipse_Rows
rom[382] = 16'h280c; // Ellipse_Swap: PSH R2
rom[383] = 16'h200c; //               PSH R0
    //               ; Frame: [1] dx, [2] dy, [3] swap, [4] return, [5] R5, [6] R4, [7] R2,
    //               ;        [8] x, [9] y, [10] return, [11] rx, [12] ry, [13] color
rom[384] = 16'hc702; // Ellipse_Rows: LD R1 [SP +2]
rom[385] = 16'hbc0a; //               JSR Ellipse_Row
rom[386] = 16'hc702; //               LD R1 [SP +2]
rom[387] = 16'h0487; //               NOT R1 R1
rom[388] = 16'h048c; //               INC R1 R1
rom[389] = 16'hbc06; //               JSR Ellipse_Row
rom[390] = 16'h1b1c; //               INC SP SP 2
rom[391] = 16'h090c; //               INC R2 R2
rom[392] = 16'h022e; //               CMP R4 R2
rom[393] = 16'h47dc; //               BCC Ellipse_Loop
rom[394] = 16'h1b0c; //               INC SP SP
rom[395] = 16'h3c0d; //               RET
    // 
    // ; Two points at distance dx from the center, in the row at distance R1 from the center
rom[396] = 16'hcf0a; // Ellipse_Row:  LD R3 [SP +10]
rom[397] = 16'h04b0; //               ADD R1 R1 R3
rom[398] = 16'h240c; //               PSH R1
    //               ; Frame: [1] row, [2] return, [3] dx, ... [10] x, ... [15] color
rom[399] = 16'hc30a; //               LD R0 [SP +10]
rom[400] = 16'hcf03; //               LD R3 [SP +3]
rom[401] = 16'h0030; //               ADD R0 R0 R3
rom[402] = 16'hcf0f; //               LD R3 [SP +15]
rom[403] = 16'h2c0c; //               PSH R3
rom[404] = 16'hbf20; //               JSR DrawPixel
rom[405] = 16'h1b0c; //               INC SP SP
rom[406] = 16'hc701; //               LD R1 [SP +1]
rom[407] = 16'hc30a; //               LD R0 [SP +10]
rom[408] = 16'hcf03; //               LD R3 [SP +3]
rom[409] = 16'h0032; //               SUB R0 R0 R3
rom[410] = 16'hcf0f; //               LD R3 [SP +15]
rom[411] = 16'h2c0c; //               PSH R3
rom[412] = 16'hbf18; //               JSR DrawPixel
rom[413] = 16'h1b1c; //               INC SP SP 2
rom[414] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Sprites
    // ;------------------------------------------------------------------------------
    // 
    // ; R3 = address of the X register of sprite R0. Changes R0.
rom[415] = 16'h2001; // Sprite_Reg:   SHL R0 R0
rom[416] = 16'h6ee8; //               LDLZ R3 0xE8
rom[417] = 16'h6dff; //               LDH R3 0xFF
rom[418] = 16'h0d80; //               ADD R3 R3 R0
rom[419] = 16'h3c0d; //               RET
    // 
    // ; void SetSpriteImage(unsigned sprite, unsigned *image)
    // ; Copies the 64 words of a sprite image.
rom[420] = 16'h6f86; // SetSpriteImage: LDHZ R3 0x86
rom[421] = 16'h2051; //               SHL R0 R0 6
rom[422] = 16'h0030; //               ADD R0 R0 R3
rom[423] = 16'h6e40; //               LDLZ R3 64
rom[424] = 16'h9cc1; //               JMP Copy_Words
    // 
    // ; void PlaceSprite(unsigned sprite, int x, int y)
    // ; Moves a sprite. It stays shown or hidden. x and y are in points (320 x 240).
rom[425] = 16'hbff5; // PlaceSprite:  JSR Sprite_Reg
rom[426] = 16'h2481; //               SHL R1 R1
rom[427] = 16'hc180; //               LD R0 [R3]
rom[428] = 16'h2001; //               SHL R0 R0
rom[429] = 16'h2483; //               ROR R1 R1
rom[430] = 16'he580; //               STO R1 [R3]
rom[431] = 16'hc302; //               LD R0 [SP +2]
rom[432] = 16'he181; //               STO R0 [R3 +1]
rom[433] = 16'h3c0d; //               RET
    // 
    // ; void ShowSprite(unsigned sprite)
rom[434] = 16'hbfec; // ShowSprite:   JSR Sprite_Reg
rom[435] = 16'h6780; //               LDHZ R1 0x80
rom[436] = 16'hc180; //               LD R0 [R3]
rom[437] = 16'h0015; //               OR R0 R0 R1
rom[438] = 16'he180; //               STO R0 [R3]
rom[439] = 16'h3c0d; //               RET
    // 
    // ; void HideSprite(unsigned sprite)
rom[440] = 16'hbfe6; // HideSprite:   JSR Sprite_Reg
rom[441] = 16'h6780; //               LDHZ R1 0x80
rom[442] = 16'h0487; //               NOT R1 R1
rom[443] = 16'hc180; //               LD R0 [R3]
rom[444] = 16'h0014; //               AND R0 R0 R1
rom[445] = 16'he180; //               STO R0 [R3]
rom[446] = 16'h3c0d; //               RET
    // 
    // ; int SpriteCollide(unsigned a, unsigned b)
    // ; Returns 1 if both sprites are shown and their 16 x 16 squares overlap, otherwise 0.
rom[447] = 16'h280c; // SpriteCollide: PSH R2
rom[448] = 16'hbfde; //               JSR Sprite_Reg
rom[449] = 16'h0988; //               LD R2 R3
rom[450] = 16'h0088; //               LD R0 R1
rom[451] = 16'hbfdb; //               JSR Sprite_Reg
rom[452] = 16'hc100; //               LD R0 [R2]
rom[453] = 16'h5790; //               BNC SpriteCollide_No
rom[454] = 16'hc580; //               LD R1 [R3]
rom[455] = 16'h578e; //               BNC SpriteCollide_No
rom[456] = 16'h0012; //               SUB R0 R0 R1
rom[457] = 16'h6704; //               LDHZ R1 0x04
rom[458] = 16'hbc0e; //               JSR Sprite_Near
rom[459] = 16'h478a; //               BCC SpriteCollide_No
rom[460] = 16'hc101; //               LD R0 [R2 +1]
rom[461] = 16'hc581; //               LD R1 [R3 +1]
rom[462] = 16'h0012; //               SUB R0 R0 R1
rom[463] = 16'h2001; //               SHL R0 R0
rom[464] = 16'h6708; //               LDHZ R1 0x08
rom[465] = 16'hbc07; //               JSR Sprite_Near
rom[466] = 16'h4783; //               BCC SpriteCollide_No
rom[467] = 16'h6201; //               LDLZ R0 1
rom[468] = 16'h280d; //               POP R2
rom[469] = 16'h3c0d; //               RET
rom[470] = 16'h6200; // SpriteCollide_No: LDLZ R0 0
rom[471] = 16'h280d; //               POP R2
rom[472] = 16'h3c0d; //               RET
    // 
    // ; X has 10 bits and Y has 9 bits. A difference of Y is shifted once more, so the limit in R1
    // ; is 16 shifted by 6 or by 7. C = 1 if the difference, as a signed number, is below the limit.
rom[473] = 16'h2051; // Sprite_Near:  SHL R0 R0 6
rom[474] = 16'h5782; //               BNC Sprite_NearPositive
rom[475] = 16'h0007; //               NOT R0 R0
rom[476] = 16'h000c; //               INC R0 R0
rom[477] = 16'h001e; // Sprite_NearPositive: CMP R0 R1
rom[478] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Screen addresses
    // ;------------------------------------------------------------------------------
    // 
    // ; R0 = 0x8000 + 40 * R1 + R0. Changes R1 and R3.
rom[479] = 16'h6f80; // Cell_Address: LDHZ R3 $FrameHigh
rom[480] = 16'h0030; //               ADD R0 R0 R3
    // ; R0 = 40 * R1 + R0. Changes R1.
rom[481] = 16'h24a1; // Cell_Offset:  SHL R1 R1 3
rom[482] = 16'h0010; //               ADD R0 R0 R1
rom[483] = 16'h2491; //               SHL R1 R1 2
rom[484] = 16'h0010; //               ADD R0 R0 R1
rom[485] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Runtime of the C compiler
    // ;------------------------------------------------------------------------------
    // 
    // ; R0 = R0 * R1
rom[486] = 16'h6e00; // RtMul:        LDLZ R3 0
rom[487] = 16'h2480; // RtMul_Loop:   SHR R1 R1
rom[488] = 16'h4781; //               BCC RtMul_Next
rom[489] = 16'h0d80; //               ADD R3 R3 R0
rom[490] = 16'h2001; // RtMul_Next:   SHL R0 R0
rom[491] = 16'h0488; //               LD R1 R1
rom[492] = 16'h4ffa; //               BZC RtMul_Loop
rom[493] = 16'h0188; //               LD R0 R3
rom[494] = 16'h3c0d; //               RET
    // 
    // ; R0 = R0 / R1, R1 = R0 % R1 (unsigned)
rom[495] = 16'h6e00; // RtUDiv:       LDLZ R3 0
    // ; R0 = R3 R0 / R1, R1 = R3 R0 % R1
rom[496] = 16'h280c; // RtUDiv_Core:  PSH R2
rom[497] = 16'h6a10; //               LDLZ R2 16
rom[498] = 16'h2001; // RtUDiv_Loop:  SHL R0 R0
rom[499] = 16'h2d84; //               ROL R3 R3
rom[500] = 16'h4382; //               BCS RtUDiv_Sub
rom[501] = 16'h019e; //               CMP R3 R1
rom[502] = 16'h4382; //               BCS RtUDiv_Next
rom[503] = 16'h0d92; // RtUDiv_Sub:   SUB R3 R3 R1
rom[504] = 16'h000c; //               INC R0 R0
rom[505] = 16'h090f; // RtUDiv_Next:  DEC R2 R2
rom[506] = 16'h4ff7; //               BZC RtUDiv_Loop
rom[507] = 16'h0588; //               LD R1 R3
rom[508] = 16'h280d; //               POP R2
rom[509] = 16'h3c0d; //               RET
    // 
    // ; R0 = R0 / R1, R1 = R0 % R1 (signed, rounded towards zero)
rom[510] = 16'h200c; // RtDiv:        PSH R0
rom[511] = 16'h0c16; //               XOR R3 R0 R1
rom[512] = 16'h2c0c; //               PSH R3
rom[513] = 16'h0008; //               LD R0 R0
rom[514] = 16'h5782; //               BNC RtDiv_1
rom[515] = 16'h0007; //               NOT R0 R0
rom[516] = 16'h000c; //               INC R0 R0
rom[517] = 16'h0488; // RtDiv_1:      LD R1 R1
rom[518] = 16'h5782; //               BNC RtDiv_2
rom[519] = 16'h0487; //               NOT R1 R1
rom[520] = 16'h048c; //               INC R1 R1
rom[521] = 16'hbfe5; // RtDiv_2:      JSR RtUDiv
rom[522] = 16'h2c0d; //               POP R3
rom[523] = 16'h0d88; //               LD R3 R3
rom[524] = 16'h5782; //               BNC RtDiv_3
rom[525] = 16'h0007; //               NOT R0 R0
rom[526] = 16'h000c; //               INC R0 R0
rom[527] = 16'h2c0d; // RtDiv_3:      POP R3
rom[528] = 16'h0d88; //               LD R3 R3
rom[529] = 16'h5782; //               BNC RtDiv_4
rom[530] = 16'h0487; //               NOT R1 R1
rom[531] = 16'h048c; //               INC R1 R1
rom[532] = 16'h3c0d; // RtDiv_4:      RET
    // 
    // ; R0 = R0 << R1
rom[533] = 16'h6e08; // RtShl:        LDLZ R3 8
rom[534] = 16'h00be; // RtShl_8:      CMP R1 R3
rom[535] = 16'h4383; //               BCS RtShl_1
rom[536] = 16'h2071; //               SHL R0 R0 8
rom[537] = 16'h04b2; //               SUB R1 R1 R3
rom[538] = 16'h9ffb; //               JMP RtShl_8
rom[539] = 16'h0488; // RtShl_1:      LD R1 R1
rom[540] = 16'h4b83; //               BZS RtShl_Done
rom[541] = 16'h2001; // RtShl_Loop:   SHL R0 R0
rom[542] = 16'h048f; //               DEC R1 R1
rom[543] = 16'h4ffd; //               BZC RtShl_Loop
rom[544] = 16'h3c0d; // RtShl_Done:   RET
    // 
    // ; R0 = R0 >> R1 (unsigned)
rom[545] = 16'h6e08; // RtShr:        LDLZ R3 8
rom[546] = 16'h00be; // RtShr_8:      CMP R1 R3
rom[547] = 16'h4383; //               BCS RtShr_1
rom[548] = 16'h2070; //               SHR R0 R0 8
rom[549] = 16'h04b2; //               SUB R1 R1 R3
rom[550] = 16'h9ffb; //               JMP RtShr_8
rom[551] = 16'h0488; // RtShr_1:      LD R1 R1
rom[552] = 16'h4b83; //               BZS RtShr_Done
rom[553] = 16'h2000; // RtShr_Loop:   SHR R0 R0
rom[554] = 16'h048f; //               DEC R1 R1
rom[555] = 16'h4ffd; //               BZC RtShr_Loop
rom[556] = 16'h3c0d; // RtShr_Done:   RET
    // 
    // ; R0 = R0 >> R1 (signed)
rom[557] = 16'h6e08; // RtAShr:       LDLZ R3 8
rom[558] = 16'h00be; // RtAShr_8:     CMP R1 R3
rom[559] = 16'h4383; //               BCS RtAShr_1
rom[560] = 16'h2072; //               ASHR R0 R0 8
rom[561] = 16'h04b2; //               SUB R1 R1 R3
rom[562] = 16'h9ffb; //               JMP RtAShr_8
rom[563] = 16'h0488; // RtAShr_1:     LD R1 R1
rom[564] = 16'h4b83; //               BZS RtAShr_Done
rom[565] = 16'h2002; // RtAShr_Loop:  ASHR R0 R0
rom[566] = 16'h048f; //               DEC R1 R1
rom[567] = 16'h4ffd; //               BZC RtAShr_Loop
rom[568] = 16'h3c0d; // RtAShr_Done:  RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Wide arithmetic (unsigned)
    // ;------------------------------------------------------------------------------
    // 
    // ; unsigned Mul32(unsigned a, unsigned b, unsigned *high)
    // ; Returns the low word of a * b and stores the high word in *high (unless high is 0).
rom[569] = 16'hbc04; // Mul32:        JSR Mul32_Core
rom[570] = 16'hcf02; //               LD R3 [SP +2]
rom[571] = 16'h4b81; //               BZS Mul32_Done
rom[572] = 16'he580; //               STO R1 [R3]
rom[573] = 16'h3c0d; // Mul32_Done:   RET
    // 
    // ; R1 R0 = R0 * R1
rom[574] = 16'h280c; // Mul32_Core:   PSH R2
rom[575] = 16'h6e00; //               LDLZ R3 0
rom[576] = 16'h6a10; //               LDLZ R2 16
rom[577] = 16'h2480; //               SHR R1 R1
rom[578] = 16'h4781; // Mul32_Loop:   BCC Mul32_Shift
rom[579] = 16'h0d80; //               ADD R3 R3 R0
rom[580] = 16'h2d83; // Mul32_Shift:  ROR R3 R3
rom[581] = 16'h2483; //               ROR R1 R1
rom[582] = 16'h090f; //               DEC R2 R2
rom[583] = 16'h4ffa; //               BZC Mul32_Loop
rom[584] = 16'h0088; //               LD R0 R1
rom[585] = 16'h0588; //               LD R1 R3
rom[586] = 16'h280d; //               POP R2
rom[587] = 16'h3c0d; //               RET
    // 
    // ; unsigned Div32(unsigned high, unsigned low, unsigned divisor, unsigned *remainder)
    // ; Returns the low word of (high low) / divisor and stores the remainder in *remainder
    // ; (unless remainder is 0). high must be smaller than divisor if the result is to fit.
rom[588] = 16'h0c08; // Div32:        LD R3 R0
rom[589] = 16'h0088; //               LD R0 R1
rom[590] = 16'hc702; //               LD R1 [SP +2]
rom[591] = 16'hbfa0; //               JSR RtUDiv_Core
rom[592] = 16'hcf03; //               LD R3 [SP +3]
rom[593] = 16'h4b81; //               BZS Div32_Done
rom[594] = 16'he580; //               STO R1 [R3]
rom[595] = 16'h3c0d; // Div32_Done:   RET
    // 
    // ; unsigned MulDiv(unsigned a, unsigned b, unsigned c)
    // ; Returns a * b / c, with a 32-bit intermediate result.
rom[596] = 16'hbfe9; // MulDiv:       JSR Mul32_Core
rom[597] = 16'h0c88; //               LD R3 R1
rom[598] = 16'hc702; //               LD R1 [SP +2]
rom[599] = 16'h9f98; //               JMP RtUDiv_Core
    // 
    // ; unsigned Sqrt(unsigned value)
    // ; Returns the integer square root (rounded down).
rom[600] = 16'h280c; // Sqrt:         PSH R2
rom[601] = 16'h6600; //               LDLZ R1 0
rom[602] = 16'h6f40; //               LDHZ R3 0x40
rom[603] = 16'h08b0; // Sqrt_Loop:    ADD R2 R1 R3
rom[604] = 16'h2480; //               SHR R1 R1
rom[605] = 16'h002e; //               CMP R0 R2
rom[606] = 16'h4382; //               BCS Sqrt_Next
rom[607] = 16'h0022; //               SUB R0 R0 R2
rom[608] = 16'h04b0; //               ADD R1 R1 R3
rom[609] = 16'h2d90; // Sqrt_Next:    SHR R3 R3 2
rom[610] = 16'h4ff8; //               BZC Sqrt_Loop
rom[611] = 16'h0088; //               LD R0 R1
rom[612] = 16'h280d; //               POP R2
rom[613] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Memory and strings. A string has one character per word and ends with 0, like in C.
    // ;------------------------------------------------------------------------------
    // 
    // ; void MemCopy(unsigned *destination, unsigned *source, unsigned count)
    // ; The areas can overlap.
rom[614] = 16'hcf02; // MemCopy:      LD R3 [SP +2]
rom[615] = 16'h4b8a; //               BZS MemCopy_Done
rom[616] = 16'h008e; //               CMP R1 R0
rom[617] = 16'h4389; //               BCS Copy_Back
    // ; R3 > 0 words from R1 up to R0. Afterwards, R0 and R1 are behind the areas.
rom[618] = 16'h280c; // Copy_Words:   PSH R2
rom[619] = 16'hc880; // Copy_Loop:    LD R2 [R1]
rom[620] = 16'he800; //               STO R2 [R0]
rom[621] = 16'h048c; //               INC R1 R1
rom[622] = 16'h000c; //               INC R0 R0
rom[623] = 16'h0d8f; //               DEC R3 R3
rom[624] = 16'h4ffa; //               BZC Copy_Loop
rom[625] = 16'h280d; //               POP R2
rom[626] = 16'h3c0d; // MemCopy_Done: RET
    // ; R3 > 0 words from R1 to R0, the last word first. Afterwards, R0 and R1 are unchanged.
rom[627] = 16'h280c; // Copy_Back:    PSH R2
rom[628] = 16'h0030; //               ADD R0 R0 R3
rom[629] = 16'h04b0; //               ADD R1 R1 R3
rom[630] = 16'h048f; // Copy_BackLoop: DEC R1 R1
rom[631] = 16'h000f; //               DEC R0 R0
rom[632] = 16'hc880; //               LD R2 [R1]
rom[633] = 16'he800; //               STO R2 [R0]
rom[634] = 16'h0d8f; //               DEC R3 R3
rom[635] = 16'h4ffa; //               BZC Copy_BackLoop
rom[636] = 16'h280d; //               POP R2
rom[637] = 16'h3c0d; //               RET
    // 
    // ; void MemFill(unsigned *destination, unsigned value, unsigned count)
rom[638] = 16'hcf02; // MemFill:      LD R3 [SP +2]
rom[639] = 16'h4b84; //               BZS MemFill_Done
    // ; R3 > 0 words at R0 = R1. Afterwards, R0 is behind the area.
rom[640] = 16'he400; // MemFill_Core: STO R1 [R0]
rom[641] = 16'h000c; //               INC R0 R0
rom[642] = 16'h0d8f; //               DEC R3 R3
rom[643] = 16'h4ffc; //               BZC MemFill_Core
rom[644] = 16'h3c0d; // MemFill_Done: RET
    // 
    // ; unsigned StrLen(char *string)
rom[645] = 16'h0408; // StrLen:       LD R1 R0
rom[646] = 16'hcc80; // StrLen_Loop:  LD R3 [R1]
rom[647] = 16'h4b82; //               BZS StrLen_Done
rom[648] = 16'h048c; //               INC R1 R1
rom[649] = 16'h9ffc; //               JMP StrLen_Loop
rom[650] = 16'h0082; // StrLen_Done:  SUB R0 R1 R0
rom[651] = 16'h3c0d; //               RET
    // 
    // ; char *StrCpy(char *destination, char *source)
    // ; Returns the address of the 0 at the end of the copy.
rom[652] = 16'hcc80; // StrCpy:       LD R3 [R1]
rom[653] = 16'hec00; //               STO R3 [R0]
rom[654] = 16'h4b83; //               BZS StrCpy_Done
rom[655] = 16'h000c; //               INC R0 R0
rom[656] = 16'h048c; //               INC R1 R1
rom[657] = 16'h9ffa; //               JMP StrCpy
rom[658] = 16'h3c0d; // StrCpy_Done:  RET
    // 
    // ; int StrCmp(char *a, char *b)
    // ; Returns 0 if the strings are equal, < 0 if a comes first, > 0 if b comes first.
rom[659] = 16'h280c; // StrCmp:       PSH R2
rom[660] = 16'hc800; // StrCmp_Loop:  LD R2 [R0]
rom[661] = 16'hcc80; //               LD R3 [R1]
rom[662] = 16'h013e; //               CMP R2 R3
rom[663] = 16'h4f85; //               BZC StrCmp_Done
rom[664] = 16'h0908; //               LD R2 R2
rom[665] = 16'h4b83; //               BZS StrCmp_Done
rom[666] = 16'h000c; //               INC R0 R0
rom[667] = 16'h048c; //               INC R1 R1
rom[668] = 16'h9ff7; //               JMP StrCmp_Loop
rom[669] = 16'h0132; // StrCmp_Done:  SUB R0 R2 R3
rom[670] = 16'h280d; //               POP R2
rom[671] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Scrolling by one character. value is the character word for the new row or column.
    // ;------------------------------------------------------------------------------
    // 
    // ; void ScrollUp(unsigned value)
rom[672] = 16'h200c; // ScrollUp:     PSH R0
rom[673] = 16'h6380; //               LDHZ R0 $FrameHigh
rom[674] = 16'h6428; //               LDL R1 0x8028.L
rom[675] = 16'h6580; //               LDH R1 0x8028.H
rom[676] = 16'h6c88; //               LDL R3 ($Cells - 40).L
rom[677] = 16'h6d04; //               LDH R3 ($Cells - 40).H
rom[678] = 16'hbfc3; //               JSR Copy_Words
rom[679] = 16'h240d; //               POP R1
rom[680] = 16'h6e28; //               LDLZ R3 40
rom[681] = 16'h9fd6; //               JMP MemFill_Core
    // 
    // ; void ScrollDown(unsigned value)
rom[682] = 16'h200c; // ScrollDown:   PSH R0
rom[683] = 16'h6028; //               LDL R0 0x8028.L
rom[684] = 16'h6180; //               LDH R0 0x8028.H
rom[685] = 16'h6780; //               LDHZ R1 $FrameHigh
rom[686] = 16'h6c88; //               LDL R3 ($Cells - 40).L
rom[687] = 16'h6d04; //               LDH R3 ($Cells - 40).H
rom[688] = 16'hbfc2; //               JSR Copy_Back
rom[689] = 16'h0088; //               LD R0 R1
rom[690] = 16'h240d; //               POP R1
rom[691] = 16'h6e28; //               LDLZ R3 40
rom[692] = 16'h9fcb; //               JMP MemFill_Core
    // 
    // ; void ScrollLeft(unsigned value)
rom[693] = 16'h280c; // ScrollLeft:   PSH R2
rom[694] = 16'h300c; //               PSH R4
rom[695] = 16'h1008; //               LD R4 R0
rom[696] = 16'h6380; //               LDHZ R0 $FrameHigh
rom[697] = 16'h6a1e; //               LDLZ R2 30
rom[698] = 16'h040c; // ScrollLeft_Row: INC R1 R0
rom[699] = 16'h6e27; //               LDLZ R3 39
rom[700] = 16'hbfad; //               JSR Copy_Words
rom[701] = 16'hf000; //               STO R4 [R0]
rom[702] = 16'h000c; //               INC R0 R0
rom[703] = 16'h090f; //               DEC R2 R2
rom[704] = 16'h4ff9; //               BZC ScrollLeft_Row
rom[705] = 16'h9c0d; //               JMP Scroll_End
    // 
    // ; void ScrollRight(unsigned value)
rom[706] = 16'h280c; // ScrollRight:  PSH R2
rom[707] = 16'h300c; //               PSH R4
rom[708] = 16'h1008; //               LD R4 R0
rom[709] = 16'h6780; //               LDHZ R1 $FrameHigh
rom[710] = 16'h6a1e; //               LDLZ R2 30
rom[711] = 16'h008c; // ScrollRight_Row: INC R0 R1
rom[712] = 16'h6e27; //               LDLZ R3 39
rom[713] = 16'hbfa9; //               JSR Copy_Back
rom[714] = 16'hf080; //               STO R4 [R1]
rom[715] = 16'h6e28; //               LDLZ R3 40
rom[716] = 16'h04b0; //               ADD R1 R1 R3
rom[717] = 16'h090f; //               DEC R2 R2
rom[718] = 16'h4ff8; //               BZC ScrollRight_Row
rom[719] = 16'h300d; // Scroll_End:   POP R4
rom[720] = 16'h280d; //               POP R2
rom[721] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Text
    // ;------------------------------------------------------------------------------
    // 
    // ; R1 = character R0 in the text color. Changes R3.
rom[722] = 16'h6f85; // Text_Word:    LDHZ R3 $VarsHigh
rom[723] = 16'hc581; //               LD R1 [R3 +$VarColor]
rom[724] = 16'h6f07; //               LDHZ R3 0x07
rom[725] = 16'h04b6; //               XOR R1 R1 R3
rom[726] = 16'h0409; //               LDL R1 R0
rom[727] = 16'h3c0d; //               RET
    // 
    // ; void ClearScreen(unsigned character, unsigned color)
    // ; Fills the screen, makes color the text color, and moves the cursor to the top left.
    // ; color: bits 15 .. 8 of a character word, e.g. BG_BLUE | FG_WHITE.
rom[728] = 16'h0409; // ClearScreen:  LDL R1 R0
rom[729] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[730] = 16'h6200; //               LDLZ R0 0
rom[731] = 16'he180; //               STO R0 [R3 +$VarCursor]
rom[732] = 16'h6307; //               LDHZ R0 0x07
rom[733] = 16'h0016; //               XOR R0 R0 R1
rom[734] = 16'he181; //               STO R0 [R3 +$VarColor]
rom[735] = 16'h6380; //               LDHZ R0 $FrameHigh
rom[736] = 16'h6cb0; //               LDL R3 $Cells.L
rom[737] = 16'h6d04; //               LDH R3 $Cells.H
rom[738] = 16'h9f9d; //               JMP MemFill_Core
    // 
    // ; void SetTextColor(unsigned color)
    // ; color: bits 15 .. 8 of a character word, e.g. BG_BLUE | FG_WHITE.
rom[739] = 16'h6f07; // SetTextColor: LDHZ R3 0x07
rom[740] = 16'h0036; //               XOR R0 R0 R3
rom[741] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[742] = 16'he181; //               STO R0 [R3 +$VarColor]
rom[743] = 16'h3c0d; //               RET
    // 
    // ; void SetCursor(unsigned column, unsigned row)
rom[744] = 16'hbef8; // SetCursor:    JSR Cell_Offset
rom[745] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[746] = 16'he180; //               STO R0 [R3 +$VarCursor]
rom[747] = 16'h3c0d; //               RET
    // 
    // ; void PutChar(unsigned character)
    // ; Writes a character at the cursor. '\n' moves to the next line. After the last
    // ; position the screen scrolls up.
rom[748] = 16'h280c; // PutChar:      PSH R2
rom[749] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[750] = 16'hc980; //               LD R2 [R3 +$VarCursor]
rom[751] = 16'h660a; //               LDLZ R1 10
rom[752] = 16'h001e; //               CMP R0 R1
rom[753] = 16'h4b86; //               BZS PutChar_Newline
rom[754] = 16'hbfdf; //               JSR Text_Word
rom[755] = 16'h6f80; //               LDHZ R3 $FrameHigh
rom[756] = 16'h0da0; //               ADD R3 R3 R2
rom[757] = 16'he580; //               STO R1 [R3]
rom[758] = 16'h090c; //               INC R2 R2
rom[759] = 16'h9c06; //               JMP PutChar_Check
rom[760] = 16'h6200; // PutChar_Newline: LDLZ R0 0
rom[761] = 16'h6628; //               LDLZ R1 40
rom[762] = 16'h0010; // PutChar_Next: ADD R0 R0 R1
rom[763] = 16'h010e; //               CMP R2 R0
rom[764] = 16'h47fd; //               BCC PutChar_Next
rom[765] = 16'h0808; //               LD R2 R0
rom[766] = 16'h64b0; // PutChar_Check: LDL R1 $Cells.L
rom[767] = 16'h6504; //               LDH R1 $Cells.H
rom[768] = 16'h011e; //               CMP R2 R1
rom[769] = 16'h4386; //               BCS PutChar_Store
rom[770] = 16'h6220; //               LDLZ R0 ' '
rom[771] = 16'hbfce; //               JSR Text_Word
rom[772] = 16'h0088; //               LD R0 R1
rom[773] = 16'hbf9a; //               JSR ScrollUp
rom[774] = 16'h6888; //               LDL R2 ($Cells - 40).L
rom[775] = 16'h6904; //               LDH R2 ($Cells - 40).H
rom[776] = 16'h6f85; // PutChar_Store: LDHZ R3 $VarsHigh
rom[777] = 16'he980; //               STO R2 [R3 +$VarCursor]
rom[778] = 16'h280d; //               POP R2
rom[779] = 16'h3c0d; //               RET
    // 
    // ; void PrintAt(unsigned column, unsigned row, char *string)
rom[780] = 16'hbfdb; // PrintAt:      JSR SetCursor
rom[781] = 16'hc302; //               LD R0 [SP +2]
    // ; void Print(char *string)
rom[782] = 16'h280c; // Print:        PSH R2
rom[783] = 16'h0808; //               LD R2 R0
rom[784] = 16'hc100; // Print_Loop:   LD R0 [R2]
rom[785] = 16'h4b83; //               BZS Print_Done
rom[786] = 16'hbfd9; //               JSR PutChar
rom[787] = 16'h090c; //               INC R2 R2
rom[788] = 16'h9ffb; //               JMP Print_Loop
rom[789] = 16'h280d; // Print_Done:   POP R2
rom[790] = 16'h3c0d; //               RET
    // 
    // ; void PrintHex(unsigned value)
    // ; Prints 4 hexadecimal digits at the cursor.
rom[791] = 16'h6c42; // PrintHex:     LDL R3 HexToStr.L
rom[792] = 16'h6df3; //               LDH R3 HexToStr.H
rom[793] = 16'h9c02; //               JMP Print_Number
    // 
    // ; void PrintInt(int value)
rom[794] = 16'h6c25; // PrintInt:     LDL R3 IntToStr.L
rom[795] = 16'h6df3; //               LDH R3 IntToStr.H
    // ; Converts R0 with routine R3 into a buffer on the stack, and prints it
rom[796] = 16'h6608; // Print_Number: LDLZ R1 8
rom[797] = 16'h1b12; //               SUB SP SP R1
rom[798] = 16'h070c; //               INC R1 SP
rom[799] = 16'hac00; //               JSR [R3]
rom[800] = 16'h030c; //               INC R0 SP
rom[801] = 16'hbfec; //               JSR Print
rom[802] = 16'h6e08; //               LDLZ R3 8
rom[803] = 16'h1b30; //               ADD SP SP R3
rom[804] = 16'h3c0d; //               RET
    // 
    // ; char *IntToStr(int value, char *buffer)
    // ; Writes at most 7 words. Returns the address of the 0 at the end.
rom[805] = 16'h0008; // IntToStr:     LD R0 R0
rom[806] = 16'h5785; //               BNC UIntToStr
rom[807] = 16'h6e2d; //               LDLZ R3 '-'
rom[808] = 16'hec80; //               STO R3 [R1]
rom[809] = 16'h048c; //               INC R1 R1
rom[810] = 16'h0007; //               NOT R0 R0
rom[811] = 16'h000c; //               INC R0 R0
    // ; char *UIntToStr(unsigned value, char *buffer)
    // ; Writes at most 6 words. Returns the address of the 0 at the end.
rom[812] = 16'h280c; // UIntToStr:    PSH R2
rom[813] = 16'h300c; //               PSH R4
rom[814] = 16'h0888; //               LD R2 R1
rom[815] = 16'h7200; //               LDLZ R4 0
rom[816] = 16'h660a; // UIntToStr_Digit: LDLZ R1 10
rom[817] = 16'hbebd; //               JSR RtUDiv
rom[818] = 16'h6e30; //               LDLZ R3 '0'
rom[819] = 16'h04b0; //               ADD R1 R1 R3
rom[820] = 16'h240c; //               PSH R1
rom[821] = 16'h120c; //               INC R4 R4
rom[822] = 16'h0008; //               LD R0 R0
rom[823] = 16'h4ff8; //               BZC UIntToStr_Digit
rom[824] = 16'h240d; // UIntToStr_Out: POP R1
rom[825] = 16'he500; //               STO R1 [R2]
rom[826] = 16'h090c; //               INC R2 R2
rom[827] = 16'h120f; //               DEC R4 R4
rom[828] = 16'h4ffb; //               BZC UIntToStr_Out
rom[829] = 16'hf100; //               STO R4 [R2]
rom[830] = 16'h0108; //               LD R0 R2
rom[831] = 16'h300d; //               POP R4
rom[832] = 16'h280d; //               POP R2
rom[833] = 16'h3c0d; //               RET
    // 
    // ; char *HexToStr(unsigned value, char *buffer)
    // ; Writes 5 words: 4 digits and the 0. Returns the address of the 0.
rom[834] = 16'h280c; // HexToStr:     PSH R2
rom[835] = 16'h300c; //               PSH R4
rom[836] = 16'h6a04; //               LDLZ R2 4
rom[837] = 16'h0c08; // HexToStr_Digit: LD R3 R0
rom[838] = 16'h2df0; //               SHR R3 R3 8
rom[839] = 16'h2db0; //               SHR R3 R3 4
rom[840] = 16'h2031; //               SHL R0 R0 4
rom[841] = 16'h720a; //               LDLZ R4 10
rom[842] = 16'h01ce; //               CMP R3 R4
rom[843] = 16'h4382; //               BCS HexToStr_Decimal
rom[844] = 16'h7207; //               LDLZ R4 'A' - '0' - 10
rom[845] = 16'h0dc0; //               ADD R3 R3 R4
rom[846] = 16'h7230; // HexToStr_Decimal: LDLZ R4 '0'
rom[847] = 16'h0dc0; //               ADD R3 R3 R4
rom[848] = 16'hec80; //               STO R3 [R1]
rom[849] = 16'h048c; //               INC R1 R1
rom[850] = 16'h090f; //               DEC R2 R2
rom[851] = 16'h4ff1; //               BZC HexToStr_Digit
rom[852] = 16'he880; //               STO R2 [R1]
rom[853] = 16'h0088; //               LD R0 R1
rom[854] = 16'h300d; //               POP R4
rom[855] = 16'h280d; //               POP R2
rom[856] = 16'h3c0d; //               RET
    // 
    // ; void FillCharRect(unsigned column, unsigned row, unsigned width, unsigned height, unsigned word)
    // ; Fills a rectangle of characters with a complete character word. Not clipped: the
    // ; rectangle must be on the screen.
rom[857] = 16'h280c; // FillCharRect: PSH R2
rom[858] = 16'h300c; //               PSH R4
rom[859] = 16'hbe83; //               JSR Cell_Address
rom[860] = 16'hcb05; //               LD R2 [SP +5]
rom[861] = 16'h4b8c; //               BZS FillCharRect_End
rom[862] = 16'hc706; //               LD R1 [SP +6]
rom[863] = 16'hcf04; // FillCharRect_Row: LD R3 [SP +4]
rom[864] = 16'h4b89; //               BZS FillCharRect_End
rom[865] = 16'h1008; //               LD R4 R0
rom[866] = 16'he600; // FillCharRect_Col: STO R1 [R4]
rom[867] = 16'h120c; //               INC R4 R4
rom[868] = 16'h0d8f; //               DEC R3 R3
rom[869] = 16'h4ffc; //               BZC FillCharRect_Col
rom[870] = 16'h6e28; //               LDLZ R3 40
rom[871] = 16'h0030; //               ADD R0 R0 R3
rom[872] = 16'h090f; //               DEC R2 R2
rom[873] = 16'h4ff5; //               BZC FillCharRect_Row
rom[874] = 16'h300d; // FillCharRect_End: POP R4
rom[875] = 16'h280d; //               POP R2
rom[876] = 16'h3c0d; //               RET
    // 
    // ; void CopyCharRect(unsigned column, unsigned row, unsigned width, unsigned height, unsigned *words)
    // ; Copies width * height character words, row by row, from memory to the screen. Not
    // ; clipped: the rectangle must be on the screen.
rom[877] = 16'h280c; // CopyCharRect: PSH R2
rom[878] = 16'h300c; //               PSH R4
rom[879] = 16'h340c; //               PSH R5
rom[880] = 16'hbe6e; //               JSR Cell_Address
rom[881] = 16'hcb06; //               LD R2 [SP +6]
rom[882] = 16'h4b8e; //               BZS CopyCharRect_End
rom[883] = 16'hc707; //               LD R1 [SP +7]
rom[884] = 16'hd705; // CopyCharRect_Row: LD R5 [SP +5]
rom[885] = 16'h4b8b; //               BZS CopyCharRect_End
rom[886] = 16'h1008; //               LD R4 R0
rom[887] = 16'hcc80; // CopyCharRect_Col: LD R3 [R1]
rom[888] = 16'hee00; //               STO R3 [R4]
rom[889] = 16'h048c; //               INC R1 R1
rom[890] = 16'h120c; //               INC R4 R4
rom[891] = 16'h168f; //               DEC R5 R5
rom[892] = 16'h4ffa; //               BZC CopyCharRect_Col
rom[893] = 16'h6e28; //               LDLZ R3 40
rom[894] = 16'h0030; //               ADD R0 R0 R3
rom[895] = 16'h090f; //               DEC R2 R2
rom[896] = 16'h4ff3; //               BZC CopyCharRect_Row
rom[897] = 16'h340d; // CopyCharRect_End: POP R5
rom[898] = 16'h300d; //               POP R4
rom[899] = 16'h280d; //               POP R2
rom[900] = 16'h3c0d; //               RET
    // 
    // ; void SetChar(unsigned character, unsigned *lines)
    // ; Defines character 128 .. 255 with 4 words: word k holds line 2 * k in bits 7 .. 0 and
    // ; line 2 * k + 1 in bits 15 .. 8. Bit 0 of a line is the leftmost point.
rom[901] = 16'h6e7f; // SetChar:      LDLZ R3 0x7F
rom[902] = 16'h0034; //               AND R0 R0 R3
rom[903] = 16'h2001; //               SHL R0 R0
rom[904] = 16'h2001; //               SHL R0 R0
rom[905] = 16'h6f88; //               LDHZ R3 0x88
rom[906] = 16'h0030; //               ADD R0 R0 R3
rom[907] = 16'h6e04; //               LDLZ R3 4
rom[908] = 16'h9edd; //               JMP Copy_Words
    // 
    // ;------------------------------------------------------------------------------
    // ; Serial port: 8 data bits, no parity, 1 stop bit; the bit rate is in CONTROL
    // ;------------------------------------------------------------------------------
    // 
    // ; unsigned SerialCanRead(void)
    // ; 1 if a received byte is there (SerialRead does not wait), else 0.
rom[909] = 16'h6e1f; // SerialCanRead: LDLZ R3 $SerialNot
rom[910] = 16'h0d87; //               NOT R3 R3
rom[911] = 16'hc181; //               LD R0 [R3 +1]
rom[912] = 16'h6601; // Serial_Bit0:  LDLZ R1 1
rom[913] = 16'h0014; //               AND R0 R0 R1
rom[914] = 16'h3c0d; //               RET
    // 
    // ; unsigned SerialCanWrite(void)
    // ; 1 if a byte can be written (SerialWrite does not wait), else 0.
rom[915] = 16'h6e1f; // SerialCanWrite: LDLZ R3 $SerialNot
rom[916] = 16'h0d87; //               NOT R3 R3
rom[917] = 16'hc181; //               LD R0 [R3 +1]
rom[918] = 16'h2000; //               SHR R0 R0
rom[919] = 16'h9ff8; //               JMP Serial_Bit0
    // 
    // ; unsigned SerialRead(void)
    // ; Waits for a received byte and returns it (0 .. 255).
rom[920] = 16'h6e1f; // SerialRead:   LDLZ R3 $SerialNot
rom[921] = 16'h0d87; //               NOT R3 R3
rom[922] = 16'hc181; // SerialRead_Wait: LD R0 [R3 +1]
rom[923] = 16'h2000; //               SHR R0 R0                   ; RX_READY
rom[924] = 16'h47fd; //               BCC SerialRead_Wait
rom[925] = 16'hc180; //               LD R0 [R3]
rom[926] = 16'h3c0d; //               RET
    // 
    // ; void SerialWrite(unsigned byte)
    // ; Waits until a byte can be written, and sends it.
rom[927] = 16'h6e1f; // SerialWrite:  LDLZ R3 $SerialNot
rom[928] = 16'h0d87; //               NOT R3 R3
rom[929] = 16'hc581; // SerialWrite_Wait: LD R1 [R3 +1]
rom[930] = 16'h2490; //               SHR R1 R1 2                 ; TX_READY
rom[931] = 16'h47fd; //               BCC SerialWrite_Wait
rom[932] = 16'he180; //               STO R0 [R3]
rom[933] = 16'h3c0d; //               RET
    // 
    // ; void SerialPrint(char *string)
    // ; Sends the characters of the string (one per word, it ends with 0).
rom[934] = 16'h280c; // SerialPrint:  PSH R2
rom[935] = 16'h0808; //               LD R2 R0
rom[936] = 16'hc100; // SerialPrint_Loop: LD R0 [R2]
rom[937] = 16'h4b83; //               BZS SerialPrint_Done
rom[938] = 16'hbff4; //               JSR SerialWrite
rom[939] = 16'h090c; //               INC R2 R2
rom[940] = 16'h9ffb; //               JMP SerialPrint_Loop
rom[941] = 16'h280d; // SerialPrint_Done: POP R2
rom[942] = 16'h3c0d; //               RET
    // 
    // ;------------------------------------------------------------------------------
    // ; Monitor at 0xF400: set the switches to F400 and press START
    // ;------------------------------------------------------------------------------
    // ; Talks over the serial port at 115200 baud, 8N1, like WOZMON. A line holds commands
    // ; with hexadecimal words of 1 .. 4 digits:
    // ;   1000            shows 1000: ABCD
    // ;   1000.103F       shows the words up to 103F, 8 per line
    // ;   1000: 12 3456   stores words from 1000 on; ": 78" goes on at the next address
    // ;   1000R           runs from 1000 with JSR: a program that ends with RET comes back
    // ; The output of a dump has the input format, so a dump can be sent back as it is.
    // ; ESC cancels the line, Backspace deletes a character. Unknown characters: "?".
    // ;
    // ; Registers: R2 = position in the line, R4 = examine address, R5 = store address.
    // ; The line (80 characters and a 0) is at 0x8580 .. 0x85D0, in the unused frame buffer.
    // 
    // .define $MonLine      0x80    ; Low byte of the line address (high byte $VarsHigh)
    // .define $MonLineEnd   0xD0    ; Low byte of the end of the line: 80 characters
    // .define $VarMonMode   6       ; 0 examine, 1 store, 2 dump
    // .define $VarMonOpen   7       ; 1 while an output line is open
    // .define $VarMonNumber 8       ; The number that was read
    // 
    // .org 0xF400
    // 
rom[1024] = 16'h200a; // Monitor:      CLI
rom[1025] = 16'h7afe; //               LDLZ SP 0xFE
rom[1026] = 16'h790f; //               LDH SP 0x0F
rom[1027] = 16'h6e1f; //               LDLZ R3 $SerialNot
rom[1028] = 16'h0d87; //               NOT R3 R3
rom[1029] = 16'h6200; //               LDLZ R0 0
rom[1030] = 16'he182; //               STO R0 [R3 +2]              ; CONTROL: 115200 baud, no interrupts
rom[1031] = 16'h6220; //               LDLZ R0 32
rom[1032] = 16'h6707; //               LDHZ R1 0x07                ; White on black
rom[1033] = 16'h6cd8; //               LDL R3 ClearScreen.L
rom[1034] = 16'h6df2; //               LDH R3 ClearScreen.H
rom[1035] = 16'hac00; //               JSR [R3]
rom[1036] = 16'h60f7; //               LDL R0 Mon_Title.L
rom[1037] = 16'h61f4; //               LDH R0 Mon_Title.H
rom[1038] = 16'h6c0e; //               LDL R3 Print.L
rom[1039] = 16'h6df3; //               LDH R3 Print.H
rom[1040] = 16'hac00; //               JSR [R3]
rom[1041] = 16'h60e9; //               LDL R0 Mon_Banner.L
rom[1042] = 16'h61f4; //               LDH R0 Mon_Banner.H
rom[1043] = 16'hbf92; //               JSR SerialPrint
rom[1044] = 16'hbcbe; //               JSR Mon_Crlf
rom[1045] = 16'h7200; //               LDLZ R4 0
rom[1046] = 16'h7600; //               LDLZ R5 0
    // 
    // ; Reads a line
rom[1047] = 16'h7afe; // Mon_GetLine:  LDLZ SP 0xFE
rom[1048] = 16'h790f; //               LDH SP 0x0F
rom[1049] = 16'h6a80; //               LDLZ R2 $MonLine
rom[1050] = 16'h6985; //               LDH R2 $VarsHigh
rom[1051] = 16'hbf7c; // Mon_Key:      JSR SerialRead
rom[1052] = 16'h660d; //               LDLZ R1 13
rom[1053] = 16'h001e; //               CMP R0 R1
rom[1054] = 16'h4baa; //               BZS Mon_EndLine
rom[1055] = 16'h661b; //               LDLZ R1 27
rom[1056] = 16'h001e; //               CMP R0 R1
rom[1057] = 16'h4ba3; //               BZS Mon_Escape
rom[1058] = 16'h6608; //               LDLZ R1 8
rom[1059] = 16'h001e; //               CMP R0 R1
rom[1060] = 16'h4b94; //               BZS Mon_Back
rom[1061] = 16'h667f; //               LDLZ R1 127
rom[1062] = 16'h001e; //               CMP R0 R1
rom[1063] = 16'h4b91; //               BZS Mon_Back
rom[1064] = 16'h47f2; //               BCC Mon_Key                 ; 128 .. 255
rom[1065] = 16'h6620; //               LDLZ R1 32
rom[1066] = 16'h001e; //               CMP R0 R1
rom[1067] = 16'h43ef; //               BCS Mon_Key                 ; Control characters, LF too
rom[1068] = 16'h6661; //               LDLZ R1 97
rom[1069] = 16'h001e; //               CMP R0 R1
rom[1070] = 16'h4382; //               BCS Mon_Put
rom[1071] = 16'h66df; //               LDLZ R1 0xDF                ; a .. z to upper case
rom[1072] = 16'h0014; //               AND R0 R0 R1
rom[1073] = 16'h66d0; // Mon_Put:      LDLZ R1 $MonLineEnd
rom[1074] = 16'h6585; //               LDH R1 $VarsHigh
rom[1075] = 16'h011e; //               CMP R2 R1
rom[1076] = 16'h4be6; //               BZS Mon_Key                 ; The line is full
rom[1077] = 16'he100; //               STO R0 [R2]
rom[1078] = 16'h090c; //               INC R2 R2
rom[1079] = 16'hbf67; //               JSR SerialWrite
rom[1080] = 16'h9fe2; //               JMP Mon_Key
rom[1081] = 16'h6680; // Mon_Back:     LDLZ R1 $MonLine
rom[1082] = 16'h6585; //               LDH R1 $VarsHigh
rom[1083] = 16'h011e; //               CMP R2 R1
rom[1084] = 16'h4bde; //               BZS Mon_Key
rom[1085] = 16'h090f; //               DEC R2 R2
rom[1086] = 16'h6208; //               LDLZ R0 8
rom[1087] = 16'hbf5f; //               JSR SerialWrite
rom[1088] = 16'h6220; //               LDLZ R0 32
rom[1089] = 16'hbf5d; //               JSR SerialWrite
rom[1090] = 16'h6208; //               LDLZ R0 8
rom[1091] = 16'hbf5b; //               JSR SerialWrite
rom[1092] = 16'h9fd6; //               JMP Mon_Key
rom[1093] = 16'h625c; // Mon_Escape:   LDLZ R0 92                  ; "\"
rom[1094] = 16'hbf58; //               JSR SerialWrite
rom[1095] = 16'hbc8b; //               JSR Mon_Crlf
rom[1096] = 16'h9fce; //               JMP Mon_GetLine
    // 
    // ; Runs the commands of the line
rom[1097] = 16'h6200; // Mon_EndLine:  LDLZ R0 0
rom[1098] = 16'he100; //               STO R0 [R2]
rom[1099] = 16'hbc87; //               JSR Mon_Crlf
rom[1100] = 16'h6200; //               LDLZ R0 0
rom[1101] = 16'h6a80; //               LDLZ R2 $MonLine
rom[1102] = 16'h6985; //               LDH R2 $VarsHigh
rom[1103] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[1104] = 16'he186; //               STO R0 [R3 +$VarMonMode]
rom[1105] = 16'he187; //               STO R0 [R3 +$VarMonOpen]
rom[1106] = 16'hc100; // Mon_Next:     LD R0 [R2]
rom[1107] = 16'h4b9d; //               BZS Mon_Done
rom[1108] = 16'h090c; //               INC R2 R2
rom[1109] = 16'h6620; //               LDLZ R1 32
rom[1110] = 16'h001e; //               CMP R0 R1
rom[1111] = 16'h4bfa; //               BZS Mon_Next
rom[1112] = 16'h6652; //               LDLZ R1 82                  ; "R"
rom[1113] = 16'h001e; //               CMP R0 R1
rom[1114] = 16'h4b9d; //               BZS Mon_Run
rom[1115] = 16'h662e; //               LDLZ R1 46                  ; "."
rom[1116] = 16'h001e; //               CMP R0 R1
rom[1117] = 16'h4b8d; //               BZS Mon_Dot
rom[1118] = 16'h663a; //               LDLZ R1 58                  ; ":"
rom[1119] = 16'h001e; //               CMP R0 R1
rom[1120] = 16'h4b8c; //               BZS Mon_Colon
rom[1121] = 16'hbc75; //               JSR Mon_HexDigit
rom[1122] = 16'h4390; //               BCS Mon_Error
rom[1123] = 16'h0408; //               LD R1 R0
rom[1124] = 16'hc100; // Mon_Digits:   LD R0 [R2]
rom[1125] = 16'hbc71; //               JSR Mon_HexDigit
rom[1126] = 16'h439a; //               BCS Mon_Number
rom[1127] = 16'h090c; //               INC R2 R2
rom[1128] = 16'h24b1; //               SHL R1 R1 4
rom[1129] = 16'h0485; //               OR R1 R1 R0
rom[1130] = 16'h9ff9; //               JMP Mon_Digits
rom[1131] = 16'h6202; // Mon_Dot:      LDLZ R0 2
rom[1132] = 16'h9c01; //               JMP Mon_SetMode
rom[1133] = 16'h6201; // Mon_Colon:    LDLZ R0 1
rom[1134] = 16'h6f85; // Mon_SetMode:  LDHZ R3 $VarsHigh
rom[1135] = 16'he186; //               STO R0 [R3 +$VarMonMode]
rom[1136] = 16'h9fe1; //               JMP Mon_Next
rom[1137] = 16'hbc5c; // Mon_Done:     JSR Mon_Close
rom[1138] = 16'h9fa4; //               JMP Mon_GetLine
rom[1139] = 16'hbc5a; // Mon_Error:    JSR Mon_Close
rom[1140] = 16'h623f; //               LDLZ R0 63                  ; "?"
rom[1141] = 16'hbf29; //               JSR SerialWrite
rom[1142] = 16'hbc5c; //               JSR Mon_Crlf
rom[1143] = 16'h9f9f; //               JMP Mon_GetLine
    // 
    // ; Runs the program at the examine address. Afterwards: 115200 baud, no interrupts.
rom[1144] = 16'hbc55; // Mon_Run:      JSR Mon_Close
rom[1145] = 16'hb000; //               JSR [R4]
rom[1146] = 16'h200a; //               CLI
rom[1147] = 16'h6e1f; //               LDLZ R3 $SerialNot
rom[1148] = 16'h0d87; //               NOT R3 R3
rom[1149] = 16'h6200; //               LDLZ R0 0
rom[1150] = 16'he182; //               STO R0 [R3 +2]
rom[1151] = 16'hbc53; //               JSR Mon_Crlf
rom[1152] = 16'h9f96; //               JMP Mon_GetLine
    // 
    // ; A number: a ":" after it makes it the store address
rom[1153] = 16'h6f85; // Mon_Number:   LDHZ R3 $VarsHigh
rom[1154] = 16'he588; //               STO R1 [R3 +$VarMonNumber]
rom[1155] = 16'h0508; //               LD R1 R2
rom[1156] = 16'hc080; // Mon_Look:     LD R0 [R1]
rom[1157] = 16'h6e20; //               LDLZ R3 32
rom[1158] = 16'h003e; //               CMP R0 R3
rom[1159] = 16'h4f82; //               BZC Mon_Looked
rom[1160] = 16'h048c; //               INC R1 R1
rom[1161] = 16'h9ffa; //               JMP Mon_Look
rom[1162] = 16'h6e3a; // Mon_Looked:   LDLZ R3 58
rom[1163] = 16'h003e; //               CMP R0 R3
rom[1164] = 16'h4f86; //               BZC Mon_Use
rom[1165] = 16'h088c; //               INC R2 R1                   ; Behind the ":"
rom[1166] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[1167] = 16'hd588; //               LD R5 [R3 +$VarMonNumber]
rom[1168] = 16'h6201; //               LDLZ R0 1
rom[1169] = 16'he186; //               STO R0 [R3 +$VarMonMode]
rom[1170] = 16'h9fbf; //               JMP Mon_Next
rom[1171] = 16'h0408; // Mon_Use:      LD R1 R0                    ; The character after the number
rom[1172] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[1173] = 16'hc186; //               LD R0 [R3 +$VarMonMode]
rom[1174] = 16'h4b86; //               BZS Mon_Examine
rom[1175] = 16'h2000; //               SHR R0 R0
rom[1176] = 16'h478b; //               BCC Mon_Dump
rom[1177] = 16'hc188; //               LD R0 [R3 +$VarMonNumber]   ; Store
rom[1178] = 16'he280; //               STO R0 [R5]
rom[1179] = 16'h168c; //               INC R5 R5
rom[1180] = 16'h9fb5; //               JMP Mon_Next
rom[1181] = 16'hd188; // Mon_Examine:  LD R4 [R3 +$VarMonNumber]
rom[1182] = 16'h1608; //               LD R5 R4
rom[1183] = 16'h6252; //               LDLZ R0 82
rom[1184] = 16'h001e; //               CMP R0 R1
rom[1185] = 16'h4b81; //               BZS Mon_Examined            ; "R" follows: run without showing
rom[1186] = 16'hbc0e; //               JSR Mon_Line
rom[1187] = 16'h9fae; // Mon_Examined: JMP Mon_Next
rom[1188] = 16'h6f85; // Mon_Dump:     LDHZ R3 $VarsHigh
rom[1189] = 16'hc188; //               LD R0 [R3 +$VarMonNumber]
rom[1190] = 16'h020e; //               CMP R4 R0
rom[1191] = 16'h4381; //               BCS Mon_DumpNext            ; Up to the number
rom[1192] = 16'h9fa9; //               JMP Mon_Next
rom[1193] = 16'h120c; // Mon_DumpNext: INC R4 R4
rom[1194] = 16'h6207; //               LDLZ R0 7
rom[1195] = 16'h0044; //               AND R0 R0 R4
rom[1196] = 16'h4f82; //               BZC Mon_DumpWord
rom[1197] = 16'hbc03; //               JSR Mon_Line
rom[1198] = 16'h9ff5; //               JMP Mon_Dump
rom[1199] = 16'hbc09; // Mon_DumpWord: JSR Mon_Value
rom[1200] = 16'h9ff3; //               JMP Mon_Dump
    // 
    // ; Starts an output line: "1000: ABCD" for the word at R4
rom[1201] = 16'hbc1c; // Mon_Line:     JSR Mon_Close
rom[1202] = 16'h6f85; //               LDHZ R3 $VarsHigh
rom[1203] = 16'h6201; //               LDLZ R0 1
rom[1204] = 16'he187; //               STO R0 [R3 +$VarMonOpen]
rom[1205] = 16'h0208; //               LD R0 R4
rom[1206] = 16'hbc05; //               JSR Mon_Hex4
rom[1207] = 16'h623a; //               LDLZ R0 58
rom[1208] = 16'hbee6; //               JSR SerialWrite
    // ; Shows " ABCD", the word at R4
rom[1209] = 16'h6220; // Mon_Value:    LDLZ R0 32
rom[1210] = 16'hbee4; //               JSR SerialWrite
rom[1211] = 16'hc200; //               LD R0 [R4]
    // ; Sends R0 as 4 hexadecimal digits
rom[1212] = 16'h280c; // Mon_Hex4:     PSH R2
rom[1213] = 16'h0808; //               LD R2 R0
rom[1214] = 16'hbc05; //               JSR Mon_HexHigh
rom[1215] = 16'hbc04; //               JSR Mon_HexHigh
rom[1216] = 16'hbc03; //               JSR Mon_HexHigh
rom[1217] = 16'hbc02; //               JSR Mon_HexHigh
rom[1218] = 16'h280d; //               POP R2
rom[1219] = 16'h3c0d; //               RET
    // ; Sends the digit of bits 15 .. 12 of R2, and shifts R2 left by 4
rom[1220] = 16'h2170; // Mon_HexHigh:  SHR R0 R2 8
rom[1221] = 16'h2030; //               SHR R0 R0 4
rom[1222] = 16'h2931; //               SHL R2 R2 4
rom[1223] = 16'h660a; //               LDLZ R1 10
rom[1224] = 16'h001e; //               CMP R0 R1
rom[1225] = 16'h6630; //               LDLZ R1 48                  ; "0"
rom[1226] = 16'h4381; //               BCS Mon_HexOut
rom[1227] = 16'h6637; //               LDLZ R1 55                  ; "A" - 10
rom[1228] = 16'h0010; // Mon_HexOut:   ADD R0 R0 R1
rom[1229] = 16'h9ed1; //               JMP SerialWrite
    // 
    // ; Ends an open output line
rom[1230] = 16'h6f85; // Mon_Close:    LDHZ R3 $VarsHigh
rom[1231] = 16'hc187; //               LD R0 [R3 +$VarMonOpen]
rom[1232] = 16'h4b95; //               BZS Mon_Return
rom[1233] = 16'h6200; //               LDLZ R0 0
rom[1234] = 16'he187; //               STO R0 [R3 +$VarMonOpen]
rom[1235] = 16'h620d; // Mon_Crlf:     LDLZ R0 13
rom[1236] = 16'hbeca; //               JSR SerialWrite
rom[1237] = 16'h620a; //               LDLZ R0 10
rom[1238] = 16'h9ec8; //               JMP SerialWrite
    // 
    // ; R0: character "0" .. "9", "A" .. "F" -> value and C = 0; other characters: C = 1
rom[1239] = 16'h6e30; // Mon_HexDigit: LDLZ R3 48
rom[1240] = 16'h0032; //               SUB R0 R0 R3
rom[1241] = 16'h438c; //               BCS Mon_Return
rom[1242] = 16'h6e0a; //               LDLZ R3 10
rom[1243] = 16'h003e; //               CMP R0 R3
rom[1244] = 16'h438a; //               BCS Mon_HexOk
rom[1245] = 16'h6e07; //               LDLZ R3 7
rom[1246] = 16'h0032; //               SUB R0 R0 R3
rom[1247] = 16'h6e0a; //               LDLZ R3 10
rom[1248] = 16'h003e; //               CMP R0 R3
rom[1249] = 16'h4384; //               BCS Mon_Return
rom[1250] = 16'h6e10; //               LDLZ R3 16
rom[1251] = 16'h003e; //               CMP R0 R3
rom[1252] = 16'h4382; //               BCS Mon_HexOk
rom[1253] = 16'h2009; //               SEC
rom[1254] = 16'h3c0d; // Mon_Return:   RET
rom[1255] = 16'h2008; // Mon_HexOk:    CLC
rom[1256] = 16'h3c0d; //               RET
    // 
rom[1257] = 16'h000d; // .data 13, 10
rom[1258] = 16'h000a;
rom[1259] = 16'h004b; // .cstring "K16 Monitor"
rom[1260] = 16'h0031;
rom[1261] = 16'h0036;
rom[1262] = 16'h0020;
rom[1263] = 16'h004d;
rom[1264] = 16'h006f;
rom[1265] = 16'h006e;
rom[1266] = 16'h0069;
rom[1267] = 16'h0074;
rom[1268] = 16'h006f;
rom[1269] = 16'h0072;
rom[1270] = 16'h0000;
rom[1271] = 16'h004b; // .cstring "K16 Monitor: serial port 115200 8N1"
rom[1272] = 16'h0031;
rom[1273] = 16'h0036;
rom[1274] = 16'h0020;
rom[1275] = 16'h004d;
rom[1276] = 16'h006f;
rom[1277] = 16'h006e;
rom[1278] = 16'h0069;
rom[1279] = 16'h0074;
rom[1280] = 16'h006f;
rom[1281] = 16'h0072;
rom[1282] = 16'h003a;
rom[1283] = 16'h0020;
rom[1284] = 16'h0073;
rom[1285] = 16'h0065;
rom[1286] = 16'h0072;
rom[1287] = 16'h0069;
rom[1288] = 16'h0061;
rom[1289] = 16'h006c;
rom[1290] = 16'h0020;
rom[1291] = 16'h0070;
rom[1292] = 16'h006f;
rom[1293] = 16'h0072;
rom[1294] = 16'h0074;
rom[1295] = 16'h0020;
rom[1296] = 16'h0031;
rom[1297] = 16'h0031;
rom[1298] = 16'h0035;
rom[1299] = 16'h0032;
rom[1300] = 16'h0030;
rom[1301] = 16'h0030;
rom[1302] = 16'h0020;
rom[1303] = 16'h0038;
rom[1304] = 16'h004e;
rom[1305] = 16'h0031;
rom[1306] = 16'h0000;
    // Unused words
rom[943] = 16'h0000;
rom[944] = 16'h0000;
rom[945] = 16'h0000;
rom[946] = 16'h0000;
rom[947] = 16'h0000;
rom[948] = 16'h0000;
rom[949] = 16'h0000;
rom[950] = 16'h0000;
rom[951] = 16'h0000;
rom[952] = 16'h0000;
rom[953] = 16'h0000;
rom[954] = 16'h0000;
rom[955] = 16'h0000;
rom[956] = 16'h0000;
rom[957] = 16'h0000;
rom[958] = 16'h0000;
rom[959] = 16'h0000;
rom[960] = 16'h0000;
rom[961] = 16'h0000;
rom[962] = 16'h0000;
rom[963] = 16'h0000;
rom[964] = 16'h0000;
rom[965] = 16'h0000;
rom[966] = 16'h0000;
rom[967] = 16'h0000;
rom[968] = 16'h0000;
rom[969] = 16'h0000;
rom[970] = 16'h0000;
rom[971] = 16'h0000;
rom[972] = 16'h0000;
rom[973] = 16'h0000;
rom[974] = 16'h0000;
rom[975] = 16'h0000;
rom[976] = 16'h0000;
rom[977] = 16'h0000;
rom[978] = 16'h0000;
rom[979] = 16'h0000;
rom[980] = 16'h0000;
rom[981] = 16'h0000;
rom[982] = 16'h0000;
rom[983] = 16'h0000;
rom[984] = 16'h0000;
rom[985] = 16'h0000;
rom[986] = 16'h0000;
rom[987] = 16'h0000;
rom[988] = 16'h0000;
rom[989] = 16'h0000;
rom[990] = 16'h0000;
rom[991] = 16'h0000;
rom[992] = 16'h0000;
rom[993] = 16'h0000;
rom[994] = 16'h0000;
rom[995] = 16'h0000;
rom[996] = 16'h0000;
rom[997] = 16'h0000;
rom[998] = 16'h0000;
rom[999] = 16'h0000;
rom[1000] = 16'h0000;
rom[1001] = 16'h0000;
rom[1002] = 16'h0000;
rom[1003] = 16'h0000;
rom[1004] = 16'h0000;
rom[1005] = 16'h0000;
rom[1006] = 16'h0000;
rom[1007] = 16'h0000;
rom[1008] = 16'h0000;
rom[1009] = 16'h0000;
rom[1010] = 16'h0000;
rom[1011] = 16'h0000;
rom[1012] = 16'h0000;
rom[1013] = 16'h0000;
rom[1014] = 16'h0000;
rom[1015] = 16'h0000;
rom[1016] = 16'h0000;
rom[1017] = 16'h0000;
rom[1018] = 16'h0000;
rom[1019] = 16'h0000;
rom[1020] = 16'h0000;
rom[1021] = 16'h0000;
rom[1022] = 16'h0000;
rom[1023] = 16'h0000;
    end
endmodule

`endif
