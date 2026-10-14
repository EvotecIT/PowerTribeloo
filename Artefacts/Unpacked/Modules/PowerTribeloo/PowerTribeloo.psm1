function Join-UriQuery {
    <#
    .SYNOPSIS
    Provides ability to join two Url paths together including advanced querying

    .DESCRIPTION
    Provides ability to join two Url paths together including advanced querying which is useful for RestAPI/GraphApi calls

    .PARAMETER BaseUri
    Primary Url to merge

    .PARAMETER RelativeOrAbsoluteUri
    Additional path to merge with primary url (optional)

    .PARAMETER QueryParameter
    Parameters and their values in form of hashtable

    .PARAMETER EscapeUriString
    If set, will escape the url string

    .EXAMPLE
    Join-UriQuery -BaseUri 'https://evotec.xyz/' -RelativeOrAbsoluteUri '/wp-json/wp/v2/posts' -QueryParameter @{
        page     = 1
        per_page = 20
        search   = 'SearchString'
    }

    .EXAMPLE
    Join-UriQuery -BaseUri 'https://evotec.xyz/wp-json/wp/v2/posts' -QueryParameter @{
        page     = 1
        per_page = 20
        search   = 'SearchString'
    }

    .EXAMPLE
    Join-UriQuery -BaseUri 'https://evotec.xyz' -RelativeOrAbsoluteUri '/wp-json/wp/v2/posts'

    .NOTES
    General notes
    #>
    [alias('Join-UrlQuery')]
    [CmdletBinding()]
    param (
        [parameter(Mandatory)][uri] $BaseUri,
        [parameter(Mandatory = $false)][uri] $RelativeOrAbsoluteUri,
        [Parameter()][System.Collections.IDictionary] $QueryParameter,
        [alias('EscapeUrlString')][switch] $EscapeUriString
    )
    begin {
        Add-Type -AssemblyName System.Web
    }
    process {
        # Join primary url with additional path if needed
        if ($BaseUri -and $RelativeOrAbsoluteUri) {
            $Url = Join-Uri -BaseUri $BaseUri -RelativeOrAbsoluteUri $RelativeOrAbsoluteUri
        }
        else {
            $Url = $BaseUri
        }

        # Create a http name value collection from an empty string
        if ($QueryParameter) {
            $Collection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            foreach ($key in $QueryParameter.Keys) {
                $Collection.Add($key, $QueryParameter.$key)
            }
        }

        # Build the uri
        $uriRequest = [System.UriBuilder] $Url
        if ($Collection) {
            $uriRequest.Query = $Collection.ToString()
        }
        if (-not $EscapeUriString) {
            $uriRequest.Uri.AbsoluteUri
        }
        else {
            [System.Uri]::EscapeUriString($uriRequest.Uri.AbsoluteUri)
        }
    }
 }
