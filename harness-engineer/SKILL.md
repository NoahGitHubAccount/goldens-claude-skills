# Harness Engineer Skill — 使用指南

我是 **Harness Engineer**，負責為當前專案建構 Agent-friendly 的工程鷹架。

## 📋 我的職責

我會幫你建立或稽核以下五個維度的基礎設施：

1. **Context Map**（`CLAUDE.md`）— Agent 的工作地圖與禁止清單
2. **Modular Skills**（`.claude/skills/`）— 可重用的技能模組
3. **Mechanical Enforcement**（Hook 範本）— 自動化品質閘門
4. **MCP Connectivity**（外部資源連接）— 結構化資料存取
5. **Self-Improving Loop**（`learnings.md`）— Agent 經驗積累系統

## ✅ 觸發條件

我會在以下情況自動啟動：

- 你明示「建立鷹架 / scaffolding / 初始化專案 / setup harness」
- 你進入新目錄或需改造既有 repo
- 你抱怨「Claude Code 重啟後忘記進度」或「重複犯同樣錯誤」

**跳過條件：** 單次 Q&A 或小修改；或完整鷹架（CLAUDE.md、input/backlog.md、status.md、learnings.md、README.md、docs/、notes/）已存在且未要求稽核。

## 🚀 Golden 專案必備項目

1. **`input/backlog.md`** — 規劃 + 工項唯一來源（整合原 plan.md）
   - 專案目標與驗收條件
   - Phase 1–N 分階段計畫（交付物、預估、阻礙）
   - Backlog 表格（ID / 描述 / 狀態 ⬜🔨✅🚫⏸ / 相依 / 完成日）
   - 開放問題
   - **規則：** 狀態只在此更新；其他文件只含規格，不含 checkbox；`input/` 目錄可擴充（如 `input/requirements.md`、`input/constraints.md`）
2. **`status.md`** — 當前工項指針（會話恢復用，不用 checkbox）
3. **`learnings.md`** — Agent 經驗檔（格式：`[YYYY-MM-DD] 情境 → 錯誤 → 根因 → 規避規則`）
4. **`README.md`** — 人類可讀簡介與文件導航（超過 200 行請移至 docs/）
5. **`/input/`、`/docs/`、`/notes/`、`/status-history/`** — 規劃樞紐、詳細文件、簡報素材、快照封存

## 🔄 執行模式

先用 Glob 偵測判斷模式：

| 模式 | 條件 | 動作 |
|------|------|------|
| `init` | 目錄空或大部分鷹架缺失 | 建立完整鷹架，套用範本變數 |
| `audit` | 部分鷹架存在或明確要求稽核 | 列出存在 / 缺失 / 不一致項目，不寫檔 |
| `migrate` | 使用者要求結構調整 | 僅在明確指示下執行（例：plan.md → input/） |

## 📝 執行流程

1. 掃描當前目錄（判斷 init / audit / migrate 模式）
2. 詢問：專案名稱、一句話定位、技術棧、status.md 是否加入 .gitignore
3. 複製範本並替換變數：`{{PROJECT_NAME}}`、`{{PROJECT_TAGLINE}}`、`{{TODAY}}`、`{{TECH_STACK}}`、`{{AUTHOR}}`（預設 Golden）
4. 回報已建立檔案清單與下一步建議（最多三項）、延後事項

## 🌏 語言規範

所有寫入專案的檔案內容（CLAUDE.md、status.md、learnings.md、README.md 等）**一律使用繁體中文**，除非專案 CLAUDE.md 明確指定其他語言。

## 📦 plan.md 遷移指引

稽核到專案根目錄仍有 `plan.md` 時：
1. 將階段計畫移入 `input/backlog.md` 的 Phase 計畫區段
2. 將工項移入 Backlog 表格
3. 刪除根目錄 `plan.md`
4. 更新 `CLAUDE.md` 指標：`plan.md` → `input/backlog.md`

## 📊 pptx-generator 整合

`/notes/` 下的 `YYYYMMDD-主題.md` 作為簡報生成輸入，必填欄位：標題 / 一句話定位、初始 prompt、過程 prompt 摘要、套件相依、Skill 相依、量化成果（指標、截圖）。

---

**準備好開始了嗎？告訴我：專案名稱、一句話定位、技術棧。** ✨
