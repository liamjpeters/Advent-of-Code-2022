# The expedition can depart as soon as the final supplies have been unloaded from the ships. 
# Supplies are stored in stacks of marked crates, but because the needed supplies are buried under 
# many other crates, the crates need to be rearranged.

# The ship has a giant cargo crane capable of moving crates between stacks. To ensure none of the 
# crates get crushed or fall over, the crane operator will rearrange them in a series of 
# carefully-planned steps. After the crates are rearranged, the desired crates will be at the top of
# each stack.

# The Elves don't want to interrupt the crane operator during this delicate procedure, but they 
# forgot to ask her which crate will end up where, and they want to be ready to unload them as soon 
# as possible so they can embark.

# They do, however, have a drawing of the starting stacks of crates and the rearrangement procedure 
# (your puzzle input). For example:

#     [D]    
# [N] [C]    
# [Z] [M] [P]
#  1   2   3 

# move 1 from 2 to 1
# move 3 from 1 to 3
# move 2 from 2 to 1
# move 1 from 1 to 2

# In this example, there are three stacks of crates. Stack 1 contains two crates: crate Z is on the 
# bottom, and crate N is on top. Stack 2 contains three crates; from bottom to top, they are crates 
# M, C, and D. Finally, stack 3 contains a single crate, P.

# Then, the rearrangement procedure is given. In each step of the procedure, a quantity of crates is
# moved from one stack to a different stack. In the first step of the above rearrangement procedure,
# one crate is moved from stack 2 to stack 1, resulting in this configuration:

# [D]        
# [N] [C]    
# [Z] [M] [P]
#  1   2   3 
# In the second step, three crates are moved from stack 1 to stack 3. Crates are moved one at a 
# time, so the first crate to be moved (D) ends up below the second and third crates:

#         [Z]
#         [N]
#     [C] [D]
#     [M] [P]
#  1   2   3

# Then, both crates are moved from stack 2 to stack 1. Again, because crates are moved one at a 
# time, crate C ends up below crate M:

#         [Z]
#         [N]
# [M]     [D]
# [C]     [P]
#  1   2   3

# Finally, one crate is moved from stack 1 to stack 2:

#         [Z]
#         [N]
#         [D]
# [C] [M] [P]
#  1   2   3

# The Elves just need to know which crate will end up on top of each stack; in this example, the top
# crates are C in stack 1, M in stack 2, and Z in stack 3, so you should combine these together and 
# give the Elves the message CMZ.

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
    for ($i = 0; $i -lt $Move.Quantity; $i++) {
        # Capture the value to be moved
        $MovingValue = $CrateLayout[$Move.From][-1]

        # Shorten the 'From' stack of crates, lopping off the last value
        $CrateLayout[$Move.From] = $CrateLayout[$Move.From][0..($CrateLayout[$Move.From].Length-2)]
        
        # Put the value onto the end of the 'To' stack of crates
        $CrateLayout[$Move.To] += $MovingValue
    }
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