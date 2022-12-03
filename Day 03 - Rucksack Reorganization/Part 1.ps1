# One Elf has the important job of loading all of the rucksacks with supplies for the jungle 
# journey. Unfortunately, that Elf didn't quite follow the packing instructions, and so a few items 
# now need to be rearranged.

# Each rucksack has two large compartments. All items of a given type are meant to go into exactly 
# one of the two compartments. The Elf that did the packing failed to follow this rule for exactly 
# one item type per rucksack.

# The Elves have made a list of all of the items currently in each rucksack (your puzzle input), but
# they need your help finding the errors. Every item type is identified by a single lowercase or 
# uppercase letter (that is, a and A refer to different types of items).

# The list of items for each rucksack is given as characters all on a single line. A given rucksack 
# always has the same number of items in each of its two compartments, so the first half of the 
# characters represent items in the first compartment, while the second half of the characters 
# represent items in the second compartment.

# For example, suppose you have the following list of contents from six rucksacks:

#       vJrwpWtwJgWrhcsFMMfFFhFp
#       jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
#       PmmdzqPrVvPwwTWBwg
#       wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
#       ttgJtRGJQctTZtZT
#       CrZsJsPPZsGzwwsLwLmpwMDw

# The first rucksack contains the items vJrwpWtwJgWrhcsFMMfFFhFp, which means its first compartment 
# contains the items vJrwpWtwJgWr, while the second compartment contains the items hcsFMMfFFhFp. 
# The only item type that appears in both compartments is lowercase p.

# The second rucksack's compartments contain jqHRNqRjqzjGDLGL and rsFMfFZSrLrFZsSL. The only item 
# type that appears in both compartments is uppercase L.

# The third rucksack's compartments contain PmmdzqPrV and vPwwTWBwg; the only common item type is 
# uppercase P.
# The fourth rucksack's compartments only share item type v.

# The fifth rucksack's compartments only share item type t.

# The sixth rucksack's compartments only share item type s.

# To help prioritize item rearrangement, every item type can be converted to a priority:

# Lowercase item types a through z have priorities 1 through 26.

# Uppercase item types A through Z have priorities 27 through 52.

# In the above example, the priority of the item type that appears in both compartments of each 
# rucksack is 16 (p), 38 (L), 42 (P), 22 (v), 20 (t), and 19 (s); the sum of these is 157.

# Find the item type that appears in both compartments of each rucksack. 

# What is the sum of the priorities of those item types?

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
foreach ($RucksackInventory in $RucksackInventories) {
    # Each 'RucksackInventory' inventory is a differnet length. Determine half
    $CompartmentSize = $RucksackInventory.Length / 2
    # Take each half into a compartment and treat as an array of characters so we can use
    # compare-object to find the unique shared character
    $Compartment1 = $RucksackInventory.Substring(0, $CompartmentSize).ToCharArray()
    $Compartment2 = $RucksackInventory.Substring($CompartmentSize, $CompartmentSize).ToCharArray()
    $ComparisonSplat = @{
        'CaseSensitive'    = $true
        'ExcludeDifferent' = $true
        'IncludeEqual'     = $true
        'ReferenceObject'  = $Compartment1
        'DifferenceObject' = $Compartment2
    }
    $Shared = Compare-Object @ComparisonSplat | Select-Object -Unique -ExpandProperty 'InputObject'
    $Inventories += [PSCustomObject]@{
        Inventory = $RucksackInventory
        Shared = $Shared
        Priority = DeterminePriority $Shared
    }
} 

$Sum = $Inventories | Measure-Object -Property 'Priority' -Sum | Select-Object -ExpandProperty Sum

Write-Host "Sum of priorities is $Sum"