param(
  [string]$EmulatorId = 'Medium_Phone_API_36.1',
  [string]$DeviceId,
  [int]$ApiPort = 3001,
  [bool]$AutoIniciarBackend = $true,
  [int]$TimeoutEmuladorSegundos = 90,
  [switch]$SoloPreparar,
  [switch]$NoResident,
  [bool]$RequerirKioscoEstricto = $true,
  [bool]$AutoConfigurarDeviceOwner = $true
)

$ErrorActionPreference = 'Stop'

function Obtener-DispositivoEmuladorActivo {
  $rutaAdb = Obtener-RutaAdb
  $lineasAdb = & $rutaAdb devices
  foreach ($linea in $lineasAdb) {
    if ($linea -match '^\s*(emulator-\d+)\s+device\s*$') {
      return $Matches[1]
    }
  }
  return $null
}

function Obtener-RutaAdb {
  $candidatas = @(
    (Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'),
    (Join-Path $env:LOCALAPPDATA 'Android\sdk\platform-tools\adb.exe')
  )

  foreach ($ruta in $candidatas) {
    if ($ruta -and (Test-Path $ruta)) {
      return $ruta
    }
  }

  throw 'No se encontró adb.exe en Android SDK local.'
}

function Obtener-RutaEmulatorExe {
  $candidatas = @()
  if (-not [string]::IsNullOrWhiteSpace($env:ANDROID_SDK_ROOT)) {
    $candidatas += (Join-Path $env:ANDROID_SDK_ROOT 'emulator\emulator.exe')
  }
  if (-not [string]::IsNullOrWhiteSpace($env:ANDROID_HOME)) {
    $candidatas += (Join-Path $env:ANDROID_HOME 'emulator\emulator.exe')
  }
  if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
    $candidatas += (Join-Path $env:LOCALAPPDATA 'Android\Sdk\emulator\emulator.exe')
    $candidatas += (Join-Path $env:LOCALAPPDATA 'Android\sdk\emulator\emulator.exe')
  }

  foreach ($ruta in $candidatas) {
    if ($ruta -and (Test-Path $ruta)) {
      return $ruta
    }
  }

  throw 'No se encontró emulator.exe en Android SDK local.'
}

function Esperar-DispositivoEmulador {
  param(
    [int]$TimeoutSegundos,
    [string]$Etapa = 'espera emulador'
  )

  $reintentos = [Math]::Max([int]([Math]::Ceiling($TimeoutSegundos / 2.0)), 1)
  for ($intento = 1; $intento -le $reintentos; $intento += 1) {
    if ($intento -eq 1 -or ($intento % 5 -eq 0)) {
      $transcurrido = [Math]::Min($intento * 2, $TimeoutSegundos)
      Write-Host "[$Etapa] esperando dispositivo... ${transcurrido}s/${TimeoutSegundos}s"
    }
    Start-Sleep -Seconds 2
    $detectado = Obtener-DispositivoEmuladorActivo
    if (-not [string]::IsNullOrWhiteSpace($detectado)) {
      return $detectado
    }
  }

  return $null
}

function Esperar-DispositivoListo {
  param(
    [string]$RutaAdb,
    [string]$IdDispositivo,
    [int]$TimeoutSegundos = 120
  )

  $reintentos = [Math]::Max([int]([Math]::Ceiling($TimeoutSegundos / 2.0)), 1)
  for ($intento = 1; $intento -le $reintentos; $intento += 1) {
    try {
      $estado = ((& $RutaAdb -s $IdDispositivo get-state 2>$null) | Out-String).Trim()
      if ($estado -eq 'device') {
        $arranque = ((& $RutaAdb -s $IdDispositivo shell getprop sys.boot_completed 2>$null) | Out-String).Trim()
        if ($arranque -eq '1') {
          return $true
        }
      }
    } catch {
      # Puede estar en transición offline al arrancar o cerrar.
    }
    Start-Sleep -Seconds 2
  }

  return $false
}

function Detener-ProcesosEmuladorPorId {
  param([string]$IdAvd)

  $objetivo = [Regex]::Escape($IdAvd)
  $procesos = Get-CimInstance Win32_Process -Filter "Name = 'emulator.exe'" -ErrorAction SilentlyContinue |
    Where-Object { [string]$_.CommandLine -match $objetivo }

  foreach ($proceso in $procesos) {
    try {
      Stop-Process -Id ([int]$proceso.ProcessId) -Force -ErrorAction Stop
    } catch {
      # El proceso pudo cerrarse entre lecturas.
    }
  }
}

