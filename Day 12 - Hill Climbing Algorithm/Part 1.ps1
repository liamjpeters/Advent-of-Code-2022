# You try contacting the Elves using your handheld device, but the river you're following must be 
# too low to get a decent signal.

# You ask the device for a heightmap of the surrounding area (your puzzle input). The heightmap 
# shows the local area from above broken into a grid; the elevation of each square of the grid is 
# given by a single lowercase letter, where a is the lowest elevation, b is the next-lowest, and so 
# on up to the highest elevation, z.

# Also included on the heightmap are marks for your current position (S) and the location that 
# should get the best signal (E). Your current position (S) has elevation a, and the location that 
# should get the best signal (E) has elevation z.

# You'd like to reach E, but to save energy, you should do it in as few steps as possible. During 
# each step, you can move exactly one square up, down, left, or right. To avoid needing to get out 
# your climbing gear, the elevation of the destination square can be at most one higher than the 
# elevation of your current square; that is, if your current elevation is m, you could step to 
# elevation n, but not to elevation o. (This also means that the elevation of the destination square
# can be much lower than the elevation of your current square.)

# For example:

#   Sabqponm
#   abcryxxl
#   accszExk
#   acctuvwj
#   abdefghi

# Here, you start in the top-left corner; your goal is near the middle. You could start by moving 
# down or right, but eventually you'll need to head toward the e at the bottom. From there, you can 
# spiral around to the goal:

#   v..v<<<<
#   >v.vv<<^
#   .>vv>E^^
#   ..v>>>^^
#   ..>>>>>^

# In the above diagram, the symbols indicate whether the path exits each square moving up (^), 
# down (v), left (<), or right (>). The location that should get the best signal is still E, and . 
# marks unvisited squares.

# This path reaches the goal in 31 steps, the fewest possible.

# What is the fewest steps required to move from your current position to the location that should 
# get the best signal?

function GetElevationAtPoint {
    # Returns a number from 1-26 representing the height
    # at a given point in the heightmap
    [OutputType([Int32])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string[]] $HeightMap,
        [Parameter(Mandatory, Position = 1)]
        [Int32] $XPos,
        [Parameter(Mandatory, Position = 2)]
        [Int32] $YPos
    )
    $Char = $HeightMap[$YPos][$XPos]
    if ($Char -clike 'S') {
        # Starting position has elevation 'a'
        return 1
    }
    if ($Char -clike 'E') {
        # Destination position has elevation 'z'
        return 26
    }
    ([char]$Char - [char]'a') + 1
}

function FindLetter {
    # Returns a 2-length array of x,y
    # representing the location of chosen letter
    # -1,-1 if not found
    [OutputType([Int32[]])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string[]] $HeightMap,
        [Parameter(Mandatory, Position = 1)]
        [char] $Letter
    )
    for ($Y = 0; $Y -lt $HeightMap.Count; $Y++) {
        for ($X = 0; $X -lt $HeightMap[0].Length; $X++) {
            if ($HeightMap[$Y][$X] -clike $Letter) {
                return @($X,$Y)
            }
        }
    }
    return @(-1,-1)
}

function DistanceToPoint {
    [OutputType([Double])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [Int32[]]
        $PointA,
        [Parameter(Mandatory, Position = 1)]
        [Int32[]]
        $PointB
    )

    $DiffX = [Math]::Abs($PointA[0] - $PointB[0])
    $DiffY = [Math]::Abs($PointA[1] - $PointB[1])
    return [Math]::Sqrt(($DiffX * $DiffX) + ($DiffY * $DiffY))
}

function GetNeighbouringPoints {
    # Returns a number from 1-26 representing the height
    # at a given point in the heightmap
    [OutputType([Int32])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [Int32] $Width,
        [Parameter(Mandatory, Position = 1)]
        [Int32] $Height,
        [Parameter(Mandatory, Position = 2)]
        [Int32] $XPos,
        [Parameter(Mandatory, Position = 3)]
        [Int32] $YPos
    )
    $PointList = [System.Collections.ArrayList]::new()

    # Top Middle
    if ($YPos -gt 0) {
        $PointList.Add(@($XPos, ($YPos - 1))) | Out-Null
    }
    # Middle Left
    if ($XPos -gt 0) {
        $PointList.Add(@(($XPos - 1), $YPos)) | Out-Null
    }
    # Middle Right
    if ($XPos -lt ($Width - 1)) {
        $PointList.Add(@(($XPos + 1), $YPos)) | Out-Null
    }
    # Bottom Middle
    if ($YPos -lt ($Height - 1)) {
        $PointList.Add(@($XPos, ($YPos + 1))) | Out-Null
    }
    return $PointList
}

class Point {
    [int32] $X
    [int32] $Y

    [Point] $Parent

    [int32] $DistanceToStart = 0
    [double] $DistanceToDest

    [double] $Cost

    Point([int32] $X, [int32] $Y, [Point] $Parent) {
        $this.X = $X
        $this.Y = $Y
        $this.SetParent($Parent)
    }

    [void] SetParent([Point] $Parent) {
        $this.Parent = $Parent
        if ($null -ne $Parent) {
            $this.DistanceToStart = $Parent.DistanceToStart + 1
        }
    }

