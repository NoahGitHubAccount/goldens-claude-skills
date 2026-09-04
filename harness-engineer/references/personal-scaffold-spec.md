# Personal Scaffold Spec：Golden 個人鷹架規格

> 本文件為 `harness-engineer` 的核心差異點，融合 Golden 多次協作中的個人需求。

## 鷹架檔總覽

| 檔案 | 目標讀者 | 是否進 git | 更新頻率 |
|---|---|---|---|
| `CLAUDE.md` | Agent | ✅ | 低（架構穩定後） |
| `README.md` | 人類 | ✅ | 中 |
| `plan.md` | Agent + 人類 | ✅ | 中（每階段） |
| `status.md` | Agent + 人類 | 看情況 | 高（每次任務結束） |
| `learnings/cards/` | Agent | ✅ | 中（每次失誤，一張卡一個檔） |
| `docs/` | 人類 | ✅ | 中 |
| `notes/` | 人類 + pptx-generator | ✅ | 低（重大成果時） |

## plan.md：階段化任務規劃

### 為什麼必要

> Golden：「跟 Claude Code 的協作時，大部分的真實任務都要發展 plan.md，去規劃步驟，才能持續分階段進行。」

沒有 plan.md，Agent 容易「先做再說」，做到一半才發現方向錯誤；有 plan.md 才能跨日 / 跨人 / 跨 session 對齊。

### 必含區塊

1. **目標**（What & Why）
2. **驗收條件**（明確、可驗證）
3. **Phase 1..N**（每階段含：產出物、預估工時、阻塞風險）
4. **未決問題**（待使用者決策的開放問題）

### 觸發更新時機

- 完成一個 Phase → 標記 ✅ 並補上實際耗時
- 發現新需求 → 加入新 Phase 或修改驗收條件
- 阻塞風險變實際 → 把 risk 改寫成 blocker

## status.md：跨日協作恢復

### 為什麼必要

> Golden：「跟 Claude Code 的協作有時沒有辦法在 1 天完成，每次重新開啟，Agent 應該要能載入任務進行的狀態。」

Claude Code 重啟後沒有上下文記憶，需要 status.md 作為「恢復點」。

### 必含區塊

```markdown
## 最後更新：YYYY-MM-DD HH:MM

## 進行中任務
- [ ] [plan.md Phase 2] 實作 user 模型

## 已完成 checkpoint
- ✅ [Phase 1] 環境建置（2026-05-04 完成）

## 下次啟動第一步
打開 src/models/user.ts，實作 validateEmail()

## Blocker
- 無 / 等待 X 回覆 / Y 套件相容性問題

## Git 狀態
- branch: feature/user-model
- HEAD: abc1234 "WIP: user schema draft"
```

### 自動化建議

啟用 `stop-status-snapshot.ps1` hook，在 session 結束時自動更新「最後更新」「Git 狀態」兩欄，使用者只需手動填「下次第一步」。

## learnings/：經驗教訓卡

### 為什麼必要

> Golden：「跟 Claude Code 的協作，會持續於專案發生失誤，為了累積經驗，錯誤的部分應該要有 for agent 的經驗學習檔案，避免重複失誤浪費 token。」

**For Agent，非 for human。** 重點是讓 Agent 在新 session 一開始就讀，避免再犯。

### 條目格式

```markdown
[YYYY-MM-DD] 一行情境摘要
- 情境：什麼時候、做什麼
- 錯誤：實際發生什麼問題
- 根因：為什麼會錯
- 規避規則：下次怎麼避（必填，可執行）
```

### 自動化建議

啟用 `post-bash-learning.ps1` hook，在 Bash 失敗時自動把指令與 stderr 摘要寫入 `learnings/inbox.md`，使用者再決定要不要用 `new-learning-card.ps1` 整理成正式卡片。收件匣建議加入 .gitignore。

## README.md：人類可讀

### 為什麼必要

> Golden：「專案一定要有 readme 摘要，包含簡介專案、說明專案的安裝程序或安裝程序文件、基礎啟停用方法 / 指令 / 步驟文件，相關內容較多時，要收錄到 /docs 中，readme 釋放置對應文件路徑。」

### 必含區塊（順序）

1. **專案名稱 + 一句話定位**
2. **簡介**（不超過三段）
3. **安裝程序**（直接寫，或指向 `docs/install.md`）
4. **基礎啟停用方法**（直接寫，或指向 `docs/usage.md`）
5. **目錄樹**（簡化版）
6. **相關文件**（指向 `docs/` 內各文件）
7. **作者 / 授權**

### 200 行原則

README.md 內容超過 200 行時，把「安裝程序」「啟停用方法」「進階使用」等較長段落外推到 `/docs/`，README 只放路徑連結。

## /docs：人類可閱讀文件

### 為什麼必要

> Golden：「跟 Claude Code 的協作，我時常需要於發展的專案中，產生對應的文件，來讓相關專案可被人類閱讀，需要有 /docs 的目錄去存放這些文件。」

### 建議結構

```
docs/
├── README.md          # 索引（指向以下各文件）
├── architecture.md    # 系統架構
├── install.md         # 詳細安裝步驟
├── usage.md           # 詳細使用方式
├── api.md             # API 規格（如有）
├── deployment.md      # 部署指南
├── troubleshooting.md # 疑難排解
└── adr/               # 架構決策記錄
    └── 0001-why-X.md
```

## /notes：成果分享素材庫

### 為什麼必要

> Golden：「當專案累積出成果時，我時常需要跟他人分享這份成果，我首先會需要 /notes 來存放相關資料跟過程的報告或數據，包含初始及過程中的重要提示詞、套件依賴、skill 依賴、成效等等，格式要是 md 檔案，我另會使用我自帶的 skill 將素材轉成簡報摘要的 md 格式。」

### 銜接 pptx-generator

`/notes/` 的素材會被 `pptx-generator` skill 取用，產出 Pandoc Markdown → PPTX。

### 命名規則

`YYYYMMDD-topic-slug.md`，例如：`20260505-harness-engineer-launch.md`

### 必含欄位

詳見 `pptx-handoff.md`。
