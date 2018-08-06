$Root = "$(Split-Path $MyInvocation.MyCommand.Path -Parent)\.."
$Sut = (Get-ChildItem $Root -Include ((Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.') -Recurse).FullName

$PSVersion = $PSVersionTable.PSVersion.Major

. $Sut

Describe "Copy-FileHash PS$PSVersion" {
    
    $CopyParams1 = @{
        Source      = 'TestDrive:\TempSource'
        Destination = 'TestDrive:\TempDest'
        Recurse      = $true
    }
    $CopyParams2 = @{
        Source      = 'TestDrive:\TempSource\Temp2\Temp3'
        Destination = 'TestDrive:\TempDest'
        Recurse      = $true
    }
    $CopyParams3 = @{
        Source      = 'TestDrive:\TempSource'
        Destination = 'TestDrive:\TempDest\Temp2\Temp3'
        Recurse      = $true
    }
    
    $CopyParams1,$CopyParams2,$CopyParams3 | ForEach-Object {
        
        Context "Copy-FileHash -Source $($_.Source) -Destination $($_.Destination) -Recurse:$($_.Recurse)" {
            $CopyParams = $_

            New-Item -ItemType Directory $CopyParams.Source
            New-Item -ItemType Directory $CopyParams.Destination

            Context 'New file to copy and existing file to modify' {
                New-Item "$($CopyParams.Source)\somenewfile.txt"
                'newcontent' | Out-File "$($CopyParams.Source)\someoriginalfile.txt"
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
                New-Item -ItemType Directory "$($CopyParams.Source)\Somesubdir"
                New-Item  "$($CopyParams.Source)\Somesubdir\someoriginalfile.txt"
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
                New-Item -ItemType Directory "$($CopyParams.Source)\Somedir"
                New-Item -ItemType Directory "$($CopyParams.Source)\Somedir\Someotherdir"
                New-Item  "$($CopyParams.Source)\Somedir\Someotherdir\someoriginalfile.txt"
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
                'onecontent' | Out-File "$($CopyParams.Source)\someoriginalfile.txt"
                'onecontent' | Out-File "$($CopyParams.Destination)\someoriginalfile.txt"
                
                It 'Copy-FileHash should return null"' {
                    Copy-FileHash @CopyParams | Should -Be $Null
                }
                It 'The pre-existing destination file "someoriginalfile.txt" should still contain "onecontent"' {
                    "$($CopyParams.Destination)\someoriginalfile.txt" | Should -FileContentMatchExactly 'onecontent'
                }
            }

            Context 'No file changes needed with multiple files' {
                'onecontent' | Out-File "$($CopyParams.Source)\someoriginalfile.txt"
                'onecontent' | Out-File "$($CopyParams.Destination)\someoriginalfile.txt"
                'twocontent' | Out-File "$($CopyParams.Source)\someotherfile.txt"
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
                'oldcontent' | Out-File "$($CopyParams.Source)\someoriginalfile.txt"

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
                    Get-ChildItem "$($CopyParams.Source)\" | Should -Be $null
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
}