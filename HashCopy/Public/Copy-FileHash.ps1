function Copy-FileHash {
    <#
        .SYNOPSIS
            Copies files from one location to another based on determining change via computed hash value.

        .DESCRIPTION
            The Copy-FileHash cmdlet uses the Get-FileHash cmdlet to compute the hash value of one or more files and then copies any changed
            and new files to the specified destination path. If you use the -Recurse parameter the cmdlet will synchronise a full directory
            tree, preserving the structure and creating any missing directories in the destination path as required.

            The purpose of this cmdlet is to copy specific file changes between two paths in situations where you cannot rely on the modified
            date of the files to determine if a file has changed. This can occur in situations where file modified dates have been changed, such
            as when cloning a set of files from a source control system.

        .PARAMETER Path
            The path to the source file/s or folder/s to copy any new or changed files from.

        .PARAMETER LiteralPath
            The literal path to the source file/s or folder/s to copy any new or changed files from. Unlike the Path parameter, the value of
            LiteralPath is used exactly as it is typed. No characters are interpreted as wildcards.

        .PARAMETER Destination
            The Destination folder to compare to -Path and overwrite with any changed or new files from -Path. If the folder does not exist
            It will be created.

        .PARAMETER Algorithm
            Specifies the cryptographic hash function to use for computing the hash value of the contents of the specified file. A cryptographic
            hash function includes the property that it is not possible to find two distinct inputs that generate the same hash values. Hash
            functions are commonly used with digital signatures and for data integrity. The acceptable values for this parameter are:

            SHA1 | SHA256 | SHA384 | SHA512 | MACTripleDES | MD5 | RIPEMD160

            If no value is specified, or if the parameter is omitted, the default value is SHA256.

        .PARAMETER Exclude
            Exclude one or more files from being copied.

        .PARAMETER PassThru
            Returns the output of the file copy as an object. By default, this cmdlet does not generate any output.

        .PARAMETER Recurse
            Indicates that this cmdlet performs a recursive copy.

        .PARAMETER Mirror
            Use to remove files from the Destination path that are no longer in any of the Source paths.

        .PARAMETER Force
            Indicates that this cmdlet will copy items that cannot otherwise be changed, such as copying over a read-only file or alias.

        .EXAMPLE
            Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse

            Compares the files between the two trees and replaces in the destination any where they have different contents as determined
            via hash value comparison.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateScript( {if (Test-Path $_) {$True} Else { Throw '-Path must be a valid path.'} })]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateScript( {if (Test-Path $_) {$True} Else { Throw '-LiteralPath must be a valid path.'} })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateScript( {if (Test-Path $_ -PathType Container -IsValid) {$True} Else { Throw '-Destination must be a valid path.' } })]
        [string]
        $Destination,

        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MACTripleDES', 'MD5', 'RIPEMD160')]
        [string]
        $Algorithm = 'SHA256',

        [string[]]
        $Exclude,

        [switch]
        $PassThru,

        [switch]
        $Recurse,

        [switch]
        $Mirror,

        [switch]
        $Force
    )
    begin {
        try {
            $SourcePath = if ($PSBoundParameters.ContainsKey('LiteralPath')) {
                (Resolve-Path -LiteralPath $LiteralPath).Path
            }
            else {
                (Resolve-Path -Path $Path).Path
            }

            if (-Not (Test-Path $Destination)) {
                New-Item -Path $Destination -ItemType Container | Out-Null
                Write-Warning "$Destination did not exist and has been created as a folder path."
            }

            $Destination = Join-Path ((Resolve-Path -Path $Destination).Path) -ChildPath '/'
        }
        catch {
            throw $_
        }

        if ($Mirror -and ($SourcePath -is [array])) {
            throw 'Cannot use -Mirror with an array of Paths. Specify a single Source path only.'
        }

    }
    process {
        foreach ($Source in $SourcePath) {
            $SourceFiles = (Get-ChildItem -Path $Source -Recurse:$Recurse -File -Exclude $Exclude).FullName

            foreach ($SourceFile in $SourceFiles) {
                $DestFile = Get-DestinationFilePath -File $SourceFile -Source $Source -Destination $Destination
                $SourceHash = (Get-FileHash $SourceFile -Algorithm $Algorithm).hash

                if (Test-Path $DestFile) {
                    $DestHash = (Get-FileHash $DestFile -Algorithm $Algorithm).hash
                }
                else {
                    #Using New-Item -Force creates an initial destination file along with any folders missing from its path.
                    #We use (Get-Date).Ticks to give the file a random value so that it is copied even if the source file is
                    #empty, so that if -PassThru has been used it is returned.
                    if ($PSCmdlet.ShouldProcess($DestFile, 'New-Item')) {
                        New-Item -Path $DestFile -Value (Get-Date).Ticks -Force -ItemType 'file' | Out-Null
                    }
                    $DestHash = $null
                }

                if (($SourceHash -ne $DestHash) -and $PSCmdlet.ShouldProcess($SourceFile, 'Copy-Item')) {
                    Copy-Item -Path $SourceFile -Destination $DestFile -Force:$Force -PassThru:$PassThru
                }
            }

            if ($Mirror) {
                $DestFiles = (Get-ChildItem $Destination -Recurse:$Recurse -File).FullName

                foreach ($DestFile in $DestFiles) {
                    $SourceFile = Get-DestinationFilePath -File $DestFile -Source $Destination -Destination $Source

                    if (-not (Test-Path $SourceFile)) {
                        if ($PSCmdlet.ShouldProcess($DestFile, 'Remove-Item')) {
                            Remove-Item $DestFile
                        }
                    }
                }
            }
        }
    }
}