function Lanzar-EmuladorDirecto {
  param(
    [string]$RutaEmulator,
    [string]$IdAvd,
    [string[]]$ArgumentosExtra
  )

  $argumentos = @('-avd', $IdAvd) + $ArgumentosExtra
  $salida = Join-Path $env:TEMP ("evalpro_emulator_{0}_out.log" -f ([DateTime]::Now.ToString('yyyyMMddHHmmssfff')))
  $errores = Join-Path $env:TEMP ("evalpro_emulator_{0}_err.log" -f ([DateTime]::Now.ToString('yyyyMMddHHmmssfff')))
  $proceso = Start-Process -FilePath $RutaEmulator -ArgumentList $argumentos -PassThru -RedirectStandardOutput $salida -RedirectStandardError $errores

  return @{
    Proceso = $proceso
    LogOut = $salida
    LogErr = $errores
  }
}

function Testear-BackendLocal {
  param([int]$Puerto)

  try {
    $respuesta = Invoke-WebRequest -Uri "http://127.0.0.1:$Puerto/api/v1/salud" -UseBasicParsing -TimeoutSec 4
    return $respuesta.StatusCode -eq 200
  } catch {
    return $false
  }
}

function Iniciar-BackendSiHaceFalta {
  param([int]$Puerto, [bool]$AutoIniciar)

  if (Testear-BackendLocal -Puerto $Puerto) {
    Write-Host "Backend detectado en puerto $Puerto."
    return
  }

  if (-not $AutoIniciar) {
    throw "Backend no responde en puerto $Puerto."
  }

  $raizRepo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
  $backendDir = Join-Path $raizRepo 'Backend'

  if (-not (Test-Path (Join-Path $backendDir 'package.json'))) {
    throw "No se encontró Backend/package.json en $backendDir"
  }

  Write-Host "Backend no disponible. Iniciando backend en $backendDir ..."
  $comandoInicio = "set PUERTO_APP=$Puerto&& npm run start"
  $proceso = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', $comandoInicio -WorkingDirectory $backendDir -PassThru
  Write-Host "Backend lanzado (PID=$($proceso.Id)). Esperando salud..."

  for ($intento = 1; $intento -le 60; $intento += 1) {
    Start-Sleep -Seconds 2
    if (Testear-BackendLocal -Puerto $Puerto) {
      Write-Host 'Backend listo.'
      return
    }
  }

  throw "No fue posible levantar backend en puerto $Puerto."
}

function Testear-PuertoDesdeEmulador {
  param(
    [string]$RutaAdb,
    [string]$IdDispositivo,
    [string]$HostObjetivo,
    [int]$Puerto
  )

  $salida = & $RutaAdb -s $IdDispositivo shell "nc -z -w 2 $HostObjetivo $Puerto >/dev/null 2>&1; echo EXIT:`$?"
  return ($salida -join "`n") -match 'EXIT:0'
}

function Resolver-UrlsParaEmulador {
  param(
    [string]$RutaAdb,
    [string]$IdDispositivo,
    [int]$Puerto
  )

  if (Testear-PuertoDesdeEmulador -RutaAdb $RutaAdb -IdDispositivo $IdDispositivo -HostObjetivo '10.0.2.2' -Puerto $Puerto) {
    return @{
      ApiUrl = "http://10.0.2.2:$Puerto/api/v1"
      SocketUrl = "http://10.0.2.2:$Puerto"
      Modo = '10.0.2.2'
    }
  }

  Write-Host "10.0.2.2:$Puerto no respondió desde emulador. Configurando adb reverse..."
  & $RutaAdb -s $IdDispositivo reverse "tcp:$Puerto" "tcp:$Puerto" | Out-Null

  if (Testear-PuertoDesdeEmulador -RutaAdb $RutaAdb -IdDispositivo $IdDispositivo -HostObjetivo '127.0.0.1' -Puerto $Puerto) {
    return @{
      ApiUrl = "http://127.0.0.1:$Puerto/api/v1"
      SocketUrl = "http://127.0.0.1:$Puerto"
      Modo = 'adb-reverse'
    }
  }

  throw "No hay conectividad desde emulador al backend (ni por 10.0.2.2 ni por adb reverse) en puerto $Puerto."
}

