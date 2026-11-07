// ----------------------------------------------------------------------------
// Runs a K16 assembler or C program in the JavaScript emulator until HLT and
// writes the final state. Used by CompareWithEmulator.ps1.
//
// Usage: cscript //nologo K16Emulate.js <emulator folder> <program.asm or .c> <output folder>
//
// Writes to the output folder:
//   program.vh    the program as Verilog assignments for K16Compare_tb.v
//   program.asm   the generated assembly code (C programs only)
//   emulator.txt  registers, flags, RAM, frame buffer, sprite registers, and
//                 changeable characters after HLT
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
   fail("Usage: cscript //nologo K16Emulate.js <emulator folder> <program.asm or .c> <output folder>");
}
var emulatorFolder = WScript.Arguments(0);
var programPath = WScript.Arguments(1);
var outputFolder = WScript.Arguments(2);

eval(readFile(emulatorFolder + "\\K16RomImage.js"));
eval(readFile(emulatorFolder + "\\K16Cpu.js"));
eval(readFile(emulatorFolder + "\\K16Memory.js"));
eval(readFile(emulatorFolder + "\\K16Assembler.js"));

var assemblyCode = readFile(programPath);
if (/\.c$/i.test(programPath))
{
   // C program: compile it first, #include files are next to the program
   var compilerFiles = [ "K16CAst.js", "K16CPreprocessor.js", "K16CLexer.js", "K16CParser.js",
                         "K16CAnalyzer.js", "K16CCodeGen.js", "K16Compiler.js" ];
   for (var i = 0; i < compilerFiles.length; i++)
   {
      eval(readFile(emulatorFolder + "\\" + compilerFiles[i]));
   }
   var programFolder = fso.GetParentFolderName(fso.GetAbsolutePathName(programPath));
   var compiler = new K16Compiler(function (theName)
   {
      var path = programFolder + "\\" + theName;
      return fso.FileExists(path) ? readFile(path) : undefined;
   });
   if (!compiler.compile(assemblyCode, fso.GetFileName(programPath)))
   {
      fail("Compiler: " + compiler.errorText());
   }
   assemblyCode = compiler.assemblyCode;
   var assemblyFile = fso.CreateTextFile(outputFolder + "\\program.asm", true);
   assemblyFile.Write(assemblyCode.replace(/\n/g, "\r\n"));
   assemblyFile.Close();
}

// Assemble
var assembler = new K16Assembler();
if (assembler.parse(assemblyCode) == false)
{
   fail("Assembler error in line " + assembler.line + ": " + assembler.errorMessage);
}

// Memory with cleared RAM and frame buffer. Of the I/O, only the clock counter:
// one count per step. A program must not depend on the exact number of clocks.
var ticks = 0;
var frameBuffer = [];
for (var i = 0; i < 0x0800; i++)
{
   frameBuffer[i] = 0;
}
var io =
{
   read: function (theAddress)
   {
      switch (theAddress)
      {
         case 5: return Math.floor(ticks / 65536) & 0xFFFF;
         case 6: return ticks & 0xFFFF;
      }
      return 0;
   },
   write: function () {}
};
var spriteRegisters = [];
for (var i = 0; i < 16; i++)
{
   spriteRegisters[i] = 0;
}
var characterRam = [];
for (var i = 0; i < 512; i++)
{
   characterRam[i] = 0;
}
var memory = new K16Memory(frameBuffer, io, spriteRegisters, characterRam);
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

// Run from address 0 until HLT, with a frame interrupt every 800 * 525 clocks
var cpu = new K16Cpu(memory);
cpu.runningM = true;
while (cpu.runningM && ticks < 20000000)
{
   if (ticks % 420000 == 419999)
   {
      cpu.interrupt();
   }
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
for (var i = 0; i < 16; i++)
{
   output.WriteLine("SPR " + i + " " + hex4(spriteRegisters[i]));
}
for (var i = 0; i < 512; i++)
{
   output.WriteLine("CHR " + i + " " + hex4(characterRam[i]));
}
output.Close();
