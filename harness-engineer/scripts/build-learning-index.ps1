<#
.SYNOPSIS
  掃描 learnings/cards/ 產生 learnings/INDEX.md。

.DESCRIPTION
  INDEX.md 完全由卡片推導而來，因此它是可拋棄的：
  多人協作時若 git 在 INDEX.md 上發生衝突，不要手動合併，直接重跑本腳本覆蓋即可。

.PARAMETER ProjectPath
  專案根目錄（預設為當前目錄）。

.PARAMETER Quiet
  只在有問題時輸出訊息。

.EXAMPLE
  .\build-learning-index.ps1

.EXAMPLE
  .\build-learning-index.ps1 -ProjectPath D:\MyProject
#>
[CmdletBinding()]
param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

$learningsDir = Join-Path $ProjectPath 'learnings'
$cardsDir = Join-Path $learningsDir 'cards'
$indexPath = Join-Path $learningsDir 'INDEX.md'

if (-not (Test-Path -LiteralPath $cardsDir)) {
    Write-Host "找不到 learnings\cards\，先用 new-learning-card.ps1 建立第一張卡。" -ForegroundColor Yellow
    return
}

# --- 解析卡片開頭的 front matter ---
function Read-CardMeta {
    param([System.IO.FileInfo]$File)

    $lines = Get-Content -LiteralPath $File.FullName -Encoding UTF8
    $meta = [ordered]@{
        id       = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
        date     = ''
        author   = ''
        project  = ''
        tags     = @()
        severity = 'medium'
        status   = 'active'
        title    = ''
        file     = $File.Name
    }

    $inFront = $false
    foreach ($line in $lines) {
        if ($line.Trim() -eq '---') {
            if (-not $inFront) { $inFront = $true; continue }
            else { $inFront = $false; continue }
        }
        if ($inFront) {
            if ($line -match '^\s*([a-zA-Z_]+)\s*:\s*(.*)$') {
                $key = $Matches[1].ToLower()
                $val = $Matches[2].Trim()
                if ($key -eq 'tags') {
                    $val = $val.Trim('[', ']')
                    $meta.tags = @($val -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
                } elseif ($meta.Contains($key)) {
                    $meta[$key] = $val
                }
            }
            continue
        }
        # front matter 之後第一個 H1 當標題
        if (-not $meta.title -and $line -match '^#\s+(.+)$') {
            $meta.title = $Matches[1].Trim()
        }
    }
    if (-not $meta.title) { $meta.title = $meta.id }
    return $meta
}

$cards = @()
foreach ($f in (Get-ChildItem -LiteralPath $cardsDir -Filter '*.md' -File | Sort-Object Name -Descending)) {
    try { $cards += (Read-CardMeta -File $f) }
    catch { Write-Host "略過無法解析的卡片：$($f.Name)（$($_.Exception.Message)）" -ForegroundColor Yellow }
}

$active = @($cards | Where-Object { $_.status -ne 'archived' })
$archived = @($cards | Where-Object { $_.status -eq 'archived' })

$sevLabel = @{ high = '高'; medium = '中'; low = '低' }
$sevOrder = @{ high = 0; medium = 1; low = 2 }

function Format-Row {
    param($c)
    $tags = if ($c.tags.Count) { ($c.tags | ForEach-Object { "``$_``" }) -join ' ' } else { '—' }
    $sev = if ($sevLabel.ContainsKey($c.severity)) { $sevLabel[$c.severity] } else { $c.severity }
    $date = if ($c.date) { ($c.date -split ' ')[0] } else { '—' }
    "| $date | [$($c.title)](./cards/$($c.file)) | $($c.author) | $sev | $tags |"
}

$sb = [System.Text.StringBuilder]::new()
$null = $sb.AppendLine('# 經驗教訓卡索引')
$null = $sb.AppendLine()
$null = $sb.AppendLine('> 本檔由 `scripts/build-learning-index.ps1` 產生，**請勿手動編輯**。')
$null = $sb.AppendLine('> git 若在本檔發生衝突，不要手動合併 —— 重跑一次腳本覆蓋即可。')
$null = $sb.AppendLine()
$null = $sb.AppendLine("最後更新：$(Get-Date -Format 'yyyy-MM-dd HH:mm')")
$null = $sb.AppendLine()

$highCount = @($active | Where-Object { $_.severity -eq 'high' }).Count
$null = $sb.AppendLine("共 $($cards.Count) 張卡：現行 $($active.Count) 張（其中高嚴重度 $highCount 張）、已封存 $($archived.Count) 張。")
$null = $sb.AppendLine()

if ($active.Count) {
    $null = $sb.AppendLine('## 現行卡片')
    $null = $sb.AppendLine()
    $null = $sb.AppendLine('依嚴重度與時間排序，高嚴重度的請優先閱讀。')
    $null = $sb.AppendLine()
    $null = $sb.AppendLine('| 日期 | 標題 | 作者 | 嚴重度 | 標籤 |')
    $null = $sb.AppendLine('|---|---|---|---|---|')
    $sorted = $active | Sort-Object `
        @{ Expression = { if ($sevOrder.ContainsKey($_.severity)) { $sevOrder[$_.severity] } else { 9 } } },
        @{ Expression = { $_.date }; Descending = $true }
    foreach ($c in $sorted) { $null = $sb.AppendLine((Format-Row -c $c)) }
    $null = $sb.AppendLine()

    # 標籤索引：同一主題的卡片放一起，方便按情境找
    $tagMap = @{}
    foreach ($c in $active) {
        foreach ($t in $c.tags) {
            if (-not $tagMap.ContainsKey($t)) { $tagMap[$t] = @() }
            $tagMap[$t] += $c
        }
    }
    if ($tagMap.Count) {
        $null = $sb.AppendLine('## 依標籤')
        $null = $sb.AppendLine()
        foreach ($t in ($tagMap.Keys | Sort-Object)) {
            $items = ($tagMap[$t] | ForEach-Object { "[$($_.title)](./cards/$($_.file))" }) -join '、'
            $null = $sb.AppendLine("- **$t**（$($tagMap[$t].Count)）：$items")
        }
        $null = $sb.AppendLine()
    }
} else {
    $null = $sb.AppendLine('## 現行卡片')
    $null = $sb.AppendLine()
    $null = $sb.AppendLine('尚無卡片。用 `scripts/new-learning-card.ps1 -Title "標題"` 建立第一張。')
    $null = $sb.AppendLine()
}

if ($archived.Count) {
    $null = $sb.AppendLine('## 已封存')
    $null = $sb.AppendLine()
    $null = $sb.AppendLine('技術棧或流程已改變、不再適用的卡片。保留以看出決策演變。')
    $null = $sb.AppendLine()
    $null = $sb.AppendLine('| 日期 | 標題 | 作者 | 嚴重度 | 標籤 |')
    $null = $sb.AppendLine('|---|---|---|---|---|')
    foreach ($c in ($archived | Sort-Object { $_.date } -Descending)) { $null = $sb.AppendLine((Format-Row -c $c)) }
    $null = $sb.AppendLine()
}

[System.IO.File]::WriteAllText($indexPath, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))

if (-not $Quiet) {
    Write-Host ""
    Write-Host "已更新 learnings\INDEX.md" -ForegroundColor Green
    Write-Host "  現行 $($active.Count) 張、已封存 $($archived.Count) 張"
}
