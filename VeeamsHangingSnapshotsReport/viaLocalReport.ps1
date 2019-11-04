$vCenterServer  = 'vCenterName'
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
Disconnect-VIServer * -Confirm:$false
    Write-Host '> Logged out of' $vCenterServer
