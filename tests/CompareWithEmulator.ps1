<#
.SYNOPSIS
Runs test programs in the JavaScript emulator and in the Verilog simulation
of the complete computer, and compares the results.

.DESCRIPTION
Each program in tests\programs (or the ones given with -Programs) is
assembled with the emulator's assembler and run from address 0 until HLT,
once in the emulator (Windows Script Host) and once in the hardware
simulation (Icarus Verilog from the apio packages). Registers, flags, RAM,
and frame buffer must be identical afterwards.

The programs must not depend on timing: no interrupts, no cycle counter,
no switches.

.EXAMPLE
.\tests\CompareWithEmulator.ps1
.\tests\CompareWithEmulator.ps1 -Programs tests\programs\alu.asm
#>
param(
   [string]   $EmulatorDir = "G:\usbwebserver\root\code\K16",
   [string[]] $Programs = @(),
   [string]   $IverilogDir = "$env:USERPROFILE\.apio\packages\toolchain-iverilog"
)

# Not "Stop": in Windows PowerShell, stderr output of the native tools
# would then end the script. Errors are checked explicitly.
$ErrorActionPreference = "Continue"
$repoDir = Split-Path -Parent $PSScriptRoot
if ($Programs.Count -eq 0)
{
   $Programs = Get-ChildItem "$PSScriptRoot\programs\*.asm" | ForEach-Object { $_.FullName }
}
foreach ($file in "K16Cpu.js", "K16Memory.js", "K16Assembler.js")
{
   if (-not (Test-Path "$EmulatorDir\$file")) { throw "Emulator not found: $EmulatorDir\$file (use -EmulatorDir)" }
}
if (-not (Test-Path "$IverilogDir\bin\iverilog.exe")) { throw "Icarus Verilog not found in $IverilogDir (use -IverilogDir)" }

$workDir = Join-Path ([IO.Path]::GetTempPath()) "K16Compare"
$failed = 0

foreach ($program in $Programs)
{
   $program = (Resolve-Path $program).Path
   $name = [IO.Path]::GetFileNameWithoutExtension($program)
   $outDir = Join-Path $workDir $name
   if (Test-Path $outDir) { Remove-Item -Recurse -Force $outDir }
   New-Item -ItemType Directory -Force $outDir | Out-Null

   # Emulator
   $emulatorStart = Get-Date
   & cscript //nologo "$PSScriptRoot\K16Emulate.js" $EmulatorDir $program $outDir
   if ($LASTEXITCODE -ne 0) { Write-Host "$name : FAILED (emulator)" -ForegroundColor Red; $failed++; continue }
   $emulatorTime = (Get-Date) - $emulatorStart

   # Hardware simulation (without the CPU trace)
   $hardwareStart = Get-Date
   Push-Location $outDir
   try
   {
      & "$IverilogDir\bin\iverilog.exe" "-B$IverilogDir\lib\ivl" -DK16_NO_TRACE -I $repoDir -I $outDir -o sim.vvp "$PSScriptRoot\K16Compare_tb.v" 2> iverilog.log
      if ($LASTEXITCODE -ne 0) { Get-Content iverilog.log | Select-Object -First 10; throw "iverilog failed" }
      & "$IverilogDir\bin\vvp.exe" "-M$IverilogDir\lib\ivl" sim.vvp 2> vvp.log | Out-Null
   }
   catch
   {
      Write-Host "$name : FAILED ($($_.Exception.Message))" -ForegroundColor Red; $failed++; Pop-Location; continue
   }
   Pop-Location
   $hardwareTime = (Get-Date) - $hardwareStart
   if (-not (Test-Path "$outDir\hardware.txt"))
   {
      Write-Host "$name : FAILED (hardware simulation: $(Get-Content "$outDir\vvp.log" | Select-Object -Last 1))" -ForegroundColor Red; $failed++; continue
   }

   # Compare
   $emulator = Get-Content "$outDir\emulator.txt"
   $hardware = Get-Content "$outDir\hardware.txt"
   $differences = @()
   for ($i = 0; $i -lt [math]::Max($emulator.Count, $hardware.Count); $i++)
   {
      if ($emulator[$i] -ne $hardware[$i]) { $differences += "    emulator: $($emulator[$i])    hardware: $($hardware[$i])" }
   }
   $times = "emulator {0:N1} s, hardware {1:N1} s" -f $emulatorTime.TotalSeconds, $hardwareTime.TotalSeconds
   if ($differences.Count -eq 0)
   {
      Write-Host "$name : passed ($($emulator.Count) values identical; $times)" -ForegroundColor Green
   }
   else
   {
      Write-Host "$name : FAILED ($($differences.Count) differences; $times)" -ForegroundColor Red
      $differences | Select-Object -First 20 | ForEach-Object { Write-Host $_ }
      $failed++
   }
}

Write-Host ""
if ($failed -eq 0) { Write-Host "All $($Programs.Count) programs passed." -ForegroundColor Green; exit 0 }
Write-Host "$failed of $($Programs.Count) programs failed. Files are in $workDir" -ForegroundColor Red
exit 1
