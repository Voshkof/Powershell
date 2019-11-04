First things first
Start Powershell and secure the credentials you want to use this script with: 
Get-Credential -Credential (Get-Credential) | Export-Clixml 'C:\...\Credentials.xml'
