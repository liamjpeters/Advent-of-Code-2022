# Content with the amount of tree cover available, the Elves just need to know the best spot to 
# build their tree house: they would like to be able to see a lot of trees.

# To measure the viewing distance from a given tree, look up, down, left, and right from that tree; 
# stop if you reach an edge or at the first tree that is the same height or taller than the tree 
# under consideration. (If a tree is right on the edge, at least one of its viewing distances will 
# be zero.)

# The Elves don't care about distant trees taller than those found by the rules above; the proposed 
# tree house has large eaves to keep it dry, so they wouldn't be able to see higher than the tree 
# house anyway.

# In the example above, consider the middle 5 in the second row:

#   30373
#   25512
#   65332
#   33549
#   35390

# - Looking up, its view is not blocked; it can see 1 tree (of height 3).
# - Looking left, its view is blocked immediately; it can see only 1 tree (of height 5, right next 
#   to it).
# - Looking right, its view is not blocked; it can see 2 trees.
# - Looking down, its view is blocked eventually; it can see 2 trees (one of height 3, then the tree
#   of height 5 that blocks its view).

# A tree's scenic score is found by multiplying together its viewing distance in each of the four 
# directions. For this tree, this is 4 (found by multiplying 1 * 1 * 2 * 2).

# However, you can do even better: consider the tree of height 5 in the middle of the fourth row:

#   30373
#   25512
#   65332
#   33549
#   35390

# - Looking up, its view is blocked at 2 trees (by another tree with a height of 5).
# - Looking left, its view is not blocked; it can see 2 trees.
# - Looking down, its view is also not blocked; it can see 1 tree.
# - Looking right, its view is blocked at 2 trees (by a massive tree of height 9).
# - This tree's scenic score is 8 (2 * 2 * 1 * 2); this is the ideal spot for the tree house.

# Consider each tree on your map. What is the highest scenic score possible for any tree?

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

function CalculateTreeScenicScore {
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
    if ($X -eq 0 -or $Y -eq 0 -or $X -eq ($MapData[0].Length - 1) -or $Y -eq ($MapData.Count - 1)) {
        return 0
    }
    $TreeHeight = GetTreeHeightAtPoint $MapData $X $Y

    $DistanceLeft = $X
    $DistanceRight = ($MapData[0].Length - 1) - $X
    $DistanceUp = $Y
    $DistanceDown = ($MapData.Count - 1) - $Y

    # Distance Left
    for ($i = $X - 1; $i -ge 0; $i--) {
        # Go from X, down to 0
        if ((GetTreeHeightAtPoint $MapData $i $Y) -ge $TreeHeight) {
            $DistanceLeft = $X - $i
            break
        }
    }

    # Distance Right
    for ($i = $X + 1; $i -lt $MapData[0].Length; $i++) {
        # Go from X, up to GridWidth
        if ((GetTreeHeightAtPoint $MapData $i $Y) -ge $TreeHeight) {
            $DistanceRight = $i - $X
            break
        }
    }

    # Distance Up
    for ($i = $Y - 1; $i -ge 0; $i--) {
        # Go from Y, down to 0
        if ((GetTreeHeightAtPoint $MapData $X $i) -ge $TreeHeight) {
            $DistanceUp = $Y - $i
            break
        }
    }

    # Distance Down
    for ($i = $Y + 1; $i -lt $MapData.Count; $i++) {
        # Go from Y, up to GridHeight
        if ((GetTreeHeightAtPoint $MapData $X $i) -ge $TreeHeight) {
            $DistanceDown = $i - $Y
            break
        }
    }
    return $DistanceLeft * $DistanceRight * $DistanceUp * $DistanceDown
}


$HighestScoreSoFar = [int32]::MinValue
$BestX = -1
$BestY = -1
for ($i = 0; $i -lt $GridHeight; $i++) {
    for ($j = 0; $j -lt $GridWidth; $j++) {
        $Score = CalculateTreeScenicScore $MapData $j $i
        if ($Score -gt $HighestScoreSoFar) {
            $HighestScoreSoFar = $Score
            $BestX = $j
            $BestY = $i
        }
    }
}

Write-Host "The best score is '$HighestScoreSoFar' at ($($BestX+1), $($BestY+1))"