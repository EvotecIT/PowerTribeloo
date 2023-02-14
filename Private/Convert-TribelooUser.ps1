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
            Created      = $User.Meta.Created
            LastModified = $User.Meta.Updated
            Location     = $User.Meta.location
        }
    }
}