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
            The path to the source file/s or folder/s to copy any new or changed files from.

        .PARAMETER LiteralPath
            The literal path to the source file/s or folder/s to copy any new or changed files from. nlike the Path parameter, the value of
            LiteralPath is used exactly as it is typed. No characters are interpreted as wildcards.

        .PARAMETER Destination
            The Destination file or folder to compare to -Path and overwrite with any changed or new files from -Path.

        .PARAMETER Algorithm
            Specifies the cryptographic hash function to use for computing the hash value of the contents of the specified file. A cryptographic
            hash function includes the property that it is not possible to find two distinct inputs that generate the same hash values. Hash
            functions are commonly used with digital signatures and for data integrity. The acceptable values for this parameter are:

            SHA1 | SHA256 | SHA384 | SHA512 | MACTripleDES | MD5 | RIPEMD160

            If no value is specified, or if the parameter is omitted, the default value is SHA256.

        .PARAMETER PassThru
            Returns the output of the file copy as an object. By default, this cmdlet does not generate any output.

        .PARAMETER Recurse
            Indicates that this cmdlet performs a recursive copy.

        .PARAMETER Force
            Indicates that this cmdlet will copy items that cannot otherwise be changed, such as copying over a read-only file or alias.

        .EXAMPLE
            Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [ValidateScript( {if (Test-Path $_) {$True} Else { Throw '-Path must be a valid path.'} })]
        [String]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'LiteralPath')]
        [ValidateScript( {if (Test-Path $_) {$True} Else { Throw '-LiteralPath must be a valid path.'} })]
        [String]
        $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateScript( {if (Test-Path $_ -IsValid) {$True} Else { Throw '-Destination must be a valid path.' } })]
        [String]
        $Destination,

        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MACTripleDES', 'MD5', 'RIPEMD160')]
        [String]
        $Algorithm = 'SHA256',

        [switch]
        $PassThru,

        [switch]
        $Recurse,

        [switch]
        $Force
    )

    $Source = If ($PSBoundParameters.ContainsKey('LiteralPath')) {
        (Get-Item -LiteralPath $Path).FullName
    }
    Else {
        (Get-Item -Path $Path).FullName
    }

    $Destination = (Get-Item $Destination).FullName
    $SourceFiles = (Get-ChildItem -Path $Source -Recurse:$Recurse -File).FullName

    ForEach ($SourceFile in $SourceFiles) {

        $DestFile = $SourceFile -Replace "^$([Regex]::Escape($Source))", $Destination

        If ((-Not (Test-Path $DestFile)) -and $PSCmdlet.ShouldProcess($DestFile, 'New-Item')) {
            #Using New-Item -Force creates an initial destination file along with any folders missing from its path.
            New-Item -Path $DestFile -Force | Out-Null
        }

        $SourceHash = (Get-FileHash $SourceFile -Algorithm $Algorithm).hash
        $DestHash = (Get-FileHash $DestFile -Algorithm $Algorithm).hash

        If (($SourceHash -ne $DestHash) -and $PSCmdlet.ShouldProcess($SourceFile, 'Copy-Item')) {
            Copy-Item -Path $SourceFile -Destination $DestFile -Force:$Force -PassThru:$PassThru
        }
    }
}