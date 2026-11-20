# Instala y ejecuta Ligaria Friends en el Android conectado por USB,
# con la configuración por defecto de la app (Supabase de producción, ver lib/core/config.dart).
# Uso: .\run_android.ps1            (modo release, como producción)
#      .\run_android.ps1 -Debug     (modo debug con hot reload)
param([switch]$Debug)

Set-Location $PSScriptRoot

$modo = if ($Debug) { '--debug' } else { '--release' }
flutter run $modo
