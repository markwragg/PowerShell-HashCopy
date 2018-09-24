function Resolve-Module {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Name
    )

    Process {
        foreach ($ModuleName in $Name) {
            $Module = Get-Module -Name $ModuleName -ListAvailable

            if ($Module) {
                $Version = $Module | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
                $GalleryVersion = Find-Module -Name $ModuleName -Repository PSGallery | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum

                if ($Version -lt $GalleryVersion) {

                    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }
                    Install-Module -Name $ModuleName -Force -Scope CurrentUser
                    Import-Module -Name $ModuleName -Force -RequiredVersion $GalleryVersion
                }
                else {
                    Import-Module -Name $ModuleName -Force -RequiredVersion $Version
                }
            }
            else {
                Install-Module -Name $ModuleName -Force -Scope CurrentUser
                Import-Module -Name $ModuleName -Force -RequiredVersion $Version
            }
        }
    }
}

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
Resolve-Module Psake, PSDeploy, PSScriptAnalyzer, Pester, BuildHelpers

Set-BuildEnvironment

# Init
"`n----------------------------------------------------------------------"
$ProjectRoot = $ENV:BHProjectPath
if (-not $ProjectRoot) { $ProjectRoot = $PSScriptRoot }

Set-Location $ProjectRoot

"Build System Details:"

Get-Item ENV:BH*
$PSVersionTable

# Test
"`n----------------------------------------------------------------------"
$Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
$PSVersion = $PSVersionTable.PSVersion.Major
$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
        
"`n`tSTATUS: Testing with PowerShell $PSVersion."

# Gather test results. Store them in a variable and file
$CodeFiles = (Get-ChildItem $ENV:BHModulePath -Recurse -Include '*.ps1').FullName
$TestResults = Invoke-Pester -Path (Join-Path $ProjectRoot 'Tests') -CodeCoverage $CodeFiles -PassThru -OutputFormat NUnitXml -OutputFile (Join-Path $ProjectRoot $TestFile)

# In Appveyor?  Upload our tests!
If ($ENV:BHBuildSystem -eq 'AppVeyor') {
    (New-Object 'System.Net.WebClient').UploadFile(
        "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
        (Join-Path $ProjectRoot $TestFile)
    )
}

Remove-Item (Join-Path $ProjectRoot $TestFile) -Force -ErrorAction SilentlyContinue

# Failed tests?
if ($Script:TestResults.FailedCount -gt 0) {
    Throw "Failed $($TestResults.FailedCount) tests, build failed."
}

#Update readme.md with Code Coverage result
"`n----------------------------------------------------------------------"
function Update-CodeCoveragePercent {
    [cmdletbinding(supportsshouldprocess)]
    param(
        [int]
        $CodeCoverage = 0,
            
        [string]
        $TextFilePath = (Join-Path $Env:BHProjectPath 'README.md')
    )
    
    $BadgeColor = switch ($CodeCoverage) {
        {$_ -in 90..100} { 'brightgreen' }
        {$_ -in 75..89} { 'yellow' }
        {$_ -in 60..74} { 'orange' }
        default { 'red' }
    }
    
    if ($PSCmdlet.ShouldProcess($TextFilePath)) {
        $ReadmeContent = (Get-Content $TextFilePath)
        $ReadmeContent = $ReadmeContent -replace "!\[Test Coverage\].+\)", "![Test Coverage](https://img.shields.io/badge/coverage-$CodeCoverage%25-$BadgeColor.svg?maxAge=60)" 
        $ReadmeContent | Set-Content -Path $TextFilePath
    }
}
    
$CoveragePercent = [math]::floor(100 - (($TestResults.CodeCoverage.NumberOfCommandsMissed / $TestResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100))

"`n`tSTATUS: Running Update-CodeCoveragePercent to update Readme.md with $CoveragePercent% code coverage badge."
Update-CodeCoveragePercent -CodeCoverage $CoveragePercent