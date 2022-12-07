# You can hear birds chirping and raindrops hitting leaves as the expedition proceeds. Occasionally,
# you can even hear much louder sounds in the distance; how big do the animals get out here, anyway?

# The device the Elves gave you has problems with more than just its communication system. You try 
# to run a system update:

#   $ system-update --please --pretty-please-with-sugar-on-top
#   Error: No space left on device

# Perhaps you can delete some files to make space for the update?

# You browse around the filesystem to assess the situation and save the resulting terminal output 
# (your puzzle input). For example:

#   $ cd /
#   $ ls
#   dir a
#   14848514 b.txt
#   8504156 c.dat
#   dir d
#   $ cd a
#   $ ls
#   dir e
#   29116 f
#   2557 g
#   62596 h.lst
#   $ cd e
#   $ ls
#   584 i
#   $ cd ..
#   $ cd ..
#   $ cd d
#   $ ls
#   4060174 j
#   8033020 d.log
#   5626152 d.ext
#   7214296 k

# The filesystem consists of a tree of files (plain data) and directories (which can contain other 
# directories or files). The outermost directory is called /. You can navigate around the 
# filesystem, moving into or out of directories and listing the contents of the directory you're 
# currently in.

# Within the terminal output, lines that begin with $ are commands you executed, very much like some
#  modern computers:

# cd means change directory. This changes which directory is the current directory, but the specific
# result depends on the argument:

#   - cd x moves in one level: it looks in the current directory for the directory named x and makes 
#     it the current directory.
#   - cd .. moves out one level: it finds the directory that contains the current directory, then 
#     makes that directory the current directory.
#   - cd / switches the current directory to the outermost directory, /.

# ls means list. It prints out all of the files and directories immediately contained by the current
# directory:
#   - 123 abc means that the current directory contains a file named abc with size 123.
#   - dir xyz means that the current directory contains a directory named xyz.

# Given the commands and output in the example above, you can determine that the filesystem looks 
# visually like this:

# - / (dir)
#   - a (dir)
#     - e (dir)
#       - i (file, size=584)
#     - f (file, size=29116)
#     - g (file, size=2557)
#     - h.lst (file, size=62596)
#   - b.txt (file, size=14848514)
#   - c.dat (file, size=8504156)
#   - d (dir)
#     - j (file, size=4060174)
#     - d.log (file, size=8033020)
#     - d.ext (file, size=5626152)
#     - k (file, size=7214296)

# Here, there are four directories: / (the outermost directory), a and d (which are in /), and 
# e (which is in a). These directories also contain files of various sizes.

# Since the disk is full, your first step should probably be to find directories that are good 
# candidates for deletion. To do this, you need to determine the total size of each directory. The 
# total size of a directory is the sum of the sizes of the files it contains, directly or 
# indirectly. (Directories themselves do not count as having any intrinsic size.)

# The total sizes of the directories above can be found as follows:
#   - The total size of directory e is 584 because it contains a single file i of size 584 and no 
#     other directories.
#   - The directory a has total size 94853 because it contains files f (size 29116), g (size 2557), 
#     and h.lst (size 62596), plus file i indirectly (a contains e which contains i).
#   - Directory d has total size 24933642.

# As the outermost directory, / contains every file. Its total size is 48381165, the sum of the size
# of every file.

# To begin, find all of the directories with a total size of at most 100000, then calculate the sum 
# of their total sizes. In the example above, these directories are a and e; the sum of their total 
# sizes is 95437 (94853 + 584). (As in this example, this process can count files more than once!)

# Find all of the directories with a total size of at most 100000. 
# What is the sum of the total sizes of those directories?

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
        $CollectedFromChildren = GetDirectoriesEqualToOrUnderSize $Node.GetChildren()
        $CollectedNodes += $CollectedFromChildren
    }
    return $CollectedNodes
}

$DirectoriesEqualToOrUnder100k = GetDirectoriesEqualToOrUnderSize $RootFolder.GetChildren()

$TotalSizeOfDirectoriesAtOrUnder100k = $DirectoriesEqualToOrUnder100k | 
    Measure-Object -Property 'Size' -Sum | 
    Select-Object -ExpandProperty Sum

Write-Host "The sum of the total sizes of those directories is $TotalSizeOfDirectoriesAtOrUnder100k"