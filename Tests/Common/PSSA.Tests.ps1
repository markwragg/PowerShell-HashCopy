# This runs all PSScriptAnalyzer rules as Pester tests to enable visibility when publishing test results

Describe 'Testing against PSSA rules' {
    
    Context 'PSSA Standard Rules' {

        BeforeAll {
            $env:BHProjectPath = Join-Path $PSScriptRoot '/../../'
            $env:BHModulePath = (Get-ChildItem (Join-Path $env:BHProjectPath '*.psm1') -Recurse).Directory

            $ScriptAnalyzerSettingsPath = Join-Path -Path $env:BHProjectPath -ChildPath 'PSScriptAnalyzerSettings.psd1'
            $analysis = Invoke-ScriptAnalyzer -Path $env:BHModulePath -Recurse -Settings $ScriptAnalyzerSettingsPath
        }
        
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule

        It "Should pass <_>" -TestCases $scriptAnalyzerRules {
            $rule = $_
            If ($analysis.RuleName -contains $rule) {
                $analysis | Where-Object RuleName -EQ $rule -OutVariable 'failures' | Out-Default
                $failures.Count | Should -Be 0
            }
        }
    }
}
