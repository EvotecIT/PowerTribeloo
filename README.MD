# PowerTribeloo - PowerShell Module

<p align="center">
  <a href="https://dev.azure.com/evotecpl/PowerTribeloo/_build/results?buildId=latest"><img src="https://img.shields.io/azure-devops/build/evotecpl/39c74615-8f34-4af0-a835-68dc33f9214f/14?label=Azure%20Pipelines&style=flat-square"></a>
  <a href="https://www.powershellgallery.com/packages/PowerTribeloo"><img src="https://img.shields.io/powershellgallery/v/PowerTribeloo.svg?style=flat-square"></a>
  <a href="https://www.powershellgallery.com/packages/PowerTribeloo"><img src="https://img.shields.io/powershellgallery/vpre/PowerTribeloo.svg?label=powershell%20gallery%20preview&colorB=yellow&style=flat-square"></a>
  <a href="https://github.com/EvotecIT/PowerTribeloo"><img src="https://img.shields.io/github/license/EvotecIT/PowerTribeloo.svg?style=flat-square"></a>
</p>

<p align="center">
  <a href="https://www.powershellgallery.com/packages/PowerTribeloo"><img src="https://img.shields.io/powershellgallery/p/PowerTribeloo.svg?style=flat-square"></a>
  <a href="https://github.com/EvotecIT/PowerTribeloo"><img src="https://img.shields.io/github/languages/top/evotecit/PowerTribeloo.svg?style=flat-square"></a>
  <a href="https://github.com/EvotecIT/PowerTribeloo"><img src="https://img.shields.io/github/languages/code-size/evotecit/PowerTribeloo.svg?style=flat-square"></a>
  <a href="https://www.powershellgallery.com/packages/PowerTribeloo"><img src="https://img.shields.io/powershellgallery/dt/PowerTribeloo.svg?style=flat-square"></a>
</p>

<p align="center">
  <a href="https://twitter.com/PrzemyslawKlys"><img src="https://img.shields.io/twitter/follow/PrzemyslawKlys.svg?label=Twitter%20%40PrzemyslawKlys&style=flat-square&logo=twitter"></a>
  <a href="https://evotec.xyz/hub"><img src="https://img.shields.io/badge/Blog-evotec.xyz-2A6496.svg?style=flat-square"></a>
  <a href="https://www.linkedin.com/in/pklys"><img src="https://img.shields.io/badge/LinkedIn-pklys-0077B5.svg?logo=LinkedIn&style=flat-square"></a>
</p>

`PowerTribeloo` is a PowerShell module to interact with service [Tribeloo](https://www.tribeloo.com/).
This module uses API exposed by **Tribeloo** and allows to Add, Get, Set and Remove users from **Tribeloo**.
This is unofiicial module and is not supported by **Tribeloo**, but it does work just fine.

### Installation

```powershell
Install-Module -Name PowerTribeloo -Force -Verbose
```

### Using the module

Connect to Tribeloo using token and URL. You can get token from your company's **Tribeloo** instance.

```powershell

$connectTribelooUserSplat = @{
    Token = 'eyJ0eXAiOiJKV1QiLCJhbGci'
    Uri   = 'https://<url of your company>.tribeloo.com/api/1.0/scim'
}

Connect-Tribeloo @connectTribelooUserSplat
```

#### Get users

Get all users

```powershell
Get-TribelooUser -Verbose | Format-Table *
```

#### Create users

```powershell
for ($i = 0; $i -lt 200; $i++) {
    New-TribelooUser -Verbose -UserName "ziomek$i@bomon.pl" -DisplayName "Test"
}
```

#### Update users

```powershell
Set-TribelooUser -Id '11105df0-31cf-11ed-ada4-2bbc677ce86d' -DisplayName 'New name' -FamilyName 'New namme' -EmailAddress 'test@evo.pl'
```

#### Remove users

```powershell
Remove-TribelooUser -Id '11105df0-31cf-11ed-ada4-2bbc677ce86d' -Verbose
```

