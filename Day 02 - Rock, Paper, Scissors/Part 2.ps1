# The Elf finishes helping with the tent and sneaks back over to you. "Anyway, the second column 
# says how the round needs to end: X means you need to lose, Y means you need to end the round in a 
# draw, and Z means you need to win. Good luck!"

# The total score is still calculated in the same way, but now you need to figure out what shape to
# choose so the round ends as indicated. The example above now goes like this:

# In the first round, your opponent will choose Rock (A), and you need the round to end in a draw 
# (Y), so you also choose Rock. This gives you a score of 1 + 3 = 4.

# In the second round, your opponent will choose Paper (B), and you choose Rock so you lose (X) with
# a score of 1 + 0 = 1.

# In the third round, you will defeat your opponent's Scissors with Rock for a score of 1 + 6 = 7.

# Now that you're correctly decrypting the ultra top secret strategy guide, you would get a total 
# score of 12.

# Following the Elf's instructions for the second column, what would your total score be if 
# everything goes exactly according to your strategy guide?

# Map the required strategy X,Y,Z to names
$OutcomesMap = @{
    'X' = 'Lose'
    'Y' = 'Draw'
    'Z' = 'Win'
}

# Convert the A,B,C of the strategy guide to names
$RockPaperScissorsMap = @{
    'A' = 'Rock'
    'B' = 'Paper'
    'C' = 'Scissors'
}

# Determine how to move based on the required outcome and opponents move
$RequiredOutComeMap = @{
    'Win' = @{
        'Rock' = 'Paper'
        'Paper' = 'Scissors'
        'Scissors' = 'Rock'
    }
    'Lose' = @{
        'Rock' = 'Scissors'
        'Paper' = 'Rock'
        'Scissors' = 'Paper'
    }
    'Draw' = @{
        'Rock' = 'Rock'
        'Paper' = 'Paper'
        'Scissors' = 'Scissors'
    }
}

$Win = 6
$Loss = 0
$Draw = 3

# Create a lookup for the score based on what I play and what my opponent plays
$ScoreMap = @{
    # Score is points for your shape and then
    # points for the outcome (as follows):
    # +0 for a loss
    # +3 for a draw
    # +6 for a win

    # (1 point)
    'Rock' = @{
        'Rock'     = 1 + $Draw # Rock vs Rock
        'Paper'    = 1 + $Loss # Rock vs Paper
        'Scissors' = 1 + $Win  # Rock vs Scissors
    }
    # (2 points)
    'Paper' = @{
        'Rock'     = 2 + $Win  # Paper vs Rock
        'Paper'    = 2 + $Draw # Paper vs Paper
        'Scissors' = 2 + $Loss # Paper vs Scissors
    }
    # (3 points)
    'Scissors' = @{
        'Rock'     = 3 + $Loss # Scissors vs Rock
        'Paper'    = 3 + $Win  # Scissors vs Paper
        'Scissors' = 3 + $Draw # Scissors vs Scissors
    }
}

$GameList = . "$PSScriptRoot\Inputs.ps1"

$PointsTotal = 0
foreach ($Game in $GameList) {
    $GameSplit = $Game.Split(' ')
    $TheyPlayed = $RockPaperScissorsMap[$GameSplit[0]]
    $RequiredOutcome = $OutcomesMap[$GameSplit[1]]
    $IShouldPlay = $RequiredOutComeMap[$RequiredOutcome][$TheyPlayed]
    $PointsTotal += $ScoreMap[$IShouldPlay][$TheyPlayed]
}

Write-Host "Total Score at the end of the strategy would be $PointsTotal"