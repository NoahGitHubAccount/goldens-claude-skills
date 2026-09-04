# 05 - Self-Improving Loop：learnings + eval 自我改善

## 核心理念

一個成熟的 Harness 應該讓 Agent **越用越聰明**，並防止程式碼的「熵增（Entropy）」。

兩個關鍵檔案：
- **`learnings/`**：持久化記憶，以「一張卡一個檔」收納，供團隊協作推 git。Agent 每次 session 先讀 `INDEX.md`。
- **`eval.json`**：二元驗證（Binary Evals）。任務結束時根據可量化的問題判斷成敗。

## learnings/ 經驗卡設計

### 為什麼是一張卡一個檔

早期版本把所有教訓寫在單一 `learnings.md`。實務上一旦多人協作推 git，
兩人同時新增教訓就必定在同一個檔案的同一區塊產生衝突，而衝突內容是各自的心得，
機器無從判斷該保留哪一段，只能人工合併，容易貼錯位置甚至整段遺失。

改為**一張卡一個檔**之後，各自新增互不干擾，git 幾乎不會衝突。

### 目錄結構

```
learnings/
├── README.md      # 卡片格式與命名規則
├── INDEX.md       # 由腳本產生，勿手改
├── inbox.md       # hook 自動蒐集的待整理訊息（建議 gitignore）
└── cards/
    └── YYYYMMDD-HHmm-作者-短標題.md
```

### 檔名帶時間與作者的理由

`20260904-1139-golden-工項狀態分散多檔.md`

- **時間到分鐘**：同一人同一天可以建多張卡而不撞名
- **作者**：多人同時建卡時，即使標題雷同也不會碰撞；在檔案清單上直接看得出來源

作者取自 `git config user.name`，由 `new-learning-card.ps1` 自動帶入。

### 卡片格式

開頭是 YAML front matter，供索引腳本解析：

```yaml
---
id: 20260904-1139-golden-工項狀態分散多檔
date: 2026-09-04 11:39
author: golden
project: 專案名
tags: [工程管理, 狀態管理]
severity: high        # high | medium | low
status: active        # active | archived
---
```

正文五段：情境 / 錯誤 / 根因 / **規避規則（必填）** / 相關。

### 索引是可拋棄的

`INDEX.md` 完全由 `cards/` 推導而來。git 若在索引上衝突，**不要手動合併**，
重跑 `build-learning-index.ps1` 覆蓋即可。

### 過期處理

不刪卡片，把 front matter 的 `status` 改成 `archived`，索引會自動移到「已封存」區。
保留下來才看得出決策的演變。

## eval.json 設計

### Binary Evals 原則

每個 eval 必須是**是 / 否**，無灰色地帶。模糊問題（如「程式碼好不好？」）要拆解成可驗證的子問題：
- 「是否所有檔案通過 linter？」是 / 否
- 「README 是否包含安裝段落？」是 / 否
- 「測試覆蓋率是否 ≥ 80%？」是 / 否

### 範例 schema

```json
{
  "version": "1.0",
  "evals": [
    {
      "id": "readme-has-install",
      "question": "README.md 是否包含 ## 安裝 區塊？",
      "type": "file-contains",
      "file": "README.md",
      "pattern": "^## 安裝"
    },
    {
      "id": "linter-pass",
      "question": "所有檔案是否通過 prettier 檢查？",
      "type": "command-exit-zero",
      "command": "npx prettier --check ."
    }
  ]
}
```

## 自我改善迴圈如何運作

```
[Session 開始]
    ↓
Agent 讀取 learnings/INDEX.md（避免重複錯誤）
    ↓
[執行任務]
    ↓
[Stop hook 觸發]
    ↓
跑 eval.json 中的所有 evals
    ↓
失敗的 eval → 建立新的經驗卡
    ↓
建卡並重建索引
    ↓
[下次 Session 開始]
    ↓
Agent 讀到新增的教訓
```

## 與本 skill 的整合

`harness-engineer` 的 `init` 模式會：
1. 建立 `learnings/`（README 說明格式、cards/ 空目錄、初始 INDEX.md）
2. 在 `assets/eval.json.tmpl` 提供 eval 骨架（使用者可選擇複製到專案）
3. 提示使用者啟用 `stop-status-snapshot.ps1` 與 `post-bash-learning.ps1` 兩個 hook，串成自動化迴圈

## 反模式

- ❌ 把所有教訓塞回單一檔案（多人推 git 必定衝突）
- ❌ eval.json 含主觀問題（「程式碼是否優雅？」）
- ❌ 卡片沒有「規避規則」（只記錄錯誤、沒記錄怎麼避）
- ❌ 手動編輯 INDEX.md（下次重跑腳本就被覆蓋）
- ❌ 刪除過期卡片（應改 status 為 archived，保留決策軌跡）
