# As you watch the crane operator expertly rearrange the crates, you notice the process isn't 
# following your prediction.

# Some mud was covering the writing on the side of the crane, and you quickly wipe it away. The 
# crane isn't a CrateMover 9000 - it's a CrateMover 9001.

# The CrateMover 9001 is notable for many new and exciting features: air conditioning, leather 
# seats, an extra cup holder, and the ability to pick up and move multiple crates at once.

# Again considering the example above, the crates begin in the same configuration:

#     [D]    
# [N] [C]    
# [Z] [M] [P]
#  1   2   3 

# Moving a single crate from stack 2 to stack 1 behaves the same as before:

# [D]        
# [N] [C]    
# [Z] [M] [P]
#  1   2   3 

# However, the action of moving three crates from stack 1 to stack 3 means that those three moved 
# crates stay in the same order, resulting in this new configuration:

#         [D]
#         [N]
#     [C] [Z]
#     [M] [P]
#  1   2   3

# Next, as both crates are moved from stack 2 to stack 1, they retain their order as well:

#         [D]
#         [N]
# [C]     [Z]
# [M]     [P]
#  1   2   3

# Finally, a single crate is still moved from stack 1 to stack 2, but now it's crate C that gets 
# moved:

#         [D]
#         [N]
#         [Z]
# [M] [C] [P]
#  1   2   3

# In this example, the CrateMover 9001 has put the crates in a totally different order: MCD.

# Before the rearrangement process finishes, update your simulation so that the Elves know where 
# they should stand to be ready to unload the final supplies. 

# After the rearrangement procedure completes, what crate ends up on top of each stack?


function ParseMoveInstruction {
    # If the input string is a move instruction, it extracts
    # and returns the pertinent numeric values
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]
        $Instruction
    )
    PROCESS{
        # Capture the numberic values to named capture groups
        $Pattern = 'move (?<Quantity>[\d].*?) from (?<From>[\d].*?) to (?<To>[\d].*?)'
        if ($Instruction -match $Pattern) {
            [PSCustomObject]@{
                Quantity = $Matches.Quantity -as [int32]
                From = $Matches.From -as [int32]
                To = $Matches.To -as [int32]
            }
        }
    }
}

function PrintCrateLayout {
    param (
        [Parameter(Mandatory, Position = 0)]
        [hashtable]
        $CrateLayout
    )
    Write-Host "============CRATE LAYOUT==============="
    foreach ($Entry in $CrateLayout.GetEnumerator() | Sort-Object Name) {
        Write-Host "$($Entry.Name) - $($Entry.Value -Join ', ')"
    }
    Write-Host "======================================="
}

function GetTopMostCrates {
    param (
        [Parameter(Mandatory, Position = 0)]
        [hashtable]
        $CrateLayout
    )
    $TopMostCrates = @()
    foreach ($Entry in $CrateLayout.GetEnumerator() | Sort-Object Name) {
        $TopMostCrates += $Entry.Value[-1]
    }
    $TopMostCrates -Join ''
}

function PerformMove {
    param (
        [Parameter(Mandatory, Position = 0)]
        [hashtable]
        $CrateLayout,
        [Parameter(Mandatory, Position = 1)]
        [pscustomobject]
        $Move
    )

    # Capture the last X values from the 'From' stack, based on the move quantity
    $MovingValues = $CrateLayout[$Move.From][-$($Move.Quantity)..-1]

    # Shorten the 'From' stack of crates, lopping off the last X values, based on the move quantity
    $CrateLayout[$Move.From] = $CrateLayout[$Move.From][0..($CrateLayout[$Move.From].Length-(1+$Move.Quantity))]
    
    # Add the captured values to the end of the 'To' stack of crates.
    $CrateLayout[$Move.To] += $MovingValues
}

$InputData = . "$PSScriptRoot\Inputs.ps1"

$CrateLayout = $InputData['InitialCrateLayout']
$MoveProcedure = $InputData['MoveProcedure']

# Parse all the moves into numeric instructions (Number of crates, from stack, to stack)
$Moves = $MoveProcedure | ParseMoveInstruction

# Perform the moves
PrintCrateLayout $CrateLayout
foreach ($Move in $Moves) {
    PerformMove $CrateLayout $Move
}
PrintCrateLayout $CrateLayout

# Printout the crates that are on the top of each stack
GetTopMostCrates $CrateLayout