function Remove-EmptyValue {
    <#
    .SYNOPSIS
    Removes empty values from a hashtable recursively.

    .DESCRIPTION
    This function removes empty values from a given hashtable. It can be used to clean up a hashtable by removing keys with null, empty string, empty array, or empty dictionary values. The function supports recursive removal of empty values.

    .PARAMETER Hashtable
    The hashtable from which empty values will be removed.

    .PARAMETER ExcludeParameter
    An array of keys to exclude from the removal process.

    .PARAMETER Recursive
    Indicates whether to recursively remove empty values from nested hashtables.

    .PARAMETER Rerun
    Specifies the number of times to rerun the removal process recursively.

    .PARAMETER DoNotRemoveNull
    If specified, null values will not be removed.

    .PARAMETER DoNotRemoveEmpty
    If specified, empty string values will not be removed.

    .PARAMETER DoNotRemoveEmptyArray
    If specified, empty array values will not be removed.

    .PARAMETER DoNotRemoveEmptyDictionary
    If specified, empty dictionary values will not be removed.

    .EXAMPLE
    $hashtable = @{
        'Key1' = '';
        'Key2' = $null;
        'Key3' = @();
        'Key4' = @{}
    }
    Remove-EmptyValue -Hashtable $hashtable -Recursive

    Description
    -----------
    This example removes empty values from the $hashtable recursively.

    .EXAMPLE
    $SplatDictionary = [ordered] @{
        Test  = $NotExistingParameter
        Test1 = 'Existing Entry'
        Test2 = $null
        Test3 = ''
        Test5 = 0
        Test6 = 6
        Test7 = @{}
    }

    Remove-EmptyValue -Splat $SplatDictionary -Recursive -ExcludeParameter 'Test7'

    $SplatDictionary

    #>
    [alias('Remove-EmptyValues')]
    [CmdletBinding()]
    param(
        [alias('Splat', 'IDictionary')][Parameter(Mandatory)][System.Collections.IDictionary] $Hashtable,
        [string[]] $ExcludeParameter,
        [switch] $Recursive,
        [int] $Rerun,
        [switch] $DoNotRemoveNull,
        [switch] $DoNotRemoveEmpty,
        [switch] $DoNotRemoveEmptyArray,
        [switch] $DoNotRemoveEmptyDictionary
    )
    foreach ($Key in [string[]] $Hashtable.Keys) {
        if ($Key -notin $ExcludeParameter) {
            if ($Recursive) {
                if ($Hashtable[$Key] -is [System.Collections.IDictionary]) {
                    if ($Hashtable[$Key].Count -eq 0) {
                        if (-not $DoNotRemoveEmptyDictionary) {
                            $Hashtable.Remove($Key)
                        }
                    }
                    else {
                        Remove-EmptyValue -Hashtable $Hashtable[$Key] -Recursive:$Recursive -ExcludeParameter $ExcludeParameter -DoNotRemoveNull:$DoNotRemoveNull -DoNotRemoveEmpty:$DoNotRemoveEmpty -DoNotRemoveEmptyArray:$DoNotRemoveEmptyArray -DoNotRemoveEmptyDictionary:$DoNotRemoveEmptyDictionary
                    }
                }
                else {
                    if (-not $DoNotRemoveNull -and $null -eq $Hashtable[$Key]) {
                        $Hashtable.Remove($Key)
                    }
                    elseif (-not $DoNotRemoveEmpty -and $Hashtable[$Key] -is [string] -and $Hashtable[$Key] -eq '') {
                        $Hashtable.Remove($Key)
                    }
                    elseif (-not $DoNotRemoveEmptyArray -and $Hashtable[$Key] -is [System.Collections.IList] -and $Hashtable[$Key].Count -eq 0) {
                        $Hashtable.Remove($Key)
                    }
                }
            }
            else {
                if (-not $DoNotRemoveNull -and $null -eq $Hashtable[$Key]) {
                    $Hashtable.Remove($Key)
                }
                elseif (-not $DoNotRemoveEmpty -and $Hashtable[$Key] -is [string] -and $Hashtable[$Key] -eq '') {
                    $Hashtable.Remove($Key)
                }
                elseif (-not $DoNotRemoveEmptyArray -and $Hashtable[$Key] -is [System.Collections.IList] -and $Hashtable[$Key].Count -eq 0) {
                    $Hashtable.Remove($Key)
                }
            }
        }
    }
    if ($Rerun) {
        for ($i = 0; $i -lt $Rerun; $i++) {
            Remove-EmptyValue -Hashtable $Hashtable -Recursive:$Recursive -ExcludeParameter $ExcludeParameter -DoNotRemoveNull:$DoNotRemoveNull -DoNotRemoveEmpty:$DoNotRemoveEmpty -DoNotRemoveEmptyArray:$DoNotRemoveEmptyArray -DoNotRemoveEmptyDictionary:$DoNotRemoveEmptyDictionary
        }
    }
 }