function Testear-DeviceOwnerEvalPro {
  param(
    [string]$RutaAdb,
    [string]$IdDispositivo
  )

  try {
    $salida = & $RutaAdb -s $IdDispositivo shell dpm list-owners 2>$null
    $texto = ($salida | Out-String)
    if ($texto -match 'com\.evalpro\.movil/.EvalProDeviceAdminReceiver') {
      return $true
    }
    if ($texto -match 'admin=com\.evalpro\.movil/.EvalProDeviceAdminReceiver') {
      return $true
    }
    return $false
  } catch {
    return $false
  }
}

function Testear-PaqueteEvalProInstalado {
  param(
    [string]$RutaAdb,
    [string]$IdDispositivo
  )

  try {
    $salida = & $RutaAdb -s $IdDispositivo shell pm list packages com.evalpro.movil 2>$null
    return (($salida -join "`n") -match 'package:com\.evalpro\.movil')
  } catch {
    return $false
  }
}

function Configurar-DeviceOwnerEvalPro {
  param(
    [string]$RutaAdb,
    [string]$IdDispositivo
  )

  if (-not (Testear-PaqueteEvalProInstalado -RutaAdb $RutaAdb -IdDispositivo $IdDispositivo)) {
    return @{
      Exito = $false
      Mensaje = 'No se pudo configurar Device Owner: la app com.evalpro.movil aun no está instalada en el emulador.'
    }
  }

  $salida = & $RutaAdb -s $IdDispositivo shell dpm set-device-owner com.evalpro.movil/.EvalProDeviceAdminReceiver 2>&1
  $texto = ($salida | ForEach-Object { "$_" }) -join "`n"

  if ($texto -match 'Success: Device owner set') {
    return @{
      Exito = $true
      Mensaje = 'Device Owner configurado correctamente para EvalPro.'
    }
  }

  if (Testear-DeviceOwnerEvalPro -RutaAdb $RutaAdb -IdDispositivo $IdDispositivo) {
    return @{
      Exito = $true
      Mensaje = 'Device Owner ya estaba configurado para EvalPro.'
    }
  }

  return @{
    Exito = $false
    Mensaje = "No se pudo configurar Device Owner automáticamente. Salida dpm: $texto"
  }
}

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
  $DeviceId = Obtener-DispositivoEmuladorActivo
}

$lanzamiento = $null

if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
  $rutaAdbInicial = Obtener-RutaAdb
  if (-not (Esperar-DispositivoListo -RutaAdb $rutaAdbInicial -IdDispositivo $DeviceId -TimeoutSegundos 20)) {
    $DeviceId = $null
  }
}

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
  Write-Host "Lanzando emulador: $EmulatorId (via flutter) ..."
  $valorPrevioNativo = $PSNativeCommandUseErrorActionPreference
  $codigoSalidaFlutter = -1
  $huboFalloExplicitoEmulador = $false
  $PSNativeCommandUseErrorActionPreference = $false
  try {
    $salidaFlutter = & flutter emulators --launch $EmulatorId 2>&1
    $salidaFlutter | Out-Host
    $textoSalidaFlutter = ($salidaFlutter | ForEach-Object { "$_" }) -join "`n"
    $huboFalloExplicitoEmulador = $textoSalidaFlutter -match 'exited with code\s+\d+' -or $textoSalidaFlutter -match 'Address these issues and try again'
    $codigoSalidaFlutter = $LASTEXITCODE
  } finally {
    $PSNativeCommandUseErrorActionPreference = $valorPrevioNativo
  }
  if ($huboFalloExplicitoEmulador) {
    $codigoSalidaFlutter = 1
  }
  if ($codigoSalidaFlutter -ne 0) {
    Write-Host "Aviso: 'flutter emulators --launch' devolvió código $codigoSalidaFlutter. Se usará fallback inmediato."
    $DeviceId = $null
  } else {
    $DeviceId = Esperar-DispositivoEmulador -TimeoutSegundos 40 -Etapa 'arranque flutter'
  }
}

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
  $rutaEmulator = Obtener-RutaEmulatorExe
  Write-Host "Fallback: lanzando emulador directo con emulator.exe ..."
  $lanzamiento = Lanzar-EmuladorDirecto -RutaEmulator $rutaEmulator -IdAvd $EmulatorId -ArgumentosExtra @('-no-snapshot-load')
  $DeviceId = Esperar-DispositivoEmulador -TimeoutSegundos 40 -Etapa 'fallback directo'

  if ([string]::IsNullOrWhiteSpace($DeviceId)) {
    Write-Host 'Reintento de recuperación: limpiando estado del AVD y relanzando...'
    Detener-ProcesosEmuladorPorId -IdAvd $EmulatorId
    $lanzamiento = Lanzar-EmuladorDirecto -RutaEmulator $rutaEmulator -IdAvd $EmulatorId -ArgumentosExtra @('-wipe-data', '-no-snapshot', '-no-boot-anim')
    $DeviceId = Esperar-DispositivoEmulador -TimeoutSegundos $TimeoutEmuladorSegundos -Etapa 'reintento wipe-data'
  }
}

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
  Write-Host 'Diagnóstico rápido:'
  flutter emulators | Out-Host
  $rutaAdb = Obtener-RutaAdb
  & $rutaAdb devices | Out-Host
  if ($null -ne $lanzamiento -and (Test-Path $lanzamiento.LogErr)) {
    Write-Host 'Últimas líneas de error de emulator.exe:'
    Get-Content $lanzamiento.LogErr -Tail 40 | Out-Host
  }
  throw 'No se detectó emulador Android activo.'
}

