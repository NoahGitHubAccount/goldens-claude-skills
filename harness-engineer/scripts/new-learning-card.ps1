<#
.SYNOPSIS
  新增一張經驗教訓卡到 learnings/cards/。

.DESCRIPTION
  檔名格式為 YYYYMMDD-HHmm-<作者>-<短標題>.md。
  時間與作者是刻意放進檔名的：多人協作推 git 時，靠這兩段避開檔名碰撞，
  也讓人在檔案清單上直接看出是誰、什麼時候留下的經驗。

  作者取自 git config user.name；取不到時退回系統帳號名稱。

.PARAMETER Title
  卡片標題，會成為檔名的一部分。

.PARAMETER ProjectPath
  專案根目錄（預設為當前目錄）。卡片會寫到 <ProjectPath>\learnings\cards\。

.PARAMETER Author
  作者代號。省略時自動偵測。

.PARAMETER Tags
  標籤，以逗號分隔。例如 "工程管理,狀態管理"

.PARAMETER Severity
  嚴重度：high / medium / low，預設 medium。

.PARAMETER SkipIndex
  不重建 INDEX.md。批次建立多張卡時可加此參數，最後再手動重建一次。

.EXAMPLE
  .\new-learning-card.ps1 -Title "工項狀態分散多檔" -Tags "工程管理" -Severity high

.EXAMPLE
  .\new-learning-card.ps1 -Title "CSV 匯入中文亂碼" -ProjectPath D:\MyProject
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Title,
    [string]$ProjectPath = (Get-Location).Path,
    [string]$Author = '',
    [string]$Tags = '',
    [ValidateSet('high', 'medium', 'low')][string]$Severity = 'medium',
    [switch]$SkipIndex
)

$ErrorActionPreference = 'Stop'
$skillRoot = Split-Path -Parent $PSScriptRoot

# --- 作者：git 設定優先，取不到才用系統帳號 ---
function Resolve-Author {
    param([string]$Given)
    if ($Given) { return $Given }
    try {
        $name = (git -C $ProjectPath config user.name 2>$null)
        if ($LASTEXITCODE -eq 0 -and $name) { return $name.Trim() }
    } catch { }
    if ($env:USERNAME) { return $env:USERNAME }
    return 'unknown'
}

# --- 檔名安全化：移除路徑不合法字元，空白轉連字號 ---
function ConvertTo-FileSlug {
    param([string]$Text, [int]$MaxLength = 40)
    $s = $Text.Trim()
    $invalid = [System.IO.Path]::GetInvalidFileNameChars() + @('/', '\', ' ', '.')
    foreach ($ch in $invalid) { $s = $s.Replace([string]$ch, '-') }
    while ($s.Contains('--')) { $s = $s.Replace('--', '-') }
    $s = $s.Trim('-')
    if ($s.Length -gt $MaxLength) { $s = $s.Substring(0, $MaxLength).Trim('-') }
    if (-not $s) { $s = 'untitled' }
    return $s
}

$author = Resolve-Author -Given $Author
$authorSlug = ConvertTo-FileSlug -Text $author -MaxLength 20
$titleSlug = ConvertTo-FileSlug -Text $Title -MaxLength 40

$now = Get-Date
$stamp = $now.ToString('yyyyMMdd-HHmm')
$cardsDir = Join-Path $ProjectPath 'learnings\cards'

if (-not (Test-Path -LiteralPath $cardsDir)) {
    New-Item -ItemType Directory -Path $cardsDir -Force | Out-Null
    Write-Host "已建立目錄：learnings\cards" -ForegroundColor DarkGray
}

# 同一分鐘內重複建卡時，補上秒數避免覆蓋
$baseName = "$stamp-$authorSlug-$titleSlug"
$fileName = "$baseName.md"
if (Test-Path -LiteralPath (Join-Path $cardsDir $fileName)) {
    $fileName = "$stamp$($now.ToString('ss'))-$authorSlug-$titleSlug.md"
}
$target = Join-Path $cardsDir $fileName

# --- 專案名稱：優先讀 CLAUDE.md 第一個標題，否則用目錄名 ---
$projectName = Split-Path -Leaf $ProjectPath
$claudeMd = Join-Path $ProjectPath 'CLAUDE.md'
if (Test-Path -LiteralPath $claudeMd) {
    $firstHeading = (Get-Content -LiteralPath $claudeMd -Encoding UTF8 |
                     Where-Object { $_ -match '^#\s+' } | Select-Object -First 1)
    if ($firstHeading) { $projectName = ($firstHeading -replace '^#\s+', '').Trim() }
}

$templatePath = Join-Path $skillRoot 'templates\learnings\card.md.tmpl'
if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "找不到卡片範本：$templatePath"
}

$content = Get-Content -LiteralPath $templatePath -Raw -Encoding UTF8
$replacements = @{
    '{{CARD_ID}}'       = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    '{{CARD_DATETIME}}' = $now.ToString('yyyy-MM-dd HH:mm')
    '{{CARD_AUTHOR}}'   = $author
    '{{CARD_TITLE}}'    = $Title
    '{{CARD_TAGS}}'     = ($Tags -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) -join ', '
    '{{CARD_SEVERITY}}' = $Severity
    '{{PROJECT_NAME}}'  = $projectName
}
foreach ($k in $replacements.Keys) { $content = $content.Replace($k, $replacements[$k]) }

[System.IO.File]::WriteAllText($target, $content, (New-Object System.Text.UTF8Encoding $false))

Write-Host ""
Write-Host "已建立經驗卡" -ForegroundColor Green
Write-Host "  檔案：learnings\cards\$fileName"
Write-Host "  作者：$author"
Write-Host "  嚴重度：$Severity"
Write-Host ""
Write-Host "請填寫「規避規則」段落 —— 那是整張卡最重要的部分。" -ForegroundColor Yellow

if (-not $SkipIndex) {
    $indexScript = Join-Path $PSScriptRoot 'build-learning-index.ps1'
    if (Test-Path -LiteralPath $indexScript) {
        & $indexScript -ProjectPath $ProjectPath -Quiet
        Write-Host "已更新 learnings\INDEX.md" -ForegroundColor DarkGray
    }
}
