# It seems like there is still quite a bit of duplicate work planned. Instead, the Elves would like 
# to know the number of pairs that overlap at all.

# In the above example, the first two pairs (2-4,6-8 and 2-3,4-5) don't overlap, while the remaining
# four pairs (5-7,7-9, 2-8,3-7, 6-6,4-6, and 2-6,4-8) do overlap:

#   5-7,7-9 overlaps in a single section, 7.
#   2-8,3-7 overlaps all of the sections 3 through 7.
#   6-6,4-6 overlaps in a single section, 6.
#   2-6,4-8 overlaps in sections 4, 5, and 6.

# So, in this example, the number of overlapping assignment pairs is 4.

# In how many assignment pairs do the ranges overlap?

function CheckRangesForOverlap {
    # Returns $true if the two assignments contain at least one number that's the same
    param (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        # Take in a an assignment pair in the form '12-34,56-78'
        $AssignmentPairs
    )
    # Split the assignment pair into 2 assignments
    $AssignmentPairsSplit = $AssignmentPairs.Split(',')

    # Split each assignment on a dash to get the lower and upper bounds of
    # the assignment
    $Assignment1Split = $AssignmentPairsSplit[0].Split('-')
    $Assignment2Split = $AssignmentPairsSplit[1].Split('-')

    # Expand the range for each assignement
    # e.g. 1-5 becomes an array of 1,2,3,4,5
    $Assignment1Expanded = ($Assignment1Split[0] -as [int32])..($Assignment1Split[1] -as [int32])
    $Assignment2Expanded = ($Assignment2Split[0] -as [int32])..($Assignment2Split[1] -as [int32])

    # Compare the two assignment arrays. Ignoring where there are different elements, focusing only
    # on elements in common.
    # If there is more than 0 elements in common, return true
    Compare-Object $Assignment1Expanded $Assignment2Expanded -ExcludeDifferent -IncludeEqual |
        Measure-Object |
        Select-Object -ExpandProperty Count | ForEach-Object {
            $_ -gt 0
        }
}

$SectionAssignments = . "$PSScriptRoot\Inputs.ps1"

$RunningTotal = 0
foreach ($SectionAssignment in $SectionAssignments) {
    if (CheckRangesForOverlap $SectionAssignment) {
        $RunningTotal++
    }
}

Write-Host "There are $RunningTotal assignment pairs which overlap with one another"