# Golden's Claude Code Skills

Claude Code 全域 skill 集合。clone 後把要用的 skill 資料夾放到 `~/.claude/skills/` 即可。

## Skills

| 名稱 | 用途 |
|---|---|
| [`harness-engineer`](./harness-engineer) | 為新專案建立 Agent 鷹架（CLAUDE.md / plan / status / learnings / README / docs / notes / hook 範本） |
| [`integration-test-authoring`](./integration-test-authoring) | 從任意素材（SA 文件 / 需求情境 / 畫面截圖 / 操作手冊 / 程式碼 / 單元測試）抽取業務情境，產出情境式整合測試案例（端到端 + 角色驅動 + 狀態流轉 + 需求追溯），可橋接自動化與報告 md→docx |

## 安裝

### Windows (PowerShell 5.1+)

```powershell
git clone https://github.com/<your-account>/goldens-claude-skills.git
Copy-Item -Recurse goldens-claude-skills\harness-engineer "$HOME\.claude\skills\"
```

### macOS / Linux

```bash
git clone https://github.com/<your-account>/goldens-claude-skills.git
cp -r goldens-claude-skills/harness-engineer ~/.claude/skills/
```

或用 symlink（方便日後 `git pull` 同步）：

```bash
ln -s "$(pwd)/goldens-claude-skills/harness-engineer" ~/.claude/skills/harness-engineer
```

Windows 用 `New-Item -ItemType SymbolicLink`（需系統管理員或開發者模式）：

```powershell
New-Item -ItemType SymbolicLink `
  -Path "$HOME\.claude\skills\harness-engineer" `
  -Target "$(Resolve-Path .\harness-engineer)"
```

## 使用

裝好後在任意專案啟動 Claude Code，輸入：

> 請幫我為這個新專案建立 harness 鷹架

對應 skill 會自動觸發。也可手動用 `/skills` 確認載入清單。

## 環境需求

- Claude Code（CLI / Desktop / IDE 任一）
- 執行 PowerShell 腳本：Windows PowerShell 5.1 或 PowerShell 7+
- 含中文的 `.ps1` 已預先以 UTF-8 with BOM 儲存（PS 5.1 必要）

## 開發

各 skill 為獨立資料夾，遵循 Claude Code skill 三層 progressive disclosure 結構：

```
<skill-name>/
├── SKILL.md          # YAML metadata + 主協定
├── references/       # 依需載入的細節
├── templates/        # 範本檔
├── scripts/          # 工具腳本
└── assets/           # 範本資產（hook、eval、config）
```

新增 skill 時，在 repo root 建一個資料夾，並在本 README 的 Skills 表格加一列。

## 授權

未公開授權，使用前請聯絡作者。
