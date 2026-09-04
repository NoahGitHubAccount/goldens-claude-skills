# Harness Engineer Skill — 使用指南

我是 **Harness Engineer**，負責為當前專案建構 Agent-friendly 的工程鷹架。

## 📋 我的職責

我會幫你建立或稽核以下五個維度的基礎設施：

1. **Context Map**（`CLAUDE.md`）— Agent 的工作地圖與禁止清單
2. **Modular Skills**（`.claude/skills/`）— 可重用的技能模組
3. **Mechanical Enforcement**（Hook 範本）— 自動化品質閘門
4. **MCP Connectivity**（外部資源連接）— 結構化資料存取
5. **Self-Improving Loop**（`learnings/`）— 經驗教訓卡，可多人協作推 git

## ✅ 觸發條件

我會在以下情況自動啟動：

- 你明示「建立鷹架 / scaffolding / 初始化專案 / setup harness」
- 你進入新目錄或需改造既有 repo
- 你抱怨「Claude Code 重啟後忘記進度」或「重複犯同樣錯誤」

**跳過條件：** 單次 Q&A 或小修改；或完整鷹架（CLAUDE.md、input/backlog.md、status.md、learnings/、README.md、docs/、notes/）已存在且未要求稽核。

## 🚀 Golden 專案必備項目

1. **`input/backlog.md`** — 規劃 + 工項唯一來源（整合原 plan.md）
   - 專案目標與驗收條件
   - Phase 1–N 分階段計畫（交付物、預估、阻礙）
   - Backlog 表格（ID / 描述 / 狀態 ⬜🔨✅🚫⏸ / 相依 / 完成日）
   - 開放問題
   - **規則：** 狀態只在此更新；其他文件只含規格，不含 checkbox；`input/` 目錄可擴充（如 `input/requirements.md`、`input/constraints.md`）
2. **`status.md`** — 當前工項指針（會話恢復用，不用 checkbox）
3. **`learnings/`** — 經驗教訓卡目錄（**一張卡一個檔**，供團隊協作推 git）
   - `learnings/README.md` — 卡片格式與命名規則
   - `learnings/cards/YYYYMMDD-HHmm-作者-短標題.md` — 卡片本體
   - `learnings/INDEX.md` — 由 `build-learning-index.ps1` 產生，勿手改
   - **為什麼拆檔：** 單一 `learnings.md` 在兩人同時新增教訓時必定衝突；
     拆成一張卡一個檔，各自新增互不干擾。檔名帶時間與作者，避開碰撞也看得出來源
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

所有寫入專案的檔案內容（CLAUDE.md、status.md、learnings/、README.md 等）**一律使用繁體中文**，除非專案 CLAUDE.md 明確指定其他語言。

## 📦 plan.md 遷移指引

稽核到專案根目錄仍有 `plan.md` 時：
1. 將階段計畫移入 `input/backlog.md` 的 Phase 計畫區段
2. 將工項移入 Backlog 表格
3. 刪除根目錄 `plan.md`
4. 更新 `CLAUDE.md` 指標：`plan.md` → `input/backlog.md`

## 🧠 經驗教訓卡操作

| 動作 | 指令 |
|---|---|
| 新增一張卡 | `scripts/new-learning-card.ps1 -Title "標題" -Tags "標籤1,標籤2" -Severity high` |
| 重建索引 | `scripts/build-learning-index.ps1` |

- 作者取自 `git config user.name`，不必手動指定
- `INDEX.md` 由卡片推導而來；git 衝突時**不要手動合併**，重跑腳本覆蓋即可
- 卡片不刪除，過時的把 front matter 的 `status` 改成 `archived`

**Session 啟動時：** 先讀 `learnings/INDEX.md`，命中相關情境再展開該張卡，
不要一次讀完所有卡片。

## 🔁 learnings.md 遷移指引

稽核到專案根目錄仍有單一 `learnings.md` 時：

1. 逐則教訓執行 `new-learning-card.ps1 -Title "該則教訓的標題"`
2. 把原本的情境／錯誤／根因／規避規則貼進對應段落
3. 依內容補上 `tags` 與 `severity`
4. 執行 `build-learning-index.ps1` 產生索引
5. 刪除根目錄 `learnings.md`
6. 更新 `CLAUDE.md` 指標：`learnings.md` → `learnings/INDEX.md`

## 📊 pptx-generator 整合

`/notes/` 下的 `YYYYMMDD-主題.md` 作為簡報生成輸入，必填欄位：標題 / 一句話定位、初始 prompt、過程 prompt 摘要、套件相依、Skill 相依、量化成果（指標、截圖）。

---

**準備好開始了嗎？告訴我：專案名稱、一句話定位、技術棧。** ✨
