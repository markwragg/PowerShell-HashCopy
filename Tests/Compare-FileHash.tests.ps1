$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Compare-FileHash PS$PSVersion" {

    BeforeAll {
        . $PSScriptRoot/../HashCopy/Public/Compare-FileHash.ps1
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

    Context "Compare-FileHash -Path <Path> -Destination <Destination> -Recurse:<Recurse>" -ForEach ($CopyParams1, $CopyParams2, $CopyParams3) {

        BeforeAll {
            $Path = Join-Path $TestDrive $Path
            $Destination = Join-Path $TestDrive $Destination

            New-Item -ItemType Directory $Path
            New-Item -ItemType Directory $Destination
        }

        Context 'New file to copy and existing file to modify' {

            BeforeAll {
                New-Item (Join-Path $Path '/somenewfile.txt')
                'newcontent' | Out-File (Join-Path $Path '/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
            }

            It 'Compare-FileHash should return two files' {
                Compare-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse  | Should -Be @((Join-Path $Path '/somenewfile.txt'), (Join-Path $Path '/someoriginalfile.txt'))
            }
            It 'Should not copy somenewfile.txt to destination' {
                    (Join-Path $Destination '/somenewfile.txt') | Should -Not -Exist
            }
            It 'Should not update someoriginalfile.txt with newcontent' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
            }
        }

        Context 'New file in subdirectory with existing file in root' {

            BeforeAll {
                New-Item -ItemType Directory (Join-Path $Path '/Somesubdir')
                New-Item  (Join-Path $Path '/Somesubdir/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
            }

            It 'Compare-FileHash should return one file' {
                Compare-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be (Join-Path $Path '/Somesubdir/someoriginalfile.txt')
            }
            It 'Should not copy new someorginalfile.txt to subfolder destination' {
                    (Join-Path $Destination '/Somesubdir/someoriginalfile.txt') | Should -Not -Exist
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

            It 'Compare-FileHash should return one file' {
                Compare-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be (Join-Path $Path '/Somedir/Someotherdir/someoriginalfile.txt')
            }
            It 'Should not copy new someoriginalfile.txt to sub-subfolder destination' {
                    (Join-Path $Destination '/Somedir/Someotherdir/someoriginalfile.txt') | Should -Not -Exist
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

            It 'Compare-FileHash should return null"' {
                Compare-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be $Null
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

            It 'Compare-FileHash should return null"' {
                Compare-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be $Null
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
            It 'Compare-FileHash should return one file' {
                Compare-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be (Join-Path $Path '/someoriginalfile.txt')
            }
            It 'The destination folder should not contain someoriginalfile.txt' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -Not -Exist
            }
        }

        Context 'Source folder empty' {

            BeforeAll {
                'oldcontent' | Out-File (Join-Path $Destination '/someoriginalfile.txt')
            }

            It 'The source folder should be empty before performing a copy' {
                Get-ChildItem (Join-Path $Path '/') | Should -Be $null
            }
            It 'Compare-FileHash should return null' {
                Compare-FileHash -Path $Path -Destination $Destination -Recurse:$Recurse | Should -Be $Null
            }
            It 'The destination folder should now contain someoriginalfile.txt containing "oldcontent"' {
                    (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
            }
        }
    }

    $CopyLiteralParams = @{
        LiteralPath = '/LiteralTempSource'
        Destination = '/LiteralTempDest'
        Recurse     = $true
    }

    Context "Compare-FileHash -LiteralPath $LiteralPath -Destination $Destination -Recurse:$Recurse" -ForEach $CopyLiteralParams {

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

            It 'Compare-FileHash should return two files' {
                Compare-FileHash -LiteralPath $LiteralPath -Destination $Destination | Should -Be @((Join-Path $LiteralPath '/somenewfile.txt'), (Join-Path $LiteralPath '/someoriginalfile.txt'))
            }
            It 'Should not copy somenewfile.txt to destination' {
                (Join-Path $Destination '/somenewfile.txt') | Should -Not -Exist
            }
            It 'Should not update someoriginalfile.txt with newcontent' {
                (Join-Path $Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
            }
        }
    }

    Context 'Compare-FileHash with Invalid -Path input' {

        It 'Compare-FileHash should throw "-Path must be a valid path." for a missing path' {
            { Compare-FileHash -Path 'TestDrive:/fake/path/not/exist' -Destination 'TestDrive:/' } | Should -Throw
        }
        It 'Compare-FileHash should throw "-Path must be a valid path." for an invalid path' {
            { Compare-FileHash -Path 'z:|invalid<path' -Destination $TestDrive } | Should -Throw
        }
    }

    Context 'Compare-FileHash with Invalid -LiteralPath input' {

        It 'Compare-FileHash should throw "-LiteralPath must be a valid path." for a missing path' {
            { Compare-FileHash -LiteralPath 'TestDrive:/temp/fake/path/not/exist' -Destination $TestDrive } | Should -Throw
        }
        It 'Compare-FileHash should throw "-LiteralPath must be a valid path." for an invalid path' {
            { Compare-FileHash -LiteralPath 'z:|invalid<path' -Destination $TestDrive } | Should -Throw
        }
    }

    Context 'Compare-FileHash with Invalid -Destination input' {

        It 'Compare-FileHash should throw "-Destination must be a valid path." for an invalid path' {
            { Compare-FileHash -Path 'TestDrive:/' -Destination 'z:|invalid<path' } | Should -Throw "Cannot validate argument on parameter 'Destination'. -Destination must be a valid path."
        }
    }
}