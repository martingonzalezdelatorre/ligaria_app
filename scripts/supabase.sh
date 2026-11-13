#!/usr/bin/env bash
# Gestión del Supabase de Ligaria desde macOS/Linux (equivalente a aplicar-migraciones.ps1).
# Uso:
#   scripts/supabase.sh login      # una sola vez: inicia sesión en Supabase (abre el navegador)
#   scripts/supabase.sh enlazar    # una sola vez: vincula esta carpeta con el proyecto (pide la contraseña de la BD)
#   scripts/supabase.sh estado     # qué migraciones están aplicadas en remoto y cuáles faltan
#   scripts/supabase.sh simular    # muestra lo que se aplicaría, sin cambiar nada
#   scripts/supabase.sh subir      # aplica las migraciones pendientes (pide confirmación)
#   scripts/supabase.sh marcar 0001 0002 ...   # marca como YA aplicadas migraciones que ejecutaste a mano
set -euo pipefail
REF="gftslrixaeggchimldmf"
cd "$(dirname "$0")/.."
SB="npx --yes supabase"

case "${1:-}" in
  login)   $SB login ;;
  enlazar) $SB link --project-ref "$REF" ;;
  estado)  $SB migration list --remote ;;
  simular) $SB db push --remote --dry-run ;;
  subir)
    $SB db push --remote --dry-run
    read -r -p "Esto es PRODUCCIÓN. Escribe SI para aplicar: " ok
    [ "$ok" = "SI" ] || { echo "Cancelado, no se ha aplicado nada."; exit 0; }
    $SB db push --remote
    $SB migration list --remote ;;
  marcar)
    shift
    [ $# -gt 0 ] || { echo "Indica las versiones, p. ej.: marcar 0001 0002"; exit 1; }
    $SB migration repair --remote --status applied "$@" ;;
  *) sed -n '2,10p' "$0"; exit 1 ;;
esac
