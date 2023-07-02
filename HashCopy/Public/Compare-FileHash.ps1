function Compare-FileHash {
    <#
        .SYNOPSIS
            Compares files from one location to another based on determining change via computed hash value.

        .DESCRIPTION
            The Compare-FileHash cmdlet uses the Get-FileHash cmdlet to compute the hash value of one or more files and then returns any changed
            and new files from the specified source path. If you use the -Recurse parameter the cmdlet will synchronise a full directory
            tree, preserving the structure and creating any missing directories in the destination path as required.

            The purpose of this cmdlet is to compare specific file changes between two paths in situations where you cannot rely on the modified
            date of the files to determine if a file has changed. This can occur in situations where file modified dates have been changed, such
            as when cloning a set of files from a source control system.

        .PARAMETER Path
            The path to the source file/s or folder/s to copy any new or changed files from.

        .PARAMETER LiteralPath
            The literal path to the source file/s or folder/s to copy any new or changed files from. Unlike the Path parameter, the value of
            LiteralPath is used exactly as it is typed. No characters are interpreted as wildcards.

        .PARAMETER Destination
            The Destination folder to compare to -Path or -LiteralPath and return any changed or new files.

        .PARAMETER Algorithm
            Specifies the cryptographic hash function to use for computing the hash value of the contents of the specified file. A cryptographic
            hash function includes the property that it is not possible to find two distinct inputs that generate the same hash values. Hash
            functions are commonly used with digital signatures and for data integrity. The acceptable values for this parameter are:

            SHA1 | SHA256 | SHA384 | SHA512 | MACTripleDES | MD5 | RIPEMD160

            If no value is specified, or if the parameter is omitted, the default value is SHA256.

        .PARAMETER Exclude
            Exclude one or more files from being compared.

        .PARAMETER Recurse
            Indicates that this cmdlet performs a recursive comparison.

        .EXAMPLE
            Compare-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse

            Compares the files between the two trees and returns any where they have different contents as determined via hash value comparison.
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateScript( {if (Test-Path $_) {$True} Else { Throw '-Path must be a valid path.'} })]
        [String[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateScript( {if (Test-Path $_) {$True} Else { Throw '-LiteralPath must be a valid path.'} })]
        [String[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateScript( {if (Test-Path $_ -PathType Container -IsValid) {$True} Else { Throw '-Destination must be a valid path.' } })]
        [String]
        $Destination,

        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MACTripleDES', 'MD5', 'RIPEMD160')]
        [String]
        $Algorithm = 'SHA256',

        [string[]]
        $Exclude,

        [switch]
        $Recurse
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
                throw "$Destination does not exist"
            }
            else {
                $Destination = Join-Path ((Resolve-Path -Path $Destination).Path) -ChildPath '/'
            }
        }
        catch {
            throw $_
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
                    Write-Verbose "New file: $SourceFile"
                    $DestHash = $null
                }

                if ($SourceHash -ne $DestHash) {
                    Get-ChildItem -Path $SourceFile
                }
            }
        }
    }
}