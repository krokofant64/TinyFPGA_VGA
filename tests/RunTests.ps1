<#
.SYNOPSIS
Runs all Verilog testbenches of the K16 computer.

.DESCRIPTION
Compiles and runs every testbench (tests\*_tb.v, K16Computer_tb.v, and
K16Cpu_tb.v) with Icarus Verilog from the apio packages, without the CPU
trace, and reports which passed.

With -Emulator, CompareWithEmulator.ps1 also runs (it needs the
JavaScript emulator, see there).

.EXAMPLE
.\tests\RunTests.ps1
.\tests\RunTests.ps1 -Filter Alu
.\tests\RunTests.ps1 -Emulator
#>
param(
   [string] $Filter = "",
   [switch] $Emulator,
   [string] $IverilogDir = "$env:USERPROFILE\.apio\packages\toolchain-iverilog"
)

# Not "Stop": in Windows PowerShell, stderr output of the native tools
# would then end the script. Errors are checked explicitly.
$ErrorActionPreference = "Continue"
$repoDir = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path "$IverilogDir\bin\iverilog.exe")) { throw "Icarus Verilog not found in $IverilogDir (use -IverilogDir)" }

# K16Compare_tb.v needs a program from CompareWithEmulator.ps1
$testbenches = @(Get-ChildItem "$PSScriptRoot\*_tb.v" | Where-Object { $_.Name -ne "K16Compare_tb.v" }) +
               @(Get-Item "$repoDir\K16Computer_tb.v", "$repoDir\K16Cpu_tb.v")
$testbenches = $testbenches | Where-Object { $_.Name -like "*$Filter*" }

$workDir = Join-Path ([IO.Path]::GetTempPath()) "K16Tests"
$failed = 0

# Runs a tool with stdout and stderr in files; returns the exit code
function Invoke-Tool([string] $Exe, [string[]] $Arguments, [string] $StdOut, [string] $StdErr)
{
   $quoted = $Arguments | ForEach-Object { if ($_ -match '\s') { "`"$_`"" } else { $_ } }
   $process = Start-Process -FilePath $Exe -ArgumentList $quoted -NoNewWindow -Wait -PassThru `
                            -RedirectStandardOutput $StdOut -RedirectStandardError $StdErr
   return $process.ExitCode
}

foreach ($testbench in $testbenches)
{
   $name = $testbench.BaseName
   $outDir = Join-Path $workDir $name
   if (Test-Path $outDir) { Remove-Item -Recurse -Force $outDir }
   New-Item -ItemType Directory -Force $outDir | Out-Null
   Push-Location $outDir
   $start = Get-Date

   $exitCode = Invoke-Tool "$IverilogDir\bin\iverilog.exe" @("-B$IverilogDir\lib\ivl", "-DK16_NO_TRACE", "-I", $repoDir, "-I", $PSScriptRoot, "-o", "sim.vvp", $testbench.FullName) `
                           "$outDir\compile_out.log" "$outDir\compile.log"
   if ($exitCode -ne 0)
   {
      Pop-Location
      Write-Host ("{0,-22} FAILED to compile" -f $name) -ForegroundColor Red
      Get-Content "$outDir\compile.log" | Select-Object -First 10 | ForEach-Object { Write-Host "    $_" }
      $failed++
      continue
   }
   $null = Invoke-Tool "$IverilogDir\bin\vvp.exe" @("-M$IverilogDir\lib\ivl", "sim.vvp") "$outDir\output.log" "$outDir\result.log"
   Pop-Location

   $seconds = ((Get-Date) - $start).TotalSeconds
   $result = @(Get-Content "$outDir\result.log") + @(Get-Content "$outDir\output.log" | Select-Object -Last 5)
   $summary = $result | Where-Object { $_ -match "^(PASS|FAIL)" } | Select-Object -Last 1
   # The older K16Cpu_tb.v reports "All tests passed!" or "ERROR: ..."
   if (-not $summary)
   {
      if ($result -match "All tests passed!") { $summary = "PASS" }
      elseif ($result -match "ERROR") { $summary = "FAIL: " + ($result -match "ERROR" | Select-Object -First 1) }
      else { $summary = "FAIL: no result (timeout or crash)" }
   }
   if ($summary -like "PASS*")
   {
      Write-Host ("{0,-22} {1}  ({2:N1} s)" -f $name, $summary, $seconds) -ForegroundColor Green
   }
   else
   {
      Write-Host ("{0,-22} {1}  ({2:N1} s)" -f $name, $summary, $seconds) -ForegroundColor Red
      Get-Content "$outDir\result.log" | Where-Object { $_ -match "failed|FAIL|ERROR|^\S" } | Select-Object -First 30 | ForEach-Object { Write-Host "    $_" }
      $failed++
   }
}

if ($Emulator)
{
   Write-Host ""
   Write-Host "Comparison with the emulator:"
   & "$PSScriptRoot\CompareWithEmulator.ps1"
   if ($LASTEXITCODE -ne 0) { $failed++ }
}

Write-Host ""
if ($failed -eq 0) { Write-Host "All tests passed." -ForegroundColor Green; exit 0 }
Write-Host "$failed failed. Logs are in $workDir" -ForegroundColor Red
exit 1
