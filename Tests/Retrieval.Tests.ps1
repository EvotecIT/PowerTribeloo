BeforeAll {
    . (Join-Path $PSScriptRoot '../Public/Get-TribelooUser.ps1')
    function Remove-EmptyValue { param($Hashtable) }
    function Join-UriQuery { param($BaseUri, $RelativeOrAbsoluteUri, $QueryParameter) $script:Query = $QueryParameter; 'https://tenant.example/scim/v2/Users' }
    function Invoke-RestMethod { [CmdletBinding()] param($Method, $Uri, $Headers, $ContentType) }
    function Convert-TribelooUser { param($Users) foreach ($user in $Users) { [pscustomobject]@{ id = $user.id; Converted = $true } } }
}

Describe 'Tribeloo complete user retrieval' {
    BeforeEach {
        $script:AuthorizationTribeloo = @{ BaseUri = 'https://tenant.example/scim/v2/'; Authorization = 'synthetic' }
        $script:Queries = [Collections.Generic.List[object]]::new()
        Mock Invoke-RestMethod {
            $script:Queries.Add(@{ Start = $script:Query.startIndex; Count = $script:Query.count; Filter = $script:Query.filter; Sort = $script:Query.sortBy })
            $start = [int] $script:Query.startIndex
            $take = [math]::Min(1000, 1001 - $start + 1)
            @{ totalResults = 1001; startIndex = $start; itemsPerPage = $take; Resources = @($start..($start + $take - 1) | ForEach-Object { [pscustomobject] @{ id = "user-$_" } }) }
        }
    }

    It 'includes the final user at the default 1000-user boundary and preserves search and sort' {
        $users = @(Get-TribelooUser -SearchUserName 'one@example.test' -SortBy DisplayName -Native -ErrorAction Stop)
        $users.Count | Should -Be 1001
        $users[-1].id | Should -Be 'user-1001'
        $script:Queries.Start | Should -Be @(1, 1001)
        $script:Queries[1].Filter | Should -Be 'userName eq "one@example.test"'
        $script:Queries[1].Sort | Should -Be 'displayName'
    }

    It 'advances by the returned size when the server caps pages below the requested count' {
        Mock Invoke-RestMethod { @{ totalResults = 3; startIndex = $script:Query.startIndex; Resources = @([pscustomobject] @{ id = "user-$($script:Query.startIndex)" }) } }
        $users = @(Get-TribelooUser -Native -ErrorAction Stop)
        $users.id | Should -Be @('user-1', 'user-2', 'user-3')
        Should -Invoke Invoke-RestMethod -Times 3 -Exactly
    }

    It 'honors a total result limit across pages and preserves converted output' {
        Mock Invoke-RestMethod { $start = [int] $script:Query.startIndex; @{ totalResults = 10; startIndex = $start; Resources = @($start..($start + 2) | ForEach-Object { [pscustomobject]@{id = $_} }) } }
        $users = @(Get-TribelooUser -MaxResults 5 -ErrorAction Stop)
        $users.Count | Should -Be 5
        $users[-1].id | Should -Be 5
        $users[-1].Converted | Should -BeTrue
        Should -Invoke Invoke-RestMethod -Times 2 -Exactly
    }

    It 'terminates on a later HTTP failure for an explicit Stop caller' {
        Mock Invoke-RestMethod { if ($script:Query.startIndex -gt 1) { throw 'Later page failed' }; @{ totalResults = 2; startIndex = 1; Resources = @([pscustomobject] @{ id = 'first' }) } }
        { @(Get-TribelooUser -Native -ErrorAction Stop) } | Should -Throw '*Later page failed*'
    }

    It 'keeps the default warning and partial output behavior' {
        Mock Invoke-RestMethod { if ($script:Query.startIndex -gt 1) { throw 'Later page failed' }; @{ totalResults = 2; startIndex = 1; Resources = @([pscustomobject] @{ id = 'first' }) } }
        $users = @(Get-TribelooUser -Native -ErrorAction Continue -WarningVariable warnings -WarningAction SilentlyContinue)
        $users.Count | Should -Be 1
        $warnings.Count | Should -Be 1
    }

    It 'rejects an empty intermediate page and nonadvancing pagination' {
        Mock Invoke-RestMethod { @{ totalResults = 2; startIndex = 1; Resources = @() } }
        { Get-TribelooUser -Native -ErrorAction Stop } | Should -Throw '*empty page*'
        Mock Invoke-RestMethod { @{ totalResults = 3; startIndex = 1; Resources = @([pscustomobject] @{ id = 'first' }) } }
        { @(Get-TribelooUser -Native -ErrorAction Stop) } | Should -Throw '*did not advance*'
    }

    It 'allows an empty directory and a single user request' {
        Mock Invoke-RestMethod { @{ totalResults = 0; startIndex = 1; Resources = @() } }
        @(Get-TribelooUser -Native -ErrorAction Stop).Count | Should -Be 0
        Mock Invoke-RestMethod { @{ schemas = @('User'); id = 'one' } }
        (Get-TribelooUser -Id one -Native -ErrorAction Stop).id | Should -Be one
    }

    It 'rejects missing authorization or malformed list responses for Stop callers' {
        $script:AuthorizationTribeloo = $null
        { Get-TribelooUser -ErrorAction Stop } | Should -Throw '*Connect-Tribeloo*'
        $script:AuthorizationTribeloo = @{ BaseUri = 'https://tenant.example/'; Authorization = 'synthetic' }
        Mock Invoke-RestMethod { @{ message = 'unexpected payload' } }
        { Get-TribelooUser -ErrorAction Stop } | Should -Throw '*list response*'
    }
}
