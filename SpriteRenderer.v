`ifndef SPRITERENDERER_V
`define SPRITERENDERER_V

module SpriteRenderer(theClk,
                      vstart,
                      load,
                      hstart,
                      theSpriteLine,
                      theSpriteBits,
                      red,
                      green,
                      blue,
                      alpha,
                      in_progress);

  input theClk;
  input vstart;		// start Drawing (top border)
  input load;		// ok to load sprite data?
  input hstart;		// start Drawing scanline (left border)
  output reg [3:0] theSpriteLine;	// select ROM address
  input [63:0] theSpriteBits;		// input bits from ROM
  output reg red;		// output pixel red
  output reg green;	// output pixel green
  output reg blue;	// output pixel blue
  output reg alpha;	// output pixel alpha
  output in_progress;	// 0 if waiting for vstart

  reg [2:0] state;	// current state #
  reg [5:0] ycount;	// number of scanlines Drawn so far
  reg [5:0] xcount;	// number of horiz. pixels in this line

  reg [63:0] outbits;	// register to store bits from ROM

  // states for state machine
  localparam WaitForVstart = 0;
  localparam WaitForLoad   = 1;
  localparam LoadSetup     = 2;
  localparam LoadFetch     = 3;
  localparam WaitForHstart = 4;
  localparam Draw            = 5;

  // assign in_progress output bit
  assign in_progress = state != WaitForVstart;

  always @(posedge theClk)
    begin
      case (state)
        WaitForVstart:
          begin
            ycount <= 0; // initialize vertical count
            alpha <= 0; // default pixel value (off)
            // wait for vstart, then next state
            if (vstart)
              state <= WaitForLoad;
          end
        WaitForLoad:
          begin
            xcount <= 0; // initialize horiz. count
	          alpha <= 0;
            // wait for load, then next state
            if (load)
              state <= LoadSetup;
          end
        LoadSetup:
          begin
            theSpriteLine <= ycount[5:2]; // load ROM address
            state <= LoadFetch;
          end
        LoadFetch:
          begin
	          outbits <= theSpriteBits; // latch bits from ROM
            state <= WaitForHstart;
          end
        WaitForHstart:
          begin
            // wait for hstart, then start Drawing
            if (hstart)
              state <= Draw;
          end
        Draw:
          begin
            // get pixels
            red   <= outbits[~{xcount[5:2], 2'b00}];
            green <= outbits[~{xcount[5:2], 2'b01}];
            blue  <= outbits[~{xcount[5:2], 2'b10}];
            alpha <= outbits[~{xcount[5:2], 2'b11}] && in_progress;

            xcount <= xcount + 1;
            // finished Drawing horizontal slice?
            if (xcount == 63)
              begin // pre-increment value
                ycount <= ycount + 1;
                // finished Drawing sprite?
                if (ycount == 63) // pre-increment value
                  state <= WaitForVstart; // done Drawing sprite
                else
	                state <= WaitForLoad; // done Drawing this scanline
              end
          end
        // unknown state -- reset
        default:
          begin
            state <= WaitForVstart;
          end
      endcase
    end

endmodule


`endif
