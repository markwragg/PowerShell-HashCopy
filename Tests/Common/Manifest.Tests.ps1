BeforeAll {
    $env:BHProjectPath = Resolve-Path (Join-Path $PSScriptRoot "../../")
    $env:BHProjectName = (Get-ChildItem $env:BHProjectPath -Filter '*.psm1' -Recurse | Select-Object -First 1).BaseName
    $env:BHPSModuleManifest = (Get-ChildItem (Join-Path $env:BHProjectPath $env:BHProjectName) -Filter "${env:BHProjectName}.psd1").FullName

    $moduleName = $env:BHProjectName
    $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
    $outputManifestPath = Join-Path -Path (Join-Path $env:BHProjectPath $env:BHProjectName) "$($moduleName).psd1"
    $manifestData = Test-ModuleManifest -Path $outputManifestPath -Verbose:$false -ErrorAction Stop -WarningAction SilentlyContinue

    $changelogPath = Join-Path -Path $env:BHProjectPath -Child 'CHANGELOG.md'
    $changelogVersion = Get-Content $changelogPath | ForEach-Object {
        if ($_ -match "^##\s\[(?<Version>(\d+\.){1,3}\d+)\]") {
            $changelogVersion = $matches.Version
            break
        }
    }

    $script:manifest = $null
}

Describe 'Module manifest' {

    Context 'Validation' {

        It 'Has a valid manifest' {
            $manifestData | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid name in the manifest' {
            $manifestData.Name | Should -Be $moduleName
        }

        It 'Has a valid root module' {
            $manifestData.RootModule | Should -Be "$($moduleName).psm1"
        }

        It 'Has a valid version in the manifest' {
            $manifestData.Version -as [Version] | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid description' {
            $manifestData.Description | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid author' {
            $manifestData.Author | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid guid' {
            { [guid]::Parse($manifestData.Guid) } | Should -Not -Throw
        }

        It 'Has a valid copyright' {
            $manifestData.CopyRight | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid version in the changelog' {
            $changelogVersion               | Should -Not -BeNullOrEmpty
            $changelogVersion -as [Version] | Should -Not -BeNullOrEmpty
        }

        It 'Changelog and manifest versions are the same' {
            $changelogVersion -as [Version] | Should -Be ( $manifestData.Version -as [Version] )
        }
    }
}

Describe 'Git tagging' -Skip {

    BeforeAll {
        $gitTagVersion = $null

        if ($git = Get-Command git -CommandType Application -ErrorAction SilentlyContinue) {
            $thisCommit = & $git log --decorate --oneline HEAD~1..HEAD
            if ($thisCommit -match 'tag:\s*(\d+(?:\.\d+)*)') { $gitTagVersion = $matches[1] }
        }
    }

    It 'Is tagged with a valid version' {
        $gitTagVersion               | Should -Not -BeNullOrEmpty
        $gitTagVersion -as [Version] | Should -Not -BeNullOrEmpty
    }

    It 'Matches manifest version' {
        $manifestData.Version -as [Version] | Should -Be ( $gitTagVersion -as [Version])
    }
}