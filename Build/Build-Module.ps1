param(
    [ValidateSet('Manifest', 'Build')][string] $RunMode = 'Build',
    [bool] $SignModule = $false,
    [string] $PackageRoot = (Join-Path $PSScriptRoot '../Artefacts')
)
Import-Module PSPublishModule -MinimumVersion 3.0.153 -Force
Invoke-ModuleBuild -ModuleName 'PowerTribeloo' -RunMode $RunMode -SkipInstall -NoInteractive {
    New-ConfigurationManifest -ModuleVersion '0.0.3' -CompatiblePSEditions Desktop, Core `
        -Guid '213a3e47-3a56-45da-93bd-9ef647dd22e2' -Author 'Przemyslaw Klys' -CompanyName Evotec `
        -Copyright "(c) 2011 - $((Get-Date).Year) Przemyslaw Klys @ Evotec. All rights reserved." `
        -Description 'PowerShell module to interact with Tribeloo.' -PowerShellVersion '5.1' `
        -Tags Windows, macOS, Linux, Tribeloo -ProjectUri 'https://github.com/EvotecIT/PowerTribeloo'
    New-ConfigurationModule -Type RequiredModule -Name PSSharedGoods -Guid Auto -RequiredVersion '0.0.313' -VersionSource PSGallery
    New-ConfigurationModule -Type ApprovedModule -Name PSSharedGoods, PSWriteColor
    New-ConfigurationModuleSkip -IgnoreFunctionName IsOfType, IsNumeric -IgnoreModuleName Microsoft.PowerShell.Utility, Microsoft.PowerShell.Management, Microsoft.PowerShell.Security
    New-ConfigurationImportModule -ImportSelf -ImportRequiredModules
    New-ConfigurationBuild -Enable -SignModule:$SignModule -MergeModuleOnBuild -MergeFunctionsFromApprovedModules
    New-ConfigurationArtefact -Type Unpacked -Enable -Path (Join-Path $PackageRoot 'Unpacked') -ModulesPath Modules -RequiredModulesPath Modules -AddRequiredModules
    New-ConfigurationArtefact -Type Packed -Enable -Path (Join-Path $PackageRoot 'Packed') -ArtefactName '<ModuleName>.v<ModuleVersion>.zip'
}
