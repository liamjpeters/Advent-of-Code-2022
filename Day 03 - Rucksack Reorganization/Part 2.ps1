# As you finish identifying the misplaced items, the Elves come to you with another issue.

# For safety, the Elves are divided into groups of three. Every Elf carries a badge that identifies 
# their group. For efficiency, within each group of three Elves, the badge is the only item type 
# carried by all three Elves. That is, if a group's badge is item type B, then all three Elves will 
# have item type B somewhere in their rucksack, and at most two of the Elves will be carrying any 
# other item type.

# The problem is that someone forgot to put this year's updated authenticity sticker on the badges. 
# All of the badges need to be pulled out of the rucksacks so the new authenticity stickers can be 
# attached.

# Additionally, nobody wrote down which item type corresponds to each group's badges. The only way 
# to tell which item type is the right one is by finding the one item type that is common between 
# all three Elves in each group.

# Every set of three lines in your list corresponds to a single group, but each group can have a 
# different badge item type. So, in the above example, the first group's rucksacks are the first 
# three lines:

#   vJrwpWtwJgWrhcsFMMfFFhFp
#   jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
#   PmmdzqPrVvPwwTWBwg

# And the second group's rucksacks are the next three lines:

#   wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
#   ttgJtRGJQctTZtZT
#   CrZsJsPPZsGzwwsLwLmpwMDw

# In the first group, the only item type that appears in all three rucksacks is lowercase r; this 
# must be their badges. In the second group, their badge item type must be Z.

# Priorities for these items must still be found to organize the sticker attachment efforts: here, 
# they are 18 (r) for the first group and 52 (Z) for the second group. The sum of these is 70.

# Find the item type that corresponds to the badges of each three-Elf group. What is the sum of the 
# priorities of those item types?

function DeterminePriority {
    param (
        [Parameter(Mandatory, Position = 0)]
        [char]
        $ItemType
    )
    # If it's uppercase then add 27 to it (as the scoring below is 0-indexed and the
    # priorities start at 1 - uppercase priorities start at 27).
    # Then make it lowercase so we only need one set of calculations.
    $Modifier = if ($ItemType -lt [char]'a') {
        $ItemType = ($ItemType.ToString().ToLower()) -as [Char]
        27
    } else {
        1
    }
    # Find the absolute difference between the char 'a' and the input
    # Add the modifier to shift the priority correctly for uppercase and 1-indexing.
    [Math]::Abs(([char]'a') - ($ItemType)) + $Modifier
}

$RucksackInventories = . "$PSScriptRoot\Inputs.ps1"

$Inventories = @()
# Loop through the full list in steps of 3
for ($i = 0; $i -lt $RucksackInventories.Count; $i += 3) {
    $Elf1 = $RucksackInventories[$i + 0].ToCharArray()
    $Elf2 = $RucksackInventories[$i + 1].ToCharArray()
    $Elf3 = $RucksackInventories[$i + 2].ToCharArray()
    
    # First, compare elf1 and elf2
    $ComparisonSplat = @{
        'CaseSensitive'    = $true
        'ExcludeDifferent' = $true
        'IncludeEqual'     = $true
        'ReferenceObject'  = $Elf1
        'DifferenceObject' = $Elf2
    }
    $1and2 = Compare-Object @ComparisonSplat | Select-Object -Unique -ExpandProperty 'InputObject'

    # Second, compare the result of the first comaprison, with elf3
    $ComparisonSplat['ReferenceObject'] = $1and2
    $ComparisonSplat['DifferenceObject'] = $Elf3
    $Shared = Compare-Object @ComparisonSplat | Select-Object -Unique -ExpandProperty 'InputObject'

    $Inventories += [PSCustomObject]@{
        Group = ($i / 3) + 1
        Elf1 = $Elf1
        Elf2 = $Elf2
        Elf3 = $Elf3
        Shared = $Shared
        Priority = DeterminePriority $Shared
    }
}


$Sum = $Inventories | Measure-Object -Property 'Priority' -Sum | Select-Object -ExpandProperty Sum

Write-Host "Sum of priorities is $Sum"