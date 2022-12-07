# Now, you're ready to choose a directory to delete.

# The total disk space available to the filesystem is 70000000. To run the update, you need unused 
# space of at least 30000000. You need to find a directory you can delete that will free up enough 
# space to run the update.

# In the example above, the total size of the outermost directory (and thus the total amount of used
# space) is 48381165; this means that the size of the unused space must currently be 21618835, which
# isn't quite the 30000000 required by the update. Therefore, the update still requires a directory 
# with total size of at least 8381165 to be deleted before it can run.

# To achieve this, you have the following options:

# Delete directory e, which would increase unused space by 584.
# Delete directory a, which would increase unused space by 94853.
# Delete directory d, which would increase unused space by 24933642.
# Delete directory /, which would increase unused space by 48381165.

# Directories e and a are both too small; deleting them would not free up enough space. However, 
# directories d and / are both big enough! Between these, choose the smallest: d, increasing unused 
# space by 24933642.

# Find the smallest directory that, if deleted, would free up enough space on the filesystem to run 
# the update. What is the total size of that directory?

class Node {
    hidden [string] $TabChar = '    '
    hidden [Node] $Parent = $null
    [string] $Name = ''
    [int64] $Size = 0

    [void] SetParent([Node] $Parent) {
        $this.Parent = $Parent
    }

    [Node] GetParent() {
        return $this.Parent
    }

    [void] Print([int32] $IndentLevel = 0) {
        Write-Host "$($this.TabChar*$IndentLevel)$($this.Name) (node)"
    }

}

class Folder : Node {
    hidden [System.Collections.Generic.List[Node]] $Children = 
        [System.Collections.Generic.List[Node]]::new()

    Folder([string] $Name) {
        $this.Name = $Name
    }

    [void] AddChild([Node] $Child) {
        $Child.SetParent($this)
        $this.Children.Add($Child)
        $this.IncrementSize($Child.Size)
    }

    [System.Collections.Generic.List[Node]] GetChildren() {
        return $this.Children
    }

    [Node] GetChildByName([string] $Name, [bool] $DirOnly = $false) {
        foreach ($Child in $this.Children.GetEnumerator()) {
            if ($DirOnly -and ($Child -is [File])) {
                continue
            }
            if ($Child.Name -eq $Name) {
                return $Child
            }
        }
        return $null
    }

    [void] Print([int32] $IndentLevel = 0) {
        Write-Host "$($this.TabChar*$IndentLevel)$($this.Name) (dir, size = $($this.Size))"
        foreach ($Child in $this.Children.GetEnumerator()) {
            $Child.Print($IndentLevel + 1)
        }
    }

    [void] ParseLSOutput([string[]]$LSOutput) {
        foreach ($Line in $LSOutput) {
            $SplitOnSpace = $Line.Split(' ')
            if ($SplitOnSpace[0] -eq 'dir') {
                $Folder = [Folder]::new($SplitOnSpace[1])
                $this.AddChild($Folder)
            } else {
                $File = [File]::new($SplitOnSpace[1], ($SplitOnSpace[0] -as [int64]))
                $this.AddChild($File)
            }
        }
    }

    [void] IncrementSize([int64] $IncrementBy) {
        $this.Size += $IncrementBy
        if ($null -ne $this.Parent) {
            $this.Parent.IncrementSize($IncrementBy)
        }
    }

}

class File : Node {
    File([string] $Name, [int64] $Size) {
        $this.Name = $Name
        $this.Size = $Size
    }

    [void] Print([int32] $IndentLevel = 0) {
        Write-Host "$($this.TabChar*$IndentLevel)$($this.Name) (file, size = $($this.Size))"
    }
}

function New-AoCFile {
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,
        [Parameter(Mandatory, Position = 1)]
        [ValidateRange(1,[int64]::MaxValue)]
        [int64]
        $Size
    )
    [File]::new($Name,$Size)
}

function New-AoCFolder {
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )
    [Folder]::new($Name)
}

$InputData = . "$PSScriptRoot\Inputs.ps1"
$RootFolder = New-AoCFolder '/'

# Keep Track of where we are in our TerminalOutput and what the current folder is
$TerminalCursor = 0
$CurrentFolder = $RootFolder

