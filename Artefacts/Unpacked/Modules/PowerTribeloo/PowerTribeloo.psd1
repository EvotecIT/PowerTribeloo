@{
    AliasesToExport      = @()
    Author               = 'Przemyslaw Klys'
    CmdletsToExport      = @()
    CompanyName          = 'Evotec'
    CompatiblePSEditions = @('Desktop', 'Core')
    Copyright            = '(c) 2011 - 2026 Przemyslaw Klys @ Evotec. All rights reserved.'
    Description          = 'PowerShell module to interact with Tribeloo.'
    FunctionsToExport    = @('Connect-Tribeloo', 'Get-TribelooUser', 'New-TribelooUser', 'Remove-TribelooUser', 'Set-TribelooUser')
    GUID                 = '213a3e47-3a56-45da-93bd-9ef647dd22e2'
    ModuleVersion        = '0.0.3'
    PowerShellVersion    = '5.1'
    PrivateData          = @{
        PSData = @{
            Tags                       = @('Windows', 'macOS', 'Linux', 'Tribeloo')
            ProjectUri                 = 'https://github.com/EvotecIT/PowerTribeloo'
            RequireLicenseAcceptance   = $false
            ExternalModuleDependencies = @()
        }
    }
    RequiredModules      = @()
    RootModule           = 'PowerTribeloo.psm1'
}