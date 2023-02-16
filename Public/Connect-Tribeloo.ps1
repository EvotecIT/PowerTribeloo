function Connect-Tribeloo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Token,
        [Parameter(Mandatory)][alias('Url', 'BaseUri')][string] $Uri
    )

    $Script:AuthorizationTribeloo = @{
        'Authorization' = "Bearer $Token"
        'Content-Type'  = 'application/json; charset=utf-8'
        'BaseUri'       = $Uri
    }
}