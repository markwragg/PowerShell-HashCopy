if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'HashCopy'

If (-not (Get-Module $Module)) { Import-Module "$Root\$Module" -Force }

Describe "Copy-FileHash PS$PSVersion" {
    
    $CopyParams1 = @{
        Path      = 'TestDrive:\TempSource'
        Destination = 'TestDrive:\TempDest'
        Recurse      = $true
    }
    $CopyParams2 = @{
        Path      = 'TestDrive:\TempSource\Temp2\Temp3'
        Destination = 'TestDrive:\TempDest'
        Recurse      = $true
    }
    $CopyParams3 = @{
        Path      = 'TestDrive:\TempSource'
        Destination = 'TestDrive:\TempDest\Temp2\Temp3'
        Recurse      = $true
    }

    $CopyParams1,$CopyParams2,$CopyParams3 | ForEach-Object {
        
        Context "Copy-FileHash -Path $($_.Path) -Destination $($_.Destination) -Recurse:$($_.Recurse)" {
            $CopyParams = $_

            New-Item -ItemType Directory $CopyParams.Path
            New-Item -ItemType Directory $CopyParams.Destination

            Context 'New file to copy and existing file to modify' {
                New-Item "$($CopyParams.Path)\somenewfile.txt"
                'newcontent' | Out-File "$($CopyParams.Path)\someoriginalfile.txt"
                'oldcontent' | Out-File "$($CopyParams.Destination)\someoriginalfile.txt"

                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'Should copy somenewfile.txt to destination' {
                    "$($CopyParams.Destination)\somenewfile.txt" | Should -Exist
                }
                It 'Should update someoriginalfile.txt with newcontent' {
                    "$($CopyParams.Destination)\someoriginalfile.txt" | Should -FileContentMatchExactly 'newcontent'
                }
            }

            Context 'New file in subdirectory with existing file in root' {
                New-Item -ItemType Directory "$($CopyParams.Path)\Somesubdir"
                New-Item  "$($CopyParams.Path)\Somesubdir\someoriginalfile.txt"
                'oldcontent' | Out-File "$($CopyParams.Destination)\someoriginalfile.txt"
            
                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'Should copy new someorginalfile.txt to subfolder destination' {
                    "$($CopyParams.Destination)\Somesubdir\someoriginalfile.txt" | Should -Exist
                }
                It 'Should not change existing someoriginalfile.txt in root' {
                    "$($CopyParams.Destination)\someoriginalfile.txt" | Should -FileContentMatchExactly 'oldcontent'
                }
            }

            Context 'New file in subdirectory two levels deep' {
                New-Item -ItemType Directory "$($CopyParams.Path)\Somedir"
                New-Item -ItemType Directory "$($CopyParams.Path)\Somedir\Someotherdir"
                New-Item  "$($CopyParams.Path)\Somedir\Someotherdir\someoriginalfile.txt"
                'oldcontent' | Out-File "$($CopyParams.Destination)\someoriginalfile.txt"
            
                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'Should copy new someoriginalfile.txt to sub-subfolder destination' {
                    "$($CopyParams.Destination)\Somedir\Someotherdir\someoriginalfile.txt" | Should -Exist
                }
                It 'Should not change existing someoriginalfile.txt in root' {
                    "$($CopyParams.Destination)\someoriginalfile.txt" | Should -FileContentMatchExactly 'oldcontent'
                }
            }

            Context 'No file changes needed with a single file' {
                'onecontent' | Out-File "$($CopyParams.Path)\someoriginalfile.txt"
                'onecontent' | Out-File "$($CopyParams.Destination)\someoriginalfile.txt"
                
                It 'Copy-FileHash should return null"' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'The pre-existing destination file "someoriginalfile.txt" should still contain "onecontent"' {
                    "$($CopyParams.Destination)\someoriginalfile.txt" | Should -FileContentMatchExactly 'onecontent'
                }
            }

            Context 'No file changes needed with multiple files' {
                'onecontent' | Out-File "$($CopyParams.Path)\someoriginalfile.txt"
                'onecontent' | Out-File "$($CopyParams.Destination)\someoriginalfile.txt"
                'twocontent' | Out-File "$($CopyParams.Path)\someotherfile.txt"
                'twocontent' | Out-File "$($CopyParams.Destination)\someotherfile.txt"
                
                It 'Copy-FileHash should return null"' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'The pre-existing destination file "someoriginalfile.txt" should still contain "onecontent"' {
                    "$($CopyParams.Destination)\someoriginalfile.txt" | Should -FileContentMatchExactly 'onecontent'
                }
                It 'The pre-existing destination file "someotherfile.txt" should still contain "twocontent"' {
                    "$($CopyParams.Destination)\someotherfile.txt" | Should -FileContentMatchExactly 'twocontent'
                }
            }

            Context 'Destination folder empty' {
                'oldcontent' | Out-File "$($CopyParams.Path)\someoriginalfile.txt"

                It 'The destination folder should be empty before performing a copy' {
                    Get-ChildItem "$($CopyParams.Destination)\" | Should -Be $null
                }
                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'The destination folder should now contain someoriginalfile.txt containing "oldcontent"' {
                    "$($CopyParams.Destination)\someoriginalfile.txt" | Should -FileContentMatchExactly 'oldcontent'
                }
            }

            Context 'Source folder empty' {
                'oldcontent' | Out-File "$($CopyParams.Destination)\someoriginalfile.txt"

                It 'The source folder should be empty before performing a copy' {
                    Get-ChildItem "$($CopyParams.Path)\" | Should -Be $null
                }
                It 'Copy-FileHash should return null' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'The destination folder should now contain someoriginalfile.txt containing "oldcontent"' {
                    "$($CopyParams.Destination)\someoriginalfile.txt" | Should -FileContentMatchExactly 'oldcontent'
                }
            }
        }
    }    
    
    Context 'Copy-FileHash with Invalid -Path input' {

        It 'Copy-FileHash should throw "-Path must be a valid path." for a missing path' {
            {Copy-FileHash -Path 'C:\temp\fake\path\not\exist' -Destination 'TestDrive:\'} | Should -Throw '-Path must be a valid path.'
        }
        It 'Copy-FileHash should throw "-Path must be a valid path." for an invalid path' {
            {Copy-FileHash -Path 'z:|invalid<path' -Destination 'TestDrive:\'} | Should -Throw '-Path must be a valid path.'
        }
    }

    Context 'Copy-FileHash with Invalid -Destination input' {

        It 'Copy-FileHash should throw "-Destination must be a valid path." for an invalid path' {
            {Copy-FileHash -Path 'TestDrive:\' -Destination 'z:|invalid<path'} | Should -Throw "Cannot validate argument on parameter 'Destination'. -Destination must be a valid path."
        }
    }
}