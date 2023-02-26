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