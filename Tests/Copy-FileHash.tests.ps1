if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot/../"
$Module = 'HashCopy'

If (-not (Get-Module $Module)) { Import-Module "$Root/$Module" -Force }

Describe "Copy-FileHash PS$PSVersion" {

    $CopyParams1 = @{
        Path        = Join-Path $TestDrive '/TempSource'
        Destination = Join-Path $TestDrive '/TempDest/'
        Recurse     = $true
    }
    $CopyParams2 = @{
        Path        = Join-Path $TestDrive '/TempSource/Temp2/Temp3/'
        Destination = Join-Path $TestDrive '/TempDest'
        Recurse     = $true
    }
    $CopyParams3 = @{
        Path        = Join-Path $TestDrive '/TempSource/'
        Destination = Join-Path $TestDrive '/TempDest/Temp2/Temp3'
        Recurse     = $true
    }

    ForEach ($CopyParams in $CopyParams1, $CopyParams2, $CopyParams3) {

        Context "Copy-FileHash -Path $($CopyParams.Path) -Destination $($CopyParams.Destination) -Recurse:$($CopyParams.Recurse)" {

            New-Item -ItemType Directory $CopyParams.Path
            New-Item -ItemType Directory $CopyParams.Destination

            Context 'New file to copy and existing file to modify' {
                New-Item (Join-Path $CopyParams.Path '/somenewfile.txt')
                'newcontent' | Out-File (Join-Path $CopyParams.Path '/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $CopyParams.Destination '/someoriginalfile.txt')

                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'Should copy somenewfile.txt to destination' {
                    (Join-Path $CopyParams.Destination '/somenewfile.txt') | Should -Exist
                }
                It 'Should update someoriginalfile.txt with newcontent' {
                    (Join-Path $CopyParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'newcontent'
                }
            }

            Context 'New file in subdirectory with existing file in root' {
                New-Item -ItemType Directory (Join-Path $CopyParams.Path '/Somesubdir')
                New-Item  (Join-Path $CopyParams.Path '/Somesubdir/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $CopyParams.Destination '/someoriginalfile.txt')

                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'Should copy new someorginalfile.txt to subfolder destination' {
                    (Join-Path $CopyParams.Destination '/Somesubdir/someoriginalfile.txt') | Should -Exist
                }
                It 'Should not change existing someoriginalfile.txt in root' {
                    (Join-Path $CopyParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
                }
            }

            Context 'New file in subdirectory two levels deep' {
                New-Item -ItemType Directory (Join-Path $CopyParams.Path '/Somedir')
                New-Item -ItemType Directory (Join-Path $CopyParams.Path '/Somedir/Someotherdir')
                New-Item  (Join-Path $CopyParams.Path '/Somedir/Someotherdir/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $CopyParams.Destination '/someoriginalfile.txt')

                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'Should copy new someoriginalfile.txt to sub-subfolder destination' {
                    (Join-Path $CopyParams.Destination '/Somedir/Someotherdir/someoriginalfile.txt') | Should -Exist
                }
                It 'Should not change existing someoriginalfile.txt in root' {
                    (Join-Path $CopyParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
                }
            }

            Context 'No file changes needed with a single file' {
                'onecontent' | Out-File (Join-Path $CopyParams.Path '/someoriginalfile.txt')
                'onecontent' | Out-File (Join-Path $CopyParams.Destination '/someoriginalfile.txt')

                It 'Copy-FileHash should return null"' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'The pre-existing destination file "someoriginalfile.txt" should still contain "onecontent"' {
                    (Join-Path $CopyParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'onecontent'
                }
            }

            Context 'No file changes needed with multiple files' {
                'onecontent' | Out-File (Join-Path $CopyParams.Path '/someoriginalfile.txt')
                'onecontent' | Out-File (Join-Path $CopyParams.Destination '/someoriginalfile.txt')
                'twocontent' | Out-File (Join-Path $CopyParams.Path '/someotherfile.txt')
                'twocontent' | Out-File (Join-Path $CopyParams.Destination '/someotherfile.txt')

                It 'Copy-FileHash should return null"' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'The pre-existing destination file "someoriginalfile.txt" should still contain "onecontent"' {
                    (Join-Path $CopyParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'onecontent'
                }
                It 'The pre-existing destination file "someotherfile.txt" should still contain "twocontent"' {
                    (Join-Path $CopyParams.Destination '/someotherfile.txt') | Should -FileContentMatchExactly 'twocontent'
                }
            }

            Context 'Destination folder empty' {
                'oldcontent' | Out-File (Join-Path $CopyParams.Path '/someoriginalfile.txt')

                It 'The destination folder should be empty before performing a copy' {
                    Get-ChildItem (Join-Path $CopyParams.Destination '/') | Should -Be $null
                }
                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'The destination folder should now contain someoriginalfile.txt containing "oldcontent"' {
                    (Join-Path $CopyParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
                }
            }

            Context 'Source folder empty' {
                'oldcontent' | Out-File (Join-Path $CopyParams.Destination '/someoriginalfile.txt')

                It 'The source folder should be empty before performing a copy' {
                    Get-ChildItem (Join-Path $CopyParams.Path '/') | Should -Be $null
                }
                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'The destination folder should now contain someoriginalfile.txt containing "oldcontent"' {
                    (Join-Path $CopyParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'oldcontent'
                }
            }

            Context 'Using -Mirror removes files from destination that are not in source' {
                New-Item (Join-Path $CopyParams.Path '/somenewfile.txt')
                'newcontent' | Out-File (Join-Path $CopyParams.Path '/someoriginalfile.txt')
                'oldcontent' | Out-File (Join-Path $CopyParams.Destination '/someoriginalfile.txt')
                'existingfi' | Out-File (Join-Path $CopyParams.Destination '/someexistingfile.txt')

                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams -Mirror | Should -Be $Null
                }
                It 'Should copy somenewfile.txt to destination' {
                    (Join-Path $CopyParams.Destination '/somenewfile.txt') | Should -Exist
                }
                It 'Should update someoriginalfile.txt with newcontent' {
                    (Join-Path $CopyParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'newcontent'
                }
                It 'Should remove someexistingfile.txt from the destination' {
                    (Join-Path $CopyParams.Destination '/someexistingfile.txt') | Should -Not -Exist
                }
            }
        }
    }

    $CopyLiteralParams = @{
        LiteralPath = Join-Path $TestDrive '/LiteralTempSource'
        Destination = Join-Path $TestDrive '/LiteralTempDest'
        Recurse     = $true
    }

    Context "Copy-FileHash -LiteralPath $($CopyLiteralParams.LiteralPath) -Destination $($CopyLiteralParams.Destination) -Recurse:$($CopyLiteralParams.Recurse)" {

        New-Item -ItemType Directory $CopyLiteralParams.LiteralPath
        New-Item -ItemType Directory $CopyLiteralParams.Destination

        Context 'New file to copy and existing file to modify' {
            New-Item (Join-Path $CopyLiteralParams.LiteralPath '/somenewfile.txt')
            'newcontent' | Out-File (Join-Path $CopyLiteralParams.LiteralPath '/someoriginalfile.txt')
            'oldcontent' | Out-File (Join-Path $CopyLiteralParams.Destination '/someoriginalfile.txt')

            It 'Copy-FileHash should return null' {
                Copy-FileHash @CopyLiteralParams | Should -Be $Null
            }
            It 'Should copy somenewfile.txt to destination' {
                (Join-Path $CopyLiteralParams.Destination '/somenewfile.txt') | Should -Exist
            }
            It 'Should update someoriginalfile.txt with newcontent' {
                (Join-Path $CopyLiteralParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'newcontent'
            }
        }

        Context 'Using -Mirror removes files from destination that are not in source' {
            New-Item (Join-Path $CopyLiteralParams.LiteralPath '/somenewfile.txt')
            'newcontent' | Out-File (Join-Path $CopyLiteralParams.LiteralPath '/someoriginalfile.txt')
            'oldcontent' | Out-File (Join-Path $CopyLiteralParams.Destination '/someoriginalfile.txt')
            'existingfi' | Out-File (Join-Path $CopyLiteralParams.Destination '/someexistingfile.txt')

            It 'Copy-FileHash should return null' {
                Copy-FileHash @CopyLiteralParams -Mirror | Should -Be $Null
            }
            It 'Should copy somenewfile.txt to destination' {
                (Join-Path $CopyLiteralParams.Destination '/somenewfile.txt') | Should -Exist
            }
            It 'Should update someoriginalfile.txt with newcontent' {
                (Join-Path $CopyLiteralParams.Destination '/someoriginalfile.txt') | Should -FileContentMatchExactly 'newcontent'
            }
            It 'Should remove someexistingfile.txt from the destination' {
                (Join-Path $CopyLiteralParams.Destination '/someexistingfile.txt') | Should -Not -Exist
            }
        }
    }

    Context 'Copy-FileHash with Invalid -Path input' {

        It 'Copy-FileHash should throw "-Path must be a valid path." for a missing path' {
            { Copy-FileHash -Path 'C:/temp/fake/path/not/exist' -Destination 'TestDrive:/' } | Should -Throw '-Path must be a valid path.'
        }
        It 'Copy-FileHash should throw "-Path must be a valid path." for an invalid path' {
            { Copy-FileHash -Path 'z:|invalid<path' -Destination $TestDrive } | Should -Throw '-Path must be a valid path.'
        }
    }

    Context 'Copy-FileHash with Invalid -LiteralPath input' {

        It 'Copy-FileHash should throw "-LiteralPath must be a valid path." for a missing path' {
            { Copy-FileHash -LiteralPath 'C:/temp/fake/path/not/exist' -Destination $TestDrive } | Should -Throw '-LiteralPath must be a valid path.'
        }
        It 'Copy-FileHash should throw "-LiteralPath must be a valid path." for an invalid path' {
            { Copy-FileHash -LiteralPath 'z:|invalid<path' -Destination $TestDrive } | Should -Throw '-LiteralPath must be a valid path.'
        }
    }

    Context 'Copy-FileHash with Invalid -Destination input' {

        It 'Copy-FileHash should throw "-Destination must be a valid path." for an invalid path' {
            { Copy-FileHash -Path 'TestDrive:/' -Destination 'z:|invalid<path' } | Should -Throw "Cannot validate argument on parameter 'Destination'. -Destination must be a valid path."
        }
    }

    Context 'Copy-FileHash -WhatIf' {

        $CopyWhatIfParams = @{
            Path        = Join-Path $TestDrive '/TempSource'
            Destination = Join-Path $TestDrive '/TempDest'
            Recurse     = $true
            WhatIf      = $true
        }

        New-Item -ItemType Directory $CopyWhatIfParams.Path
        New-Item -ItemType Directory $CopyWhatIfParams.Destination

        New-Item (Join-Path $CopyWhatIfParams.Path '/somenewfile.txt') 

        It 'Should not throw when using -WhatIf and a destination file does not exist' {
            { Copy-FileHash @CopyWhatIfParams } | Should -Not -Throw
        }
    }

    Context 'Copy-FileHash -Mirror with multiple source paths' {

        $CopyMirrorParams = @{
            Path        = @((Join-Path $TestDrive '/TempSource1'),(Join-Path $TestDrive '/TempSource2'))
            Destination = Join-Path $TestDrive '/TempDest'
            Recurse     = $true
            Mirror      = $true
        }

        New-Item -ItemType Directory $CopyMirrorParams.Path
        New-Item -ItemType Directory $CopyMirrorParams.Destination

        It 'Should throw when using -Mirror with multiple source paths' {
            { Copy-FileHash @CopyMirrorParams } | Should -Throw
        }
    }
}