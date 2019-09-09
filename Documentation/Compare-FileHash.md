# Compare-FileHash

## SYNOPSIS
Compares files from one location to another based on determining change via computed hash value.

## SYNTAX

### Path
```
Compare-FileHash -Path <String[]> -Destination <String> [-Algorithm <String>] [-Recurse] [<CommonParameters>]
```

### LiteralPath
```
Compare-FileHash -LiteralPath <String[]> -Destination <String> [-Algorithm <String>] [-Recurse]
 [<CommonParameters>]
```

## DESCRIPTION
The Compare-FileHash cmdlet uses the Get-FileHash cmdlet to compute the hash value of one or more files and then returns any changed
and new files from the specified source path.
If you use the -Recurse parameter the cmdlet will synchronise a full directory
tree, preserving the structure and creating any missing directories in the destination path as required.

The purpose of this cmdlet is to compare specific file changes between two paths in situations where you cannot rely on the modified
date of the files to determine if a file has changed.
This can occur in situations where file modified dates have been changed, such
as when cloning a set of files from a source control system.

## EXAMPLES

### EXAMPLE 1
```
Compare-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse
```

Compares the files between the two trees and returns any where they have different contents as determined via hash value comparison.

## PARAMETERS

### -Path
The path to the source file/s or folder/s to copy any new or changed files from.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -LiteralPath
The literal path to the source file/s or folder/s to copy any new or changed files from.
Unlike the Path parameter, the value of
LiteralPath is used exactly as it is typed.
No characters are interpreted as wildcards.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Destination
The Destination folder to compare to -Path or -LiteralPath and return any changed or new files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Algorithm
Specifies the cryptographic hash function to use for computing the hash value of the contents of the specified file.
A cryptographic
hash function includes the property that it is not possible to find two distinct inputs that generate the same hash values.
Hash
functions are commonly used with digital signatures and for data integrity.
The acceptable values for this parameter are:

SHA1 | SHA256 | SHA384 | SHA512 | MACTripleDES | MD5 | RIPEMD160

If no value is specified, or if the parameter is omitted, the default value is SHA256.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: SHA256
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse
Indicates that this cmdlet performs a recursive comparison.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
