param(
  [switch]$ReinstalarFrontend
)

$ErrorActionPreference = 'Stop'

$raiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$backendDir = Join-Path $raiz 'Backend'
$frontendDir = Join-Path $raiz 'Frontend'
$frontendLogPath = Join-Path $frontendDir '.frontend_dev_runtime.log'
$frontendErrPath = "$frontendLogPath.err"

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

function Stop-FrontendPortProcesses {
  param([array]$ProcessInfo, [int]$LocalPort)

  foreach ($proceso in $ProcessInfo) {
    $id = [int]$proceso.ProcessId
    $nombre = [string]$proceso.Name
    $linea = [string]$proceso.CommandLine
    $esFrontendLocal = ($nombre -match 'node\.exe|cmd\.exe') -and ($linea -match 'EvalPro\\Frontend')

    if (-not $esFrontendLocal) {
      throw "Puerto $LocalPort ocupado por proceso no reconocido: $nombre (PID=$id)."
    }

    Stop-Process -Id $id -Force -ErrorAction Stop
    Write-Output "Proceso frontend detenido: $nombre (PID=$id)"
  }
}

function Stop-LocalFrontendProcesses {
  $procesos = Get-CimInstance Win32_Process |
    Where-Object {
      $_.Name -match 'node\.exe|cmd\.exe' -and
      [string]$_.CommandLine -match 'EvalPro\\Frontend'
    }

  foreach ($proceso in $procesos) {
    try {
      Stop-Process -Id ([int]$proceso.ProcessId) -Force -ErrorAction Stop
      Write-Output "Proceso frontend previo detenido: $($proceso.Name) (PID=$($proceso.ProcessId))"
    } catch {
      # Ignore processes already stopped between scans.
    }
  }
}

function Wait-Health {
  param([string]$HealthUrl)

  for ($intento = 1; $intento -le 40; $intento += 1) {
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

function Wait-Frontend {
  param([string]$FrontendUrl)

  for ($intento = 1; $intento -le 60; $intento += 1) {
    try {
      $respuesta = Invoke-WebRequest -Uri $FrontendUrl -Method Get -TimeoutSec 4
      if ($respuesta.StatusCode -ge 200 -and $respuesta.StatusCode -lt 500) {
        return
      }
    } catch {
      Start-Sleep -Seconds 2
    }
  }

  throw "Frontend no respondió en tiempo esperado: $FrontendUrl"
}

function Start-FrontendDev {
  param([string]$FrontendPath, [string]$RuntimeLogPath, [bool]$ForceInstall)

  Stop-LocalFrontendProcesses
  Start-Sleep -Seconds 1

  if ($ForceInstall -or -not (Test-Path (Join-Path $FrontendPath 'node_modules'))) {
    Push-Location $FrontendPath
    try {
      npm ci | Out-Host
    } finally {
      Pop-Location
    }
  }

  if (Test-Path $RuntimeLogPath) {
    Remove-Item $RuntimeLogPath -Force -ErrorAction SilentlyContinue
  }
  if (Test-Path $frontendErrPath) {
    Remove-Item $frontendErrPath -Force -ErrorAction SilentlyContinue
  }

  $proc = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', 'npm run dev' -WorkingDirectory $FrontendPath -RedirectStandardOutput $RuntimeLogPath -RedirectStandardError $frontendErrPath -PassThru
  Write-Output "Frontend lanzado en segundo plano (PID=$($proc.Id))."
}

Write-Output 'Preparando backend y frontend locales...'

$backendScript = Join-Path $backendDir 'scripts\reparar-backend-runtime.ps1'
if (-not (Test-Path $backendScript)) {
  throw "No se encontró script backend requerido: $backendScript"
}

Write-Output 'Reparando runtime backend...'
powershell -ExecutionPolicy Bypass -File $backendScript | Out-Host
Wait-Health -HealthUrl 'http://127.0.0.1:3001/api/v1/salud'

$bloqueadoresFrontend = Get-ListenerProcesses -LocalPort 3000
if ($bloqueadoresFrontend.Count -gt 0) {
  Stop-FrontendPortProcesses -ProcessInfo $bloqueadoresFrontend -LocalPort 3000
  Start-Sleep -Seconds 2
}

Write-Output 'Lanzando frontend en modo desarrollo...'
Start-FrontendDev -FrontendPath $frontendDir -RuntimeLogPath $frontendLogPath -ForceInstall $ReinstalarFrontend.IsPresent
Wait-Frontend -FrontendUrl 'http://127.0.0.1:3000'

Write-Output ''
Write-Output 'OK: entorno local levantado.'
Write-Output 'Backend salud:  http://localhost:3001/api/v1/salud'
Write-Output 'Frontend web:   http://localhost:3000'
Write-Output "Frontend log:   $frontendLogPath"
Write-Output ''
Write-Output 'Comando móvil (emulador Android):'
Write-Output '  cd Movil'
Write-Output '  .\scripts\run_android_emulador.ps1'
Write-Output ''
Write-Output 'Comando móvil (dispositivo físico con IP LAN automática):'
Write-Output '  cd Movil'
Write-Output '  .\scripts\run_android_fisico.ps1 -DeviceId <id-dispositivo>'