    [void] CalculateCost([int32] $DestX, [int32] $DestY) {
        $DiffX = [Math]::Abs($this.X - $DestX)
        $DiffY = [Math]::Abs($this.y - $DestY)
        $this.DistanceToDest = [Math]::Sqrt(($DiffX * $DiffX) + ($DiffY * $DiffY))
        $this.Cost = $this.DistanceToDest + $this.DistanceToStart
    }
}

$HeightMap = . "$PSScriptRoot\Inputs.ps1"
$Height = $HeightMap.Count
$Width = $HeightMap[0].Length

$IntMap = [System.Collections.ArrayList]::new()
foreach ($Row in $HeightMap) {
    $RowMap = @()
    for ($i = 0; $i -lt $Row.Length; $i++) {
        $Char = $Row[$i]
        $RowMap += if ($Char -clike 'S') {
            # Starting position has elevation 'a'
            1
        } elseif ($Char -clike 'E') {
            # Destination position has elevation 'z'
            26
        } else {
            ([char]$Char - [char]'a') + 1
        }
    }
    $IntMap.Add($RowMap) | Out-Null
}

$StartingPos = FindLetter $HeightMap 'S'
$EndingPos = FindLetter $HeightMap 'E'

$StartingPoint = [Point]::new($StartingPos[0],$StartingPos[1],$null)
$StartingPoint.CalculateCost($EndingPos[0], $EndingPos[1])

$OpenList = [System.Collections.ArrayList]::new()
$OpenList.Add($StartingPoint) | Out-Null
$ClosedList = [System.Collections.ArrayList]::new()
$ClosedListHash = @{}
$TargetInClosedList = $false

do {
    $CurrentSquare = $OpenList.GetEnumerator() | Sort-Object 'Cost' | Select-Object -First 1
    $OpenList.Remove($CurrentSquare) | Out-Null
    $ClosedList.Add($CurrentSquare) | Out-Null
    $ClosedListHash["$($CurrentSquare.X),$($CurrentSquare.Y)"] = 1
    # Is the point the destination?
    if ($CurrentSquare.X -eq $EndingPos[0] -and
        $CurrentSquare.Y -eq $EndingPos[1]) {
        $TargetInClosedList = $true
        continue
    }

    $PotentialNeighbours = GetNeighbouringPoints $Width $Height $CurrentSquare.X $CurrentSquare.Y

    $CurrentElevation = $IntMap[$CurrentSquare.Y][$CurrentSquare.X]
    foreach($PotentialNeighbour in $PotentialNeighbours) {
        # Is the point traversible
        $ElevationAtNeighbour = $IntMap[$PotentialNeighbour[1]][$PotentialNeighbour[0]]
        if ($ElevationAtNeighbour -gt ($CurrentElevation + 1)) {
            continue
        }

        
        # $PointInClosedList = $ClosedList.GetEnumerator() | Where-Object {
            #     $_.X -eq $PotentialNeighbour[0] -and
            #     $_.Y -eq $PotentialNeighbour[1]
            # } | Measure-Object | Select-Object -Expand Count
        # Is this point in the closed list?
        if ($ClosedListHash.ContainsKey("$($PotentialNeighbour[0]),$($PotentialNeighbour[1])")) {
            continue
        }

        # Is this point in the open list?
        $PointInOpenList = $OpenList.GetEnumerator() | Where-Object {
            $_.X -eq $PotentialNeighbour[0] -and
            $_.Y -eq $PotentialNeighbour[1]
        } | Select-Object -First 1

        if ($null -ne $PointInOpenList) {
            # Point is in the open list
            $NewPoint = [Point]::new(
                $PotentialNeighbour[0],
                $PotentialNeighbour[1],
                $CurrentSquare
            )
            $NewPoint.CalculateCost($EndingPos[0], $EndingPos[1])
            if ($NewPoint.DistanceToStart -lt $PointInOpenList.DistanceToStart) {
                $IndexOfPoint = $OpenList.IndexOf($PointInOpenList)
                $OpenList[$IndexOfPoint].SetParent($CurrentSquare)
                $OpenList[$IndexOfPoint].CalculateCost($EndingPos[0], $EndingPos[1])
            }
        } else {
            # Point is not in the open list
            $NewPoint = [Point]::new(
                $PotentialNeighbour[0],
                $PotentialNeighbour[1],
                $CurrentSquare
            )
            $NewPoint.CalculateCost($EndingPos[0], $EndingPos[1])
            $OpenList.Add($NewPoint) | Out-Null
        }
    }
    if ($ClosedList.Count % 100 -eq 0) {
        Write-Host "$($ClosedList.Count)"
    }
} while (
    $OpenList.Count -gt 0 -and -not $TargetInClosedList
)

if ($TargetInClosedList) {
    $Path = @()
    $Point = $ClosedList[-1]
    while ($null -ne $Point) {
        $Path += $Point
        $Point = $Point.Parent
    }
    [array]::Reverse($Path)
    $PathLength = $Path.Count - 1
    Write-Host "The shortest path is $PathLength steps"
} else {
    Write-Host "Failed to find a path to target"
}