while ($TerminalCursor -lt $InputData.Count - 1) {
    $Instruction = $InputData[$TerminalCursor]

    if (-not $Instruction.StartsWith('$')) {
        # If we are currently looking at something that is not 
        # an instruction - something has gone awry
        throw "Expected instruction, got '$Instruction'"
    }
    # Get rid of the dollar-space, split on space to seperate into
    # command and arguments
    $SplitInstruction = $Instruction.Replace('$ ','').split(' ')
    $Command = $SplitInstruction[0]
    $Arguments = $SplitInstruction | Select-Object -Skip 1
    :switchLabel switch ($Command) {
        'cd' {
            if (($Arguments | Measure-Object).Count -gt 1) {
                throw "Unexpected number of arguments for 'cd' - '$($Arguments -join ' ')'"
            }
            if ($Arguments -eq '..') {
                # Up a directory
                $Parent = $CurrentFolder.GetParent()
                Write-Verbose "Moving from '$($CurrentFolder.Name)' to '$($Parent.Name)'"
                $CurrentFolder = $Parent
            } elseif ($Arguments -eq '/') {
                # Go to root directory
                Write-Verbose "Moving from '$($CurrentFolder.Name)' to '$($RootFolder.Name)'"
                $CurrentFolder = $RootFolder
            } else {
                # find folder in current directory
                Write-Verbose "Moving from '$($CurrentFolder.Name)' to a folder with name '$($Arguments)'"
                $Directory = $CurrentFolder.GetChildByName($Arguments, $true)
                if ($null -eq $Directory) {
                    throw "Couldn't find folder with name '$($Arguments)' in directory '$($CurrentFolder.Name)'"
                }
                $CurrentFolder = $Directory
            }
            $TerminalCursor++
            break
        }
        'ls' {
            if (($Arguments | Measure-Object).Count -gt 0) {
                throw "Unexpected number of arguments for 'ls' - '$($Arguments -join ' ')'"
            }
            # Increment the cursor
            # Get the LS Output and pass it to the current folder for parsing into
            # children

            $TerminalCursor++
            # Find the next line that has a dollar-sign at the start
            for ($i = $TerminalCursor; $i -lt $InputData.Count; $i++) {
                if ($InputData[$i].StartsWith('$')) {
                    $CurrentFolder.ParseLSOutput($InputData[$TerminalCursor..$($i-1)])
                    $TerminalCursor = $i
                    break switchLabel
                }
            }
            $CurrentFolder.ParseLSOutput($InputData[$TerminalCursor..$($InputData.Count-1)])
            # We didn't find another command - set the cursor to past the end of the data
            # so the while loop ends
            $TerminalCursor = $InputData.Count + 1

            break
        }
        default {
            throw "Not yet implemented '$Command'"
        }
    }
}

function GetDirectoriesEqualToOrUnderSize {
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Collections.Generic.List[Node]] 
        $Nodes,
        [int64] 
        $SizeLimit = 100000
    )
    $CollectedNodes = @()
    foreach ($Node in $Nodes.GetEnumerator()) {
        if ($Node -is [File]) {
            continue
        }
        if ($Node.Size -le $SizeLimit) {
            $CollectedNodes += $Node
        }
        $CollectedFromChildren = GetDirectoriesEqualToOrUnderSize $Node.GetChildren() -SizeLimit $SizeLimit
        $CollectedNodes += $CollectedFromChildren
    }
    return $CollectedNodes
}

function GetDirectoriesEqualToOrOverSize {
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Collections.Generic.List[Node]] 
        $Nodes,
        [int64] 
        $SizeLimit = 100000
    )
    $CollectedNodes = @()
    foreach ($Node in $Nodes.GetEnumerator()) {
        if ($Node -is [File]) {
            continue
        }
        if ($Node.Size -ge $SizeLimit) {
            $CollectedNodes += $Node
        }
        $CollectedFromChildren = GetDirectoriesEqualToOrOverSize $Node.GetChildren() -SizeLimit $SizeLimit
        $CollectedNodes += $CollectedFromChildren
    }
    return $CollectedNodes
}

$TotalSystemSpace = 70000000 # 70 million
$SpaceNeededForUpdate = 30000000 # 30 million
$UsedSpace = $RootFolder.Size
$FreeSpace = $TotalSystemSpace - $UsedSpace

$FreeUp = $SpaceNeededForUpdate - $FreeSpace

$DirGTEFreeUpSapce = GetDirectoriesEqualToOrOverSize $RootFolder.GetChildren() -SizeLimit $FreeUp

$PickedDir = $DirGTEFreeUpSapce | Sort-Object Size | Select-Object -First 1

Write-Host "Picked Directory '$($PickedDir.Name)' with size '$($PickedDir.Size)'"
