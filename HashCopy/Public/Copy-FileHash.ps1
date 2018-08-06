function Copy-FileHash {
    <#
        .SYNOPSIS
            Copies an item from one location to another based on determining change via computed hash value.

        .DESCRIPTION
            The Copy-FileHash cmdlet uses the Get-FileHash cmdlet to compute the hash value of one or more files and then copies any changed
            and new files to the specified destination path. If you use the -Recurse parameter the cmdlet will synchronise a full directory
            tree, preserving the structure and creating any missing directories in the destination path as required.

            The purpose of this cmdlet is to copy specific file changes between two paths in situations where you cannot rely on the modified
            date of the files to determine if a file has changed. This can occur in situations where file modified dates have been changed, such
            as when cloning a set of files from a source control system.

        .PARAMETER Path
            The Source file or folder to copy any new or changed files from.

        .PARAMETER Destination
            The Destination file or folder to compare to source and overwrite with any changed or new files.
        
        .PARAMETER Recurse
            Indicates that this cmdlet performs a recursive copy.

        .PARAMETER Force
            Indicates that this cmdlet will copy items that cannot otherwise be changed, such as copying over a read-only file or alias.

        .EXAMPLE
            Copy-FileHash -Source C:\Some\Files -Destination D:\Some\Other\Files -Recurse
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript( {if (Test-Path $_) {$True} Else {Throw '-Source must be a valid path.'} })]
        [String]
        $Path,

        [Parameter(Mandatory)]
        [String]
        $Destination,

        #Recurse sub-folders
        [switch]
        $Recurse,

        #Enable -Force on Copy-Item
        [switch]
        $Force
    )

    $Source = (Get-Item $Path).FullName
    $Destination = (Get-Item $Destination).FullName
    $SourceFiles = (Get-ChildItem -Path $Source -Recurse:$Recurse -File).FullName

    ForEach ($SourceFile in $SourceFiles) {
        
        $DestFile = $SourceFile -Replace "^$([Regex]::Escape($Source))", $Destination
        
        If ((-Not (Test-Path $DestFile)) -and $PSCmdlet.ShouldProcess($DestFile, 'New-Item')) {
            #Using New-Item -Force creates an initial destination file along with any folders missing from its path.
            New-Item -Path $DestFile -Force | Out-Null
        }

        $SourceHash = (Get-FileHash $SourceFile).hash
        $DestHash = (Get-FileHash $DestFile).hash
        
        If (($SourceHash -ne $DestHash) -and $PSCmdlet.ShouldProcess($SourceFile, 'Copy-Item')) {
            Copy-Item -Path $SourceFile -Destination $DestFile -Force:$Force
        }
    }
}