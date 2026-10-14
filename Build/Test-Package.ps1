param(
    [string] $ModuleRoot = (Join-Path $PSScriptRoot '../Artefacts/Unpacked/Modules/PowerTribeloo'),
    [string] $ModuleName = 'PowerTribeloo'
)
$ErrorActionPreference = 'Stop'
$env:PSModulePath = (Split-Path -Parent $ModuleRoot) + [IO.Path]::PathSeparator + (Join-Path $PSHOME 'Modules')
Import-Module (Join-Path $ModuleRoot "$ModuleName.psd1") -Force
$module = Get-Module $ModuleName
& $module {
    $script:GetCalls = 0
    $script:FailLaterPage = $false
    function script:Invoke-RestMethod {
        [CmdletBinding()] param($Method, $Uri, $Headers, $ContentType)
        $script:GetCalls++
        if ($script:FailLaterPage -and $script:GetCalls -eq 2) { throw 'synthetic-later-page-failure' }
        $start = [int] [regex]::Match([string] $Uri, 'startIndex=(\d+)').Groups[1].Value
        if ($start -lt 1) { throw 'Missing page start index' }
        $end = [math]::Min($start + 499, 1001)
        [pscustomobject]@{ startIndex = $start; totalResults = 1001; Resources = @($start..$end | ForEach-Object { [pscustomobject]@{ id = "user-$_" } }) }
    }
    $null = Connect-Tribeloo -Token synthetic -Uri 'https://tenant.example/scim/v2/'
    $users = @(Get-TribelooUser -Native -ErrorAction Stop)
    if ($users.Count -ne 1001 -or $users[-1].id -ne 'user-1001' -or $script:GetCalls -ne 3) { throw 'Packaged Tribeloo pagination was incomplete' }
    $script:GetCalls = 0
    $script:FailLaterPage = $true
    $failed = $false
    try { $users = @(Get-TribelooUser -Native -ErrorAction Stop) }
    catch { $failed = $_.Exception.Message -eq 'synthetic-later-page-failure' }
    if (-not $failed -or $script:GetCalls -ne 2) { throw 'Packaged Tribeloo strict pagination failed' }
}
[pscustomobject]@{ Module = $ModuleName; Version = [string] $module.Version; PowerShell = [string] $PSVersionTable.PSVersion; PaginationAndStrictFailure = 'PASS'; ExternalCalls = 0 } | ConvertTo-Json
