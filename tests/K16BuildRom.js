// ----------------------------------------------------------------------------
// Assembles the ROM library. Used by BuildRom.ps1.
//
// Usage: cscript //nologo K16BuildRom.js <emulator folder> <output folder>
//
// Reads K16Rom.asm from the emulator folder and writes to the output folder:
//   K16Rom.v         the ROM for the hardware
//   K16RomImage.js   the ROM and its public symbols for the emulator, the
//                    assembler, and the C compiler
// ----------------------------------------------------------------------------

var romAddress = 0xF000;
var romSize = 1024;

var fso = new ActiveXObject("Scripting.FileSystemObject");

function readFile(thePath)
{
   var stream = fso.OpenTextFile(thePath, 1);
   var text = stream.AtEndOfStream ? "" : stream.ReadAll();
   stream.Close();
   return text;
}

function writeFile(thePath, theLines)
{
   var stream = fso.CreateTextFile(thePath, true);
   stream.Write(theLines.join("\r\n") + "\r\n");
   stream.Close();
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

if (WScript.Arguments.length != 2)
{
   fail("Usage: cscript //nologo K16BuildRom.js <emulator folder> <output folder>");
}
var emulatorFolder = WScript.Arguments(0);
var outputFolder = WScript.Arguments(1);

eval(readFile(emulatorFolder + "\\K16Cpu.js"));
eval(readFile(emulatorFolder + "\\K16Assembler.js"));

var assembler = new K16Assembler();
if (assembler.parse(readFile(emulatorFolder + "\\K16Rom.asm")) == false)
{
   fail("K16Rom.asm, line " + assembler.line + ": " + assembler.errorMessage);
}

// Words
var image = [];
for (var address in assembler.code)
{
   var index = Number(address) - romAddress;
   if (index < 0)
   {
      fail("K16Rom.asm: code below 0x" + hex4(romAddress));
   }
   image[index] = assembler.code[address];
}
if (image.length > romSize)
{
   fail("K16Rom.asm: " + image.length + " words, the ROM has " + romSize);
}

// Public symbols: labels without "_"
var symbols = [];
for (var name in assembler.labelMap)
{
   if (name.indexOf("_") < 0)
   {
      symbols.push(name);
   }
}
symbols.sort(function (theA, theB) { return assembler.labelMap[theA].address - assembler.labelMap[theB].address; });

// K16Rom.v
var verilog = [];
verilog.push("`ifndef K16ROM_V");
verilog.push("`define K16ROM_V");
verilog.push("");
verilog.push("// Generated from K16Rom.asm by tests\\BuildRom.ps1. Do not edit.");
verilog.push("module K16Rom (addr, clk, dout);// " + romSize + "x16");
verilog.push("  parameter addr_width = 10;");
verilog.push("  parameter data_width = 16;");
verilog.push("  input [addr_width-1:0] addr;");
verilog.push("  input clk;");
verilog.push("  output [data_width-1:0] dout;");
verilog.push("  reg [data_width-1:0] dout; // Register for output.");
verilog.push("  reg [data_width-1:0] rom [(1<<addr_width)-1:0];");
verilog.push("  always @(posedge clk)");
verilog.push("    begin");
verilog.push("      dout <= rom[addr]; // Output register controlled by clock.");
verilog.push("    end");
verilog.push("  initial");
verilog.push("    begin");
for (var i = 0; i < assembler.sourceCode.length; i++)
{
   var line = assembler.sourceCode[i];
   if (!line)
   {
      continue;
   }
   var text = line.sourceCode.replace(/[\r\n]+$/, "");
   if (line.address == undefined || line.length === 0)
   {
      verilog.push("    // " + text);
      continue;
   }
   var length = line.length == undefined ? 1 : line.length;
   for (var j = 0; j < length; j++)
   {
      verilog.push("rom[" + (line.address + j - romAddress) + "] = 16'h" + hex4(assembler.code[line.address + j]) +
                   ";" + (j == 0 ? " // " + text : ""));
   }
}
verilog.push("    end");
verilog.push("endmodule");
verilog.push("");
verilog.push("`endif");
writeFile(outputFolder + "\\K16Rom.v", verilog);

// K16RomImage.js
var script = [];
script.push("// Generated from K16Rom.asm by tests\\BuildRom.ps1 in the Verilog repository. Do not edit.");
script.push("var K16RomImage =");
script.push("[");
for (var i = 0; i < image.length; i += 12)
{
   var words = [];
   for (var j = i; j < i + 12 && j < image.length; j++)
   {
      words.push("0x" + hex4(image[j]));
   }
   script.push("   " + words.join(", ") + (i + 12 < image.length ? "," : ""));
}
script.push("];");
script.push("");
script.push("var K16RomSymbols =");
script.push("{");
for (var i = 0; i < symbols.length; i++)
{
   script.push("   \"" + symbols[i] + "\": 0x" + hex4(assembler.labelMap[symbols[i]].address) + (i + 1 < symbols.length ? "," : ""));
}
script.push("};");
writeFile(outputFolder + "\\K16RomImage.js", script);

WScript.Echo("ROM: " + image.length + " of " + romSize + " words, " + symbols.length + " public symbols");
