function New-TribelooUser {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory)][string] $UserName,
        [string] $FamilyName,
        [string] $GivenName,
        [parameter(Mandatory)][string] $DisplayName,
        [string] $NickName,
        [string] $EmailAddress,
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