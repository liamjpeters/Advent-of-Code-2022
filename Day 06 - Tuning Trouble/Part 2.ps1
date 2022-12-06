# Your device's communication system is correctly detecting packets, but still isn't working. It 
# looks like it also needs to look for messages.

# A start-of-message marker is just like a start-of-packet marker, except it consists of 14 distinct
# characters rather than 4.

# Here are the first positions of start-of-message markers for all of the above examples:

# mjqjpqmgbljsphdztnvjfqwrcgsmlb: first marker after character 19
# bvwbjplbgvbhsrlpgdmjqwftvncz: first marker after character 23
# nppdvjthqldpwncqszvftbrmjlhg: first marker after character 23
# nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg: first marker after character 29
# zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw: first marker after character 26

# How many characters need to be processed before the first start-of-message marker is detected?

function AreAllCharactersUnique {
    param (
        [Parameter(Mandatory, Position=0)]
        [char[]]
        $Chars
    )
    # If the count of the unique set of characters is the same as the number of
    # input characters - each character must be unique
    ($Chars | Select-Object -Unique).Count -eq $Chars.Count
}

$InputData = . "$PSScriptRoot\Inputs.ps1"
$Buffer = $InputData.ToCharArray()

# Starting at the 4th character, iterate through the array
$StartOfMessageIndex = -1
for ($i = 13; $i -lt $Buffer.Count; $i++) {
    if (AreAllCharactersUnique $Buffer[($i-13)..($i)]) {
        $StartOfMessageIndex = $i
        break
    }
}
# Add 1 to go from 0-indexed to 1-indexed
Write-Host "StartOfMessage found at offset $($StartOfMessageIndex + 1)"