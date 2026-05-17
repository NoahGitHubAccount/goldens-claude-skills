<#
.SYNOPSIS
  在當前目錄初始化 Harness 鷹架（複製所有範本並替換變數）。

.PARAMETER ProjectPath
  目標專案根目錄（預設為當前目錄）

.PARAMETER ProjectName
  專案名稱（替換 {{PROJECT_NAME}}）

.PARAMETER ProjectTagline
  一句話定位（替換 {{PROJECT_TAGLINE}}）

.PARAMETER TechStack
  技術棧（替換 {{TECH_STACK}}）

.PARAMETER Author
  作者（替換 {{AUTHOR}}）

.PARAMETER DryRun
  只列出將要建立的檔案，不實際寫入

.PARAMETER Force
  覆寫已存在的檔案

.EXAMPLE
  .\init-scaffold.ps1 -ProjectPath D:\NewProject -ProjectName MyApp -ProjectTagline "範例專案" -TechStack "Node.js + TypeScript" -Author Golden
#>
[CmdletBinding()]
param(
    [string]$ProjectPath = (Get-Location).Path,
    [Parameter(Mandatory)][string]$ProjectName,
    [string]$ProjectTagline = "",
    [string]$TechStack = "",
    [string]$Author = "Golden",
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$skillRoot = Split-Path -Parent $PSScriptRoot
$templatesDir = Join-Path $skillRoot 'templates'
$renderScript = Join-Path $PSScriptRoot 'render-template.ps1'

$today = Get-Date -Format 'yyyy-MM-dd'
$variables = @{
    PROJECT_NAME    = $ProjectName
    PROJECT_TAGLINE = $ProjectTagline
    TECH_STACK      = $TechStack
    AUTHOR          = $Author
    TODAY           = $today
}

# 範本 → 目標檔的映射
$mapping = @(
    @{ Src = 'CLAUDE.md.tmpl';            Dst = 'CLAUDE.md' }
    @{ Src = 'plan.md.tmpl';               Dst = 'plan.md' }
    @{ Src = 'status.md.tmpl';             Dst = 'status.md' }
    @{ Src = 'learnings.md.tmpl';          Dst = 'learnings.md' }
    @{ Src = 'README.md.tmpl';             Dst = 'README.md' }
    @{ Src = 'docs/README.md.tmpl';        Dst = 'docs/README.md' }
    @{ Src = 'notes/README.md.tmpl';       Dst = 'notes/README.md' }
    @{ Src = 'backlog.md.tmpl';            Dst = 'input/backlog.md' }
)

Write-Host ""
Write-Host "=== Harness Engineer Init ===" -ForegroundColor Cyan
Write-Host "目標目錄：$ProjectPath"
Write-Host "專案名稱：$ProjectName"
if ($DryRun) { Write-Host "[DryRun 模式 — 不實際寫入]" -ForegroundColor Yellow }
Write-Host ""

# 確保目標目錄存在
if (-not (Test-Path -LiteralPath $ProjectPath)) {
    if ($DryRun) {
        Write-Host "[Dry] 將建立目錄：$ProjectPath"
    } else {
        New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
    }
}

$created = @()
$skipped = @()

foreach ($m in $mapping) {
    $src = Join-Path $templatesDir $m.Src
    $dst = Join-Path $ProjectPath $m.Dst

    if ((Test-Path -LiteralPath $dst) -and -not $Force) {
        Write-Host "略過（已存在）：$($m.Dst)" -ForegroundColor DarkGray
        $skipped += $m.Dst
        continue
    }

    if ($DryRun) {
        Write-Host "[Dry] 將建立：$($m.Dst)"
        $created += $m.Dst
    } else {
        & $renderScript -Source $src -Destination $dst -Variables $variables
        $created += $m.Dst
    }
}

# 建立空目錄（assets 等）
$emptyDirs = @('docs/adr', 'notes/assets', 'input', 'status-history')
foreach ($d in $emptyDirs) {
    $full = Join-Path $ProjectPath $d
    if (-not (Test-Path -LiteralPath $full)) {
        if ($DryRun) {
            Write-Host "[Dry] 將建立空目錄：$d"
        } else {
            New-Item -ItemType Directory -Path $full -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $full '.gitkeep') -Force | Out-Null
            Write-Host "已建立空目錄：$d"
        }
    }
}

# 寫入 .harness-version 標記裝的 skill 版本（未來 upgrade 模式會讀此檔）
$manifestPath = Join-Path $skillRoot 'manifest.json'
$skillVersion = 'unknown'
if (Test-Path -LiteralPath $manifestPath) {
    try {
        $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($manifest.version) { $skillVersion = $manifest.version }
    } catch {
        Write-Host "警告：無法解析 manifest.json，version 標記為 unknown" -ForegroundColor Yellow
    }
}

$harnessVersionContent = @"
{
  "skill": "harness-engineer",
  "version": "$skillVersion",
  "installed_at": "$today",
  "installed_files": [$(($created | ForEach-Object { "`"$_`"" }) -join ', ')]
}
"@

$harnessVersionPath = Join-Path $ProjectPath '.harness-version'
if ($DryRun) {
    Write-Host "[Dry] 將寫入：.harness-version (version=$skillVersion)"
} else {
    [System.IO.File]::WriteAllText($harnessVersionPath, $harnessVersionContent, (New-Object System.Text.UTF8Encoding $false))
    Write-Host "已寫入：.harness-version (version=$skillVersion)"
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Green
Write-Host "建立 $($created.Count) 個檔案，略過 $($skipped.Count) 個。"
if ($skipped.Count -gt 0) {
    Write-Host "如需覆寫已存在的檔案，加上 -Force 參數。" -ForegroundColor Yellow
}
