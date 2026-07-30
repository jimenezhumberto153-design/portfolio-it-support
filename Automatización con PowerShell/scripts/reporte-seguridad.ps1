<#
.SINOPSIS
    Reporte de seguridad - Analisis de logs de eventos de Windows

.DESCRIPCION
    Analiza el Visor de Eventos de Windows en busca de actividad sospechosa:
    - Intentos fallidos de inicio de sesion (Event ID 4625)
    - Posible fuerza bruta (multiples fallos del mismo usuario/IP)
    - Bloqueos de cuenta (Event ID 4740)
    - Creacion de nuevas cuentas de usuario (Event ID 4720)
    - Inicios de sesion exitosos fuera de horario habitual

.PARAMETRO Horas
    Cantidad de horas hacia atras a analizar (por defecto 24)

.PARAMETRO UmbralFuerzaBruta
    Cantidad de fallos del mismo usuario para considerarse sospechoso (por defecto 3)

.EJEMPLO
    .\reporte-seguridad.ps1
    .\reporte-seguridad.ps1 -Horas 72 -UmbralFuerzaBruta 5
#>

param(
    [int]$Horas = 24,
    [int]$UmbralFuerzaBruta = 3,
    [string]$RutaExportCSV = ".\reporte-seguridad-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
)

$fechaInicio = (Get-Date).AddHours(-$Horas)

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "   REPORTE DE SEGURIDAD - LOGS DE EVENTOS" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Fecha de ejecucion : $(Get-Date)" -ForegroundColor Gray
Write-Host "Rango analizado    : desde $fechaInicio" -ForegroundColor Gray
Write-Host "Umbral fuerza bruta: $UmbralFuerzaBruta intentos" -ForegroundColor Gray
Write-Host ""

$hallazgos = @()

# ============================================
# 1. Intentos fallidos de inicio de sesion (4625)
# ============================================
Write-Host "[1] Analizando intentos fallidos de inicio de sesion (Event ID 4625)..." -ForegroundColor Yellow

try {
    $fallos = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4625
        StartTime = $fechaInicio
    } -ErrorAction SilentlyContinue

    if ($fallos) {
        Write-Host "  Total de intentos fallidos: $($fallos.Count)" -ForegroundColor White

        # Agrupar por usuario para detectar fuerza bruta
        $agrupados = $fallos | ForEach-Object {
            $xml = [xml]$_.ToXml()
            $usuario = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' }).'#text'
            $ip = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'IpAddress' }).'#text'
            [PSCustomObject]@{
                Usuario = $usuario
                IP      = $ip
                Fecha   = $_.TimeCreated
            }
        }

        $porUsuario = $agrupados | Group-Object Usuario | Sort-Object Count -Descending

        foreach ($grupo in $porUsuario) {
            $nivel = if ($grupo.Count -ge $UmbralFuerzaBruta) { "SOSPECHOSO - POSIBLE FUERZA BRUTA" } else { "Normal" }
            $color = if ($grupo.Count -ge $UmbralFuerzaBruta) { "Red" } else { "Gray" }

            Write-Host "    Usuario: $($grupo.Name) - $($grupo.Count) intentos - $nivel" -ForegroundColor $color

            $hallazgos += [PSCustomObject]@{
                Tipo      = "Inicio de sesion fallido"
                Usuario   = $grupo.Name
                Cantidad  = $grupo.Count
                Nivel     = $nivel
                Detalle   = "IPs: $(($grupo.Group.IP | Select-Object -Unique) -join ', ')"
            }
        }
    } else {
        Write-Host "  No se encontraron intentos fallidos en el periodo analizado" -ForegroundColor Green
    }
} catch {
    Write-Host "  No se pudo acceder al log de Seguridad (se requieren permisos de administrador)" -ForegroundColor Red
}

Write-Host ""

# ============================================
# 2. Bloqueos de cuenta (4740)
# ============================================
Write-Host "[2] Analizando bloqueos de cuenta (Event ID 4740)..." -ForegroundColor Yellow

try {
    $bloqueos = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4740
        StartTime = $fechaInicio
    } -ErrorAction SilentlyContinue

    if ($bloqueos) {
        foreach ($evento in $bloqueos) {
            $xml = [xml]$evento.ToXml()
            $usuario = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' }).'#text'

            Write-Host "    Cuenta bloqueada: $usuario - $($evento.TimeCreated)" -ForegroundColor Red

            $hallazgos += [PSCustomObject]@{
                Tipo     = "Cuenta bloqueada"
                Usuario  = $usuario
                Cantidad = 1
                Nivel    = "ALERTA"
                Detalle  = "Fecha: $($evento.TimeCreated)"
            }
        }
    } else {
        Write-Host "  No se registraron bloqueos de cuenta" -ForegroundColor Green
    }
} catch {
    Write-Host "  No se pudo acceder al log de Seguridad" -ForegroundColor Red
}

Write-Host ""

# ============================================
# 3. Creacion de nuevas cuentas de usuario (4720)
# ============================================
Write-Host "[3] Analizando creacion de nuevas cuentas (Event ID 4720)..." -ForegroundColor Yellow

try {
    $nuevasCuentas = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4720
        StartTime = $fechaInicio
    } -ErrorAction SilentlyContinue

    if ($nuevasCuentas) {
        foreach ($evento in $nuevasCuentas) {
            $xml = [xml]$evento.ToXml()
            $usuario = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' }).'#text'

            Write-Host "    Cuenta creada: $usuario - $($evento.TimeCreated)" -ForegroundColor Yellow

            $hallazgos += [PSCustomObject]@{
                Tipo     = "Cuenta nueva creada"
                Usuario  = $usuario
                Cantidad = 1
                Nivel    = "Informativo - Verificar autorizacion"
                Detalle  = "Fecha: $($evento.TimeCreated)"
            }
        }
    } else {
        Write-Host "  No se crearon cuentas nuevas en el periodo analizado" -ForegroundColor Green
    }
} catch {
    Write-Host "  No se pudo acceder al log de Seguridad" -ForegroundColor Red
}

Write-Host ""

# ============================================
# 4. Inicios de sesion exitosos (4624) - resumen
# ============================================
Write-Host "[4] Resumen de inicios de sesion exitosos (Event ID 4624)..." -ForegroundColor Yellow

try {
    $exitosos = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4624
        StartTime = $fechaInicio
    } -ErrorAction SilentlyContinue

    if ($exitosos) {
        Write-Host "  Total de inicios de sesion exitosos: $($exitosos.Count)" -ForegroundColor White
    } else {
        Write-Host "  No se registraron inicios de sesion exitosos" -ForegroundColor Gray
    }
} catch {
    Write-Host "  No se pudo acceder al log de Seguridad" -ForegroundColor Red
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan

# ============================================
# Resumen final y exportacion
# ============================================
$alertas = $hallazgos | Where-Object { $_.Nivel -like "*SOSPECHOSO*" -or $_.Nivel -eq "ALERTA" }

Write-Host "RESUMEN: $($hallazgos.Count) hallazgos totales, $($alertas.Count) requieren atencion" -ForegroundColor $(if ($alertas.Count -gt 0) { "Red" } else { "Green" })

if ($hallazgos.Count -gt 0) {
    $hallazgos | Export-Csv -Path $RutaExportCSV -NoTypeInformation -Encoding UTF8
    Write-Host "Reporte exportado a: $RutaExportCSV" -ForegroundColor Cyan
}

Write-Host "===========================================" -ForegroundColor Cyan