Iniciar-BackendSiHaceFalta -Puerto $ApiPort -AutoIniciar $AutoIniciarBackend

$rutaAdb = Obtener-RutaAdb
if (-not (Esperar-DispositivoListo -RutaAdb $rutaAdb -IdDispositivo $DeviceId -TimeoutSegundos 90)) {
  throw "El emulador '$DeviceId' no alcanzó estado listo (boot completo)."
}

$deviceOwnerActivo = Testear-DeviceOwnerEvalPro -RutaAdb $rutaAdb -IdDispositivo $DeviceId
if (-not $deviceOwnerActivo -and $AutoConfigurarDeviceOwner) {
  Write-Host 'Intentando configurar Device Owner para bloqueo estricto...'
  $resultadoOwner = Configurar-DeviceOwnerEvalPro -RutaAdb $rutaAdb -IdDispositivo $DeviceId
  Write-Host $resultadoOwner.Mensaje
  $deviceOwnerActivo = Testear-DeviceOwnerEvalPro -RutaAdb $rutaAdb -IdDispositivo $DeviceId
}

if ($RequerirKioscoEstricto -and -not $deviceOwnerActivo) {
  if ($SoloPreparar) {
    Write-Host 'Advertencia: bloqueo estricto requerido, pero Device Owner no está activo aún.'
  } else {
    throw 'Bloqueo estricto requerido: no se detectó Device Owner para EvalPro. No se iniciará la app sin esta condición.'
  }
}

$conectividad = Resolver-UrlsParaEmulador -RutaAdb $rutaAdb -IdDispositivo $DeviceId -Puerto $ApiPort
$apiUrl = $conectividad.ApiUrl
$socketUrl = $conectividad.SocketUrl
$kioscoEstrictoDefine = if ($RequerirKioscoEstricto) { 'true' } else { 'false' }

Write-Host "Emulador: $DeviceId"
Write-Host "Modo conexión: $($conectividad.Modo)"
Write-Host "API_URL: $apiUrl"
Write-Host "WEBSOCKET_URL: $socketUrl"
Write-Host "Device Owner EvalPro: $deviceOwnerActivo"
Write-Host "KIOSCO_ESTRICTO_REQUERIDO: $kioscoEstrictoDefine"

if ($SoloPreparar) {
  Write-Host 'Preparación completada (sin flutter run por -SoloPreparar).'
  exit 0
}

Write-Host 'Lanzando Flutter...'
if ($NoResident) {
  flutter run -d $DeviceId `
    --dart-define="API_URL=$apiUrl" `
    --dart-define="WEBSOCKET_URL=$socketUrl" `
    --dart-define="KIOSCO_ESTRICTO_REQUERIDO=$kioscoEstrictoDefine" `
    --dart-define="DIAS_RETENCION_TELEMETRIA=7" `
    --dart-define="VERSION_APP=1.0.0-dev" `
    --no-resident
} else {
  flutter run -d $DeviceId `
    --dart-define="API_URL=$apiUrl" `
    --dart-define="WEBSOCKET_URL=$socketUrl" `
    --dart-define="KIOSCO_ESTRICTO_REQUERIDO=$kioscoEstrictoDefine" `
    --dart-define="DIAS_RETENCION_TELEMETRIA=7" `
    --dart-define="VERSION_APP=1.0.0-dev"
}
