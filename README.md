# PowerShell-HashCopy

[![Build Status](https://dev.azure.com/markwragg/GitHub/_apis/build/status/markwragg.PowerShell-HashCopy?branchName=master)](https://dev.azure.com/markwragg/GitHub/_build/latest?definitionId=2&branchName=master) ![Test Coverage](https://img.shields.io/badge/coverage-92%25-brightgreen.svg?maxAge=60)

This PowerShell module contains cmdlets for copying and comparing specific files between two paths, where those files have been determined to have changed via a computed hash value. This is useful if you need to sync specific file changes from one directory to another but cannot trust the modified date of the files to determine which files have been modified (for example, if the source files has been cloned from a source control system and as a result the modified dates had changed). 

You should of course be confident that if there is a difference between two files, it is the copy you have specified as being in the source `-Path` that you want to use to overwrite the copy in the `-Destination` path. New files (files that exist in the source path but not in the destination) will also be copied across, including any directories in their paths that may be missing in the destination folder.

You can synchronise an entire directory tree by using the `-Recurse` parameter.

# Installation

The module is published in the PSGallery, so if you have PowerShell 5 or newer can be installed by running:

```
Install-Module HashCopy -Scope CurrentUser
```

## Usage

### Copy-FileHash

You can use the `Copy-FileHash` cmdlet to sync a single path by providing it with `-Path` and `-Destination` parameters:
```
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files
```
This will compute the hash for all files in each directory (and all sub-directories, due to `-Recurse`) via the `Get-FileHash` cmdlet and then will copy any changed and new files from the source path to the destination path. 

You can include all the sub-folders of the source `-Path` by adding `-Recurse`:
```
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse
```

You can specify a `-LiteralPath` instead of a Path if you want to avoid wildcard characters from being interpreted as such:
```
Copy-FileHash -LiteralPath C:\Some\Files -Destination D:\Some\Other\Files -Recurse
```

You can remove files from the Destination path that are not in the Source path by adding `-Mirror`:
```
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Mirror
```

You can have the destination file objects returned by adding `-PassThru`:
```
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse -PassThru
```

You can Force the overwrite of read-only files in the Destination path by adding `-Force`:
```
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Force
```

You can specify the algorithm that `Get-FileHash` uses to create the Hash by using `-Algorithm`:
```
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Algorithm MD5
```
Valid `-Algorithm` values are: SHA1 | SHA256 | SHA384 | SHA512 | MACTripleDES | MD5 | RIPEMD160.

### Compare-FileHash

If you'd like to check which files will be copied from a source path before actually using `Copy-FileHash`, you can use `Compare-FileHash`. This cmdlet outputs file objects for any new or modified file having performed the same comparison as the `Copy-` cmdlet (e.g via using Get-FileHash of the source and destination file to determine if they are different).

Check which files would be copied from one single directory to another:
```
Compare-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files
```
Check which files would be copied between one directory tree and another (including all sub-directories):
```
Compare-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse
```

As with `Copy-FileHash` you can use `-LiteralPath` instead of `-Path` to have paths interpreted literally.

## Cmdlets

A full list of cmdlets in this module is provided below for reference. Use `Get-Help <cmdlet name>` with these to learn more about their usage.

Cmdlet           | Description
-----------------| -------------------------------------------------------------------------------------------------------
Copy-FileHash    | Copies any files between two directory paths that are new or have changed based on computed hash value.
Compare-FileHash | Compares files from one location to another based on determining change via computed hash value.
