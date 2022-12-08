# The expedition comes across a peculiar patch of tall trees all planted carefully in a grid. The 
# Elves explain that a previous expedition planted these trees as a reforestation effort. Now, 
# they're curious if this would be a good location for a tree house.

# First, determine whether there is enough tree cover here to keep a tree house hidden. To do this, 
# you need to count the number of trees that are visible from outside the grid when looking directly
# along a row or column.

# The Elves have already launched a quadcopter to generate a map with the height of each tree (your 
# puzzle input). For example:

# 30373
# 25512
# 65332
# 33549
# 35390

# Each tree is represented as a single digit whose value is its height, where 0 is the shortest and 
# 9 is the tallest.

# A tree is visible if all of the other trees between it and an edge of the grid are shorter than 
# it. Only consider trees in the same row or column; that is, only look up, down, left, or right 
# from any given tree.

# All of the trees around the edge of the grid are visible - since they are already on the edge, 
# there are no trees to block the view. In this example, that only leaves the interior nine trees 
# to consider:

# - The top-left 5 is visible from the left and top. (It isn't visible from the right or bottom 
#   since other trees of height 5 are in the way.)
# - The top-middle 5 is visible from the top and right.
# - The top-right 1 is not visible from any direction; for it to be visible, there would need to 
#   only be trees of height 0 between it and an edge.
# - The left-middle 5 is visible, but only from the right.
# - The center 3 is not visible from any direction; for it to be visible, there would need to be 
#   only trees of at most height 2 between it and an edge.
# - The right-middle 3 is visible from the right.
# - In the bottom row, the middle 5 is visible, but the 3 and 4 are not.

# With 16 trees visible on the edge and another 5 visible in the interior, a total of 21 trees are 
# visible in this arrangement.

# Consider your map; 

# how many trees are visible from outside the grid?

$MapData = . "$PSScriptRoot\Inputs.ps1"

$GridHeight = $MapData.Count
$GridWidth = $MapData[0].Length

function GetTreeHeightAtPoint {
    [CmdletBinding()]
    [OutputType([int32])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string[]]
        $MapData,
        [Parameter(Mandatory, Position = 1)]
        [int32]
        $X,
        [Parameter(Mandatory, Position = 2)]
        [int32]
        $Y
    )
    $MapData[$Y][$X].ToString() -as [int32]
}

function IsTreeVisible {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string[]]
        $MapData,
        [Parameter(Mandatory, Position = 1)]
        [int32]
        $X,
        [Parameter(Mandatory, Position = 2)]
        [int32]
        $Y
    )
    if ($X -eq 0 -or $Y -eq 0 -or $X -eq ($MapData[0].Length - 1) -or $Y -eq ($MapData.Count - 1)) {
        return $true
    }
    $TreeHeight = GetTreeHeightAtPoint $MapData $X $Y

    $BlockedFromTheWest = $false
    $BlockedFromTheEast = $false
    $BlockedFromTheNorth = $false
    $BlockedFromTheSouth = $false

    # Can it be viewed from the West
    for ($i = 0; $i -lt $X; $i++) {
        # Go from 0, up to X
        if ((GetTreeHeightAtPoint $MapData $i $Y) -ge $TreeHeight) {
            $BlockedFromTheWest = $true
            break
        }
    }
    if (-not $BlockedFromTheWest) {
        return $true
    }

    # Can it be viewed from the East
    for ($i = ($MapData[0].Length - 1); $i -gt $X; $i--) {
        # Go from grid width, down to X
        if ((GetTreeHeightAtPoint $MapData $i $Y) -ge $TreeHeight) {
            $BlockedFromTheEast = $true
            break
        }
    }
    if (-not $BlockedFromTheEast) {
        return $true
    }

    # Can it be viewed from the North
    for ($i = 0; $i -lt $Y; $i++) {
        # Go from 0, up to Y
        if ((GetTreeHeightAtPoint $MapData $X $i) -ge $TreeHeight) {
            $BlockedFromTheNorth = $true
            break
        }
    }
    if (-not $BlockedFromTheNorth) {
        return $true
    }

    # Can it be viewed from the South
    for ($i = ($MapData.Count - 1); $i -gt $Y; $i--) {
        # Go from grid height, down to Y
        if ((GetTreeHeightAtPoint $MapData $X $i) -ge $TreeHeight) {
            $BlockedFromTheSouth = $true
            break
        }
    }
    if (-not $BlockedFromTheSouth) {
        return $true
    }
    return $false
}

$NumVisible = 0
for ($i = 0; $i -lt $GridHeight; $i++) {
    for ($j = 0; $j -lt $GridWidth; $j++) {
        if (IsTreeVisible $MapData $j $i) {
            $NumVisible++
        }
    }
}

Write-Host "There are a total of '$NumVisible' trees visible from the edge of the grid"