# Now, you just need to put all of the packets in the right order. Disregard the blank lines in your
# list of received packets.

# The distress signal protocol also requires that you include two additional divider packets:

# [[2]]
# [[6]]
# Using the same rules as before, organize all packets - the ones in your list of received packets 
# as well as the two divider packets - into the correct order.

# For the example above, the result of putting the packets in the correct order is:

#   []
#   [[]]
#   [[[]]]
#   [1,1,3,1,1]
#   [1,1,5,1,1]
#   [[1],[2,3,4]]
#   [1,[2,[3,[4,[5,6,0]]]],8,9]
#   [1,[2,[3,[4,[5,6,7]]]],8,9]
#   [[1],4]
#   [[2]]
#   [3]
#   [[4,4],4,4]
#   [[4,4],4,4,4]
#   [[6]]
#   [7,7,7]
#   [7,7,7,7]
#   [[8,7,6]]
#   [9]

# Afterward, locate the divider packets. To find the decoder key for this distress signal, you need 
# to determine the indices of the two divider packets and multiply them together. (The first packet 
# is at index 1, the second packet is at index 2, and so on.) In this example, the divider packets 
# are 10th and 14th, and so the decoder key is 140.

# Organize all of the packets into the correct order. 

# What is the decoder key for the distress signal?
#
class List {
    hidden [string] $IndentChar = '  '
    hidden [List] $Parent
    hidden [System.Collections.ArrayList] $Children

    List() {
        $this.Children = [System.Collections.ArrayList]::new()
    }

    [void] SetParent([List] $Parent) {
        $this.Parent = $Parent
    }

    [List] GetParent() {
        return $this.Parent
    }

    [void] AddChild([psobject] $Child) {
        $this.Children.Add($Child) | Out-Null
    }

    [String] ToString() {
        $SB = [System.Text.StringBuilder]::new()
        $SB.Append("[") | Out-Null
        $SB.Append("$($this.Children -Join ',')") | Out-Null
        # foreach ($Child in $this.Children) {
        #     if ($Child -is [int32]) {
        #         $SB.Append("$Child") | Out-Null
        #     } elseif ($Child -is [List]) {
        #         $SB.Append($Child.Print2()) | Out-Null
        #     }
        # }
        $SB.Append(']') | Out-Null
        return $Sb.ToString()
    }

    # [String] Print([int32] $IndentLevel) {
    #     $SB = [System.Text.StringBuilder]::new()
    #     $SB.AppendLine("$($this.IndentChar * $IndentLevel)[") | Out-Null
    #     foreach ($Child in $this.Children) {
    #         if ($Child -is [int32]) {
    #             $SB.AppendLine("$($this.IndentChar * ($IndentLevel+1))$Child") | Out-Null
    #         } elseif ($Child -is [List]) {
    #             $SB.AppendLine($Child.Print($IndentLevel + 1)) | Out-Null
    #         }
    #     }
    #     $SB.Append("$($this.IndentChar * $IndentLevel)]") | Out-Null
    #     return $Sb.ToString()
    # }

    # [String] ToString() {
    #     return $this.Print(0)
    # }

}

function ParsePacket {
    [OutputType([List])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [String]
        $Packet
    )
    $CurrentList = $null
    $DigitAccumulator = [System.Text.StringBuilder]::new()

    # Parse the input character by character. Ensuring a 
    # reference is kept to the first list created so it can
    # be returned
    foreach ($Char in $Packet.ToCharArray()) {
        switch ($Char) {
            '[' { 
                # Push a new list
                $NewList = [List]::new()
                $NewList.SetParent($CurrentList)
                if ($null -ne $CurrentList) {
                    $CurrentList.AddChild($NewList)
                }
                $CurrentList = $NewList
            }
            ']' {
                # Pop the current list
                # If the accumulated digits is not empty
                # push it onto the current list and clear it
                if ($DigitAccumulator.Length -gt 0) {
                    $Number = $DigitAccumulator.ToString() -as [int32]
                    $DigitAccumulator.Clear() | Out-Null
                    $CurrentList.AddChild($Number)
                }
                if ($null -ne $CurrentList.GetParent()) {
                    $CurrentList = $CurrentList.GetParent()
                }
            }
            ',' {
                # If the accumulated digits is not empty
                # push it onto the current list and clear it
                if ($DigitAccumulator.Length -gt 0) {
                    $Number = $DigitAccumulator.ToString() -as [int32]
                    $DigitAccumulator.Clear() | Out-Null
                    $CurrentList.AddChild($Number)
                }
            }
            { $PSItem -in [char]'0'..[char]'9' } {
                # If the number is between 0 and 9, add to
                # the digit accumulator
                $DigitAccumulator.Append($Char) | Out-Null
            }
            Default {}
        }
    }
    if ($DigitAccumulator.Length -gt 0) {
        $Number = $DigitAccumulator.ToString() -as [int32]
        $DigitAccumulator.Clear() | Out-Null
        $CurrentList.AddChild($Number)
    }
    return $CurrentList
}

