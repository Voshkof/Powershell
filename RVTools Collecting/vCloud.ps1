Import-Module VMware.VimAutomation.Core
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false  -confirm:$false
Set-PowerCLIConfiguration -InvalidCertificateAction ignore -confirm:$false
 
$USER = "..."
$PASS = "..."
 
$currentdate = (get-date -uformat %Y-%m-%d).tostring()
$currentyearmonth = (get-date -uformat %Y-%m).tostring()
 
# Creazione cartella di logging per il mese corrente e inizio log transcript.
$Logs = "C:\...\vCloud\Logs\$currentyearmonth"
If(!(test-path $Logs)) {
	New-Item -ItemType Directory -Force -Path $Logs
}
 
$logfile = "$Logs\${currentdate}_log_vCloud.txt"
start-transcript -path $logfile
 
# Crezione cartella di destinazione per i reports del mese corrente.
$Reports = "C:\...\vCloud\Reports\$currentyearmonth"
If(!(test-path $Reports)) {
	New-Item -ItemType Directory -Force -Path $Reports
}
 
# Connessione alle celle e definizione dati da estrarre.
$CELLS= @("x", "y", "z")
$ORG_Params= @("Name", "FullName", "Description", "Enabled")
$OrgVDC_Params= @("Name", "Description", "ThinProvisioned", "VMCpuCoreMHz", "CpuGuaranteedPercent", "MemoryGuaranteedPercent", "NetworkMaxCount", "NetworkPool", "AllocationModel", "Enabled", "ProviderVdc", "CpuUsedGhz", "CpuLimitGhz", "MemoryUsedGB", "MemoryLimitGB", "MemoryAllocationGB", "Href")
 
Write-Host "Parameters set, export started..."
 
foreach($CELL in $CELLS) {
	$Outfile = "${Reports}\${currentdate}_Report_${CELL}.xlsx"
	$vCloud = Connect-CIServer -Server $CELL -User $USER -Password $PASS
 
	$Output = @()
	foreach($ORG in Get-Org) {
		$ORG_csv = Select-Object -InputObject $ORG -Property $ORG_Params
 
		foreach($OrgVDC in Get-OrgVdc -Org $ORG) {
			$OrgVDC_csv = Select-Object -InputObject $OrgVDC -Property $OrgVDC_Params
			$CSV = New-Object PSObject
 
			foreach ($param in $ORG_Params) { 
				$CSV | Add-Member NoteProperty "ORG ${param}" $ORG_csv.$param 
			}
			foreach ($param in $OrgVDC_Params) { 
				$CSV | Add-Member NoteProperty "VDC ${param}" $OrgVDC_csv.$param 
			}
 
			$Output += $CSV
		}
	}
	$Output | Export-Excel $Outfile
	Disconnect-CIServer $Cell -Confirm:$false
}
 
Write-Host
Write-Host "Export concluded."
Write-Host
Write-Host "Compressing reports..."
 
# Compressione in .zip ed eliminazione dei file .xlsx.
Get-ChildItem $Reports\$currentdate* | Compress-Archive -DestinationPath "$Reports\${currentdate}_vCloud_Reports.zip" -CompressionLevel Optimal
Start-Sleep -s 5
Get-ChildItem -Path $Reports -filter "${currentdate}*.xlsx" | Remove-Item
 
# Copia su path Dev per successive elaborazioni.
Copy-Item "$Reports\${currentdate}_vCloud_Reports.zip" -Destination "C:\...\vCloud" -Recurse
 
Write-Host
Write-Host "Reports compressed."
Write-Host
Stop-Transcript