function Join-Uri {
    <#
    .SYNOPSIS
    Provides ability to join two Url paths together

    .DESCRIPTION
    Provides ability to join two Url paths together

    .PARAMETER BaseUri
    Primary Url to merge

    .PARAMETER RelativeOrAbsoluteUri
    Additional path to merge with primary url

    .EXAMPLE
    Join-Uri 'https://evotec.xyz/' '/wp-json/wp/v2/posts'

    .EXAMPLE
    Join-Uri 'https://evotec.xyz/' 'wp-json/wp/v2/posts'

    .EXAMPLE
    Join-Uri -BaseUri 'https://evotec.xyz/' -RelativeOrAbsoluteUri '/wp-json/wp/v2/posts'

    .EXAMPLE
    Join-Uri -BaseUri 'https://evotec.xyz/test/' -RelativeOrAbsoluteUri '/wp-json/wp/v2/posts'

    .NOTES
    General notes
    #>
    [alias('Join-Url')]
    [cmdletBinding()]
    param(
        [parameter(Mandatory)][uri] $BaseUri,
        [parameter(Mandatory)][uri] $RelativeOrAbsoluteUri
    )

    return ($BaseUri.OriginalString.TrimEnd('/') + "/" + $RelativeOrAbsoluteUri.OriginalString.TrimStart('/'))
    #return [Uri]::new([Uri]::new($BaseUri), $RelativeOrAbsoluteUri).ToString()
    #return [Uri]::new($BaseUri.OriginalString, $RelativeOrAbsoluteUri).ToString()
 }

# PowerForge merged source begin 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d
function Convert-TribelooUser {
    [cmdletBinding()]
    param(
        [Array] $Users
    )
    foreach ($User in $Users) {
        $WorkEmail = $null
        $Emails = $User.'emails'
        foreach ($Email in $Emails) {
            if ($Email.Type -eq 'work') {
                $WorkEmail = $Email.Value
            }
        }

        [PSCustomObject] @{
            Id           = $User.'id'
            UserName     = $User.'userName'
            GivenName    = $User.'name'.'givenName'
            FamilyName   = $User.'name'.'familyName'
            DisplayName  = $User.'displayName'
            NickName     = $User.'nickName'
            EmailAddress = $WorkEmail
            Active       = $User.'active'
            Formatted    = $User.'addresses'[0].'formatted'
            Created      = $User.Meta.Created
            LastModified = $User.Meta.Updated
            Location     = $User.Meta.location
        }
    }
}
# PowerForge merged source end 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d

# PowerForge merged source begin 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d
function Connect-Tribeloo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Token,
        [Parameter(Mandatory)][alias('Url', 'BaseUri')][string] $Uri,
        [switch] $Suppress
    )

    $Script:AuthorizationTribeloo = @{
        'Authorization' = "Bearer $Token"
        'Content-Type'  = 'application/json; charset=utf-8'
        'BaseUri'       = $Uri
    }
    if (-not $Suppress){
        return $Script:AuthorizationTribeloo
    }
}
# PowerForge merged source end 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d

# PowerForge merged source begin 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d
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
# PowerForge merged source end 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d

