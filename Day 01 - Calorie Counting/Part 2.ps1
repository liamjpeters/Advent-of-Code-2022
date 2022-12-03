# By the time you calculate the answer to the Elves' question, they've already realized that the Elf
# carrying the most Calories of food might eventually run out of snacks.

# To avoid this unacceptable situation, the Elves would instead like to know the total Calories 
# carried by the top three Elves carrying the most Calories. That way, even if one of those Elves 
# runs out of snacks, they still have two backups.

# In the example above, the top three Elves are the fourth Elf (with 24000 Calories), then the third
# Elf (with 11000 Calories), then the fifth Elf (with 10000 Calories). The sum of the Calories 
# carried by these three elves is 45000.

# Find the top three Elves carrying the most Calories. How many Calories are those Elves carrying in
# total?

$InputData = . "$PSScriptRoot\Inputs.ps1"

$ElvesArray = @()

# Find all of the locations in the array where there is a 'blank line', denoting the end of the 
# current elf
$SplitIndices = (0..($InputData.Count-1)) | Where-Object {
    $InputData[$_] -eq ''
}

# Hold a pointer to where we are starting in the main array of data
$Cursor = 0

# Loop through each elf by looking at the main data, between the cursor location and where the next
# 'blank line' is in the data. Not forgetting to look past the index of the last 'blank line' to get
# the final elf.
for ($i = 0; $i -le $SplitIndices.Count; $i++) {
    if ($i -lt $SplitIndices.Count) {
        $Array = $InputData[$Cursor..$($SplitIndices[$i] - 1)]
        $Sum = $Array | ForEach-Object {
            $_ -AS [int64]
        } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        $ElvesArray += [PSCustomObject]@{
            Values = $Array
            Sum = $Sum
        }
        $Cursor = $SplitIndices[$i] + 1
    } else {
        $Array = $InputData[$Cursor..$($InputData.Count - 1)]
        $Sum = $Array | ForEach-Object {
            $_ -AS [int64]
        } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        $ElvesArray += [PSCustomObject]@{
            Values = $Array
            Sum = $Sum
        }
    }
}

$TopX = 3
$Calories = $ElvesArray | 
            Sort-Object 'Sum' -Descending | 
            Select-Object -First $TopX -ExpandProperty 'Sum' | 
            Measure-Object -Sum | 
            Select-Object -ExpandProperty Sum

Write-Host "The calories carried by the top $TopX elves is $Calories"