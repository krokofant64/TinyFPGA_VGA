// ----------------------------------------------------------------------------
// Runs a K16 assembler program in the JavaScript emulator until HLT and
// writes the final state. Used by CompareWithEmulator.ps1.
//
// Usage: cscript //nologo K16Emulate.js <emulator folder> <program.asm> <output folder>
//
// Writes to the output folder:
//   program.vh    the program as Verilog assignments for K16Compare_tb.v
//   emulator.txt  registers, flags, RAM, and frame buffer after HLT
// ----------------------------------------------------------------------------

var fso = new ActiveXObject("Scripting.FileSystemObject");

function readFile(thePath)
{
   var stream = fso.OpenTextFile(thePath, 1);
   var text = stream.AtEndOfStream ? "" : stream.ReadAll();
   stream.Close();
   return text;
}

function hex4(theValue)
{
   var text = (theValue & 0xFFFF).toString(16);
   while (text.length < 4)
   {
      text = "0" + text;
   }
   return text;
}

function fail(theMessage)
{
   WScript.StdErr.WriteLine(theMessage);
   WScript.Quit(1);
}

if (WScript.Arguments.length != 3)
{
   fail("Usage: cscript //nologo K16Emulate.js <emulator folder> <program.asm> <output folder>");
}
var emulatorFolder = WScript.Arguments(0);
var programPath = WScript.Arguments(1);
var outputFolder = WScript.Arguments(2);

eval(readFile(emulatorFolder + "\\K16Cpu.js"));
eval(readFile(emulatorFolder + "\\K16Memory.js"));
eval(readFile(emulatorFolder + "\\K16Assembler.js"));

// Assemble
var assembler = new K16Assembler();
if (assembler.parse(readFile(programPath)) == false)
{
   fail("Assembler error in line " + assembler.line + ": " + assembler.errorMessage);
}

// Memory with cleared RAM and frame buffer, without I/O
var frameBuffer = [];
for (var i = 0; i < 0x0800; i++)
{
   frameBuffer[i] = 0;
}
var io = { read: function () { return 0; }, write: function () {} };
var memory = new K16Memory(frameBuffer, io);
for (var i = 0; i < 0x1000; i++)
{
   memory.memoryM[i] = 0; // Remove the emulator's demo program
}

var program = fso.CreateTextFile(outputFolder + "\\program.vh", true);
for (var address in assembler.code)
{
   var value = assembler.code[address];
   if (Number(address) > 0x0FFF)
   {
      fail("The program must be in RAM (0x0000 .. 0x0FFF)");
   }
   memory.setAddress(Number(address));
   memory.write(value);
   program.WriteLine("      dut.ram.mem['h" + hex4(Number(address)) + "] = 16'h" + hex4(value) + ";");
}
program.Close();

// Run from address 0 until HLT
var cpu = new K16Cpu(memory);
cpu.runningM = true;
var ticks = 0;
while (cpu.runningM && ticks < 20000000)
{
   cpu.clockTick();
   ticks++;
}
if (cpu.runningM)
{
   fail("The program did not reach HLT");
}

// Final state
var output = fso.CreateTextFile(outputFolder + "\\emulator.txt", true);
for (var r = 0; r < 8; r++)
{
   output.WriteLine("R" + r + " " + hex4(cpu.regM[r]));
}
output.WriteLine("C " + (cpu.flagsM.carry ? 1 : 0));
output.WriteLine("Z " + (cpu.flagsM.zero ? 1 : 0));
output.WriteLine("N " + (cpu.flagsM.negative ? 1 : 0));
output.WriteLine("O " + (cpu.flagsM.overflow ? 1 : 0));
output.WriteLine("I " + (cpu.flagsM.enableInterupt ? 1 : 0));
for (var i = 0; i < 0x1000; i++)
{
   output.WriteLine("RAM " + hex4(i) + " " + hex4(memory.memoryM[i]));
}
for (var i = 0; i < 0x0800; i++)
{
   output.WriteLine("FB " + hex4(i) + " " + hex4(frameBuffer[i]));
}
output.Close();
