param(
  [Parameter(Mandatory = $true)]
  [string]$DeviceId
)

$adbPath = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
if (-not (Test-Path $adbPath)) {
  throw "No se encontro adb en: $adbPath"
}

Write-Host "Configurando adb reverse para $DeviceId ..."
& $adbPath -s $DeviceId reverse tcp:3001 tcp:3001 | Out-Null

Write-Host "Ejecutando Flutter con entorno ADB reverse ..."
flutter run -d $DeviceId --dart-define-from-file=Entornos/dev.adb.json
