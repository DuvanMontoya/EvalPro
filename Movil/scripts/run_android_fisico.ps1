param(
  [Parameter(Mandatory = $false)]
  [string]$DeviceId,

  [Parameter(Mandatory = $false)]
  [string]$ApiHost,

  [Parameter(Mandatory = $false)]
  [int]$ApiPort = 3001,

  [Parameter(Mandatory = $false)]
  [switch]$UseAdbReverse
)

function Resolve-DeviceId {
  param([string]$CurrentDeviceId)

  if (-not [string]::IsNullOrWhiteSpace($CurrentDeviceId)) {
    return $CurrentDeviceId
  }

  $adbPath = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
  if (-not (Test-Path $adbPath)) {
    throw "No se encontro adb en: $adbPath"
  }

  $lineas = & $adbPath devices
  $dispositivos = @()
  foreach ($linea in $lineas) {
    if ($linea -match "^\s*([^\s]+)\s+device\s*$" -and $linea -notmatch "^List of devices attached") {
      $dispositivos += $Matches[1]
    }
  }

  if ($dispositivos.Count -eq 0) {
    throw "No hay dispositivos Android conectados (estado 'device')."
  }

  return $dispositivos[0]
}

function Resolve-HostIp {
  $candidatas = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
      $_.IPAddress -notlike "127.*" -and
      $_.IPAddress -notlike "169.254.*" -and
      $_.IPAddress -notlike "172.17.*" -and
      $_.IPAddress -notlike "172.18.*"
    } |
    Select-Object -ExpandProperty IPAddress -Unique

  foreach ($ip in $candidatas) {
    if ($ip -like "192.168.*" -or $ip -like "10.*" -or $ip -like "172.1[6-9].*" -or $ip -like "172.2[0-9].*" -or $ip -like "172.3[0-1].*") {
      return $ip
    }
  }

  if ($candidatas.Count -gt 0) {
    return $candidatas[0]
  }

  throw "No se pudo resolver IP LAN automaticamente. Usa -ApiHost <IP>."
}

$DeviceId = Resolve-DeviceId -CurrentDeviceId $DeviceId

if ($UseAdbReverse) {
  $adbPath = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
  if (-not (Test-Path $adbPath)) {
    throw "No se encontro adb en: $adbPath"
  }
  Write-Host "Configurando adb reverse para $DeviceId en puerto $ApiPort ..."
  & $adbPath -s $DeviceId reverse "tcp:$ApiPort" "tcp:$ApiPort" | Out-Null
  $ApiHost = "127.0.0.1"
} elseif ([string]::IsNullOrWhiteSpace($ApiHost)) {
  $ApiHost = Resolve-HostIp
}

$apiUrl = "http://$ApiHost`:$ApiPort/api/v1"
$socketUrl = "http://$ApiHost`:$ApiPort"

Write-Host "Dispositivo: $DeviceId"
Write-Host "API_URL: $apiUrl"
Write-Host "WEBSOCKET_URL: $socketUrl"
Write-Host "Lanzando Flutter..."

flutter run -d $DeviceId `
  --dart-define="API_URL=$apiUrl" `
  --dart-define="WEBSOCKET_URL=$socketUrl" `
  --dart-define="DIAS_RETENCION_TELEMETRIA=7" `
  --dart-define="VERSION_APP=1.0.0-dev"