# PowerForge merged source begin 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d
function New-TribelooUser {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory)][string] $UserName,
        [string] $FamilyName,
        [string] $GivenName,
        [parameter(Mandatory)][string] $DisplayName,
        [string] $NickName,
        [string] $EmailAddress,
        [string] $Formatted,
        [switch] $Active
    )
    if (-not $Script:AuthorizationTribeloo) {
        return
    }


    $Body = [ordered] @{
        schemas       = @(
            "urn:ietf:params:scim:schemas:core:2.0:User"
        )
        "userName"    = $UserName
        "name"        = [ordered] @{
            "familyName" = $FamilyName
            "givenName"  = $GivenName
        }
        "displayName" = $DisplayName
        "nickName"    = $NickName
        "emails"      = @(
            if ($EmailAddress) {
                @{
                    "value"   = $EmailAddress
                    "type"    = "work"
                    "primary" = $true
                }
            }
        )
        "addresses"   = @(
            if ($Formatted) {
                [ordered]@{
                    "formatted" = $Formatted
                    "type"      = "work"
                }
            }
        )
        "active"      = if ($PSBoundParameters.Keys -contains ('Active')) { $Active.IsPresent } else { $Null }
    }

    Try {
        Remove-EmptyValue -Hashtable $Body -Recursive -Rerun 2

        # for troubleshooting
        if ($VerbosePreference -eq 'Continue') {
            $Body | ConvertTo-Json -Depth 10 | Write-Verbose
        }

        if ($BulkProcessing) {
            # Return body is used for using Invoke-FederatedDirectory to add/set/remove users in bulk

            $ReturnObject = [ordered] @{
                data   = $Body
                method = 'POST'
                bulkId = $Body.userName
            }
            # for troubleshooting
            if ($VerbosePreference -eq 'Continue') {
                $ReturnObject | ConvertTo-Json -Depth 10 | Write-Verbose
            }
            return $ReturnObject
        }
        $Uri = Join-UriQuery -BaseUri $Script:AuthorizationTribeloo.BaseUri -RelativeOrAbsoluteUri 'Users'
        $invokeRestMethodSplat = [ordered] @{
            Method      = 'POST'
            Uri         = $Uri
            Headers     = [ordered]  @{
                'Content-Type'  = 'application/json; charset=utf-8'
                'Authorization' = $Script:AuthorizationTribeloo.Authorization
                'Cache-Control' = 'no-cache'
            }
            Body        = $Body | ConvertTo-Json -Depth 10
            ErrorAction = 'Stop'
            ContentType = 'application/json; charset=utf-8'
        }
        if ($DirectoryID) {
            $invokeRestMethodSplat['Headers']['directoryId'] = $DirectoryID
        }

        Write-Verbose -Message "Get-TribelooUser - Using query: $Uri"

        if ($PSCmdlet.ShouldProcess("username $UserName, displayname $DisplayName", "Adding user")) {
            $ReturnData = Invoke-RestMethod @invokeRestMethodSplat -Verbose:$false
            # don't return data as we trust it's been created
            if (-not $Suppress) {
                $ReturnData
            }
        }

        # # for troubleshooting
        # if ($VerbosePreference -eq 'Continue') {
        #     $invokeRestMethodSplat.Remove('body')
        #     $invokeRestMethodSplat | ConvertTo-Json -Depth 10 | Write-Verbose
        # }
    } catch {
        if ($PSBoundParameters.ErrorAction -eq 'Stop') {
            throw
        } else {
            $ErrorDetails = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($ErrorDetails.Detail -like '*already exists*directory*') {
                Write-Warning -Message "Add-TribelooUser - $($ErrorDetails.Detail) [UserName: $UserName / DisplayName: $DisplayName]"
            } else {
                Write-Warning -Message "Add-TribelooUser - Error $($_.Exception.Message), $($ErrorDetails.Detail)"
            }
        }

    }
}
# PowerForge merged source end 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d

# PowerForge merged source begin 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d
function Remove-TribelooUser {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Position = 0, ValueFromPipeline, Mandatory, ParameterSetName = 'User')][PSCustomObject[]] $User,
        [parameter(Mandatory, ParameterSetName = 'Id')][string[]] $Id,
        [parameter(Mandatory, ParameterSetName = 'UserName')][string[]] $SearchUserName,
        [switch] $Suppress,
        [parameter(ParameterSetName = 'All')][switch] $All
    )
    Begin {
        if (-not $Script:AuthorizationTribeloo) {
            if ($PSBoundParameters.ErrorAction -eq 'Stop') {
                throw "No authorization found. Please run 'Connect-Tribeloo' first."
            } else {
                Write-Warning -Message "Remove-TribelooUser - No authorization found. Please run 'Connect-Tribeloo' first."
                return
            }
            return
        }
    }
    Process {
        if ($All) {
            # lets simplify this for all
            $Users = Get-TribelooUser
            foreach ($U in $Users) {
                Remove-TribelooUser -Id $U.id
            }
        } else {
            if ($Id) {
                $RemoveID = $Id
            } elseif ($User) {
                $RemoveID = $User.Id
            } elseif ($SearchUserName) {
                $RemoveID = Foreach ($U in $SearchUserName) {
                (Get-TribelooUser -UserName $U).Id
                }
            } else {
                return
            }
            foreach ($I in $RemoveID) {
                Try {
                    if ($BulkProcessing) {
                        # Return body is used for using Invoke-FederatedDirectory to add/set/remove users in bulk
                        return [ordered] @{
                            data   = @{
                                schemas = @("urn:ietf:params:scim:schemas:core:2.0:User")
                                id      = $I
                            }
                            method = 'DELETE'
                            bulkId = $I
                        }
                    }
                    $Uri = Join-UriQuery -BaseUri $Script:AuthorizationTribeloo.BaseUri -RelativeOrAbsoluteUri "Users/$I"
                    $invokeRestMethodSplat = [ordered] @{
                        Method      = 'DELETE'
                        Uri         = $Uri
                        Headers     = [ordered]  @{
                            'Content-Type'  = 'application/json; charset=utf-8'
                            'Authorization' = $Script:AuthorizationTribeloo.Authorization
                            'Cache-Control' = 'no-cache'
                        }
                        ErrorAction = 'Stop'
                        ContentType = 'application/json; charset=utf-8'
                    }
                    Remove-EmptyValue -Hashtable $invokeRestMethodSplat -Recursive

                    if ($VerbosePreference -eq 'Continue') {
                        $invokeRestMethodSplat | ConvertTo-Json -Depth 10 | Write-Verbose
                    }
                    if ($PSCmdlet.ShouldProcess($I, "Removing user")) {
                        $ReturnData = Invoke-RestMethod @invokeRestMethodSplat
                        if (-not $Suppress) {
                            $ReturnData
                        }
                    }
                } catch {
                    $ErrorDetails = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
                    if ($ErrorDetails.Detail -like "*not found*") {
                        Write-Warning -Message "Remove-TribelooUser - $($ErrorDetails.Detail)."
                    } else {
                        Write-Warning -Message "Remove-TribelooUser - Error $($_.Exception.Message), $($ErrorDetails.Detail)"
                    }
                }
            }
        }
    }
}
# PowerForge merged source end 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d

