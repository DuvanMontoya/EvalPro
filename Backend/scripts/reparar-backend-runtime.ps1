<#
 * @archivo   reparar-backend-runtime.ps1
 * @descripcion Levanta el backend desde fuente y valida acceso superadministrador usando configuracion externa.
 * @modulo    Scripts
 * @autor     EvalPro
 * @fecha     2026-03-15
#>
param(
  [string]$ApiHost = 'localhost',
  [int]$Port = 3001,
  [string]$CorreoSuperadmin,
  [string]$CorreoAdministradorObjetivo,
  [string]$ContrasenaSuperadmin
)

$ErrorActionPreference = 'Stop'

$backendDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$repoRootDir = (Resolve-Path (Join-Path $backendDir '..')).Path
$envFilePath = Join-Path $repoRootDir '.env'
$logPath = Join-Path $backendDir '.backend_dev_runtime.log'
$baseUrl = "http://$ApiHost`:$Port/api/v1"

function Get-DotenvValue {
  param([string]$FilePath, [string]$Key)

  if (-not (Test-Path $FilePath)) {
    return $null
  }

  $linea = Get-Content $FilePath | Where-Object {
    $texto = $_.Trim()
    $texto.Length -gt 0 -and
      -not $texto.StartsWith('#') -and
      $texto -match "^$([regex]::Escape($Key))\s*="
  } | Select-Object -First 1

  if (-not $linea) {
    return $null
  }

  $valor = ($linea -split '=', 2)[1].Trim()
  if (
    ($valor.StartsWith('"') -and $valor.EndsWith('"')) -or
    ($valor.StartsWith("'") -and $valor.EndsWith("'"))
  ) {
    return $valor.Substring(1, $valor.Length - 2)
  }

  return $valor
}

function Resolve-ConfigValue {
  param([string]$ExplicitValue, [string]$Key)

  if ($ExplicitValue) {
    return $ExplicitValue
  }

  $desdeProceso = [Environment]::GetEnvironmentVariable($Key)
  if ($desdeProceso) {
    return $desdeProceso.Trim()
  }

  $desdeDotenv = Get-DotenvValue -FilePath $envFilePath -Key $Key
  if ($desdeDotenv) {
    return $desdeDotenv.Trim()
  }

  return $null
}

function Resolve-RequiredConfigValue {
  param([string]$ExplicitValue, [string]$Key)

  $valor = Resolve-ConfigValue -ExplicitValue $ExplicitValue -Key $Key
  if ($valor) {
    return $valor
  }

  throw "No se encontro configuracion para $Key. Define el valor en .env o pasalo por parametro."
}

function Get-ListenerProcesses {
  param([int]$LocalPort)
  $conexiones = Get-NetTCPConnection -LocalPort $LocalPort -State Listen -ErrorAction SilentlyContinue
  if (-not $conexiones) {
    return @()
  }

  $ids = $conexiones | Select-Object -ExpandProperty OwningProcess -Unique
  $procesos = @()
  foreach ($id in $ids) {
    try {
      $proceso = Get-CimInstance Win32_Process -Filter "ProcessId = $id"
      if ($null -ne $proceso) {
        $procesos += $proceso
      }
    } catch {
      # Ignore stale process ids.
    }
  }

  return $procesos
}

function Stop-BlockingProcesses {
  param([array]$ProcessInfo, [int]$LocalPort)

  foreach ($proceso in $ProcessInfo) {
    $id = [int]$proceso.ProcessId
    $nombre = [string]$proceso.Name
    $linea = [string]$proceso.CommandLine

    $esBackendLocal = ($nombre -match 'node\.exe|cmd\.exe') -and ($linea -match 'EvalPro\\Backend')
    $esProxyDocker = $nombre -in @('com.docker.backend.exe', 'wslrelay.exe', 'Docker Desktop.exe')

    if (-not $esBackendLocal -and -not $esProxyDocker) {
      throw "Puerto $LocalPort ocupado por proceso no reconocido: $nombre (PID=$id)."
    }

    try {
      Stop-Process -Id $id -Force -ErrorAction Stop
      Write-Output "Proceso detenido: $nombre (PID=$id)"
    } catch {
      throw "No se pudo detener $nombre (PID=$id): $($_.Exception.Message)"
    }
  }
}

function Stop-LocalBackendProcesses {
  $procesos = Get-CimInstance Win32_Process |
    Where-Object {
      $_.Name -match 'node\.exe|cmd\.exe' -and
      [string]$_.CommandLine -match 'EvalPro\\Backend'
    }

  foreach ($proceso in $procesos) {
    try {
      Stop-Process -Id ([int]$proceso.ProcessId) -Force -ErrorAction Stop
      Write-Output "Proceso backend previo detenido: $($proceso.Name) (PID=$($proceso.ProcessId))"
    } catch {
      # Ignore processes already stopped between scans.
    }
  }
}

