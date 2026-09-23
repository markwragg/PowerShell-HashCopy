function Test-ExcludeMatch {
    <#
        .SYNOPSIS
            Returns whether a file name matches any of the given -Exclude wildcard patterns.

        .PARAMETER Name
            The file name to test.

        .PARAMETER Exclude
            One or more wildcard patterns to match the name against.

        .EXAMPLE
            Test-ExcludeMatch -Name 'somefile.txt' -Exclude 'some*'
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Name,

        [string[]]
        $Exclude
    )

    foreach ($Pattern in $Exclude) {
        if ($Name -like $Pattern) {
            return $true
        }
    }

    return $false
}
