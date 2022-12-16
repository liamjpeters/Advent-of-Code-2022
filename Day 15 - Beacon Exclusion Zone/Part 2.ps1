# Your handheld device indicates that the distress signal is coming from a beacon nearby. The 
# distress beacon is not detected by any sensor, but the distress beacon must have x and y 
# coordinates each no lower than 0 and no larger than 4000000.

# To isolate the distress beacon's signal, you need to determine its tuning frequency, which can be 
# found by multiplying its x coordinate by 4000000 and then adding its y coordinate.

# In the example above, the search space is smaller: instead, the x and y coordinates can each be at
# most 20. With this reduced search area, there is only a single position that could have a beacon: 
# x=14, y=11. The tuning frequency for this distress beacon is 56000011.

# Find the only possible position for the distress beacon. What is its tuning frequency?

$SensorAndBeaconData = . "$PSScriptRoot\Inputs.ps1"
$Sensors = @()
$Pattern = '^Sensor at x=(?<SensorX>[-\d].*?), y=(?<SensorY>[-\d].*?): closest beacon is at x=(?<BeaconX>[-\d].*?), y=(?<BeaconY>[-\d].*)$'

foreach ($Item in $SensorAndBeaconData) {
    if ($Item -match $Pattern) {
        $Sensor = [pscustomobject]@{
            SensorX = $Matches['SensorX'] -as [int64]
            SensorY = $Matches['SensorY'] -as [int64]
            BeaconX = $Matches['BeaconX'] -as [int64]
            BeaconY = $Matches['BeaconY'] -as [int64]
            MDist = 0
        }
        $Sensor.MDist = [Math]::Abs($Sensor.SensorX - $Sensor.BeaconX) + 
                        [Math]::Abs($Sensor.SensorY - $Sensor.BeaconY)

        $Sensors += $Sensor
    } else {
        throw "Something wrong with regex pattern. Item was not matched"
    }
    $i++
}

# Note: The whole thing would take ~25 mins to run.
#       Start from nearer what the answer is 😅
$CurrentPoint = @(0,3100000)
:Outer while ($true) {
    $CoveredBy = $null
    :Inner foreach ($Sensor in $Sensors) {
        if ($Sensor.MDist -ge ([Math]::Abs($Sensor.SensorX - $CurrentPoint[0]) + [Math]::Abs($Sensor.SensorY - $CurrentPoint[1]))) {
            $CoveredBy = $Sensor
            break Inner
        }
    }
    if ($null -eq $CoveredBy) {
        break Outer
    }
    $YDist = [Math]::Abs($CoveredBy.SensorY - $CurrentPoint[1])
    $XDist = [Math]::Abs($CoveredBy.SensorX - $CurrentPoint[0])
    $SkipBy = $CoveredBy.MDist - ($YDist + $XDist) + 1
    if ($CurrentPoint[0] + $SkipBy -gt 4000000) {
        $CurrentPoint[0] = 0
        $CurrentPoint[1]++
    } else {
        $CurrentPoint[0] += $SkipBy
    }
    Write-Host "$($CurrentPoint[0], $CurrentPoint[1])"
}

Write-Host "$($CurrentPoint[0]*4000000 + $CurrentPoint[1])"