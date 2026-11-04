# PowerShell-HashCopy

[![Build Status](https://github.com/markwragg/PowerShell-HashCopy/actions/workflows/build.yml/badge.svg)](https://github.com/markwragg/PowerShell-HashCopy/actions/workflows/build.yml)
![coverage](https://img.shields.io/badge/coverage-95%25-brightgreen.svg)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/hashcopy?label=PS%20Gallery)](https://www.powershellgallery.com/packages/hashcopy)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/hashcopy?color=D3D3D3)](https://www.powershellgallery.com/packages/hashcopy)

This PowerShell module contains cmdlets for copying and comparing specific files between two paths, where those files have been determined to have changed via a computed hash value. This is useful if you need to sync specific file changes from one directory to another but cannot trust the modified date of the files to determine which files have been modified (for example, if the source files has been cloned from a source control system and as a result the modified dates had changed).

You should of course be confident that if there is a difference between two files, it is the copy you have specified as being in the source `-Path` that you want to use to overwrite the copy in the `-Destination` path. New files (files that exist in the source path but not in the destination) will also be copied across, including any directories in their paths that may be missing in the destination folder.

You can synchronise an entire directory tree by using the `-Recurse` parameter.

This module is cross-platform and works anywhere PowerShell runs, including Windows, Linux, and macOS (via PowerShell 7+ / PowerShell Core).

# Installation

The module is published in the PSGallery, so if you have PowerShell 5 or newer can be installed by running:

```powershell
Install-Module HashCopy -Scope CurrentUser
```

## Cmdlets

A full list of cmdlets in this module is provided below for reference. Use `Get-Help <cmdlet name>` with these to learn more about their usage.

Cmdlet           | Description
-----------------| -------------------------------------------------------------------------------------------------------
Copy-FileHash    | Copies any files between two directory paths that are new or have changed based on computed hash value.
Compare-FileHash | Compares files from one location to another based on determining change via computed hash value.


## Usage

### Copy-FileHash

You can use the `Copy-FileHash` cmdlet to sync a single path by providing it with `-Path` and `-Destination` parameters:

```powershell
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files
```
This will compute the hash for all files in each directory (and all sub-directories, due to `-Recurse`) via the `Get-FileHash` cmdlet and then will copy any changed and new files from the source path to the destination path.

As this module is cross-platform, the same cmdlet works identically on Linux or macOS using native paths:

```powershell
Copy-FileHash -Path /home/user/Some/Files -Destination /mnt/backup/Some/Other/Files
```

You can include all the sub-folders of the source `-Path` by adding `-Recurse`:

```powershell
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse
```

You can specify a `-LiteralPath` instead of a Path if you want to avoid wildcard characters from being interpreted as such:

```powershell
Copy-FileHash -LiteralPath C:\Some\Files -Destination D:\Some\Other\Files -Recurse
```

You can remove files from the Destination path that are not in the Source path by adding `-Mirror`:

```powershell
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Mirror
```

You can have the destination file objects returned by adding `-PassThru`:

```powershell
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse -PassThru
```

You can Force the overwrite of read-only files in the Destination path by adding `-Force`:

```powershell
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Force
```

You can specify the algorithm that `Get-FileHash` uses to create the Hash by using `-Algorithm`:

```powershell
Copy-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Algorithm MD5
```
Valid `-Algorithm` values are: SHA1 | SHA256 | SHA384 | SHA512 | MACTripleDES | MD5 | RIPEMD160.

### Compare-FileHash

If you'd like to check which files will be copied from a source path before actually using `Copy-FileHash`, you can use `Compare-FileHash`. This cmdlet outputs file objects for any new or modified file having performed the same comparison as the `Copy-` cmdlet (e.g via using Get-FileHash of the source and destination file to determine if they are different).

Check which files would be copied from one single directory to another:

```powershell
Compare-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files
```
Check which files would be copied between one directory tree and another (including all sub-directories):

```powershell
Compare-FileHash -Path C:\Some\Files -Destination D:\Some\Other\Files -Recurse
```

As with `Copy-FileHash` you can use `-LiteralPath` instead of `-Path` to have paths interpreted literally.

The same cmdlets work on Linux or macOS, for example comparing two directories on macOS:

```powershell
Compare-FileHash -Path /Users/me/Some/Files -Destination /Volumes/Backup/Some/Other/Files -Recurse
```