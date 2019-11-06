$vCenterServer 	= 'vCenterName'
$Credentials    = Import-Clixml 'C:\...\Credentials.xml'
Connect-VIServer -Server $vCenterServer -Credential $Credentials 
    Write-Host "`n> Logged in" $vCenterServer
    Write-Host '> Retrieving snapshots...'
$VeeamSnapshots = 'C:\...\VeeamSnapshots.csv'
$UserSnapshots 	= 'C:\...\UserSnapshots.csv'
$Created 		= @{N='Created';E={get-date $_.Created -UFormat '%Y/%m/%d - %R'}}
Get-VM | Get-Snapshot | ?{$_.Name -Like 'VEEAM BACKUP TEMPORARY SNAPSHOT'} | Select VM, $Created | Sort Created | Export-Csv $VeeamSnapshots -NoTypeInformation 
Get-VM | Get-Snapshot | ?{$_.Name -Like '*VCD-snapshot-*'} | Select VM, $Created | Sort Created | Export-Csv $UserSnapshots -NoTypeInformation
    Write-Host '> Snapshots retrieved'
    Write-Host '> Calculating deletable snapshots...'
$Veeam 		= Import-Csv $VeeamSnapshots
$User 		= Import-Csv $UserSnapshots
$Deletable 	= 'C:\...\DeletableSnapshots.csv'
Compare-Object $Veeam $User -Property 'VM' -PassThru | ?{$_.SideIndicator -eq '<='} | Select VM, Created | Sort Created | Export-Csv $Deletable -NoTypeInformation
Remove-Item $VeeamSnapshots 
Remove-Item $UserSnapshots
    Write-Host '> Deleting Veeam Snapshots older than 7 days...'
Import-Csv $Deletable | %{
	Get-Snapshot -vm $_.VM | ?{$_.Created -lt (Get-Date).AddDays(-n)} | Remove-Snapshot -RemoveChildren -Confirm:$false
}
    Write-Host '> Snapshots deleted'
Remove-Item $Deletable
Disconnect-VIServer * -Confirm:$false 
    Write-Host '> Logged out of' $vCenterServer
