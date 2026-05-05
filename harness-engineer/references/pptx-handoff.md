# pptx-handoff：/notes → pptx-generator 銜接契約

## 背景

Golden 環境已有 `pptx-generator` skill（位於 `D:\GoldenAgent\.agent\skills\pptx-generator\`），功能：
- 將大綱 / 素材 → Pandoc Markdown → PPTX
- 支援母片、雙欄、講者備忘稿
- 版本 1.1.0

`harness-engineer` 建立的 `/notes/` 目錄是 `pptx-generator` 的**標準素材源**，兩者透過固定 schema 對接。

## /notes 檔案 schema

每份成果素材檔（`YYYYMMDD-topic.md`）必含以下欄位（YAML frontmatter + Markdown body）：

```markdown
---
title: 簡報主題
tagline: 一句話定位
date: 2026-05-05
author: Golden
duration_minutes: 15
audience: 內部技術分享 / 客戶提案 / 主管彙報
---

## 1. 專案簡介

（一段話，2~3 句）

## 2. 初始 Prompt

（驅動專案的最初指令，原文引用）

```
請幫我建立一個 ...
```

## 3. 過程 Prompt 摘要

重要轉折點的 prompt（最多 5 個）：
- [日期] Prompt 摘要：做了什麼、為什麼
- ...

## 4. 套件依賴

擷取自 package.json / requirements.txt / Pipfile，僅列關鍵：
- react@18.x
- ...

## 5. Skill 依賴

用到的 .agent/skills 或 .claude/skills：
- harness-engineer
- pptx-generator
- ...

## 6. 成效數據

可量化的結果：
- 開發時間：X 小時 → Y 小時（節省 Z%）
- 程式碼行數：N 行
- 測試覆蓋率：M%
- ...（截圖路徑：`./assets/screenshots/xxx.png`）

## 7. 關鍵截圖

（指向 `notes/assets/` 下的圖片，pptx-generator 會嵌入）

## 8. 後續展望

（一段話）
```

## pptx-generator 的接收方式

當使用者要產簡報時，呼叫 pptx-generator 並傳入 `notes/<filename>.md` 路徑。pptx-generator 會：
1. 讀取 frontmatter 取得標題、作者、時長
2. 把每個 `## N.` 區塊轉為一張投影片
3. 自動嵌入截圖
4. 輸出 Pandoc Markdown，再轉 PPTX

## 對 init 模式的影響

`harness-engineer init` 時：
1. 建立 `notes/` 目錄
2. 複製 `templates/notes/README.md.tmpl`，內含本 schema 簡化版
3. 在 `notes/.gitkeep` 保留空目錄
4. 在輸出檢查清單提示：「未來有成果時，建立 `notes/YYYYMMDD-xxx.md`，再呼叫 pptx-generator 產簡報」

## 反模式

- ❌ 在 notes/ 放零散筆記、未結構化（pptx-generator 讀不到）
- ❌ 跳過 frontmatter（pptx-generator 用它生成標題頁）
- ❌ 把截圖放外部 URL（離線無法生成）
- ❌ 一份 notes 超過 1000 字（簡報會塞不下，先精簡）
