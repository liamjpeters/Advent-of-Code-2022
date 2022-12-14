# The distress signal leads you to a giant waterfall! Actually, hang on - the signal seems like it's
# coming from the waterfall itself, and that doesn't make any sense. However, you do notice a little
# path that leads behind the waterfall.

# Correction: the distress signal leads you behind a giant waterfall! There seems to be a large cave
# system here, and the signal definitely leads further inside.

# As you begin to make your way deeper underground, you feel the ground rumble for a moment. Sand 
# begins pouring into the cave! If you don't quickly figure out where the sand is going, you could 
# quickly become trapped!

# Fortunately, your familiarity with analyzing the path of falling material will come in handy here.
# You scan a two-dimensional vertical slice of the cave above you (your puzzle input) and discover 
# that it is mostly air with structures made of rock.

# Your scan traces the path of each solid rock structure and reports the x,y coordinates that form 
# the shape of the path, where x represents distance to the right and y represents distance down. 
# Each path appears as a single line of text in your scan. After the first point of each path, each 
# point indicates the end of a straight horizontal or vertical line to be drawn from the previous point. For example:

# 498,4 -> 498,6 -> 496,6
# 503,4 -> 502,4 -> 502,9 -> 494,9

# This scan means that there are two paths of rock; the first path consists of two straight lines, 
# and the second path consists of three straight lines. (Specifically, the first path consists of a 
# line of rock from 498,4 through 498,6 and another line of rock from 498,6 through 496,6.)

# The sand is pouring into the cave from point 500,0.

# Drawing rock as #, air as ., and the source of the sand as +, this becomes:

#   4     5  5
#   9     0  0
#   4     0  3
# 0 ......+...
# 1 ..........
# 2 ..........
# 3 ..........
# 4 ....#...##
# 5 ....#...#.
# 6 ..###...#.
# 7 ........#.
# 8 ........#.
# 9 #########.

# Sand is produced one unit at a time, and the next unit of sand is not produced until the previous 
# unit of sand comes to rest. A unit of sand is large enough to fill one tile of air in your scan.

# A unit of sand always falls down one step if possible. If the tile immediately below is blocked 
# (by rock or sand), the unit of sand attempts to instead move diagonally one step down and to the 
# left. If that tile is blocked, the unit of sand attempts to instead move diagonally one step down 
# and to the right. Sand keeps moving as long as it is able to do so, at each step trying to move 
# down, then down-left, then down-right. If all three possible destinations are blocked, the unit of
# sand comes to rest and no longer moves, at which point the next unit of sand is created back at 
# the source.

# So, drawing sand that has come to rest as o, the first unit of sand simply falls straight down and
# then stops:

# ......+...
# ..........
# ..........
# ..........
# ....#...##
# ....#...#.
# ..###...#.
# ........#.
# ......o.#.
# #########.

# The second unit of sand then falls straight down, lands on the first one, and then comes to rest 
# to its left:

# ......+...
# ..........
# ..........
# ..........
# ....#...##
# ....#...#.
# ..###...#.
# ........#.
# .....oo.#.
# #########.

# After a total of five units of sand have come to rest, they form this pattern:

# ......+...
# ..........
# ..........
# ..........
# ....#...##
# ....#...#.
# ..###...#.
# ......o.#.
# ....oooo#.
# #########.

# After a total of 22 units of sand:

# ......+...
# ..........
# ......o...
# .....ooo..
# ....#ooo##
# ....#ooo#.
# ..###ooo#.
# ....oooo#.
# ...ooooo#.
# #########.

# Finally, only two more units of sand can possibly come to rest:

# ......+...
# ..........
# ......o...
# .....ooo..
# ....#ooo##
# ...o#ooo#.
# ..###ooo#.
# ....oooo#.
# .o.ooooo#.
# #########.

# Once all 24 units of sand shown above have come to rest, all further sand flows out the bottom, 
# falling into the endless void. Just for fun, the path any new sand takes before falling forever 
# is shown here with ~:

# .......+...
# .......~...
# ......~o...
# .....~ooo..
# ....~#ooo##
# ...~o#ooo#.
# ..~###ooo#.
# ..~..oooo#.
# .~o.ooooo#.
# ~#########.
# ~..........
# ~..........
# ~..........

# Using your scan, simulate the falling sand. How many units of sand come to rest before sand starts
# flowing into the abyss below?

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
        $YUpperBound = [Math]::Max($YUpperBound,$this.SandEmissionPoint.Y)
        $YLowerBound = [Math]::Min($YLowerBound,$this.SandEmissionPoint.Y)

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
        $this.Height = $YUpperBound - $YLowerBound + 1
        $this.Screen = [Screen]::new($this.Width, $this.Height)
        $this.Screen.DrawLines($this.Lines)
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
            if ($this.Screen.IsPointOutOfBounds($SandPoint)) {
                return $false
            }
            if ((-not $this.Screen.IsPointSolid($SandPoint.X - 1, $SandPoint.Y + 1))) {
                $SandPoint.X -= 1
                $SandPoint.Y++
            } elseif ((-not $this.Screen.IsPointSolid($SandPoint.X + 1, $SandPoint.Y + 1))) {
                $SandPoint.X += 1
                $SandPoint.Y++
            }
            if ($this.Screen.IsPointOutOfBounds($SandPoint)) {
                return $false
            }
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
$Sim.DumpToBitmap('MainStart')
$Iteration = 0
do {
    $InBounds = $Sim.EmitSand()
    $Iteration++
} while ($InBounds)

Write-Host "'$($Iteration - 1)' units of sand come to rest before sand starts flowing into the abyss below"

$Sim.DumpToBitmap('MainEnd')
