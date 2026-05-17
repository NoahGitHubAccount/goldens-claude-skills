<#
.SYNOPSIS
  健檢：列出當前專案的 Harness 鷹架狀態（已有 / 缺失 / 不一致）。

.PARAMETER ProjectPath
  目標專案根目錄（預設為當前目錄）

.EXAMPLE
  .\check-harness.ps1 -ProjectPath D:\GoldenAgent
#>
[CmdletBinding()]
param(
    [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$expected = @(
    @{ Path = 'CLAUDE.md';           Type = 'file'; Desc = 'Agent 地圖' }
    @{ Path = 'README.md';           Type = 'file'; Desc = '人類可讀入口' }
    @{ Path = 'plan.md';             Type = 'file'; Desc = '任務計畫' }
    @{ Path = 'status.md';           Type = 'file'; Desc = '跨日恢復狀態（工項 ID 指針）' }
    @{ Path = 'learnings.md';        Type = 'file'; Desc = 'Agent 經驗檔' }
    @{ Path = 'input';               Type = 'dir';  Desc = '工項管理目錄' }
    @{ Path = 'input/backlog.md';    Type = 'file'; Desc = '唯一工項狀態來源（Single Source of Truth）' }
    @{ Path = 'status-history';      Type = 'dir';  Desc = '已完成 checkpoint 歸檔' }
    @{ Path = 'docs';                Type = 'dir';  Desc = '人類向文件目錄' }
    @{ Path = 'docs/README.md';      Type = 'file'; Desc = 'docs 索引' }
    @{ Path = 'notes';               Type = 'dir';  Desc = 'pptx-generator 素材源' }
    @{ Path = 'notes/README.md';     Type = 'file'; Desc = 'notes 說明' }
)

Write-Host ""
Write-Host "=== Harness Audit：$ProjectPath ===" -ForegroundColor Cyan
Write-Host ""

$present = @()
$missing = @()

foreach ($e in $expected) {
    $full = Join-Path $ProjectPath $e.Path
    $exists = Test-Path -LiteralPath $full -PathType ($(if ($e.Type -eq 'dir') { 'Container' } else { 'Leaf' }))
    if ($exists) {
        Write-Host "[OK]      $($e.Path) — $($e.Desc)" -ForegroundColor Green
        $present += $e.Path
    } else {
        Write-Host "[MISSING] $($e.Path) — $($e.Desc)" -ForegroundColor Yellow
        $missing += $e.Path
    }
}

Write-Host ""
Write-Host "=== Skills 路徑偵測 ==="
$claudeSkills = Test-Path -LiteralPath (Join-Path $ProjectPath '.claude/skills') -PathType Container
$agentSkills = Test-Path -LiteralPath (Join-Path $ProjectPath '.agent/skills') -PathType Container

if ($claudeSkills) { Write-Host "[OK] .claude/skills/ 存在（官方路徑）" -ForegroundColor Green }
if ($agentSkills)  { Write-Host "[INFO] .agent/skills/ 存在（自訂路徑）" -ForegroundColor Cyan }
if ($claudeSkills -and $agentSkills) {
    Write-Host "[NOTE] 兩種 skills 路徑並存，需確認載入順序" -ForegroundColor Yellow
}
if (-not $claudeSkills -and -not $agentSkills) {
    Write-Host "[INFO] 無 skills 目錄（如有需要可建立 .claude/skills/）" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "=== Hooks 偵測 ==="
$hooksDir = Join-Path $ProjectPath '.claude/hooks'
$settingsLocal = Join-Path $ProjectPath '.claude/settings.local.json'
if (Test-Path -LiteralPath $hooksDir) {
    $hookCount = (Get-ChildItem -LiteralPath $hooksDir -Filter '*.ps1' -ErrorAction SilentlyContinue).Count
    Write-Host "[OK] .claude/hooks/ 存在（$hookCount 個 .ps1）" -ForegroundColor Green
} else {
    Write-Host "[INFO] .claude/hooks/ 不存在" -ForegroundColor DarkGray
}
if (Test-Path -LiteralPath $settingsLocal) {
    Write-Host "[OK] .claude/settings.local.json 存在" -ForegroundColor Green
} else {
    Write-Host "[INFO] .claude/settings.local.json 不存在" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "=== 摘要 ==="
Write-Host "已有：$($present.Count) 項"
Write-Host "缺失：$($missing.Count) 項"
if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "建議：執行 init-scaffold.ps1 補齊缺失項目。" -ForegroundColor Yellow
}
