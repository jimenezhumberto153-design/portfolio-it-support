# Reporte de informacion del sistema
# Genera un resumen rapido del equipo: SO, RAM, procesador, IP

Write-Host "=== INFORMACION DEL SISTEMA ===" -ForegroundColor Cyan
Write-Host "Fecha: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$computer = Get-CimInstance Win32_ComputerSystem

Write-Host "Equipo: $($computer.Name)" -ForegroundColor Yellow
Write-Host "Sistema Operativo: $($os.Caption)"
Write-Host "Version: $($os.Version)"
Write-Host "Arquitectura: $($os.OSArchitecture)"
Write-Host ""

Write-Host "Procesador: $($cpu.Name)" -ForegroundColor Yellow
Write-Host "Nucleos: $($cpu.NumberOfCores)"
Write-Host ""

$ramTotalGB = [math]::Round(($computer.TotalPhysicalMemory / 1GB), 2)
Write-Host "Memoria RAM instalada: $ramTotalGB GB" -ForegroundColor Yellow
Write-Host ""

Write-Host "Direcciones IP:" -ForegroundColor Yellow
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" } | ForEach-Object {
    Write-Host "  $($_.InterfaceAlias): $($_.IPAddress)"
}
Write-Host ""

Write-Host "Ultimo tiempo de arranque: $($os.LastBootUpTime)" -ForegroundColor Yellow
Write-Host ""

Write-Host "=== FIN DEL REPORTE ===" -ForegroundColor Cyan