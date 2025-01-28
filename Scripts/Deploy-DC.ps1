#
# Windows PowerShell script for AD DS Deployment
#

$domainName = "DomainName.Here"
$domainNetBiosName = "NETBIOSNAMEHERE" # All caps, 15 characters or less

Import-Module ADDSDeployment
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName "$domainName" `
    -DomainNetbiosName "$domainNetBiosName" `
    -ForestMode "WinThreshold" `
    -InstallDns:$false `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true
