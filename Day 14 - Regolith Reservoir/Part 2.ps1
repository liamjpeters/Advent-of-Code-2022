# You realize you misread the scan. There isn't an endless void at the bottom of the scan - there's 
# floor, and you're standing on it!

# You don't have time to scan the floor, so assume the floor is an infinite horizontal line with a y
# coordinate equal to two plus the highest y coordinate of any point in your scan.

# In the example above, the highest y coordinate of any point is 9, and so the floor is at y=11. 
# (This is as if your scan contained one extra rock path like -infinity,11 -> infinity,11.) With the
# added floor, the example above now looks like this:

#         ...........+........
#         ....................
#         ....................
#         ....................
#         .........#...##.....
#         .........#...#......
#         .......###...#......
#         .............#......
#         .............#......
#         .....#########......
#         ....................
# <-- etc #################### etc -->

# To find somewhere safe to stand, you'll need to simulate falling sand until a unit of sand comes 
# to rest at 500,0, blocking the source entirely and stopping the flow of sand into the cave. 
# In the example above, the situation finally looks like this after 93 units of sand come to rest:

# ............o............
# ...........ooo...........
# ..........ooooo..........
# .........ooooooo.........
# ........oo#ooo##o........
# .......ooo#ooo#ooo.......
# ......oo###ooo#oooo......
# .....oooo.oooo#ooooo.....
# ....oooooooooo#oooooo....
# ...ooo#########ooooooo...
# ..ooooo.......ooooooooo..
# #########################

# Using your scan, simulate the falling sand until the source of the sand becomes blocked. 
# How many units of sand come to rest?


