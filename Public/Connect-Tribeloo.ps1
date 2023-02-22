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