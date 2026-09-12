# TEMPLATE - Release Orchestrator
#
# Copie para .release/scripts/orchestrate.ps1 na pasta do projeto.
#
# O QUE ELE E': o mecanismo deterministico local que produz uma distribuicao do
# projeto. Recebe um Release Request JA' FECHADO (tipo, escopo, versoes e
# commits ja' decididos) e executa.
#
# PODE:  validar manifesto; validar repositorios; resolver dependencias
#        declaradas; disparar Release Actions; aguardar; coletar artefatos;
#        montar a distribuicao; copiar o Runtime Package; gerar o Release
#        Manifest; gerar o ZIP.
#
# NAO PODE: ler o Jira; decidir versao; decidir escopo de negocio; inventar
#        dependencia; escolher MAJOR/MINOR/PATCH; aprovar produto; executar
#        analise humana; substituir a skill.
#
# Ver: workflow-development-flow/references/release-lifecycle.md secao 12.
#
# Dependencias: gh CLI autenticado, git, e o modulo powershell-yaml
#   Install-Module powershell-yaml -Scope CurrentUser
# ponytail: powershell-yaml em vez de parser proprio - PS 5.1 nao tem
# ConvertFrom-Yaml nativo, e escrever um parser de YAML aqui seria pior que a
# dependencia. Se o modulo virar um problema, a saida e' migrar manifesto e
# request para JSON, nao escrever o parser.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Request,                 # caminho do release-request.yml

    [switch]$SkipDispatch,            # artefatos ja' publicados; so' coletar e montar
    [switch]$KeepStaging,             # nao apagar dist/ antes de montar
    [switch]$Validate                 # so' valida (passos 1-3) e sai; nao toca na rede
)

$ErrorActionPreference = 'Stop'

# A pasta do projeto e' a avó deste script: .release/scripts/orchestrate.ps1
$ProjectRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$ReleaseDir   = Join-Path $ProjectRoot '.release'
$ManifestPath = Join-Path $ReleaseDir 'project.yml'
$DistDir      = Join-Path $ReleaseDir 'dist'

function Fail($msg) { throw "BLOQUEIO: $msg" }
function Step($n, $msg) { Write-Host "`n[$n] $msg" -ForegroundColor Cyan }
function Ok($msg) { Write-Host "    OK  $msg" -ForegroundColor DarkGray }

# ----------------------------------------------------------------- 0. dependencias
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Fail "modulo powershell-yaml ausente. Rode: Install-Module powershell-yaml -Scope CurrentUser"
}
Import-Module powershell-yaml
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Fail "gh CLI nao encontrado." }

# ------------------------------------------------------------ 1. validar manifesto
Step 1 "Validando o manifesto do projeto"

if (-not (Test-Path $ManifestPath)) { Fail "manifesto nao encontrado em $ManifestPath" }
if (-not (Test-Path $Request))      { Fail "release request nao encontrado em $Request" }

$m   = ConvertFrom-Yaml (Get-Content $ManifestPath -Raw)
$req = (ConvertFrom-Yaml (Get-Content $Request -Raw)).release_request

foreach ($f in @('id', 'name', 'topology')) {
    if (-not $m.project.$f) { Fail "project.$f ausente no manifesto" }
}
if ($m.project.topology -notin @('monorepo', 'multi_repo')) {
    Fail "topology invalida: '$($m.project.topology)' (use monorepo ou multi_repo)"
}
if ($null -eq $m.runtime_package -or $null -eq $m.runtime_package.required) {
    Fail "runtime_package.required nao declarado. Ausencia silenciosa nao e' permitida."
}

$repoIds = @($m.repositories | ForEach-Object { $_.id })
foreach ($name in $m.components.Keys) {
    $c = $m.components[$name]
    if ($c.repository -notin $repoIds) {
        Fail "componente '$name' aponta para repositorio inexistente: '$($c.repository)'"
    }
    foreach ($dep in @($c.depends_on)) {
        if ($dep -and -not $m.components.ContainsKey($dep)) {
            Fail "componente '$name' declara depends_on '$dep', que nao existe"
        }
    }
}
foreach ($ex in @($m.full_release.exclusions)) {
    if ($ex -and -not $m.components.ContainsKey($ex)) {
        Fail "full_release.exclusions cita '$ex', que nao existe em components"
    }
}

# ciclo em depends_on
function Test-Cycle($name, $seen) {
    if ($seen -contains $name) { Fail "ciclo em depends_on: $($seen -join ' -> ') -> $name" }
    foreach ($dep in @($m.components[$name].depends_on)) {
        if ($dep) { Test-Cycle $dep ($seen + $name) }
    }
}
foreach ($name in $m.components.Keys) { Test-Cycle $name @() }
Ok "$($m.components.Count) componentes, topologia $($m.project.topology)"

# ------------------------------------------------- 2. validar o escopo efetivo
Step 2 "Conferindo o escopo efetivo do request"

