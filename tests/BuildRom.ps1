<#
.SYNOPSIS
Builds the ROM library: K16Rom.asm of the emulator into K16Rom.v and K16RomImage.js.

.DESCRIPTION
K16Rom.asm in the emulator folder is the source of the ROM. It is assembled
with the emulator's assembler (Windows Script Host). K16Rom.v is written to
this repository, K16RomImage.js to the emulator folder.

With -Check nothing is written: the script fails if the two files are not
up to date. RunTests.ps1 uses that.

.EXAMPLE
.\tests\BuildRom.ps1
.\tests\BuildRom.ps1 -Check
#>
param(
   [string] $EmulatorDir = "G:\usbwebserver\root\code\K16",
   [switch] $Check
)

$ErrorActionPreference = "Continue"
$repoDir = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path "$EmulatorDir\K16Rom.asm")) { throw "K16Rom.asm not found in $EmulatorDir (use -EmulatorDir)" }

$workDir = Join-Path ([IO.Path]::GetTempPath()) "K16BuildRom"
if (Test-Path $workDir) { Remove-Item -Recurse -Force $workDir }
New-Item -ItemType Directory -Force $workDir | Out-Null

& cscript //nologo "$PSScriptRoot\K16BuildRom.js" $EmulatorDir $workDir
# A script error in Windows Script Host does not set the exit code
if ($LASTEXITCODE -ne 0 -or -not (Test-Path "$workDir\K16RomImage.js")) { Write-Host "BuildRom: FAILED" -ForegroundColor Red; exit 1 }

$targets = @{ "K16Rom.v" = $repoDir; "K16RomImage.js" = $EmulatorDir }
if ($Check)
{
   $outdated = @()
   foreach ($name in $targets.Keys)
   {
      $target = Join-Path $targets[$name] $name
      if (-not (Test-Path $target) -or (Get-FileHash $target).Hash -ne (Get-FileHash "$workDir\$name").Hash) { $outdated += $name }
   }
   if ($outdated.Count -gt 0)
   {
      Write-Host "Out of date: $($outdated -join ', '). Run tests\BuildRom.ps1." -ForegroundColor Red
      exit 1
   }
   exit 0
}

foreach ($name in $targets.Keys)
{
   Copy-Item "$workDir\$name" (Join-Path $targets[$name] $name) -Force
}
Write-Host "Wrote K16Rom.v and K16RomImage.js" -ForegroundColor Green
