<#
.SYNOPSIS
Builds the start screen of the K16 from the two krokofant images of the website.

.DESCRIPTION
The images are reduced to tiles of 8 x 8 points with 2 colors each. The tiles
become the changeable characters 128 .. 255, and a frame of fixed characters
goes around them. Gray becomes white, as the K16 has no gray.

Writes:
  K16BootFrame.vh and K16BootChars.vh  in this repository, for K16Ram.v
  K16BootScreen.js                     in the emulator folder, for K16Video.js
  a preview, if -Preview gives a file name for it

With -Check nothing is written: the script fails if the files are not up to
date. RunTests.ps1 uses that.

.EXAMPLE
.\tests\BuildBootScreen.ps1 -Preview C:\Temp\boot.png
.\tests\BuildBootScreen.ps1 -Check
#>
param(
   [string] $ImagesDir = "G:\usbwebserver\root\images",
   [string] $EmulatorDir = "G:\usbwebserver\root\code\K16",
   [string] $Preview = "",
   [switch] $Check
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$repoDir = Split-Path -Parent $PSScriptRoot

$Black = 0; $Green = 2; $Red = 4; $White = 7
$FrameColor = $Green
$LineColor = $White
$Columns = 40
$Rows = 30
$TilesAvailable = 128
$WordmarkWidth = 16  # In tiles
$WordmarkHeight = 2

# ----------------------------------------------------------------------------
# Reads an image as a color class per source pixel, without the empty border.
# Returns width, height, and the pixels. -1 is the background.
function Read-Image([string] $Path, [scriptblock] $Classify)
{
   $bitmap = New-Object System.Drawing.Bitmap $Path
   $width = $bitmap.Width
   $height = $bitmap.Height
   $classes = New-Object 'int[]' ($width * $height)
   for ($y = 0; $y -lt $height; $y++)
   {
      for ($x = 0; $x -lt $width; $x++)
      {
         $color = $bitmap.GetPixel($x, $y)
         $classes[$y * $width + $x] = & $Classify $color.A $color.R $color.G $color.B
      }
   }
   $bitmap.Dispose()
   return @{ Width = $width; Height = $height; Classes = $classes }
}

# Near-white pixels connected to the edge of the image are background; the
# others (the tusk) stay white.
function Remove-OuterWhite($Image)
{
   $width = $Image.Width
   $height = $Image.Height
   $classes = $Image.Classes
   $stack = New-Object System.Collections.Generic.Stack[int]
   for ($x = 0; $x -lt $width; $x++) { $stack.Push($x); $stack.Push(($height - 1) * $width + $x) }
   for ($y = 0; $y -lt $height; $y++) { $stack.Push($y * $width); $stack.Push($y * $width + $width - 1) }
   while ($stack.Count -gt 0)
   {
      $p = $stack.Pop()
      if ($classes[$p] -ne -2) { continue }
      $classes[$p] = -1
      if ($p % $width -ne 0) { $stack.Push($p - 1) }
      if ($p % $width -ne $width - 1) { $stack.Push($p + 1) }
      if ($p -ge $width) { $stack.Push($p - $width) }
      if ($p -lt ($height - 1) * $width) { $stack.Push($p + $width) }
   }
   for ($p = 0; $p -lt $classes.Length; $p++)
   {
      if ($classes[$p] -eq -2) { $classes[$p] = $White }
   }
}

# The rectangle around everything that is not background
function Get-Bounds($Image)
{
   $left = $Image.Width; $right = -1; $top = $Image.Height; $bottom = -1
   for ($y = 0; $y -lt $Image.Height; $y++)
   {
      for ($x = 0; $x -lt $Image.Width; $x++)
      {
         if ($Image.Classes[$y * $Image.Width + $x] -ne -1)
         {
            if ($x -lt $left) { $left = $x }
            if ($x -gt $right) { $right = $x }
            if ($y -lt $top) { $top = $y }
            if ($y -gt $bottom) { $bottom = $y }
         }
      }
   }
   return @{ Left = $left; Top = $top; Width = $right - $left + 1; Height = $bottom - $top + 1 }
}

# Reduces the image to Width x Height points: each point gets the color that
# has most pixels. Outlines and the dot of the wordmark are thin, so black inside
# the figure can count more, and the background less.
function Get-Points($Image, $Bounds, [int] $Width, [int] $Height, [double] $BlackWeight, [double] $BackgroundWeight)
{
   $points = New-Object 'int[]' ($Width * $Height)
   $counts = New-Object 'double[]' 9
   for ($py = 0; $py -lt $Height; $py++)
   {
      $y0 = $Bounds.Top + [math]::Floor($py * $Bounds.Height / $Height)
      $y1 = $Bounds.Top + [math]::Floor(($py + 1) * $Bounds.Height / $Height)
      for ($px = 0; $px -lt $Width; $px++)
      {
         $x0 = $Bounds.Left + [math]::Floor($px * $Bounds.Width / $Width)
         $x1 = $Bounds.Left + [math]::Floor(($px + 1) * $Bounds.Width / $Width)
         [Array]::Clear($counts, 0, 9)
         for ($y = $y0; $y -lt $y1; $y++)
         {
            $line = $y * $Image.Width
            for ($x = $x0; $x -lt $x1; $x++)
            {
               $class = $Image.Classes[$line + $x]
               if ($class -eq -1) { $counts[8] += $BackgroundWeight }
               elseif ($class -eq $Black) { $counts[$Black] += $BlackWeight }
               else { $counts[$class] += 1 }
            }
         }
         $best = 8
         for ($c = 0; $c -lt 8; $c++)
         {
            if ($counts[$c] -gt $counts[$best]) { $best = $c }
         }
         $points[$py * $Width + $px] = $(if ($best -eq 8) { $Black } else { $best })
      }
   }
   return ,$points
}

# ----------------------------------------------------------------------------
# Tiles: a list of the patterns of the changeable characters, and a word of the
# frame buffer per screen cell.
# Returns the words of a picture of TileWidth x TileHeight tiles. Each tile has
# its 2 most frequent colors; other points get the nearer of them by count.
function Add-Tiles($Points, [int] $TileWidth, [int] $TileHeight, $Tiles)
{
   $words = New-Object 'int[]' ($TileWidth * $TileHeight)
   for ($ty = 0; $ty -lt $TileHeight; $ty++)
   {
      for ($tx = 0; $tx -lt $TileWidth; $tx++)
      {
         $counts = New-Object 'int[]' 8
         for ($y = 0; $y -lt 8; $y++)
         {
            for ($x = 0; $x -lt 8; $x++)
            {
               $counts[$Points[($ty * 8 + $y) * $TileWidth * 8 + $tx * 8 + $x]]++
            }
         }
         # Two most frequent colors; black is preferred if it is a tie
         $first = 0
         for ($c = 1; $c -lt 8; $c++) { if ($counts[$c] -gt $counts[$first]) { $first = $c } }
         $second = -1
         for ($c = 0; $c -lt 8; $c++)
         {
            if ($c -ne $first -and $counts[$c] -gt 0 -and ($second -lt 0 -or $counts[$c] -gt $counts[$second])) { $second = $c }
         }
         if ($second -lt 0)
         {
            # One color: a space with that background
            $words[$ty * $TileWidth + $tx] = ($first -shl 11) -bor 32
            continue
         }
         # The first point of a tile is background, so that inverted tiles are the same character
         $firstPoint = $Points[$ty * 8 * $TileWidth * 8 + $tx * 8]
         $background = $(if ($firstPoint -eq $second) { $second } else { $first })
         $foreground = $(if ($background -eq $first) { $second } else { $first })
         $lines = New-Object 'int[]' 8
         for ($y = 0; $y -lt 8; $y++)
         {
            for ($x = 0; $x -lt 8; $x++)
            {
               if ($Points[($ty * 8 + $y) * $TileWidth * 8 + $tx * 8 + $x] -eq $foreground)
               {
                  $lines[$y] = $lines[$y] -bor (1 -shl $x) # Bit 0 is the leftmost point
               }
            }
         }
         $key = $lines -join ","
         if (-not $Tiles.Contains($key)) { [void] $Tiles.Add($key, $lines) }
         $code = 128 + (Get-TileIndex $Tiles $key)
         $words[$ty * $TileWidth + $tx] = ($background -shl 11) -bor ($foreground -shl 8) -bor $code
      }
   }
   return ,$words
}

function Get-TileIndex($Tiles, [string] $Key)
{
   $i = 0
   foreach ($entry in $Tiles.Keys)
   {
      if ($entry -eq $Key) { return $i }
      $i++
   }
   throw "Tile not found"
}

# ----------------------------------------------------------------------------
# The images

$mascot = Read-Image "$ImagesDir\krokofant2.png" {
   param($a, $r, $g, $b)
   if ($a -lt 128) { return -1 }
   if ($r -gt 215 -and $g -gt 215 -and $b -gt 215) { return -2 } # White: background or tusk
   if ($g -gt $r + 30 -and $g -gt $b + 30) { return 2 }          # Green
   if ($r -gt $g + 40) { return 4 }                              # The tongue
   if ($r -lt 60 -and $g -lt 60 -and $b -lt 60) { return 0 }     # Outlines
   return 7                                                      # Gray becomes white
}
Remove-OuterWhite $mascot
$mascotBounds = Get-Bounds $mascot

$wordmark = Read-Image "$ImagesDir\krokofant.png" {
   param($a, $r, $g, $b)
   if ($a -lt 128 -or ($r -gt 170 -and $g -gt 170 -and $b -gt 170)) { return -1 }
   if ($g -gt $r + 30) { return 2 }
   return 7
}
$wordmarkBounds = Get-Bounds $wordmark
$wordmarkPoints = Get-Points $wordmark $wordmarkBounds ($WordmarkWidth * 8) ($WordmarkHeight * 8) 1.0 0.6

# The largest mascot that fits in the changeable characters and in the frame
$innerRows = $Rows - 4
for ($mascotWidth = 16; $mascotWidth -ge 6; $mascotWidth--)
{
   $mascotHeight = [int][math]::Round($mascotWidth * $mascotBounds.Height / $mascotBounds.Width)
   if ($mascotHeight + 1 + $WordmarkHeight -gt $innerRows) { continue }
   $tiles = New-Object System.Collections.Specialized.OrderedDictionary
   $wordmarkWords = Add-Tiles $wordmarkPoints $WordmarkWidth $WordmarkHeight $tiles
   $mascotPoints = Get-Points $mascot $mascotBounds ($mascotWidth * 8) ($mascotHeight * 8) 1.6 1.0
   $mascotWords = Add-Tiles $mascotPoints $mascotWidth $mascotHeight $tiles
   if ($tiles.Count -le $TilesAvailable) { break }
}
if ($tiles.Count -gt $TilesAvailable) { throw "Too many tiles: $($tiles.Count)" }

# ----------------------------------------------------------------------------
# The screen

$screen = New-Object 'int[]' ($Columns * $Rows)
for ($i = 0; $i -lt $screen.Length; $i++) { $screen[$i] = ($Black -shl 11) -bor ($White -shl 8) -bor 32 }

# A band in the frame color, with a line inside it
$lineAttribute = ($Black -shl 11) -bor ($LineColor -shl 8)
for ($x = 0; $x -lt $Columns; $x++)
{
   $screen[$x] = ($FrameColor -shl 11) -bor 32
   $screen[($Rows - 1) * $Columns + $x] = ($FrameColor -shl 11) -bor 32
   if ($x -gt 1 -and $x -lt $Columns - 2)
   {
      $screen[$Columns + $x] = $lineAttribute -bor 17
      $screen[($Rows - 2) * $Columns + $x] = $lineAttribute -bor 17
   }
}
for ($y = 0; $y -lt $Rows; $y++)
{
   $screen[$y * $Columns] = ($FrameColor -shl 11) -bor 32
   $screen[$y * $Columns + $Columns - 1] = ($FrameColor -shl 11) -bor 32
   if ($y -gt 1 -and $y -lt $Rows - 2)
   {
      $screen[$y * $Columns + 1] = $lineAttribute -bor 16
      $screen[$y * $Columns + $Columns - 2] = $lineAttribute -bor 16
   }
}
$screen[$Columns + 1] = $lineAttribute -bor 24                                # Top left
$screen[$Columns + $Columns - 2] = $lineAttribute -bor 26                     # Top right
$screen[($Rows - 2) * $Columns + 1] = $lineAttribute -bor 23                  # Bottom left
$screen[($Rows - 2) * $Columns + $Columns - 2] = $lineAttribute -bor 25       # Bottom right

# The pictures in the middle
$total = $mascotHeight + 1 + $WordmarkHeight
$top = [int][math]::Floor(($Rows - $total) / 2)
$left = [int][math]::Floor(($Columns - $mascotWidth) / 2)
for ($y = 0; $y -lt $mascotHeight; $y++)
{
   for ($x = 0; $x -lt $mascotWidth; $x++)
   {
      $screen[($top + $y) * $Columns + $left + $x] = $mascotWords[$y * $mascotWidth + $x]
   }
}
$top += $mascotHeight + 1
$left = [int][math]::Floor(($Columns - $WordmarkWidth) / 2)
for ($y = 0; $y -lt $WordmarkHeight; $y++)
{
   for ($x = 0; $x -lt $WordmarkWidth; $x++)
   {
      $screen[($top + $y) * $Columns + $left + $x] = $wordmarkWords[$y * $WordmarkWidth + $x]
   }
}

# The words of the changeable characters
$characters = New-Object 'int[]' 512
$index = 0
foreach ($lines in $tiles.Values)
{
   for ($k = 0; $k -lt 4; $k++)
   {
      $characters[$index * 4 + $k] = $lines[2 * $k] -bor ($lines[2 * $k + 1] -shl 8)
   }
   $index++
}
Write-Host ("Mascot {0} x {1} tiles, {2} of {3} changeable characters used" -f $mascotWidth, $mascotHeight, $tiles.Count, $TilesAvailable)

# ----------------------------------------------------------------------------
# Files

function Format-Verilog([int[]] $Words, [int] $Size)
{
   $lines = @("// Generated by tests\BuildBootScreen.ps1. Do not edit.")
   for ($i = 0; $i -lt $Size; $i++)
   {
      $word = $(if ($i -lt $Words.Length) { $Words[$i] } else { 0 })
      $lines += ("      mem[{0}] = 16'h{1:x4};" -f $i, $word)
   }
   return ($lines -join "`r`n") + "`r`n"
}

function Format-Script([string] $Name, [int[]] $Words)
{
   $lines = @()
   for ($i = 0; $i -lt $Words.Length; $i += 16)
   {
      $end = [math]::Min($i + 16, $Words.Length) - 1
      $lines += "   " + (($Words[$i..$end] | ForEach-Object { "0x{0:X4}" -f $_ }) -join ", ")
   }
   return "var $Name =`r`n[`r`n" + ($lines -join ",`r`n") + "`r`n];`r`n"
}

$files = @{
   (Join-Path $repoDir "K16BootFrame.vh") = Format-Verilog $screen 2048
   (Join-Path $repoDir "K16BootChars.vh") = Format-Verilog $characters 512
   (Join-Path $EmulatorDir "K16BootScreen.js") = "// Generated by tests\BuildBootScreen.ps1 in the K16 Verilog repository. Do not edit.`r`n`r`n" +
                                                 (Format-Script "K16BootFrameBuffer" $screen) + "`r`n" + (Format-Script "K16BootCharacters" $characters)
}

if ($Check)
{
   $outdated = @()
   foreach ($path in $files.Keys)
   {
      if (-not (Test-Path $path) -or [IO.File]::ReadAllText($path) -cne $files[$path]) { $outdated += Split-Path -Leaf $path }
   }
   if ($outdated.Count -gt 0)
   {
      Write-Host "Out of date: $($outdated -join ', '). Run tests\BuildBootScreen.ps1." -ForegroundColor Red
      exit 1
   }
   exit 0
}

foreach ($path in $files.Keys)
{
   [IO.File]::WriteAllText($path, $files[$path], (New-Object Text.ASCIIEncoding))
}

# ----------------------------------------------------------------------------
# Preview, from the same words that the video reads

if ($Preview -ne "")
{
   $fixed = @{}
   foreach ($match in [regex]::Matches((Get-Content "$EmulatorDir\K16Video.js" -Raw), 'charRom\[(\d+)\] = \[([^\]]*)\]'))
   {
      $fixed[[int] $match.Groups[1].Value] = @($match.Groups[2].Value -split "," | ForEach-Object { [Convert]::ToInt32($_.Trim().Substring(2), 16) })
   }
   # Color bits: 4 = red, 2 = green, 1 = blue
   $brushes = 0..7 | ForEach-Object { New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255 * (($_ -shr 2) -band 1), 255 * (($_ -shr 1) -band 1), 255 * ($_ -band 1))) }
   $bitmap = New-Object System.Drawing.Bitmap 640, 480
   $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
   for ($row = 0; $row -lt $Rows; $row++)
   {
      for ($column = 0; $column -lt $Columns; $column++)
      {
         $word = $screen[$row * $Columns + $column]
         $code = $word -band 0xFF
         $foreground = $brushes[($word -shr 8) -band 7]
         $background = $brushes[($word -shr 11) -band 7]
         $graphics.FillRectangle($background, $column * 16, $row * 16, 16, 16)
         for ($y = 0; $y -lt 8; $y++)
         {
            if ($code -ge 128)
            {
               $data = $characters[($code - 128) * 4 + ($y -shr 1)]
               $bits = $(if ($y -band 1) { $data -shr 8 } else { $data -band 0xFF })
            }
            else
            {
               $bits = $fixed[$code][$y]
            }
            for ($x = 0; $x -lt 8; $x++)
            {
               if ($bits -band (1 -shl $x))
               {
                  $graphics.FillRectangle($foreground, $column * 16 + $x * 2, $row * 16 + $y * 2, 2, 2)
               }
            }
         }
      }
   }
   $graphics.Dispose()
   $bitmap.Save($Preview, [System.Drawing.Imaging.ImageFormat]::Png)
   $bitmap.Dispose()
   Write-Host "Preview: $Preview"
}
Write-Host "Wrote the start screen" -ForegroundColor Green
