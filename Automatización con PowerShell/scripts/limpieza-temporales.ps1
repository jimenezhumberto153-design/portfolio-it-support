# Limpieza de archivos temporales
# Elimina archivos de las carpetas temporales del usuario y del sistema

Write-Host "=== LIMPIEZA DE ARCHIVOS TEMPORALES ===" -ForegroundColor Cyan
Write-Host "Fecha: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

$rutas = @(
    "$env:TEMP",
    "C:\Windows\Temp"
)

$totalLiberado = 0

foreach ($ruta in $rutas) {
    if (Test-Path $ruta) {
        Write-Host "Analizando: $ruta" -ForegroundColor Yellow

        $archivos = Get-ChildItem -Path $ruta -Recurse -Force -ErrorAction SilentlyContinue
        $tamanoAntes = ($archivos | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum

        if ($tamanoAntes -gt 0) {
            $tamanoMB = [math]::Round(($tamanoAntes / 1MB), 2)
            Write-Host "  Tamano encontrado: $tamanoMB MB"
        }

        Get-ChildItem -Path $ruta -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

        Write-Host "  Limpieza completada" -ForegroundColor Green
        $totalLiberado += $tamanoAntes
        Write-Host ""
    }
}

$totalMB = [math]::Round(($totalLiberado / 1MB), 2)
Write-Host "Espacio total liberado aproximado: $totalMB MB" -ForegroundColor Cyan
Write-Host "=== LIMPIEZA FINALIZADA ===" -ForegroundColor Cyan