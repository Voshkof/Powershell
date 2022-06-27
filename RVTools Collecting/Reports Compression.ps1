# Definizione parametri.
$currentdate = (get-date -uformat %Y-%m-%d).tostring()
$currentyearmonth = (get-date -uformat %Y-%m).tostring()
$Reports = "C:\...\Reports\$currentyearmonth"
 
# Compressione in .zip ed eliminazione dei file .xlsx.
Get-ChildItem $Reports\$currentdate* | Compress-Archive -DestinationPath "$Reports\${currentdate}_RVTools.zip" -CompressionLevel Optimal
Start-Sleep -s 5
Get-ChildItem –Path $Reports -filter "${currentdate}*.xlsx" | Remove-Item
 
# Copia su path Dev per elaborazioni.
Copy-Item "$Reports\${currentdate}_RVTools.zip" -Destination "C:\...\Dev" -Recurse
