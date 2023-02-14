function Get-TribelooUser {
    [CmdletBinding()]
    param(
        [string] $Id,
        [Alias('UserName')][string] $SearchUserName,
        [Alias('ExternalID')][string] $SearchExternalID,
        [string] $Search,
        [ValidateSet(
            'id',
            # 'externalId',
            'userName',
            'givenName',
            'familyName',
            'displayName',
            'nickName',
            # 'profileUrl',
            # 'title',
            # 'userType',
            'emails',
            # 'phoneNumbers',
            'addresses',
            # 'preferredLanguage',
            # 'locale',
            # 'timezone',
            # 'active',
            # 'groups',
            # 'roles',
            'meta'
            # 'organization',
            # 'employeeNumber',
            # 'costCenter',
            # 'division',
            # 'department',
            # 'manager',
            # 'description',
            # 'directoryId',
            # 'companyId',
            # 'companyLogos',
            # 'custom01',
            # 'custom02',
            # 'custom03'
        )]
        [string] $SearchProperty = 'userName',
        [string] $SearchOperator = 'eq',
        [int] $MaxResults,
        [int] $StartIndex = 1,
        [int] $Count = 1000,
        [string] $Filter,
        [ValidateSet(
            'id',
            # 'externalId',
            'userName',
            'givenName',
            'familyName',
            'displayName',
            'nickName',
            # 'profileUrl',
            # 'title',
            # 'userType',
            'emails',
            # 'phoneNumbers',
            'addresses',
            # 'preferredLanguage',
            # 'locale',
            # 'timezone',
            # 'active',
            # 'groups',
            # 'roles',
            'meta'
            # 'organization',
            # 'employeeNumber',
            # 'costCenter',
            # 'division',
            # 'department',
            # 'manager',
            # 'description',
            # 'directoryId',
            # 'companyId',
            # 'companyLogos',
            # 'custom01',
            # 'custom02',
            # 'custom03'
        )]
        [string] $SortBy,
        [ValidateSet('ascending', 'descending')][string] $SortOrder,
        [switch] $Native
    )
    if (-not $Script:AuthorizationTribeloo) {
        return
    }

    $ConvertAttributes = @{
        'id'                = 'id'
        'externalId'        = 'externalId'
        'userName'          = 'userName'
        'givenName'         = 'name.givenName'
        'familyName'        = 'name.familyName'
        'displayName'       = 'di%splayName'
        'nickName'          = 'nickName'
        'profileUrl'        = 'profileUrl'
        'title'             = 'title'
        'userType'          = 'userType'
        'emails'            = 'emails'
        'phoneNumbers'      = 'phoneNumbers'
        'addresses'         = 'addresses'
        'preferredLanguage' = 'preferredLanguage'
        'locale'            = 'locale'
        'timezone'          = 'timezone'
        'active'            = 'active'
        'groups'            = 'groups'
        'roles'             = 'roles'
        'meta'              = 'meta'
        'organization'      = 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:organization'
        'employeeNumber'    = 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:employeeNumber'
        'costCenter'        = 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:costCenter'
        'division'          = 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:division'
        'department'        = 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:department'
        'manager'           = 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:manager'
        'description'       = 'urn:ietf:params:scim:schemas:extension:fd:2.0:User:description'
        'directoryId'       = 'urn:ietf:params:scim:schemas:extension:fd:2.0:User:directoryId'
        'companyId'         = 'urn:ietf:params:scim:schemas:extension:fd:2.0:User:companyId'
        'companyLogos'      = 'urn:ietf:params:scim:schemas:extension:fd:2.0:User:companyLogos'
        'custom01'          = 'urn:ietf:params:scim:schemas:extension:fd:2.0:User:custom01'
        'custom02'          = 'urn:ietf:params:scim:schemas:extension:fd:2.0:User:custom02'
        'custom03'          = 'urn:ietf:params:scim:schemas:extension:fd:2.0:User:custom03'
    }

    if ($SortBy) {
        $SortByConverted = $ConvertAttributes[$SortBy]
    }

    $QueryParameter = @{
        count      = if ($Count) { $Count } else { $null }
        startIndex = if ($StartIndex) { $StartIndex } else { $null }
        filter     = if ($SearchUserName) {
            # keep in mind regardless of used operator it will always revert back to co as per API (weird)
            "userName eq `"$SearchUserName`""
        } elseif ($SearchExternalID) {
            "externalId eq `"$SearchExternalID`""
        } elseif ($Search -and $SearchProperty) {
            "$($ConvertAttributes[$SearchProperty]) $SearchOperator `"$Search`""
        } else {
            $Filter
        }
        sortBy     = $SortByConverted
        sortOrder  = $SortOrder
    }
    Remove-EmptyValue -Hashtable $QueryParameter

    $Uri = Join-UriQuery -BaseUri $Script:AuthorizationTribeloo.BaseUri -RelativeOrAbsoluteUri 'Users' -QueryParameter $QueryParameter
    Write-Verbose -Message "Get-TribelooUser - Using query: $Uri"


    $invokeRestMethodSplat = @{
        Method      = 'Get'
        Uri         = $Uri
        Headers     = [ordered]  @{
            'Content-Type'  = 'application/json; charset=utf-8'
            'Authorization' = $Script:AuthorizationTribeloo.Authorization
            'Cache-Control' = 'no-cache'
        }
        ErrorAction = 'Stop'
        ContentType = 'application/json; charset=utf-8'
    }

    try {
        $BatchObjects = Invoke-RestMethod @invokeRestMethodSplat
    } catch {
        if ($PSBoundParameters.ErrorAction -eq 'Stop') {
            throw
        } else {
            $ErrorDetails = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($ErrorDetails.Detail -like '*already exists*directory*') {
                Write-Warning -Message "Get-TribelooUser - $($ErrorDetails.Detail) [UserName: $UserName / ID: $ID]"
                return
            } else {
                Write-Warning -Message "Get-TribelooUser - Error $($_.Exception.Message), $($ErrorDetails.Detail)"
                return
            }
        }
    }
    if ($BatchObjects.Resources) {
        Write-Verbose -Message "Get-TribelooUser - Got $($BatchObjects.Resources.Count) users (StartIndex: $StartIndex, Count: $Count). Starting to process them."

        if ($MaxResults -gt 0 -and $BatchObjects.Resources.Count -ge $MaxResults) {
            # return users if amount of users available is more than we wanted
            if ($Native) {
                $BatchObjects.Resources | Select-Object -First $MaxResults
            } else {
                Convert-TribelooUser -Users ($BatchObjects.Resources | Select-Object -First $MaxResults)
            }
            $LimitReached = $true
        } else {
            # return all users that were given in a batch
            if ($Native) {
                $BatchObjects.Resources
            } else {
                Convert-TribelooUser -Users $BatchObjects.Resources
            }
        }
    } elseif ($BatchObjects.Schemas -and $BatchObjects.id) {
        if ($Native) {
            $BatchObjects
        } else {
            Convert-TribelooUser -Users $BatchObjects
        }
    } else {
        Write-Verbose "Get-TribelooUser - No users found"
        return
    }
    if (-not $Count -and -not $StartIndex) {
        # paging is disabled, we don't do anything
    } elseif (-not $LimitReached -and $BatchObjects.TotalResults -gt $BatchObjects.StartIndex + $Count) {
        # lets get more users because there's more to get and user wanted more
        $MaxResults = $MaxResults - $BatchObjects.Resources.Count
        Write-Verbose "Get-TribelooUser - Processing more pages (StartIndex: $StartIndex, Count: $Count)."
        $getFederatedDirectoryUserSplat = @{
            Authorization = $Authorization
            StartIndex    = $($BatchObjects.StartIndex + $Count)
            Count         = $Count
            MaxResults    = $MaxResults
            Filter        = $Filter
            SortBy        = $SortBy
            SortOrder     = $SortOrder
            Attributes    = $Attributes
            DirectoryID   = $DirectoryID
            Native        = $Native
        }
        Remove-EmptyValue -Hashtable $getFederatedDirectoryUserSplat
        Get-TribelooUser @getFederatedDirectoryUserSplat
    }
}