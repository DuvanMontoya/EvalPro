param(
  [string]$EmulatorId = 'Medium_Phone_API_36.1',
  [string]$DeviceId,
  [int]$ApiPort = 3001
)

$ErrorActionPreference = 'Stop'

function Obtener-DispositivoEmuladorActivo {
  $salida = flutter devices
  foreach ($linea in $salida) {
    if ($linea -match '^\s*(emulator-\d+)\s+.+android') {
      return $Matches[1]
    }
  }
  return $null
}

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
  $DeviceId = Obtener-DispositivoEmuladorActivo
}

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
  Write-Host "Lanzando emulador: $EmulatorId ..."
  flutter emulators --launch $EmulatorId | Out-Host

  for ($intento = 1; $intento -le 60; $intento += 1) {
    Start-Sleep -Seconds 2
    $DeviceId = Obtener-DispositivoEmuladorActivo
    if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
      break
    }
  }
}

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
  throw 'No se detectó emulador Android activo.'
}

$apiUrl = "http://10.0.2.2:$ApiPort/api/v1"
$socketUrl = "http://10.0.2.2:$ApiPort"

Write-Host "Emulador: $DeviceId"
Write-Host "API_URL: $apiUrl"
Write-Host "WEBSOCKET_URL: $socketUrl"
Write-Host 'Lanzando Flutter...'

flutter run -d $DeviceId `
  --dart-define="API_URL=$apiUrl" `
  --dart-define="WEBSOCKET_URL=$socketUrl" `
  --dart-define="DIAS_RETENCION_TELEMETRIA=7" `
  --dart-define="VERSION_APP=1.0.0-dev"
