$Server = "..."
$User = "..."
$Password = "..."
 
$currentdate = (get-date -uformat %Y-%m-%d).tostring()
$currentyearmonth = (get-date -uformat %Y-%m).tostring()
 
# Creazione cartella di logging per il mese corrente e inizio log transcript.
$Logs = "C:\...\vCenter\Logs\$currentyearmonth"
If(!(test-path $Logs)) {
	New-Item -ItemType Directory -Force -Path $Logs
}
 
$logfile = "$Logs\${currentdate}_log_${Server}.txt"
start-transcript -path $logfile
 
# Crezione cartella di destinazione per i reports del mese corrente.
$Reports = "C:\...\vCenter\Reports\$currentyearmonth"
If(!(test-path $Reports)) {
	New-Item -ItemType Directory -Force -Path $Reports
}
 
# Estrazione RVTools
$RVTools = "C:\Program Files (x86)\Robware\RVTools\RVTools.exe"
$xlsx = "${currentdate}_RVTools_${Server}.xlsx"
$Arguments = "-u $User -p $Password -s $Server -c ExportAll2xlsx -d $Reports -f $xlsx -DBColumnNames -ExcludeCustomAnnotations"
Write-Host
Write-Host "Export of $Server data started."
$Process = Start-Process -FilePath $RVTools -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
if($Process.ExitCode -eq -1) {
    Write-Host "Error on $Server : Export failed! RVTools returned exitcode -1, probably a connection error! Script is stopped."
    exit 1
}
 
Write-Host
Write-Host "Export concluded."
Write-Host
Write-Host "Compressing reports..."

# Definizione parametri.
$currentdate = (get-date -uformat %Y-%m-%d).tostring()
$currentyearmonth = (get-date -uformat %Y-%m).tostring()
$Reports = "C:\...\Reports\$currentyearmonth"
 
# Compressione in .zip ed eliminazione dei file .xlsx.
Get-ChildItem $Reports\$currentdate* | Compress-Archive -DestinationPath "$Reports\${currentdate}_RVTools.zip" -CompressionLevel Optimal
Start-Sleep -s 5
Get-ChildItem –Path $Reports -filter "${currentdate}*.xlsx" | Remove-Item
 
# Copia su path Dev per elaborazioni.
Copy-Item "$Reports\${currentdate}_RVTools.zip" -Destination "C:\...\Dev\vCenter" -Recurse


Write-Host
Write-Host "Reports compressed."
Write-Host
Stop-Transcript