function Start-BackendFromSource {
  param([string]$BackendPath, [string]$RuntimeLogPath)

  Stop-LocalBackendProcesses
  Start-Sleep -Seconds 2

  if (Test-Path $RuntimeLogPath) {
    try {
      Remove-Item $RuntimeLogPath -Force -ErrorAction Stop
    } catch {
      $respaldo = "$RuntimeLogPath.locked.$([DateTime]::Now.ToString('yyyyMMddHHmmss'))"
      Move-Item $RuntimeLogPath $respaldo -Force -ErrorAction SilentlyContinue
    }
  }

  $errorLogPath = "$RuntimeLogPath.err"
  if (Test-Path $errorLogPath) {
    Remove-Item $errorLogPath -Force -ErrorAction SilentlyContinue
  }

  $proc = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', 'npm run start:dev' -WorkingDirectory $BackendPath -RedirectStandardOutput $RuntimeLogPath -RedirectStandardError $errorLogPath -PassThru
  Write-Output "Backend lanzado en segundo plano (PID=$($proc.Id))."

  Start-Sleep -Seconds 2
}

function Wait-Health {
  param([string]$HealthUrl)

  for ($intento = 1; $intento -le 60; $intento += 1) {
    try {
      $respuesta = Invoke-RestMethod -Uri $HealthUrl -Method Get -TimeoutSec 4
      if ($respuesta.exito -eq $true) {
        return
      }
    } catch {
      Start-Sleep -Seconds 2
    }
  }

  throw "Backend no respondió salud en tiempo esperado: $HealthUrl"
}

function Login-Superadmin {
  param([string]$ApiBase, [string]$Correo, [string]$Password)

  try {
    $cuerpo = @{
      correo = $Correo
      contrasena = $Password
    } | ConvertTo-Json
    $login = Invoke-RestMethod -Uri "$ApiBase/autenticacion/iniciar-sesion" -Method Post -ContentType 'application/json' -Body $cuerpo
    $token = $login.datos.tokenAcceso
    if ($token) {
      return @{
        correo = $Correo
        token = $token
      }
    }
  } catch {
    throw "No se pudo autenticar superadmin con el correo configurado: $Correo"
  }
  throw "No se recibio token de acceso para superadmin: $Correo"
}

function Assert-SuperadminPatchUsers {
  param([string]$ApiBase, [string]$Token, [string]$CorreoAdminObjetivo)

  $headers = @{
    Authorization = "Bearer $Token"
    'Content-Type' = 'application/json'
  }

  $usuarios = (Invoke-RestMethod -Uri "$ApiBase/usuarios" -Method Get -Headers $headers).datos
  if (-not $usuarios) {
    throw 'No hay usuarios para validar PATCH /usuarios/:id.'
  }

  $objetivo = $null
  if ($CorreoAdminObjetivo) {
    $objetivo = $usuarios |
      Where-Object { $_.rol -eq 'ADMINISTRADOR' -and $_.correo -eq $CorreoAdminObjetivo } |
      Select-Object -First 1
  }

  if ($null -eq $objetivo) {
    $objetivo = $usuarios | Where-Object { $_.rol -eq 'ADMINISTRADOR' } | Select-Object -First 1
  }

  if ($null -eq $objetivo) {
    throw 'No se encontró usuario administrador objetivo para validar PATCH.'
  }

  $cuerpo = @{ nombre = [string]$objetivo.nombre } | ConvertTo-Json
  $respuesta = Invoke-RestMethod -Uri "$ApiBase/usuarios/$($objetivo.id)" -Method Patch -Headers $headers -Body $cuerpo
  if ($respuesta.exito -ne $true) {
    throw 'PATCH /usuarios/:id no retornó éxito para superadmin.'
  }
}

Write-Output "Reparando runtime backend en $baseUrl ..."

$correoSuperadminResuelto = Resolve-RequiredConfigValue -ExplicitValue $CorreoSuperadmin -Key 'SUPERADMIN_CORREO_INICIAL'
$correoAdministradorObjetivoResuelto = Resolve-ConfigValue -ExplicitValue $CorreoAdministradorObjetivo -Key 'ADMIN_CORREO_INICIAL'
$contrasenaSuperadminResuelta = Resolve-RequiredConfigValue -ExplicitValue $ContrasenaSuperadmin -Key 'SUPERADMIN_CONTRASENA_INICIAL'

$bloqueadores = Get-ListenerProcesses -LocalPort $Port
if ($bloqueadores.Count -gt 0) {
  Stop-BlockingProcesses -ProcessInfo $bloqueadores -LocalPort $Port
  Start-Sleep -Seconds 3
}

if (-not (Test-Path (Join-Path $backendDir 'node_modules'))) {
  Write-Output 'Instalando dependencias backend (npm ci)...'
  Push-Location $backendDir
  try {
    npm ci | Out-Host
  } finally {
    Pop-Location
  }
}

Start-BackendFromSource -BackendPath $backendDir -RuntimeLogPath $logPath
Wait-Health -HealthUrl "$baseUrl/salud"

$sesionSuperadmin = Login-Superadmin -ApiBase $baseUrl -Correo $correoSuperadminResuelto -Password $contrasenaSuperadminResuelta
Assert-SuperadminPatchUsers -ApiBase $baseUrl -Token $sesionSuperadmin.token -CorreoAdminObjetivo $correoAdministradorObjetivoResuelto

Write-Output "OK: Backend activo desde fuente y PATCH /usuarios/:id funciona con superadmin ($($sesionSuperadmin.correo))."
Write-Output "Log runtime: $logPath"
