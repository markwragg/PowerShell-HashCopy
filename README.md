# PowerShell-HashCopy

![Test Coverage](https://img.shields.io/badge/coverage-74%25-orange.svg?maxAge=60)

This PowerShell module contains a cmdlet for copying specific files between two paths, where those files have been determined to have changed via a computed hash value. This is useful if you need to sync specific file changes from one directory to another but cannot trust the modified date of the files to determine which files have been modified (for example, if the source files has been cloned from a source control system and as a result the modified dates had changed). 

You should of course be confident that if there is a difference between two files, it is the copy you have specified as being in the `-source` path that you want to overwrite the copy in the destination. New files (files that exist in the source but not in the destination) will also be copied across, including any directories in their paths that may be missing in the destination folder.

You can syncronise an entire directory tree by using the `-Recurse` parameter.

# Installation

The module is published in the PSGallery, so if you have PowerShell 5 or newer can be installed by running:

```
Install-Module HashCopy -Scope CurrentUser
```

## Usage

You can use the `Copy-FileHash` cmdlet by providing it with a `-Source` and `-Destination` path:

```
Copy-FileHash -Source C:\Some\Files -Destination D:\Some\Other\Files -Recurse
```

This will compute the hash for all files in each directory (and all sub-directories, due to `-Recurse`) via the `Get-FileHash` cmdlet and then will copy any changed and new files from the source path to the destination path. 

## Cmdlets

A full list of cmdlets in this module is provided below for reference. Use `Get-Help <cmdlet name>` with these to learn more about their usage.

Cmdlet        | Description
--------------| -------------------------------------------------------------------------------------------------------
Copy-FileHash | Copies any files between two directory paths that are new or have changed based on computed hash value.
