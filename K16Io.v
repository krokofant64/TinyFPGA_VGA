`ifndef K16IO_V
`define K16IO_V

module K16Io(clk, reset, select, outputBits, inputBits, cpuOutput0, cpuOutput1, cpuInput0, cpuInput1);
  input             clk;
  input             reset;
  output reg [2:0]  select;
  output reg [3:0]  outputBits;
  input  [3:0]      inputBits;
  input  [15:0]     cpuOutput0;
  input  [15:0]     cpuOutput1;
  output reg [15:0] cpuInput0;
  output reg [15:0] cpuInput1;

  always @(posedge clk)
    begin
    if (reset)
      begin
        select <= 0;
      end
    else
      case (select)
        0:
          begin
            outputBits <= cpuOutput0[3:0];
            cpuInput0[3:0] <= inputBits;
            select <= 1;
          end
        1:
          begin
            outputBits <= cpuOutput0[7:4];
            cpuInput0[7:4] <= inputBits;
            select <= 2;
          end
        2:
          begin
            outputBits <= cpuOutput0[11:8];
            cpuInput0[11:8] <= inputBits;
            select <= 3;
          end
        3:
          begin
            outputBits <= cpuOutput0[15:12];
            cpuInput0[15:12] <= inputBits;
            select <= 4;
          end
        4:
          begin
            outputBits <= cpuOutput1[3:0];
            cpuInput1[3:0] <= inputBits;
            select <= 5;
          end
        5:
          begin
            outputBits <= cpuOutput1[7:4];
            cpuInput1[7:4] <= inputBits;
            select <= 6;
          end
        6:
          begin
            outputBits <= cpuOutput1[11:8];
            cpuInput1[11:8] <= inputBits;
            select <= 7;
          end
        7:
          begin
            outputBits <= cpuOutput1[15:12];
            cpuInput1[15:12] <= inputBits;
            select <= 0;
          end
      endcase
    end
endmodule

`endif