function Resolve-Scope($names) {
    $out = New-Object System.Collections.Generic.HashSet[string]
    function Add-WithDeps($n) {
        if ($out.Add($n)) {
            foreach ($dep in @($m.components[$n].depends_on)) { if ($dep) { Add-WithDeps $dep } }
        }
    }
    foreach ($n in $names) { Add-WithDeps $n }
    return @($out)
}

$expected = Resolve-Scope $req.requested_scope | Sort-Object
$declared = @($req.effective_scope) | Sort-Object
if (Compare-Object $expected $declared) {
    Fail "effective_scope do request nao bate com a resolucao de dependencias.`n  esperado: $($expected -join ', ')`n  no request: $($declared -join ', ')"
}
Ok "escopo efetivo: $($declared -join ', ')"

$versioned = @()
if ($req.version_scope) { $versioned = @($req.version_scope.Keys) }
$carried = @()
if ($req.carried) { $carried = @($req.carried.Keys) }
Ok "versionados: $($versioned -join ', ')  |  carried: $($carried -join ', ')"

# -------------------------------------------- 3. validar os repositorios locais
Step 3 "Validando o estado local dos repositorios"

$reposInScope = @($declared | ForEach-Object { $m.components[$_].repository } | Select-Object -Unique)
foreach ($rid in $reposInScope) {
    $r    = $m.repositories | Where-Object { $_.id -eq $rid }
    $path = (Resolve-Path (Join-Path $ProjectRoot $r.path) -ErrorAction SilentlyContinue)
    if (-not $path) { Fail "repositorio '$rid' nao encontrado em $($r.path)" }

    Push-Location $path
    try {
        if (git status --porcelain) { Fail "repositorio '$rid' tem alteracoes nao commitadas" }

        $expectedCommit = $null
        if ($req.commits -and $req.commits[$rid]) { $expectedCommit = $req.commits[$rid] }
        if ($expectedCommit) {
            $head = (git rev-parse HEAD).Substring(0, $expectedCommit.Length)
            if ($head -ne $expectedCommit) {
                # G8: uma FINAL que promove um rc nao pode ser produzida de outro codigo.
                Fail "repositorio '$rid' esta' em $head, mas o request exige $expectedCommit"
            }
        }
        Ok "$rid  ($($r.remote))"
    }
    finally { Pop-Location }
}

if ($Validate) {
    Write-Host "`nValidacao OK - manifesto, escopo e repositorios conferem." -ForegroundColor Green
    Write-Host "Nada foi disparado (-Validate)." -ForegroundColor DarkGray
    exit 0
}

# ------------------------------------------------------------- 4. disparar Actions
$isFinal = ($req.type -eq 'FINAL')

