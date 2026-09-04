# 03 - Mechanical Enforcement：Hooks 設計指南

## 核心理念

**Self-evaluation 有盲點。** 讓 Agent 自評是否遵守規則，常出現「自我評估偏誤」—— 它會說自己有遵守，但實際上沒有。

Harness Engineering 強調 **Mechanical Enforcement（機械式強制執行）**：用系統層級的腳本攔截 Agent 行為，違規時用 Exit Code 2 阻擋並把錯誤訊息回傳，讓 Agent 自我修正。

## Claude Code Hooks 觸發點

| Hook | 觸發時機 | 典型用途 |
|---|---|---|
| `PreToolUse` | Agent 呼叫工具前 | 阻擋危險指令、檢查權限、驗證輸入 |
| `PostToolUse` | 工具呼叫成功後 | 自動格式化、跑單元測試、蒐集失敗訊息 |
| `Stop` | 對話 / 任務結束時 | 更新 status.md、跑 eval、產生快照 |
| `UserPromptSubmit` | 使用者送出 prompt 時 | 注入 status.md 摘要、載入經驗卡索引 |
| `SessionStart` | Session 開始 | 載入專案上下文 |
| `SubagentStop` | 子 agent 結束 | 收集子 agent 報告 |

## 設計原則

### 1. 違規回 Exit Code 2，並把錯誤訊息寫到 stderr

Claude Code 會把 Exit Code 2 的 stderr 內容當作回饋傳給 Agent，Agent 會看到、並修正。Exit Code 0 = 通過，Exit Code 1 = 警告但不阻擋。

### 2. Hook 應該快（< 1 秒）

Hook 是同步阻塞執行。慢的檢查（如完整測試套件）放 Stop hook 而非 PreToolUse。

### 3. Hook 範圍要明確

不要寫一個「萬用 hook」。`pre-write-guard` 只管寫入安全，`post-edit-format` 只管格式化。一 hook 一職。

### 4. 跨平台考量

Golden 的環境是 Windows PowerShell。所有 hook 範本以 `.ps1` 為主，註冊時用：
```json
"command": "pwsh -NoProfile -File ${CLAUDE_PROJECT_DIR}/.claude/hooks/<name>.ps1"
```

## 本 skill 提供的 Hook 範本

| 範本檔 | 觸發點 | 用途 |
|---|---|---|
| `pre-write-guard.ps1.tmpl` | PreToolUse:Write\|Edit | 阻擋寫入 secrets / 根目錄散落 .md |
| `post-edit-format.ps1.tmpl` | PostToolUse:Edit | 依副檔名觸發 prettier/black/dotnet format |
| `stop-status-snapshot.ps1.tmpl` | Stop | 自動更新 `status.md` 的時間與 git HEAD |
| `post-bash-learning.ps1.tmpl` | PostToolUse:Bash（失敗時） | 失敗指令摘要寫入 `learnings/inbox.md` 待整理 |
| `user-prompt-loader.ps1.tmpl` | UserPromptSubmit | 注入 `status.md` 摘要到上下文 |

## 啟用流程（使用者手動）

1. 把需要的 `.ps1.tmpl` 複製到 `<project>/.claude/hooks/<name>.ps1`
2. 把 `assets/settings.local.json.tmpl` 對應區塊貼到 `<project>/.claude/settings.local.json` 的 `hooks` 欄位
3. 測試：在該專案啟動 Claude Code，觸發對應行為，確認 hook 執行

**本 skill 不會自動寫入 settings.json。** 由使用者決定要不要為某專案啟用，避免一刀切影響既有環境。

## 反模式

- ❌ 在 hook 裡跑完整測試套件（慢、阻塞）
- ❌ Hook 失敗回 Exit Code 0（變成噪音，Agent 不會修正）
- ❌ 一個 hook 同時管 5 件事（職責不清）
- ❌ 把 secrets 寫死在 hook 裡（hook 也會被 commit）
