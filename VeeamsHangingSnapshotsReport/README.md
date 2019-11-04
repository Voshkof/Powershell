# What's this for?
This script was created to get a *snapshot* (pun intended) of the state of the virtual machines located in an oldish vCenter instrastructure, backed up by the Veeam software: either snapshot removal operations didn't complete successfully or snapshot creation happened twice in succession, VMs would keep this hanging snapshots that, as time passed, would grow into painful snapshot chains.

## Before running the script
Start Powershell and secure the credentials you want to use this script with, by executing the following: 
```
> Get-Credential -Credential (Get-Credential) | Export-Clixml 'C:\...\Credentials.xml'
```
After the .xml is generated, edit the script's $Credentials variable accordingly.