if ($SkipDispatch) {
    Step 4 "Dispatch pulado (-SkipDispatch)"
}
else {
    Step 4 "Disparando as Release Actions"
    foreach ($rid in $reposInScope) {
        # So' dispara repositorio que tem componente recebendo versao nova.
        $comps = @($versioned | Where-Object { $m.components[$_].repository -eq $rid })
        if (-not $comps) { Ok "$rid  - nada a versionar, sem dispatch"; continue }

        $r = $m.repositories | Where-Object { $_.id -eq $rid }
        $args = @('workflow', 'run', 'release.yml', '--repo', $r.remote, '--ref', $req.ref)
        foreach ($c in $comps) {
            $args += @('-f', "$($m.components[$c].dispatch_input)=$($req.version_scope[$c])")
        }
        $typeInput = 'pre_release'
        if ($isFinal) { $typeInput = 'final' }
        $args += @('-f', "release_type=$typeInput", '-f', 'publish=true')

        Write-Host "    gh $($args -join ' ')" -ForegroundColor DarkGray
        & gh @args
        if ($LASTEXITCODE -ne 0) { Fail "dispatch falhou em '$rid'" }
        Ok "$rid  disparado"
    }

    # ------------------------------------------------------------- 5. aguardar
    Step 5 "Aguardando as execucoes"
    Start-Sleep -Seconds 10   # dar tempo do run aparecer na API
    foreach ($rid in $reposInScope) {
        $comps = @($versioned | Where-Object { $m.components[$_].repository -eq $rid })
        if (-not $comps) { continue }
        $r = $m.repositories | Where-Object { $_.id -eq $rid }

        $runId = (gh run list --repo $r.remote --workflow release.yml --limit 1 --json databaseId `
                  --jq '.[0].databaseId')
        Write-Host "    $rid  run #$runId ..." -ForegroundColor DarkGray
        gh run watch $runId --repo $r.remote --exit-status
        if ($LASTEXITCODE -ne 0) { Fail "a Release Action de '$rid' falhou (run $runId)" }
        Ok "$rid  verde"
    }
}

# --------------------------------------------------------------- 6. coletar artefatos
Step 6 "Coletando os artefatos"

if (-not $KeepStaging -and (Test-Path $DistDir)) { Remove-Item $DistDir -Recurse -Force }
$stage = Join-Path $DistDir 'staging'
New-Item -ItemType Directory -Force -Path (Join-Path $stage 'artifacts') | Out-Null

$componentInfo = @{}
foreach ($name in $declared) {
    $c        = $m.components[$name]
    $r        = $m.repositories | Where-Object { $_.id -eq $c.repository }
    $isCarried = ($carried -contains $name)

    $version = $null
    if ($isCarried) { $version = $req.carried[$name] } else { $version = $req.version_scope[$name] }
    $tag  = "$name/v$version"
    $dest = Join-Path $stage "artifacts\$name"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null

    # De onde vem o artefato depende do tipo (ver release-lifecycle.md 9.3):
    #   FINAL      -> existe GitHub Release do componente
    #   PRE_RELEASE-> nao existe Release; vem do artefato da execucao
    #   carried    -> sempre de uma versao ja' publicada
    $fromRelease = ($isFinal -or $isCarried)

    if ($fromRelease) {
        gh release download $tag --repo $r.remote --dir $dest 2>$null
        if ($LASTEXITCODE -ne 0) {
            if ($isCarried) {
                # G3: carried precisa de versao publicada e consumivel.
                Fail "componente carried '$name' nao tem release publicada em $tag. Nunca fabricar dependencia: publique $name $version antes, ou inclua-o no version_scope."
            }
            Fail "release $tag nao encontrada em $($r.remote)"
        }
    }
    else {
        gh run download --repo $r.remote --name "$name-$version" --dir $dest
        if ($LASTEXITCODE -ne 0) {
            Fail "artefato '$name-$version' nao encontrado nas execucoes de $($r.remote). Artefato de pre-release pode ter expirado."
        }
    }

    Push-Location (Resolve-Path (Join-Path $ProjectRoot $r.path))
    $commit = (git rev-parse --short HEAD)
    Pop-Location

    $files = @(Get-ChildItem $dest -File -Recurse | ForEach-Object { $_.Name })
    $componentInfo[$name] = [ordered]@{
        version  = $version
        commit   = $commit
        tag      = $tag
        artifact = ($files -join ', ')
        carried  = $isCarried
    }
    Ok "$name $version  ($($files.Count) arquivo(s))"
}

# ------------------------------------------------------------ 7. Runtime Package
Step 7 "Incluindo o Runtime Package"

$runtimeInfo = $null
if ($m.runtime_package.required) {
    $src = Join-Path $ProjectRoot $m.runtime_package.source
    if (-not (Test-Path $src)) {
        Fail "runtime_package.required = true, mas $($m.runtime_package.source) nao existe"
    }
    $entry = Join-Path $ProjectRoot $m.runtime_package.entrypoint
    if (-not (Test-Path $entry)) {
        Fail "entrypoint declarado ($($m.runtime_package.entrypoint)) nao existe"
    }
    Copy-Item $src (Join-Path $stage 'runtime') -Recurse

    # Identidade do runtime: commit quando versionado, checksum quando nao.
    $ref = $null
    if ($m.project.topology -eq 'monorepo') {
        Push-Location $ProjectRoot
        $ref = "commit:" + (git rev-parse --short HEAD)
        Pop-Location
    }
    else {
        $hash = (Get-ChildItem $src -Recurse -File | Sort-Object FullName |
                 Get-FileHash -Algorithm SHA256 | ForEach-Object { $_.Hash }) -join ''
        $sha  = [System.BitConverter]::ToString(
                    [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                        [System.Text.Encoding]::UTF8.GetBytes($hash))).Replace('-', '').ToLower()
        $ref = "sha256:$sha"
    }
    $runtimeInfo = [ordered]@{ entrypoint = $m.runtime_package.entrypoint; checksum = $ref }
    Ok "runtime incluido ($ref)"
}
else {
    Ok "runtime_package.required = false - nada a incluir"
}

# ------------------------------------------------------------- 8. Release Manifest
Step 8 "Gerando o release-manifest.yml"

$productVersion = $req.product_version
if (-not $productVersion) { $productVersion = "parcial-$(Get-Date -Format 'yyyyMMdd-HHmm')" }

$manifestOut = [ordered]@{
    project         = $m.project.id
    product_version = $productVersion
    release_type    = $req.type.ToLower()
    created_at      = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    source_request  = (Split-Path $Request -Leaf)
    components      = $componentInfo
}
if ($runtimeInfo) { $manifestOut.runtime = $runtimeInfo }

ConvertTo-Yaml $manifestOut | Set-Content (Join-Path $stage 'release-manifest.yml') -Encoding utf8
Copy-Item $Request (Join-Path $stage 'release-request.yml')
Ok "manifesto escrito"

# --------------------------------------------------------------------- 9. ZIP
Step 9 "Gerando o ZIP"

$zipName = "$($m.project.id)-$productVersion.zip"
$zipPath = Join-Path $DistDir $zipName
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zipPath

$sizeMb = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
Write-Host ""
Write-Host "Distribuicao pronta: $zipPath ($sizeMb MB)" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos passos (fora deste script):" -ForegroundColor Yellow
Write-Host "  1. Rafinha executa a distribuicao FORA da IDE e valida"
Write-Host "  2. Guardar o ZIP no Drive"
Write-Host "  3. Registrar o conteudo do release-manifest.yml no Confluence"
if (-not $isFinal) {
    Write-Host "  4. Se aprovada, promover esta pre-release para FINAL"
}