enum Decision {
    InOrder
    OutOfOrder
    KeepChecking
}

function CompareLists {
    [OutputType([Decision])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [psobject]
        $LeftSide,
        [Parameter(Mandatory, Position = 1)]
        [psobject]
        $RightSide
    )
    # - If both values are integers, the lower integer should come first. If the left integer is lower 
    #   than the right integer, the inputs are in the right order. If the left integer is higher than 
    #   the right integer, the inputs are not in the right order. Otherwise, the inputs are the same 
    #   integer; continue checking the next part of the input.
    if ($LeftSide -is [int32] -and $RightSide -is [int32]) {
        if ($LeftSide -eq $RightSide) {
            return [Decision]::KeepChecking
        }
        if ($LeftSide -lt $RightSide) {
            return [Decision]::InOrder
        }
        return [Decision]::OutOfOrder
    }

    # - If exactly one value is an integer, convert the integer to a list which contains that integer as
    #   its only value, then retry the comparison. For example, if comparing [0,0,0] and 2, convert the 
    #   right value to [2] (a list containing 2); the result is then found by instead comparing [0,0,0] 
    #   and [2].
    if ($LeftSide -is [int32] -and $RightSide -is [List]) {
        $LeftSideAsList = [List]::new()
        $LeftSideAsList.AddChild($LeftSide)
        return CompareLists $LeftSideAsList $RightSide
    }

    if ($LeftSide -is [List] -and $RightSide -is [int32]) {
        $RightSideAsList = [List]::new()
        $RightSideAsList.AddChild($RightSide)
        return CompareLists $LeftSide $RightSideAsList
    }

    # - If both values are lists, compare the first value of each list, then the second value, and so 
    #   on. If the left list runs out of items first, the inputs are in the right order. If the right 
    #   list runs out of items first, the inputs are not in the right order. If the lists are the same 
    #   length and no comparison makes a decision about the order, continue checking the next part of 
    #   the input.
    if ($LeftSide -is [List] -and $RightSide -is [List]) {
        $i = 0
        $Decision = [Decision]::KeepChecking
        do {
            if ($null -eq $LeftSide.Children[$i] -and
                $null -ne $RightSide.Children[$i]) {
                return [Decision]::InOrder
            }
            if ($null -ne $LeftSide.Children[$i] -and
                $null -eq $RightSide.Children[$i]) {
                return [Decision]::OutOfOrder
            }
            if ($null -eq $LeftSide.Children[$i] -and
                $null -eq $RightSide.Children[$i]) {
                return [Decision]::KeepChecking
            }
            $Decision = CompareLists $LeftSide.Children[$i] $RightSide.Children[$i]
            $i++
        } while (
            $Decision -eq [Decision]::KeepChecking -and
            $i -lt $LeftSide.Children.Count -and
            $i -lt $RightSide.Children.Count
        )
        if ($Decision -ne [Decision]::KeepChecking) {
            return $Decision
        }
        if ($LeftSide.Children.Count -eq $RightSide.Children.Count) {
            return [Decision]::KeepChecking
        }
        if ($LeftSide.Children.Count -lt $RightSide.Children.Count) {
            return [Decision]::InOrder
        } else {
            return [Decision]::OutOfOrder
        }
    }
}

# Import data and remove blank lines
$ReceivedPackets = (. "$PSScriptRoot\Inputs.ps1") -notlike ''

$DividerPackers = @(
    '[[2]]'
    '[[6]]'
)

$ReceivedPackets += $DividerPackers

$ParsedPackets = @()

for ($i = 0; $i -lt $ReceivedPackets.Count; $i++) {
    $ParsedPackets += ParsePacket $ReceivedPackets[$i]
}

do {
    $Swapped = $false
    for ($i = 0; $i -lt $ParsedPackets.Count - 1; $i++) {
        $Comparison = CompareLists $ParsedPackets[$i] $ParsedPackets[$i + 1]
        if ($Comparison -ne [Decision]::InOrder) {
            $Swapped = $true
            $Temp = $ParsedPackets[$i]
            $ParsedPackets[$i] = $ParsedPackets[$i + 1]
            $ParsedPackets[$i + 1] = $Temp
        }
    }
} while (
    $Swapped
)

$TwoDivider = $ParsedPackets | Where-Object {
    '[[2]]' -eq $_.ToString()
}
$SixDivider = $ParsedPackets | Where-Object {
    '[[6]]' -eq $_.ToString()
}
$TwoDividerIndex = $ParsedPackets.IndexOf($TwoDivider)
$SixDividerIndex = $ParsedPackets.IndexOf($SixDivider)

Write-Host "The decoder key for the distress signal is $(($TwoDividerIndex + 1) * ($SixDividerIndex + 1))"