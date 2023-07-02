# Copy-FileHash

## SYNOPSIS
Copies files from one location to another based on determining change via computed hash value.

## SYNTAX

### Path
```
Copy-FileHash -Path <String[]> -Destination <String> [-Algorithm <String>] [-Exclude <String[]>] [-PassThru]
 [-Recurse] [-Mirror] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### LiteralPath
```
Copy-FileHash -LiteralPath <String[]> -Destination <String> [-Algorithm <String>] [-Exclude <String[]>]
 [-PassThru] [-Recurse] [-Mirror] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Copy-FileHash cmdlet uses the Get-FileHash cmdlet to compute the hash value of one or more files and then copies any changed
and new files to the specified destination path.
If you use the -Recurse parameter the cmdlet will synchronise a full directory
tree, preserving the structure and creating any missing directories in the destination path as required.

The purpose of this cmdlet is to copy specific file changes between two paths in situations where you cannot rely on the modified
date of the files to determine if a file has changed.
This can occur in situations where file modified dates have been changed, such
as when cloning a set of files from a source control system.

## EXAMPLES

### EXAMPLE 1
```
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse
```

Compares the files between the two trees and replaces in the destination any where they have different contents as determined
via hash value comparison.

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
The Destination folder to compare to -Path and overwrite with any changed or new files from -Path.
If the folder does not exist
It will be created.

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

### -Exclude
Exclude one or more files from being copied.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Returns the output of the file copy as an object.
By default, this cmdlet does not generate any output.

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

### -Recurse
Indicates that this cmdlet performs a recursive copy.

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

### -Mirror
Use to remove files from the Destination path that are no longer in any of the Source paths.

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

### -Force
Indicates that this cmdlet will copy items that cannot otherwise be changed, such as copying over a read-only file or alias.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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
