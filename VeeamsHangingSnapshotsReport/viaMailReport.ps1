$vCenterServer  = 'vcentername'
$Credentials    = Import-Clixml 'C:\...\Credentials.xml'
Connect-VIServer -Server $vCenterServer -Credential $Credentials 
    Write-Host "`n> Logged in" $vCenterServer
$Global:DefaultVIServers | select Name, Version, Build
    Write-Host '> Retrieving snapshots...'
$Snapshots = Get-VM | Get-Snapshot 
    Write-Host '> Snapshots retrieved'
    Write-Host '> Writing report...'
$Path 	= 'C:\...\SnapshotReport.html'
$Date 	= (get-date -UFormat '%d/%m/%Y - %R')
$Header = @'
	<title>Veeam Snapshots Report for $Date</title>
	<style> 
		body {
			font-family: 'Helvetica Neue', Helvetica, Arial;
			font-size: 14px;
			line-height: 20px;
			font-weight: 400;
			color: black;
		}
		table {
			margin: 0 0 40px 0;
			width: 100%;
			box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
			display: table;
			border-collapse: collapse;
			border: 3px solid black;
		}
		th {
			font-weight: 900;
			color: #ffffff;
			background: black;
		}
		td {
			text-align: center;
			border: 1px solid #eaeaea;
		}
		tr:nth-child(even) {
			background-color: #eaeaea;
		}
	</style>
'@
$Title = '<H1> Veeam Snapshots Report for ' + $Date + '</H1>'
$Snapshots | ?{$_.Name -Like 'VEEAM BACKUP TEMPORARY SNAPSHOT'} | Select @{N='Created';E={get-date $_.Created -UFormat '%Y/%m/%d - %R'}}, VM, @{N='Size in GB';E={[math]::round($_.SizeGB, 2)}} | Sort Created | ConvertTo-Html -Head $Header -PreContent $Title | Out-File $Path
    Write-Host '> Report file saved to:' $Path
    Write-Host '> Preparing e-mail...'
$Server   = 'smtp.server.com'
$Port     = 'portnumber'
$To       = 'mail@domain.com'
$From     = 'snapshotreport@domain.com'
$Subject  = $Title
$Body = Get-Content $Path
$Message = New-Object system.net.mail.MailMessage $To, $From, $Subject, $Body
$Message.IsBodyHTML = $true 
$Attachment = new-object Net.Mail.Attachment($Path)
$Message.attachments.add($Attachment)
    Write-Host '> E-mail ready'
$Client = New-Object system.Net.Mail.SmtpClient $Server, $Port
$Client.Credentials = [system.Net.CredentialCache]::DefaultNetworkCredentials
    Write-Host '> Sending e-mail...'
$Client.Send($Message)
    Write-Host '> E-mail sent successfully'
		Remove-Item $Path
Disconnect-VIServer * -Confirm:$false
    Write-Host '> Logged out of' $vCenterServer
