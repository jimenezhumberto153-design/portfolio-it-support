# Reporte de espacio en disco
# Muestra el espacio usado y libre de todas las unidades del equipo

Write-Host "=== REPORTE DE ESPACIO EN DISCO ===" -ForegroundColor Cyan
Write-Host "Fecha: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $usedGB = [math]::Round(($_.Used / 1GB), 2)
    $freeGB = [math]::Round(($_.Free / 1GB), 2)
    $totalGB = [math]::Round((($_.Used + $_.Free) / 1GB), 2)
    $percentUsed = if ($totalGB -gt 0) { [math]::Round(($usedGB / $totalGB) * 100, 1) } else { 0 }

    Write-Host "Unidad: $($_.Name):" -ForegroundColor Yellow
    Write-Host "  Espacio total: $totalGB GB"
    Write-Host "  Espacio usado: $usedGB GB ($percentUsed%)"
    Write-Host "  Espacio libre: $freeGB GB"

    if ($percentUsed -ge 90) {
        Write-Host "  ADVERTENCIA: Unidad casi llena" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "=== FIN DEL REPORTE ===" -ForegroundColor Cyan