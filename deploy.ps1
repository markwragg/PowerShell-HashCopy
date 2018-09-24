# Deploy
"`n----------------------------------------------------------------------"

# Update Manifest version number
$ManifestPath = $Env:BHPSModuleManifest
    
if (-Not $env:APPVEYOR_BUILD_VERSION) {
    $Manifest = Test-ModuleManifest -Path $manifestPath
    [System.Version]$Version = $Manifest.Version
    [String]$NewVersion = New-Object -TypeName System.Version -ArgumentList ($Version.Major, $Version.Minor, $Version.Build, ($Version.Revision + 1))
} 
else {
    $NewVersion = $env:APPVEYOR_BUILD_VERSION
}
"New Version: $NewVersion"

$FunctionList = @((Get-ChildItem -File -Recurse -Path (Join-Path $Env:BHModulePath 'Public')).BaseName)

Update-ModuleManifest -Path $ManifestPath -ModuleVersion $NewVersion -FunctionsToExport $functionList
    
$Params = @{
    Path    = $ProjectRoot
    Force   = $true
    Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
}
Invoke-PSDeploy @Params