# PowerForge merged source begin 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d
function Set-TribelooUser {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string] $SearchUserName,
        [string] $Id,
        [string] $UserName,
        [string] $FamilyName,
        [string] $GivenName,
        [string] $DisplayName,
        [string] $NickName,
        [string] $EmailAddress,
        [string] $Formatted,
        [bool] $Active,
        [switch] $Suppress,
        [ValidateSet('Overwrite', 'Update')][string] $Action = 'Update',
        [System.Collections.IDictionary] $ActionPerProperty = @{},
        [switch] $BulkProcessing
    )

    if (-not $Script:AuthorizationTribeloo) {
        if ($PSBoundParameters.ErrorAction -eq 'Stop') {
            throw "No authorization found. Please run 'Connect-Tribeloo' first."
        } else {
            Write-Warning -Message "Remove-TribelooUser - No authorization found. Please run 'Connect-Tribeloo' first."
            return
        }
        return
    }

    if ($Id) {
        $SetID = $Id
    } elseif ($User) {
        $SetID = $User.Id
    } elseif ($SearchUserName) {
        $SetID = Foreach ($U in $SearchUserName) {
                (Get-TribelooUser -UserName $U).Id
        }
    } else {
        Write-Warning -Message "Set-TribelooUser - No ID or UserName specified."
        return
    }
    if ($ManagerUserName) {
        $ManagerID = (Get-TribelooUser -UserName $ManagerUserName).Id
    }

    if ($Action -eq 'Update') {
        $TranslatePath = @{
            UserName     = "userName"
            FamilyName   = "name.familyName"
            GivenName    = 'name.givenName'
            DisplayName  = 'displayName'
            NickName     = 'nickName'
            EmailAddress = 'emails[type eq "work"].value'
            Active       = 'active'
            Formatted    = 'addresses[type eq "work"].formatted'
        }

        $Body = [ordered] @{
            schemas    = @(
                "urn:ietf:params:scim:api:messages:2.0:PatchOp"
            )
            Operations = @(
                foreach ($Key in $PSBoundParameters.Keys) {
                    if ($Key -in $TranslatePath.Keys) {
                        if ($TranslatePath[$Key]) {
                            $Path = $TranslatePath[$Key]
                        } else {
                            $Path = $Key
                        }
                        if ($null -ne $PSBoundParameters[$Key]) {
                            $Value = $PSBoundParameters[$Key]
                        } else {
                            $Value = $null
                        }
                        if ($ActionPerProperty) {
                            if ($ActionPerProperty[$Key]) {
                                $ActionProperty = $ActionPerProperty[$Key]
                            } else {
                                $ActionProperty = 'replace'
                            }
                        } else {
                            $ActionProperty = 'replace'
                        }
                        if ($null -ne $Value) {
                            [ordered] @{
                                op    = $ActionProperty
                                path  = $Path
                                value = $Value
                            }
                        }
                    }
                }
            )
        }
    } else {

        $Body = [ordered] @{
            schemas       = @(
                "urn:ietf:params:scim:schemas:core:2.0:User"
                "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"
                "urn:ietf:params:scim:schemas:extension:fd:2.0:User"
            )
            "id"          = $Id
            "userName"    = $UserName
            "name"        = [ordered] @{
                "familyName" = $FamilyName
                "givenName"  = $GivenName
            }
            "displayName" = $DisplayName
            "nickName"    = $NickName
            "emails"      = @(
                if ($EmailAddress) {
                    [ordered]@{
                        "value"   = $EmailAddress
                        "type"    = "work"
                        "primary" = $true
                    }
                }
            )
            "addresses"   = @(
                if ($Formatted) {
                    [ordered]@{
                        "formatted" = $Formatted
                        "type"      = "work"
                    }
                }
            )
            "active"      = if ($PSBoundParameters.Keys -contains ('Active')) { $Active } else { $Null }
        }
    }
    Try {
        Remove-EmptyValue -Hashtable $Body -Recursive -Rerun 3

        $MethodChosen = if ($Action -eq 'Update') { 'PATCH' } else { 'PUT' }
        if ($BulkProcessing) {
            # Return body is used for using Invoke-FederatedDirectory to add/set/remove users in bulk
            if ($Action -eq 'Update') {
                Write-Warning -Message "Bulk processing is not supported for Update action. Only Overwrite action is supported. Change action to Overwrite or don't use bulk processing for updates."
            } else {
                return [ordered] @{
                    data   = $Body
                    method = $MethodChosen
                    bulkId = $SetID
                }
            }
        }
        $Uri = Join-UriQuery -BaseUri $Script:AuthorizationTribeloo.BaseUri -RelativeOrAbsoluteUri "Users/$SetID"

        $invokeRestMethodSplat = [ordered] @{
            Method      = $MethodChosen
            Uri         = $Uri
            Headers     = [ordered]  @{
                'Content-Type'  = 'application/json'
                'Authorization' = $Script:AuthorizationTribeloo.Authorization
                'Cache-Control' = 'no-cache'
            }
            Body        = $Body | ConvertTo-Json -Depth 10
            ErrorAction = 'Stop'
            ContentType = 'application/json; charset=utf-8'
        }
        if ($DirectoryID) {
            $invokeRestMethodSplat['Headers']['directoryId'] = $DirectoryID
        }
        # for troubleshooting
        if ($VerbosePreference -eq 'Continue') {
            $Body | ConvertTo-Json -Depth 10 | Write-Verbose
        }
        if ($PSCmdlet.ShouldProcess($SetID, "Updating user using $Action method")) {
            $ReturnData = Invoke-RestMethod @invokeRestMethodSplat
            # don't return data as we trust it's been updated
            if (-not $Suppress) {
                $ReturnData
            }
        }
        # # for troubleshooting
        # if ($VerbosePreference -eq 'Continue') {
        #     $invokeRestMethodSplat.Remove('body')
        #     $invokeRestMethodSplat | ConvertTo-Json -Depth 10 | Write-Verbose
        # }
    } catch {
        if ($PSBoundParameters.ErrorAction -eq 'Stop') {
            throw
        } else {
            $ErrorDetails = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($ErrorDetails.Detail -like '*userName is mandatory*') {
                Write-Warning -Message "Set-TribelooUser - $($ErrorDetails.Detail) [Id: $SetID]"
            } else {
                Write-Warning -Message "Set-TribelooUser - Error $($_.Exception.Message), $($ErrorDetails.Detail) [Id: $SetID]"
            }
        }
    }

}
# PowerForge merged source end 95e36fd0deb65dba6d786a4202f1a88d856edc3649fcff3b97ebf3eaa3200a4d

$FunctionsToExport = @('Connect-Tribeloo', 'Get-TribelooUser', 'New-TribelooUser', 'Remove-TribelooUser', 'Set-TribelooUser')
$CmdletsToExport = @()
$AliasesToExport = @()
Export-ModuleMember -Function $FunctionsToExport -Alias $AliasesToExport -Cmdlet $CmdletsToExport
