# TEMPLATE - entrypoint do Runtime Package
#
# Copie para .release/runtime/start.ps1 (ou o nome que voce declarar em
# runtime_package.entrypoint) e adapte. Este arquivo e' esqueleto: a estrategia
# de execucao e' decisao do projeto, nao do workflow.
#
# Este script roda a partir do ZIP JA' DESCOMPACTADO, com esta estrutura:
#
#   <pasta>/
#   ├── artifacts/<componente>/...
#   ├── runtime/start.ps1        <- voce esta aqui
#   ├── release-manifest.yml
#   └── release-request.yml

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot     # raiz da distribuicao descompactada

Write-Host ""
Write-Host "== Iniciando a distribuicao ==" -ForegroundColor Cyan

# ------------------------------------------------------------------ manifesto
# Mostrar o que esta' sendo executado evita a duvida "que versao e' essa?".
$manifest = Join-Path $root 'release-manifest.yml'
if (Test-Path $manifest) {
    Write-Host ""
    Select-String -Path $manifest -Pattern '^(project|product_version|release_type):' |
        ForEach-Object { Write-Host "  $($_.Line)" }
    Write-Host ""
}

# ------------------------------------------------------- pre-requisitos
# [ADAPTAR] falhe CEDO e com mensagem clara. Quem vai rodar isso pode nao ser
# quem empacotou.
function Require-Command($name, $hint) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Pre-requisito ausente: '$name' nao encontrado. $hint"
    }
}

# Require-Command 'docker' 'Instale o Docker Desktop e deixe-o rodando.'
# Require-Command 'java'   'Instale o JDK 17 ou superior.'

# ------------------------------------------------------------------ execucao
# [ADAPTAR] a estrategia do projeto. Exemplos possiveis, escolha UM:
#
#   docker compose -f (Join-Path $PSScriptRoot 'docker-compose.yml') up -d
#
#   Start-Process java -ArgumentList '-jar', (Join-Path $root 'artifacts/api/app.jar')
#
#   Expand-Archive (Join-Path $root 'artifacts/web/web.zip') -DestinationPath "$env:TEMP\web"
#   Start-Process powershell -ArgumentList '-c', "cd $env:TEMP\web; python -m http.server 8080"
#
#   adb install (Join-Path $root 'artifacts/mobile/app.apk')

throw "start.ps1 ainda nao foi implementado para este projeto. Ver o README desta pasta."

# --------------------------------------------------------------- onde acessar
# [ADAPTAR] a ultima coisa que a pessoa le precisa ser onde o sistema esta'.
#
# Write-Host ""
# Write-Host "Pronto." -ForegroundColor Green
# Write-Host "  Web : http://localhost:8080"
# Write-Host "  API : http://localhost:8081"
# Write-Host ""
# Write-Host "Para parar:  docker compose down"
