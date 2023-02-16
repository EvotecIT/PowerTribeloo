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
                            if ($Key -eq 'ManagerUserName') {
                                if ($ManagerID) {
                                    $Value = $ManagerID
                                } else {
                                    $Value = $null
                                }
                            } elseif ($Key -eq 'ManagerDisplayName') {
                                $Value = @{
                                    displayName = $ManagerDisplayName
                                }
                            } else {
                                $Value = $PSBoundParameters[$Key]
                            }
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