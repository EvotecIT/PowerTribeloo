function Get-TribelooUser {
    <#
    .SYNOPSIS
    Retrieves Tribeloo users across every SCIM response page.
    .PARAMETER StartIndex
    One-based index of the first user to request.
    .PARAMETER Count
    Requested page size. A smaller server page still advances by its returned size.
    .PARAMETER MaxResults
    Maximum total users to return. Zero retrieves all users.
    .EXAMPLE
    Get-TribelooUser -ErrorAction Stop
    Stops on a failed or incomplete page so synchronization can reject partial results.
    #>
    [CmdletBinding()]
    param(
        [string] $Id,
        [Alias('UserName')][string] $SearchUserName,
        [Alias('ExternalID')][string] $SearchExternalID,
        [string] $Search,
        [ValidateSet(
            'id',
            'userName',
            'givenName',
            'familyName',
            'displayName',
            'nickName',
            'emails',
            'addresses',
            'meta'
        )]
        [string] $SearchProperty = 'userName',
        [string] $SearchOperator = 'eq',
        [int] $MaxResults,
        [string] $Filter,
        [ValidateSet(
            'id',
            'userName',
            'givenName',
            'familyName',
            'displayName',
            'nickName',
            'emails',
            'addresses',
            'meta'
        )]
        [string] $SortBy,
        [ValidateSet('ascending', 'descending')][string] $SortOrder,
        [switch] $Native,
        [ValidateRange(1, 2147483647)][int] $StartIndex = 1,
        [ValidateRange(1, 2147483647)][int] $Count = 1000
    )
    try {
        if (-not $Script:AuthorizationTribeloo) { throw "No authorization found. Run Connect-Tribeloo first." }
        $attributes = @{
            id = 'id'; userName = 'userName'; givenName = 'name.givenName'; familyName = 'name.familyName'
            displayName = 'displayName'; nickName = 'nickName'; emails = 'emails'; active = 'active'; meta = 'meta'
        }
        $effectiveFilter = if ($SearchUserName) { "userName eq `"$SearchUserName`"" }
            elseif ($SearchExternalID) { "externalId eq `"$SearchExternalID`"" }
            elseif ($Search -and $SearchProperty) { "$($attributes[$SearchProperty]) $SearchOperator `"$Search`"" }
            else { $Filter }
        $index = $StartIndex
        $remaining = $MaxResults
        while ($true) {
            $query = @{
                filter = $effectiveFilter
                sortBy = $attributes[$SortBy]
                sortOrder = $SortOrder
            }
            if (-not $Id) { $query.count = $Count; $query.startIndex = $index }
            Remove-EmptyValue -Hashtable $query
            $relative = if ($Id) { "Users/$Id" } else { 'Users' }
            $uri = Join-UriQuery -BaseUri $Script:AuthorizationTribeloo.BaseUri -RelativeOrAbsoluteUri $relative -QueryParameter $query
            Write-Verbose "Get-TribelooUser - Using query: $uri"
            $batch = Invoke-RestMethod -Method Get -Uri $uri -Headers @{
                'Content-Type' = 'application/json; charset=utf-8'
                Authorization = $Script:AuthorizationTribeloo.Authorization
                'Cache-Control' = 'no-cache'
            } -ErrorAction Stop -ContentType 'application/json; charset=utf-8'
            if ($Id) {
                if (-not $batch.id) { throw 'Tribeloo returned an invalid single-user response.' }
                if ($Native) { $batch } else { Convert-TribelooUser -Users $batch }
                return
            }
            $names = if ($batch -is [Collections.IDictionary]) { @($batch.Keys) } else { @($batch.PSObject.Properties.Name) }
            if ($names -notcontains 'Resources' -or $null -eq $batch.totalResults -or $batch.totalResults -lt 0) { throw 'Tribeloo returned an invalid user list response.' }
            $users = @($batch.Resources | Where-Object { $null -ne $_ })
            if ($users.Count -eq 0) {
                if ($batch.totalResults -ge $index) { throw 'Tribeloo returned an empty page before the declared total was retrieved.' }
                return
            }
            $pageStart = if ($null -ne $batch.startIndex) { [long] $batch.startIndex } else { [long] $index }
            if ($pageStart -ne $index) { throw 'Tribeloo pagination did not advance to the requested startIndex.' }
            $selected = if ($MaxResults -gt 0) { @($users | Select-Object -First $remaining) } else { $users }
            if ($Native) { $selected } else { Convert-TribelooUser -Users $selected }
            if ($MaxResults -gt 0) { $remaining -= $selected.Count; if ($remaining -le 0) { return } }
            $next = $pageStart + $users.Count
            if ($next -gt $batch.totalResults) { return }
            if ($next -le $index -or $next -gt [int]::MaxValue) { throw 'Tribeloo pagination did not advance. A complete result could not be retrieved.' }
            $index = [int] $next
        }
    } catch {
        if ($ErrorActionPreference -eq [Management.Automation.ActionPreference]::Stop) { throw }
        Write-Warning "Get-TribelooUser - $($_.Exception.Message)"
    }
}