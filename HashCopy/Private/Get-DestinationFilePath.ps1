function Get-DestinationFilePath {
    <#
        .SYNOPSIS
            Accepts a source and destination file paths and a file (that from the source path) and returns the equivalent destination path (regardless of whether it exists).

        .PARAMETER File
            The file to modify.

        .PARAMETER Source
            The source directory or file path.

        .PARAMETER Destination
            The destination path.

        .EXAMPLE
            Get-DestinationFilePath -File (Get-ChildItem c:\temp\somefile.txt) -Source c:\temp -Destination d:\example
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [System.IO.FileInfo]
        $File,

        [Parameter(Mandatory)]
        [String]
        $Source,

        [Parameter(Mandatory)]
        [String]
        $Destination
    )

    #Source and File are already-resolved, concrete paths (not user-typed wildcard patterns), so
    #-LiteralPath is used throughout to avoid characters like [ ] being misinterpreted as wildcards.
    if (Test-Path -LiteralPath $Source -PathType leaf) {
        $Source = Join-Path (Split-Path -Parent $Source) -ChildPath '/'
    }

    $ResolvedSource = Convert-Path -LiteralPath $Source

    $DestFile = Join-Path (Split-Path -Parent $File) -ChildPath '/'
    $DestFile = $DestFile -Replace "^$([Regex]::Escape($ResolvedSource))", $Destination
    $DestFile = Join-Path -Path $DestFile -ChildPath (Split-Path -Leaf $File)

    Return $DestFile
}
