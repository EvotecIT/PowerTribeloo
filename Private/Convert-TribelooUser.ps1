function Convert-TribelooUser {
    [cmdletBinding()]
    param(
        [Array] $Users
    )

    foreach ($User in $Users) {
        $WorkEmail = $null
        # $HomeEmail = $null
        # $WorkPhone = $null
        # $MobilePhone = $null
        # $HomePhone = $null

        # $Addresses = $User.'addresses'
        # foreach ($Address in $Addresses) {
        #     if ($Address.'type' -eq 'work') {
        #         $streetAddress = $Address.streetAddress
        #         $postalCode = $Address.PostalCode
        #         $city = $Address.Locality
        #         $region = $Address.region
        #         $country = $Address.country
        #     } elseif ($Address.'type' -eq 'home') {
        #         $HomeStreetAddress = $Address.streetAddress
        #         $HomePostalCode = $Address.PostalCode
        #         $HomeCity = $Address.Locality
        #         $HomeRegion = $Address.region
        #         $HomeCountry = $Address.country
        #     }
        # }
        $Emails = $User.'emails'
        foreach ($Email in $Emails) {
            if ($Email.Type -eq 'work') {
                $WorkEmail = $Email.Value
            } elseif ($Email.Type -eq 'home') {
                # $HomeEmail = $Email.Value
            }
        }

        $Adresses = $User.'adresses'
        foreach ($Adress in $Adresses) {
            if ($Adress.Type -eq 'work') {
                $WorkAddress = $Adress.Formatted
            }
        }
        # $PhoneNumbers = $User.'phoneNumbers'
        # foreach ($Phone in $PhoneNumbers) {
        #     if ($Phone.Type -eq 'work') {
        #         $WorkPhone = $Phone.Value
        #     } elseif ($Phone.Type -eq 'mobile') {
        #         $MobilePhone = $Phone.Value
        #     } elseif ($Phone.Type -eq 'home') {
        #         $HomePhone = $Phone.Value
        #     }
        # }

        # $CompanyLogoUrl = $null
        # $CompanyThumbnailUrl = $null
        # $CompanyLogos = $User.'urn:ietf:params:scim:schemas:extension:fd:2.0:User:companyLogos'
        # foreach ($C in $CompanyLogos) {
        #     if ($Type -eq 'logo') {
        #         $CompanyLogoUrl = $C.Value
        #     } elseif ($Type -eq 'thumbnail') {
        #         $CompanyThumbnailUrl = $C.Value
        #     }
        # }

        # $PhotoUrl = $null
        # $ThumbnailUrl = $null
        # $Photos = $User.'photos'
        # foreach ($C in $Photos) {
        #     if ($Type -eq 'photo') {
        #         $PhotoUrl = $C.Value
        #     } elseif ($Type -eq 'thumbnail') {
        #         $ThumbnailUrl = $C.Value
        #     }
        # }

        [PSCustomObject] @{
            Id           = $User.'id'
            #ExternalId        = $User.'externalId'
            UserName     = $User.'userName'
            GivenName    = $User.'name'.'givenName'
            FamilyName   = $User.'name'.'familyName'
            DisplayName  = $User.'displayName'
            NickName     = $User.'nickName'
            #ProfileUrl          = $User.'profileUrl'
            #Title             = $User.'title'
            #UserType            = $User.'userType'
            EmailAddress = $WorkEmail
            Address      = $WorkAddress
            #EmailAddressHome = $HomeEmail

            #PhoneNumberWork     = $WorkPhone
            #PhoneNumberMobile   = $MobilePhone
            #PhoneNumberHome     = $HomePhone

            # StreetAddress    = $streetAddress
            # City             = $City
            # Region           = $region
            # PostalCode       = $postalCode
            # Country          = $country

            # StreetAddressHome = $HomeStreetAddress
            # CityHome          = $HomeCity
            # RegionHome        = $HomeRegion
            # PostalCodeHome    = $HomePostalCode
            # CountryHome       = $HomeCountry

            # PreferredLanguage   = $User.'preferredLanguage'

            # Locale              = $User.'locale'
            # TimeZone            = $User.'timezone'
            Active       = $User.'active'
            # Groups              = $User.'groups'
            # Roles               = $User.'roles'.value
            # Organization        = $User.'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User'.'organization'
            # EmployeeNumber      = $User.'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User'.'employeeNumber'
            # CostCenter          = $User.'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User'.'costCenter'
            # Division            = $User.'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User'.'division'
            # Department          = $User.'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User'.'department'
            # Manager             = $User.'urn:ietf:params:scim:schemas:extension:enterprise:2.0User'.'manager'
            # Description         = $User.'urn:ietf:params:scim:schemas:extension:fd:2.0:User'.'description'
            # DirectoryId         = $User.'urn:ietf:params:scim:schemas:extension:fd:2.0:User'.'directoryId'
            # CompanyId           = $User.'urn:ietf:params:scim:schemas:extension:fd:2.0:User'.'companyId'

            # CompanyLogoUrl      = $CompanyLogoUrl
            # CompanyThumbnailUrl = $CompanyThumbnailUrl

            # PhotoUrl            = $PhotoUrl
            # ThumbnailUrl        = $ThumbnailUrl

            # Password            = $User.Password
            # ManagerID           = $User.'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User'.'manager'.'value'
            # ManagerDisplayName  = $User.'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User'.'manager'.'displayName'
            # Role                = $User.'roles'.value
            # Custom01            = $User.'urn:ietf:params:scim:schemas:extension:fd:2.0:User'.'custom01'
            # Custom02            = $User.'urn:ietf:params:scim:schemas:extension:fd:2.0:User'.'custom02'
            # Custom03            = $User.'urn:ietf:params:scim:schemas:extension:fd:2.0:User'.'custom03'

            #ResourceType        = $User.Meta.ResourceType
            Created      = $User.Meta.Created
            LastModified = $User.Meta.Updated
            Location     = $User.Meta.location
        }
    }
}