# deploy.ps1
# Coloque na raiz do projeto Flutter (ex: E:\Projetos\Van_Pro\deploy.ps1)
# Uso: .\deploy.ps1
# Uso com mensagem custom: .\deploy.ps1 -msg "ajuste no formulario de aluno"

param(
    [string]$msg = ""
)

# ── CONFIGURACOES — edite apenas aqui ────────────────────────
$servidor  = "balcao2p@balcao2ponto0.com.br"
$destino   = "/home/balcao2p/van-pro.balcao2ponto0.com.br/"
$buildPath = "build\web\*"
# ─────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== VanPro Deploy ===" -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($msg)) {
    $msg = Read-Host "Digite o texto do commit"
}

if ([string]::IsNullOrWhiteSpace($msg)) {
    $msg = "atualizacao"
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$commitMsg = "$timestamp - $msg"

Write-Host "Mensagem final: $commitMsg" -ForegroundColor Gray

Write-Host ""
Write-Host "[1/4] Flutter build web..." -ForegroundColor Yellow
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FALHOU. Abortando." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/4] Git commit/push..." -ForegroundColor Yellow
git add -A

git diff-index --quiet HEAD --
if ($LASTEXITCODE -eq 0) {
    Write-Host "Nenhuma mudanca para commit. Pulando git commit/git push." -ForegroundColor DarkYellow
}
else {
    git commit -m $commitMsg
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Git commit falhou. Abortando." -ForegroundColor Red
        exit 1
    }

    git push
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Git push falhou. Abortando." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "[3/4] Enviando arquivos para o servidor..." -ForegroundColor Yellow
scp -r $buildPath "${servidor}:${destino}"
if ($LASTEXITCODE -ne 0) {
    Write-Host "SCP falhou. Verifique as credenciais SSH." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[4/4] Deploy concluido!" -ForegroundColor Green
Write-Host "Site: https://novo.balcao2ponto0.com.br" -ForegroundColor Cyan
Write-Host ""