$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Get-DestinationFilePath PS$PSVersion" {

    BeforeAll {
        . $PSScriptRoot/../HashCopy/Private/Get-DestinationFilePath.ps1
    }

    Context 'Source and Destination are directories' {

        BeforeAll {
            $Source = Join-Path $TestDrive 'Source'
            $Destination = Join-Path $TestDrive 'Dest'

            New-Item -ItemType Directory $Source -Force
            New-Item -ItemType Directory $Destination -Force
        }

        It 'Returns the destination path for a file in the root of Source' {
            $File = Join-Path $Source 'somefile.txt'

            Get-DestinationFilePath -File $File -Source $Source -Destination $Destination |
                Should -Be (Join-Path $Destination 'somefile.txt')
        }

        It 'Returns the destination path for a file in a subdirectory of Source' {
            $File = Join-Path $Source 'Somesubdir/somefile.txt'

            Get-DestinationFilePath -File $File -Source $Source -Destination $Destination |
                Should -Be (Join-Path $Destination 'Somesubdir/somefile.txt')
        }

        It 'Returns the destination path for a file nested two directories deep' {
            $File = Join-Path $Source 'Somedir/Someotherdir/somefile.txt'

            Get-DestinationFilePath -File $File -Source $Source -Destination $Destination |
                Should -Be (Join-Path $Destination 'Somedir/Someotherdir/somefile.txt')
        }

        It 'Returns the same result whether or not Source has a trailing slash' {
            $File = Join-Path $Source 'somefile.txt'

            $WithSlash = Get-DestinationFilePath -File $File -Source "$Source/" -Destination $Destination
            $WithoutSlash = Get-DestinationFilePath -File $File -Source $Source -Destination $Destination

            $WithSlash | Should -Be $WithoutSlash
        }

        It 'Resolves to the correct file when Destination has a trailing slash, as Copy-FileHash always supplies it' {
            $File = Join-Path $Source 'somefile.txt'

            #Copy-FileHash always normalizes Destination to have a trailing slash via Join-Path before
            #calling this function, so that is the form exercised here.
            $DestFile = Get-DestinationFilePath -File $File -Source $Source -Destination (Join-Path $Destination '/')

            New-Item -ItemType Directory -Force (Split-Path -Parent $DestFile) | Out-Null
            New-Item $DestFile -Force | Out-Null

            (Join-Path $Destination 'somefile.txt') | Should -Exist
        }

        It 'Accepts File as a System.IO.FileInfo object' {
            $File = [System.IO.FileInfo](Join-Path $Source 'somefile.txt')

            Get-DestinationFilePath -File $File -Source $Source -Destination $Destination |
                Should -Be (Join-Path $Destination 'somefile.txt')
        }

        It 'Returns a string' {
            $File = Join-Path $Source 'somefile.txt'

            (Get-DestinationFilePath -File $File -Source $Source -Destination $Destination) |
                Should -BeOfType [String]
        }
    }

    Context 'Source is a single file rather than a directory' {

        BeforeAll {
            $Source = Join-Path $TestDrive 'SingleFileSource'
            $Destination = Join-Path $TestDrive 'SingleFileDest'

            New-Item -ItemType Directory $Source -Force
            New-Item -ItemType Directory $Destination -Force

            $SourceFile = Join-Path $Source 'onlyfile.txt'
            New-Item $SourceFile -Force
        }

        It 'Returns the destination path based on the parent directory of the Source file' {
            Get-DestinationFilePath -File $SourceFile -Source $SourceFile -Destination $Destination |
                Should -Be (Join-Path $Destination 'onlyfile.txt')
        }
    }

    Context 'Source path contains regex special characters' {

        BeforeAll {
            $Source = Join-Path $TestDrive 'Source[1](test)'
            $Destination = Join-Path $TestDrive 'Dest'

            New-Item -ItemType Directory -Path $Source -Force
            New-Item -ItemType Directory $Destination -Force
        }

        It 'Correctly substitutes the Destination without being affected by regex metacharacters in Source' {
            $File = Join-Path $Source 'somefile.txt'

            Get-DestinationFilePath -File $File -Source $Source -Destination $Destination |
                Should -Be (Join-Path $Destination 'somefile.txt')
        }
    }

    Context 'Mandatory parameters' {

        It 'Requires -File' {
            ((Get-Command Get-DestinationFilePath).Parameters['File'].Attributes | Where-Object { $_ -is [Parameter] }).Mandatory | Should -BeTrue
        }

        It 'Requires -Source' {
            ((Get-Command Get-DestinationFilePath).Parameters['Source'].Attributes | Where-Object { $_ -is [Parameter] }).Mandatory | Should -BeTrue
        }

        It 'Requires -Destination' {
            ((Get-Command Get-DestinationFilePath).Parameters['Destination'].Attributes | Where-Object { $_ -is [Parameter] }).Mandatory | Should -BeTrue
        }
    }
}
