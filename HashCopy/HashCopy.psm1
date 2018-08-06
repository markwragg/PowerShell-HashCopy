$Public = @( Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -Recurse )

$Public | ForEach-Object {
    try {
        . $_.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($_.FullName): $_"
    }
}