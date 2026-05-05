<#
.SYNOPSIS
  將範本檔的 {{變數}} 占位符替換為實際值，輸出到目標路徑。

.PARAMETER Source
  範本檔路徑（.tmpl）

.PARAMETER Destination
  輸出路徑

.PARAMETER Variables
  Hashtable，鍵值對例：@{ PROJECT_NAME = 'foo'; TODAY = '2026-05-05' }

.EXAMPLE
  .\render-template.ps1 -Source CLAUDE.md.tmpl -Destination CLAUDE.md -Variables @{ PROJECT_NAME = 'MyApp' }
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Destination,

    [Parameter(Mandatory)]
    [hashtable]$Variables
)

if (-not (Test-Path -LiteralPath $Source)) {
    throw "範本檔不存在：$Source"
}

$content = Get-Content -LiteralPath $Source -Raw -Encoding UTF8

foreach ($key in $Variables.Keys) {
    $placeholder = '{{' + $key + '}}'
    $value = [string]$Variables[$key]
    $content = $content.Replace($placeholder, $value)
}

# 偵測未替換的占位符
$unresolved = [regex]::Matches($content, '\{\{[A-Z_]+\}\}') | ForEach-Object { $_.Value } | Sort-Object -Unique
if ($unresolved.Count -gt 0) {
    Write-Warning "未替換的占位符：$($unresolved -join ', ')"
}

$destDir = Split-Path -Parent $Destination
if ($destDir -and -not (Test-Path -LiteralPath $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

Set-Content -LiteralPath $Destination -Value $content -Encoding UTF8 -NoNewline
Write-Host "已建立：$Destination"
