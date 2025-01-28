# Active Directory Configuration

This repo is all about Active Directory. More specifically, it is all about setting up an Active Directory environment. It covers everything from the initial configuration of hosts, installation and configuration of domain controllers, configuration of client machines, useful scripts that will help in the above configurations and probably a lot more.

My motivation behind creating this repo is that I wanted to refresh my Active Directory knowledge and also have a centralized place that I could keep all the necessary information and tools to implement an Active Directory environment for my Applied Studies class.

## Hostnames

The first thing you ideally want to do once you have installed Windows Server (or a client OS like Win11) on a host is to rename the host to something relevant to the environment that you are configuring. For example, if I'm installing a domain controller in my home, I might use something like `HOME-DC01` or if I'm installing a domain controller in my office that's located in Moncton, I might use something like `MONCTON-DC01` or `MO-OFFICE-DC01`. 

**Notes:** 
- It is best to keep your hostnames under 15 characters as this is the limit for NetBIOS. If you use a hostname with above 15 characters, this will cause your NetBIOS names to _truncate_ which can cause compatibility issues and authentication problems in some environments.
- It is pointless and redundant to include your domain name in your hostnames because the FQDN will already have your domain name in it.
- You should probably come up with a naming convention that is consistent - especially in a larger organization where many different people may be configuring many different hosts.


You can change your hostname using the [Rename-Server.ps1](./Scripts/Rename-Server.ps1) script. Or, you can just enter the following command in PowerShell:

```Powershell
Rename-Computer -NewName "MONCTON-DC01" -Restart
```

A restart is necessary to make the new hostname take effect and to avoid any complications during further configuration, I like to restart the host immediately. If you have other configurations you would like to make _before_ restarting, simply omit the `-Restart` flag.

## Network Interfaces

TODO

## Setting the Time zone

TODO

## Installing Roles & Features

The following mostly applies to Windows Servers as client operating systems like Windows 11 do not have roles. However, windows client operating systems do have many "optional features" that can be installed but in an Active Directory environment, those are usually configured using group policies or MDM policies so I won't cover those (as of now, at least).

You can install roles and features using the add Roles and Features Wizard inside of Windows Server Manager but it's important to note that if you're planning on managing the role you wish to install remotely from another server or from a Windows client that is running Remote Server Administration Tools, you can opt out of installing management tools. By default, management tools are pre-selected in the installation wizard.

Using the `Install-WindowsFeature` cmdlet is the preferred method as it is faster and can be automated through the use of scripts which is the method that I'm going to use. You can get a list of all roles and features by using the `Get-WindowsFeature` cmdlet.

### Domain Controllers

To install the necessary roles to set up a domain controller, you can use the [Install-DC.ps1](./Scripts/Install-DC.ps1) script. Or, you can enter the following command in PowerShell:

```PowerShell
Install-WindowsFeature -Name AD-Domain-Services,GPMC,DNS,RSAT-AD-Tools -IncludeManagementTools -Restart
```

This installs all of the defaults that are selected when installing Active Directory Domain Services via the Add Roles and Features Wizard with the addition of DNS. I have chosen to include the installation of DNS because in 95% of cases, you'll want your domain controllers to also be DNS servers.

However, if you want a standalone DNS server or if you want to separete DNS from your domain controllers for security purposes, simply omit DNS from the command.

**NOTES:**
- If you choose to install DNS, you will need to configure a static IP first. You can use the [Network Interfaces](TODO) section of this README for this.
- It's probably a good idea to execute the `Get-WindowsFeature` command and look through the options to customize the [Install-DC.ps1](./Scripts/Install-DC.ps1) script according to your organization's needs.
- You may wish to install roles and features on multiple hosts. You can find a detailed description of how to do that here: [Install roles and features on multiple servers](https://learn.microsoft.com/en-us/windows-server/administration/server-manager/install-or-uninstall-roles-role-services-or-features#to-install-roles-and-features-on-multiple-servers)

Once you've successfully installed the Active Directory Domain Services role, you will have to promote the server to a domain controller. In order to do that you simply modify the [Deploy-DC.ps1](./Scripts/Deploy-DC.ps1) script and then run it on your server. More specifically, enter a value for the `$domainName` and `$domainNetBiosName` variable. The `$domainNetBiosName` variable should be all caps and should be less than 15 characters as mentioned above.

Also keep in mind that the `Deploy-DC.ps1` script is configured to create a new forest. If you're trying to create a new domain in an existing forest or deploy a DC in an existing forest, you should avoid the `Deploy-DC.ps1` script and find the correct configuration here: [ADDSDeployment](https://learn.microsoft.com/en-us/powershell/module/addsdeployment/?view=windowsserver2025-ps)