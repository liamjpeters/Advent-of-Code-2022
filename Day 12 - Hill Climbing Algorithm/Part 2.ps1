# As you walk up the hill, you suspect that the Elves will want to turn this into a hiking trail. 
# The beginning isn't very scenic, though; perhaps you can find a better starting point.

# To maximize exercise while hiking, the trail should start as low as possible: elevation a. The 
# goal is still the square marked E. However, the trail should still be direct, taking the fewest 
# steps to reach its goal. So, you'll need to find the shortest path from any square at elevation 
# a to the square marked E.

# Again consider the example from above:

# Sabqponm
# abcryxxl
# accszExk
# acctuvwj
# abdefghi
# Now, there are six choices for starting position (five marked a, plus the square marked S that 
# counts as being at elevation a). If you start at the bottom-left square, you can reach the goal 
# most quickly:

# ...v<<<<
# ...vv<<^
# ...v>E^^
# .>v>>>^^
# >^>>>>>^

# This path reaches the goal in only 29 steps, the fewest possible.

# What is the fewest steps required to move starting from any square with elevation a to the 
# location that should get the best signal?

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
    return ($DiffX * $DiffX) + ($DiffY * $DiffY)
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

function FindAllStartingLocations {
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Collections.ArrayList]
        $IntMap
    )
    $StartingPoints = [System.Collections.ArrayList]::new()
    for ($Y = 0; $Y -lt $IntMap.Count; $Y++) {
        :PointLoop for ($X = 0; $X -lt $IntMap[$Y].Count; $X++) {
            if ($IntMap[$Y][$X] -eq 1) {
                # If we aren't next to a place we can start ascending, there's no point in
                # checking here
                $Points = GetNeighbouringPoints $IntMap[$Y].Count $IntMap.Count $X $Y
                foreach($Point in $Points) {
                    if ($IntMap[$Point[1]][$Point[0]] -eq 2) {
                        $StartingPoints.Add(@($X,$Y)) | Out-Null
                        continue PointLoop
                    }
                }
            }
        }
    }

    return $StartingPoints
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

$EndingPos = FindLetter $HeightMap 'E'

$PotentialStartingLocations = FindAllStartingLocations $IntMap

Write-Host "There are $($PotentialStartingLocations.Count) possible starting locations"

# Parralelised, as even with the optimisation of culling starting locations, we still
# have 43 iterations (albeit down from 2023)
$Paths = @()
$Paths = $PotentialStartingLocations.GetEnumerator() | Foreach-Object -ThrottleLimit 12 -Parallel {
    #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname
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
    
    $StartingPos = $_
    Write-Host "Starting On $($StartingPos[0]),$($StartingPos[1])"
    $EndPos = $using:EndingPos

    $IntegerMap = $using:IntMap
    $StartingPoint = [Point]::new($StartingPos[0],$StartingPos[1],$null)
    $StartingPoint.CalculateCost($EndPos[0], $EndPos[1])

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
        if ($CurrentSquare.X -eq $EndPos[0] -and
            $CurrentSquare.Y -eq $EndPos[1]) {
            $TargetInClosedList = $true
            continue
        }

        $PotentialNeighbours = GetNeighbouringPoints $using:Width $using:Height $CurrentSquare.X $CurrentSquare.Y

        $CurrentElevation = $IntegerMap[$CurrentSquare.Y][$CurrentSquare.X]
        foreach($PotentialNeighbour in $PotentialNeighbours) {
            # Is the point traversible
            $ElevationAtNeighbour = $IntegerMap[$PotentialNeighbour[1]][$PotentialNeighbour[0]]
            if ($ElevationAtNeighbour -gt ($CurrentElevation + 1)) {
                continue
            }

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
                $NewPoint.CalculateCost($EndPos[0], $EndPos[1])
                if ($NewPoint.DistanceToStart -lt $PointInOpenList.DistanceToStart) {
                    $IndexOfPoint = $OpenList.IndexOf($PointInOpenList)
                    $OpenList[$IndexOfPoint].SetParent($CurrentSquare)
                    $OpenList[$IndexOfPoint].CalculateCost($EndPos[0], $EndPos[1])
                }
            } else {
                # Point is not in the open list
                $NewPoint = [Point]::new(
                    $PotentialNeighbour[0],
                    $PotentialNeighbour[1],
                    $CurrentSquare
                )
                $NewPoint.CalculateCost($EndPos[0], $EndPos[1])
                $OpenList.Add($NewPoint) | Out-Null
            }
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
        [PSCustomObject]@{
            Distance = $PathLength
            Path = $Path
        }
    }
    Write-Host "Done with $($StartingPos[0]),$($StartingPos[1])"
}
$Shortest = $Paths | Sort-Object 'Distance' | Select-Object -First 1 -Expand 'Distance'
Write-Host "The shortest path is $Shortest steps"