# Aplica las migraciones de supabase/migrations al proyecto Supabase usando el Session pooler (IPv4).
# La contraseña se pide por consola y no se guarda en ningún archivo.

$ErrorActionPreference = 'Stop'
$ref = 'gftslrixaeggchimldmf'

Set-Location (Join-Path $PSScriptRoot '../backend/ligariaia')

Write-Host "Host del Session pooler (Supabase > Connect > Session pooler)."
Write-Host "Ejemplo: aws-0-eu-west-1.pooler.supabase.com"
$poolerHost = (Read-Host 'Host').Trim()
if (-not $poolerHost) { throw 'Falta el host del pooler.' }

$secure = Read-Host 'Contraseña de la base de datos' -AsSecureString
$plain = [System.Net.NetworkCredential]::new('', $secure).Password
$enc = [uri]::EscapeDataString($plain)

$dbUrl = "postgresql://postgres.${ref}:${enc}@${poolerHost}:5432/postgres"

try {
    Write-Host "`n== Migraciones ya aplicadas en remoto ==" -ForegroundColor Cyan
    npx --yes supabase migration list --db-url $dbUrl
    if ($LASTEXITCODE -ne 0) { throw 'Fallo al listar migraciones.' }

    Write-Host "`n== Simulacro (no cambia nada) ==" -ForegroundColor Cyan
    npx --yes supabase db push --dry-run --db-url $dbUrl
    if ($LASTEXITCODE -ne 0) { throw 'Fallo en el dry-run.' }

    $ok = Read-Host "`nEsto es PRODUCCION. Escribe SI para aplicar las migraciones"
    if ($ok -ne 'SI') { Write-Host 'Cancelado, no se ha aplicado nada.'; return }

    Write-Host "`n== Aplicando ==" -ForegroundColor Cyan
    npx --yes supabase db push --db-url $dbUrl
    if ($LASTEXITCODE -ne 0) { throw 'Fallo al aplicar las migraciones.' }

    Write-Host "`n== Estado final ==" -ForegroundColor Cyan
    npx --yes supabase migration list --db-url $dbUrl
}
finally {
    $plain = $null
    $dbUrl = $null
}
