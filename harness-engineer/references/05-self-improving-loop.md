# 05 - Self-Improving Loop：learnings + eval 自我改善

## 核心理念

一個成熟的 Harness 應該讓 Agent **越用越聰明**，並防止程式碼的「熵增（Entropy）」。

兩個關鍵檔案：
- **`learnings.md`**：持久化記憶。Agent 把過去的成功 / 失敗心得寫進來，下次 session 開始先讀。
- **`eval.json`**：二元驗證（Binary Evals）。任務結束時根據可量化的問題判斷成敗。

## learnings.md 設計

### 條目格式（Agent 直接讀取）

```markdown
[2026-05-05] Bash 路徑含中文用戶名導致 PowerShell 失敗
- 情境：在 C:\Users\張捷\ 下執行帶相對路徑的 Bash 指令
- 錯誤：PowerShell 解析失敗、shell 預期 POSIX 路徑
- 根因：中文用戶名 + Windows 路徑分隔符
- 規避規則：路徑優先用 /c/Users/張捷/ 形式或加引號
```

### 索引區（前 20 行）

最重要的「Top-N token 浪費案例」放最前面，讓 Agent 即使只讀前段也能拿到關鍵教訓。

### 過期歸檔

超過 6 個月未觸發的條目，移到 `learnings.archive.md`，主檔保持精簡。

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
Agent 讀取 learnings.md 索引（避免重複錯誤）
    ↓
[執行任務]
    ↓
[Stop hook 觸發]
    ↓
跑 eval.json 中的所有 evals
    ↓
失敗的 eval → 寫成新的 learnings 條目
    ↓
更新 learnings.md（含時間戳）
    ↓
[下次 Session 開始]
    ↓
Agent 讀到新增的教訓
```

## 與本 skill 的整合

`harness-engineer` 的 `init` 模式會：
1. 建立空的 `learnings.md`（含格式說明）
2. 在 `assets/eval.json.tmpl` 提供 eval 骨架（使用者可選擇複製到專案）
3. 提示使用者啟用 `stop-status-snapshot.ps1` 與 `post-bash-learning.ps1` 兩個 hook，串成自動化迴圈

## 反模式

- ❌ learnings.md 寫成日記體（找不到、難讀）
- ❌ eval.json 含主觀問題（「程式碼是否優雅？」）
- ❌ learnings 條目沒有「規避規則」（只記錄錯誤、沒記錄怎麼避）
- ❌ 不歸檔過期條目，main 檔案膨脹到上千行
