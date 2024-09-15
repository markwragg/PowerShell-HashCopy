$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Copy-FileHash PS$PSVersion" {

    BeforeAll {
        . $PSScriptRoot/../HashCopy/Public/Copy-FileHash.ps1
        . $PSScriptRoot/../HashCopy/Private/Get-DestinationFilePath.ps1
    }

    $CopyParams1 = @{
        Path        = '/TempSource'
        Destination = '/TempDest/'
        Recurse     = $true
    }
    $CopyParams2 = @{
        Path        = '/TempSource/Temp2/Temp3/'
        Destination = '/TempDest'
        Recurse     = $true
    }
    $CopyParams3 = @{
        Path        = '/TempSource/'
        Destination = '/TempDest/Temp2/Temp3'
        Recurse     = $true
    }

    Context "Copy-FileHash -Path <Path> -Destination <Destination> -Recurse:<Recurse>" -ForEach ($CopyParams1, $CopyParams2, $CopyParams3) {

        BeforeAll {
            $Path = Join-Path $TestDrive $Path
            $Destination = Join-Path $TestDrive $Destination

            New-Item -ItemType Directory $Path -Force
            New-Item -ItemType Directory $Destination -Force
        }

        Context 'New file to copy and existing file to modify' {

            BeforeAll {
                New-Item (Join-Path $Path 'somenewfile.txt')
                'newcontent' | Out-File (Join-Path $Path 'someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $Destination 'someoriginalfile.txt')

                $Result = Copy-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse
            }

            It 'Copy-FileHash should return null' {
                $Result | Should -Be $Null
            }
            It 'Should copy somenewfile.txt to destination' {
                (Join-Path $Destination 'somenewfile.txt') | Should -Exist
            }
            It 'Should update someoriginalfile.txt with newcontent' {
                Get-Content (Join-Path $Destination 'someoriginalfile.txt') | Should -Be 'newcontent'
            }
        }

        Context 'New file in subdirectory with existing file in root' {

            BeforeAll {
                New-Item -ItemType Directory (Join-Path $Path '/Somesubdir')
                New-Item  (Join-Path $Path '/Somesubdir/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
            }

            It 'Copy-FileHash should return null' {
                Copy-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be $Null
            }
            It 'Should copy new someorginalfile.txt to subfolder destination' {
                    (Join-Path $Destination '/Somesubdir/someoriginalfile.txt') | Should -Exist
            }
            It 'Should not change existing someoriginalfile.txt in root' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
            }
        }

        Context 'New file in subdirectory two levels deep' {

            BeforeAll {
                New-Item -ItemType Directory (Join-Path $Path '/Somedir')
                New-Item -ItemType Directory (Join-Path $Path '/Somedir/Someotherdir')
                New-Item  (Join-Path $Path '/Somedir/Someotherdir/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
            }

            It 'Copy-FileHash should return null' {
                Copy-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be $Null
            }
            It 'Should copy new someoriginalfile.txt to sub-subfolder destination' {
                    (Join-Path $Destination '/Somedir/Someotherdir/someoriginalfile.txt') | Should -Exist
            }
            It 'Should not change existing someoriginalfile.txt in root' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
            }
        }

        Context 'No file changes needed with a single file' {

            BeforeAll {
                'onecontent' | Out-File (Join-Path $Path '/someoriginalfile.txt')
                'onecontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
            }

            It 'Copy-FileHash should return null"' {
                Copy-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be $Null
            }
            It 'The pre-existing destination file "someoriginalfile.txt" should still contain "onecontent"' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'onecontent'
            }
        }

        Context 'No file changes needed with multiple files' {

            BeforeAll {
                'onecontent' | Out-File (Join-Path $Path '/someoriginalfile.txt')
                'onecontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
                'twocontent' | Out-File (Join-Path $Path '/someotherfile.txt')
                'twocontent' | Out-File (Join-Path $Destination '/someotherfile.txt')
            }

            It 'Copy-FileHash should return null"' {
                Copy-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be $Null
            }
            It 'The pre-existing destination file "someoriginalfile.txt" should still contain "onecontent"' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'onecontent'
            }
            It 'The pre-existing destination file "someotherfile.txt" should still contain "twocontent"' {
                    (Join-Path $Destination '/someotherfile.txt') | Should -FileContentMatchExactly 'twocontent'
            }
        }

        Context 'Destination folder empty' {

            BeforeAll {
                'oldcontent' | Out-File (Join-Path $Path '/someoriginalfile.txt')
            }

            It 'The destination folder should be empty before performing a copy' {
                Get-ChildItem (Join-Path $Destination '/') | Should -Be $null
            }
            It 'Copy-FileHash should return null' {
                Copy-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be $Null
            }
            It 'The destination folder should now contain someoriginalfile.txt containing "oldcontent"' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
            }
        }

        Context 'Source folder empty' {

            BeforeAll {
                'oldcontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
            }

            It 'The source folder should be empty before performing a copy' {
                Get-ChildItem (Join-Path $Path '/') | Should -Be $null
            }
            It 'Copy-FileHash should return null' {
                Copy-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be $Null
            }
            It 'The destination folder should now contain someoriginalfile.txt containing "oldcontent"' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
            }
        }

        Context 'Using -Mirror removes files from destination that are not in source' {

            BeforeAll {
                New-Item (Join-Path $Path '/somenewfile.txt')
                'newcontent' | Out-File (Join-Path $Path '/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
                'existingfi' | Out-File (Join-Path $Destination '/someexistingfile.txt')
            }

            It 'Copy-FileHash should return null' {
                Copy-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse -Mirror | Should -Be $Null
            }
            It 'Should copy somenewfile.txt to destination' {
                    (Join-Path $Destination '/somenewfile.txt') | Should -Exist
            }
            It 'Should update someoriginalfile.txt with newcontent' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'newcontent'
            }
            It 'Should remove someexistingfile.txt from the destination' {
                    (Join-Path $Destination '/someexistingfile.txt') | Should -Not -Exist
            }
        }
    }

    $CopyLiteralParams = @{
        LiteralPath = '/LiteralTempSource'
        Destination = '/LiteralTempDest'
        Recurse     = $true
    }

    Context "Copy-FileHash -LiteralPath $LiteralPath -Destination $Destination -Recurse:$Recurse" -ForEach $CopyLiteralParams {

        BeforeAll {
            $LiteralPath = Join-Path $TestDrive $LiteralPath
            $Destination = Join-Path $TestDrive $Destination

            New-Item -ItemType Directory $LiteralPath
            New-Item -ItemType Directory $Destination
        }

        Context 'New file to copy and existing file to modify' {

            BeforeAll {
                New-Item (Join-Path $LiteralPath '/somenewfile.txt')
                'newcontent' | Out-File (Join-Path $LiteralPath '/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
            }

            It 'Copy-FileHash should return null' {
                Copy-FileHash -LiteralPath $LiteralPath -Destination $Destination -Recurse:$Recurse | Should -Be $Null
            }
            It 'Should copy somenewfile.txt to destination' {
                (Join-Path $Destination '/somenewfile.txt') | Should -Exist
            }
            It 'Should update someoriginalfile.txt with newcontent' {
                (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'newcontent'
            }
        }

        Context 'Using -Mirror removes files from destination that are not in source' {

            BeforeAll {
                New-Item (Join-Path $LiteralPath '/somenewfile.txt')
                'newcontent' | Out-File (Join-Path $LiteralPath '/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
                'existingfi' | Out-File (Join-Path $Destination '/someexistingfile.txt')
            }

            It 'Copy-FileHash should return null' {
                Copy-FileHash -LiteralPath $LiteralPath -Destination $Destination -Recurse:$Recurse -Mirror | Should -Be $Null
            }
            It 'Should copy somenewfile.txt to destination' {
                (Join-Path $Destination '/somenewfile.txt') | Should -Exist
            }
            It 'Should update someoriginalfile.txt with newcontent' {
                (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'newcontent'
            }
            It 'Should remove someexistingfile.txt from the destination' {
                (Join-Path $Destination '/someexistingfile.txt') | Should -Not -Exist
            }
        }
    }

    Context 'Copy-FileHash with Invalid -Path input' {

        It 'Copy-FileHash should throw "-Path must be a valid path." for a missing path' {
            { Copy-FileHash -Path (Join-Path $TestDrive '/temp/fake/path/not/exist') -Destination $TestDrive } | Should -Throw
        }
        It 'Copy-FileHash should throw "-Path must be a valid path." for an invalid path' {
            { Copy-FileHash -Path 'z:|invalid<path' -Destination $TestDrive } | Should -Throw
        }
    }

    Context 'Copy-FileHash with Invalid -LiteralPath input' {

        It 'Copy-FileHash should throw "-LiteralPath must be a valid path." for a missing path' {
            { Copy-FileHash -LiteralPath 'C:/temp/fake/path/not/exist' -Destination $TestDrive } | Should -Throw
        }
        It 'Copy-FileHash should throw "-LiteralPath must be a valid path." for an invalid path' {
            { Copy-FileHash -LiteralPath 'z:|invalid<path' -Destination $TestDrive } | Should -Throw
        }
    }

    Context 'Copy-FileHash with Invalid -Destination input' {

        It 'Copy-FileHash should throw "-Destination must be a valid path." for an invalid path' {
            { Copy-FileHash -Path 'TestDrive:/' -Destination 'z:|invalid<path' } | Should -Throw "Cannot validate argument on parameter 'Destination'. -Destination must be a valid path."
        }
    }

    Context 'Copy-FileHash -WhatIf' {

        BeforeAll {
            $CopyWhatIfParams = @{
                Path        = Join-Path $TestDrive '/TempSource'
                Destination = Join-Path $TestDrive '/TempDest'
                Recurse     = $true
                WhatIf      = $true
            }

            New-Item -ItemType Directory $CopyWhatIfParams.Path
            New-Item -ItemType Directory $CopyWhatIfParams.Destination

            New-Item (Join-Path $CopyWhatIfParams.Path '/somenewfile.txt') 
        }

        It 'Should not throw when using -WhatIf and a destination file does not exist' {
            { Copy-FileHash @CopyWhatIfParams } | Should -Not -Throw
        }
    }

    Context 'Copy-FileHash -Mirror with multiple source paths' {

        BeforeAll {
            $CopyMirrorParams = @{
                Path        = @((Join-Path $TestDrive '/TempSource1'), (Join-Path $TestDrive '/TempSource2'))
                Destination = Join-Path $TestDrive '/TempDest'
                Recurse     = $true
                Mirror      = $true
            }

            New-Item -ItemType Directory $CopyMirrorParams.Path
            New-Item -ItemType Directory $CopyMirrorParams.Destination
        }

        It 'Should throw when using -Mirror with multiple source paths' {
            { Copy-FileHash @CopyMirrorParams } | Should -Throw
        }
    }
}