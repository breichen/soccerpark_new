# Downloads the Lato files the app uses (Light 300, Regular 400, Bold 700)
# plus the OFL license into assets\google_fonts\.
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File tool\fetch_lato.ps1
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$base = 'https://raw.githubusercontent.com/google/fonts/main/ofl/lato'
$dest = Join-Path $PSScriptRoot '..\assets\google_fonts'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

foreach ($f in 'Lato-Light.ttf', 'Lato-Regular.ttf', 'Lato-Bold.ttf', 'OFL.txt') {
    Invoke-WebRequest -Uri "$base/$f" -OutFile (Join-Path $dest $f) -UseBasicParsing
    Write-Host "OK  $f"
}
Get-ChildItem $dest | Select-Object Name, Length