[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

class Point {

    [int32] $X
    [int32] $Y

    Point([int32] $X, [int32] $Y) {
        $this.X = $X
        $this.Y = $Y
    }

    [String] ToString() {
        return "($($this.X),$($this.Y))"
    }

    [Point] Copy() {
        return [Point]::new($this.X, $this.Y)
    }

    [bool] Equal ([Point] $OtherPoint) {
        return $this.Point.X -eq $OtherPoint.X -and $this.Point.Y -eq $OtherPoint.Y
    }

}

class Line {

    [Point] $StartingPoint
    [Point] $EndingPoint

    Static [Line[]] ParseFromString([string] $InputString) {
        # '432,82 -> 450,82 -> 450,81'
        $RetLines =@()
        $SplitOnArrowSpace = $InputString.Split(' -> ')
        for ($i = 0; $i -lt $SplitOnArrowSpace.Count - 1; $i++) {
            $Point1 = $SplitOnArrowSpace[$i].Split(',')
            $Point2 = $SplitOnArrowSpace[$i + 1].Split(',')
            $RetLines += [Line]::new(
                $Point1[0] -as [int32],
                $Point1[1] -as [int32],
                $Point2[0] -as [int32],
                $Point2[1] -as [int32]
            )
        }
        return $RetLines
    }

    Line([int32] $X1, [int32] $Y1, [int32] $X2, [int32] $Y2) {
        $this.StartingPoint = [Point]::new($X1,$Y1)
        $this.EndingPoint = [Point]::new($X2,$Y2)
    }

    [Point[]] GetAllPointsOnLine() {
        $RetPoints = @()
        if ($this.StartingPoint.X -eq $this.EndingPoint.X) {
            # Horizontal
            foreach($Y in $($this.StartingPoint.Y)..$($this.EndingPoint.Y)) {
                $RetPoints += [Point]::new($this.StartingPoint.X, $Y)
            }
        } elseif ($this.StartingPoint.Y -eq $this.EndingPoint.Y) {
            # Vertical
            foreach($X in $($this.StartingPoint.X)..$($this.EndingPoint.X)) {
                $RetPoints += [Point]::new($X, $this.StartingPoint.Y)
            }
        } else {
            throw "Line doesn't seem to be horizontal or vertical"
        }
        return $RetPoints
    }

}

class Screen {

    hidden [hashtable] $Values = @{
        'Background' = 0
        'Wall' = 1
        'Sand' = 2
        'SandEmit' = 3
    }

    hidden [hashtable] $ValuesToColorMap = @{
        0 = [System.Drawing.Color]::White
        1 = [System.Drawing.Color]::Black
        2 = [System.Drawing.Color]::SandyBrown
        3 = [System.Drawing.Color]::Purple
    }

    hidden [int32] $Width = 0
    hidden [int32] $Height = 0
    hidden [System.Collections.ArrayList] $Screen

    Screen([int32] $Width, [int32] $Height) {
        $this.Width = $Width
        $this.Height = $Height
        $this.Screen = [System.Collections.ArrayList]::new($Height)
        for ($i = 0; $i -lt $Height; $i++) {
            # Creates an array of zeros
            $this.Screen.Insert($i,[Array]::CreateInstance([int32],$Width))
        }
    }

    [int32] Get([int32] $X, [int32] $Y) {
        return $this.Screen[$Y][$X]
    }

    [void] Set([int32] $X, [int32] $Y, [int32] $Value) {
        $this.Screen[$Y][$X] = $Value
    }
 
    [bool] IsPointOutOfBounds ([int32] $X, [int32] $Y) {
        return $X -lt 0 -or $X -ge $this.Width -or $Y -lt 0 -or $Y -ge $this.Height
    }
    [bool] IsPointOutOfBounds ([Point] $Point) {
        return $this.IsPointOutOfBounds($Point.X, $Point.Y)
    }
    
    [bool] IsPointSolid ([int32] $X, [int32] $Y) {
        if ($X -lt 0 -or $Y -lt 0 -or $X -ge $this.Width -or $Y -ge $this.Height) {
            return $false
        }
        return $this.Get($X,$Y) -gt 0
    }
    [bool] IsPointSolid ([Point] $Point) {
        return $this.IsPointSolid($Point.X,$Point.Y)
    }

    [void] DrawLine([Line] $Line) {
        $Points = $Line.GetAllPointsOnLine()
        foreach ($Point in $Points) {
            $this.Set($Point.X, $Point.Y, $this.Values['Wall'])
        }
    }
    [void] DrawLines([Line[]] $Lines) {
        foreach ($Line in $Lines) {
            $this.DrawLine($Line)
        }
    }

    [void] SetSandPoint([Point] $Point) {
        $this.Set($Point.X, $Point.Y, $this.Values['Sand'])
    }

    [void] SetSandEmissionPoint([Point] $Point) {
        $this.Set($Point.X, $Point.Y, $this.Values['SandEmit'])
    }

    [void] DumpToBitmap([string] $FileName) {
        $Bitmap = New-Object System.Drawing.Bitmap($this.Width, $this.Height)

        for ($y = 0; $y -lt $this.Height; $y++) {
            for ($x = 0; $x -lt $this.Width; $x++) {
                $Bitmap.SetPixel($x, $y, $this.ValuesToColorMap[$this.Get($x,$y)])
            }
        }
        
        $Bitmap.Save("$PSScriptRoot\$FileName.bmp")
    }

}

class Simulator {

    hidden [Screen] $Screen

    hidden [Line[]] $Lines = @()
    hidden [int32] $Width = 0
    hidden [int32] $Height = 0

    hidden [Point] $SandEmissionPoint = [Point]::new(500,0)

    Simulator() {}

    [void] IngestScanData([string[]]$ScanData) {
        foreach ($ScanLine in $ScanData) {
            $this.Lines += [Line]::ParseFromString($ScanLine)
        }
        $XUpperBound = [int32]::MinValue
        $XLowerBound = [int32]::MaxValue
        $YUpperBound = [int32]::MinValue
        $YLowerBound = [int32]::MaxValue
        foreach ($Line in $this.Lines) {
            $XUpperBound = [Math]::Max(
                $XUpperBound,
                [Math]::Max(
                    $Line.StartingPoint.X,
                    $Line.EndingPoint.X
                )
            )
            $XLowerBound = [Math]::Min(
                $XLowerBound,
                [Math]::Min(
                    $Line.StartingPoint.X,
                    $Line.EndingPoint.X
                )
            )
            $YUpperBound = [Math]::Max(
                $YUpperBound,
                [Math]::Max(
                    $Line.StartingPoint.Y,
                    $Line.EndingPoint.Y
                )
            )
            $YLowerBound = [Math]::Min(
                $YLowerBound,
                [Math]::Min(
                    $Line.StartingPoint.Y,
                    $Line.EndingPoint.Y
                )
            )
        }
        $XUpperBound = [Math]::Max($XUpperBound,$this.SandEmissionPoint.X)
        $XLowerBound = [Math]::Min($XLowerBound,$this.SandEmissionPoint.X)
        # Add 2 to account for the floor
        $YUpperBound = [Math]::Max($YUpperBound,$this.SandEmissionPoint.Y) + 2
        $YLowerBound = [Math]::Min($YLowerBound,$this.SandEmissionPoint.Y)
    
        $this.Height = $YUpperBound - $YLowerBound + 1

        # We ensure that the lower and upper x-bounds are large enough
        # that the sand could pile up to the emission point
        $XLowerBound = [Math]::Min(
            $XLowerBound,
            $this.SandEmissionPoint.X - $this.Height - 2
        )
        $XUpperBound = [Math]::Max(
            $XUpperBound,
            $this.SandEmissionPoint.X + $this.Height + 2
        )

        # Convert all points to screen-space
        foreach ($Line in $this.Lines) {
            $Line.StartingPoint.X -= $XLowerBound
            $Line.EndingPoint.X -= $XLowerBound

            $Line.StartingPoint.Y -= $YLowerBound
            $Line.EndingPoint.Y -= $YLowerBound
        }
        $this.SandEmissionPoint.X -= $XLowerBound
        $this.SandEmissionPoint.Y -= $YLowerBound

        $this.Width = $XUpperBound - $XLowerBound + 1
        
        
        $this.Screen = [Screen]::new($this.Width, $this.Height)
        $this.Screen.DrawLines($this.Lines)
        $Floor = [Line]::new(
            0, $this.Height - 1,
            $this.Width - 1, $this.Height - 1
        )
        $this.Screen.DrawLine($Floor)
        $this.Screen.SetSandEmissionPoint($this.SandEmissionPoint)
    }

    [void] DumpToBitmap([string] $FileName) {
        $this.Screen.DumpToBitmap($FileName)
    }

    [Point] DropPoint([Point] $Point) {
        $Landed = $false
        do {
            $Point.Y++
            $Landed = $this.Screen.IsPointSolid($Point)
        } while (
            -not $Landed -and
            -not $this.Screen.IsPointOutOfBounds($Point)
        )
        if ($Landed) {
            $Point.Y--
        }
        return $Point
    }

    [bool] EmitSand () {
        $SandPoint = [Point]::new($this.SandEmissionPoint.X, $this.SandEmissionPoint.Y)
        
        $Moved = $true
        do {
            $Copy = $SandPoint.Copy()
            $SandPoint = $this.DropPoint($SandPoint)
            # if ($this.Screen.IsPointOutOfBounds($SandPoint)) {
            #     return $false
            # }
            if ((-not $this.Screen.IsPointSolid($SandPoint.X - 1, $SandPoint.Y + 1))) {
                $SandPoint.X -= 1
                $SandPoint.Y++
            } elseif ((-not $this.Screen.IsPointSolid($SandPoint.X + 1, $SandPoint.Y + 1))) {
                $SandPoint.X += 1
                $SandPoint.Y++
            }
            if (($SandPoint.X -eq $this.SandEmissionPoint.X -and $SandPoint.Y -eq $this.SandEmissionPoint.Y)) {
                $this.Screen.SetSandPoint($Copy)
                return $false
            }
            # if ($this.Screen.IsPointOutOfBounds($SandPoint)) {
            #     return $false
            # }
            $Moved = -not ($Copy.X -eq $SandPoint.X -and $Copy.Y -eq $SandPoint.Y)
        } while (
            $Moved
        )
        $this.Screen.SetSandPoint($SandPoint)
        return $true
        # Apply rules
        # A unit of sand always falls down one step if possible. If the tile immediately below is blocked 
        # (by rock or sand), the unit of sand attempts to instead move diagonally one step down and to the 
        # left. If that tile is blocked, the unit of sand attempts to instead move diagonally one step down 
        # and to the right. Sand keeps moving as long as it is able to do so, at each step trying to move 
        # down, then down-left, then down-right. If all three possible destinations are blocked, the unit of
        # sand comes to rest and no longer moves, at which point the next unit of sand is created back at 
        # the source.
    }
}

$ScanData = . "$PSScriptRoot\Inputs.ps1"

# Sample Data
# $ScanData = @(
#     '498,4 -> 498,6 -> 496,6'
#     '503,4 -> 502,4 -> 502,9 -> 494,9'
# )

$Sim = [Simulator]::new()
$Sim.IngestScanData($ScanData)
$Sim.DumpToBitmap('Part2Start')
$Iteration = 0
do {
    $EmitterNotBlocked = $Sim.EmitSand()
    $Iteration++
    Write-Progress -Activity 'Simulating' -Status "Iteration $Iteration"
} while ($EmitterNotBlocked)

Write-Progress -Activity 'Simulating' -Completed
Write-Host "'$($Iteration)' units of sand come to rest before sand blocks the emitter"

$Sim.DumpToBitmap('Part2End')
