param(
  [Parameter(Mandatory = $false)]
  [string]$DeviceId
)

$adbPath = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
if (-not (Test-Path $adbPath)) {
  throw "No se encontro adb en: $adbPath"
}

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
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
  $DeviceId = $dispositivos[0]
}

Write-Host "Configurando adb reverse para $DeviceId ..."
& $adbPath -s $DeviceId reverse tcp:3001 tcp:3001 | Out-Null

Write-Host "Ejecutando Flutter con entorno ADB reverse ..."
flutter run -d $DeviceId --dart-define-from-file=Entornos/dev.adb.json
