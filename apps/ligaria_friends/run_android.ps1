# Instala y ejecuta Ligaria Friends en el Android conectado por USB,
# siempre con las claves de Supabase (producción) de env.json.
# Uso: .\run_android.ps1            (modo release, como producción)
#      .\run_android.ps1 -Debug     (modo debug con hot reload)
param([switch]$Debug)

Set-Location $PSScriptRoot

if (-not (Test-Path env.json)) {
    Write-Error "Falta env.json. Copia env.example.json a env.json y rellena SUPABASE_URL y SUPABASE_ANON_KEY de producción."
    exit 1
}
$cfg = Get-Content env.json -Raw | ConvertFrom-Json
if (-not $cfg.SUPABASE_URL -or $cfg.SUPABASE_URL -like '*TU-PROYECTO*' -or
    -not $cfg.SUPABASE_ANON_KEY -or $cfg.SUPABASE_ANON_KEY -like 'pega-*') {
    Write-Error "env.json todavía tiene los valores de ejemplo. Pon las claves reales de producción."
    exit 1
}

$modo = if ($Debug) { '--debug' } else { '--release' }
flutter run $modo --dart-define-from-file=env.json
