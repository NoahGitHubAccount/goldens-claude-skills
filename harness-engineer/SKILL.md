---
name: harness-engineer
description: 為當前專案建構 Harness Engineering 鷹架（CLAUDE.md 地圖、plan/status/learnings、README/docs/notes、hook 範本）。當使用者開新專案、要求「建立鷹架 / scaffolding / 初始化專案 / setup harness / 治理工程」、或請求把既有 repo 改造為 agent-friendly 時觸發。
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Harness Engineer 協定

> `Agent = Model + Harness`
> 你的任務是為當前工作目錄建構 / 稽核 Agent 的 Harness（約束、鷹架、回饋迴圈），讓後續的 AI 協作能在可靠、可恢復、可學習的環境中運行。

---

## 1. 觸發判斷

**應該執行此 skill：**
- 使用者明示「建立鷹架 / scaffolding / 初始化專案 / setup harness / 治理工程」
- 使用者開新專案或進入新目錄、希望把既有 repo 改造為 agent-friendly
- 使用者抱怨「Claude Code 重啟後忘記進度」「同樣錯誤一直犯」「不知道把文件放哪」
- 使用者明示要為某類重複任務建立規範化工作流

**不要執行此 skill：**
- 使用者只是問問題、找資料、做單次小修
- 當前專案已經有完整的 CLAUDE.md / plan.md / status.md / learnings.md / README.md / docs/ / notes/，且使用者沒明確要求 audit

---

## 2. 執行模式

執行前先用 Glob 偵測當前工作目錄，根據結果決定模式：

| 模式 | 觸發條件 | 行為 |
|---|---|---|
| `init` | 目錄為空或缺少多數鷹架檔 | 完整建立全套鷹架，複製範本並替換變數 |
| `audit` | 鷹架部分存在或使用者明示「稽核」 | 列出已有 / 缺失 / 不一致項目，報告但不寫入 |
| `migrate` | 使用者明示遷移（如 `.agent/skills/` → `.claude/skills/`） | 僅在使用者明示時執行 |

**偵測指令範例（先用 Glob）：**
```
CLAUDE.md, README.md, plan.md, status.md, learnings.md, docs/, notes/, .claude/, .agent/skills/
```

---

## 3. 五維度建構協定

每個維度的詳細指南放在 `references/`，主流程只需摘要：

### 3.1 Context Map（上下文地圖）
不要把所有規則塞進單一 `CLAUDE.md`。`CLAUDE.md` 應該是「地圖」：一句話定位、技術棧、禁止事項、繁中規則，並指向 `/docs/architecture.md`、`/learnings.md`、`/status.md`、`plan.md`。
詳見 `references/01-context-map.md`。

### 3.2 Modular Skills（模組化技能）
Progressive disclosure 三層：YAML metadata → SKILL.md → scripts/templates/references。重複性高的任務應拆分為獨立 skill 目錄，metadata 寫好觸發描述，內容隨需展開。
詳見 `references/02-modular-skills.md`。

### 3.3 Mechanical Enforcement（機械式強制約束）
人類審查無法規模化。以 PreToolUse / PostToolUse / Stop / UserPromptSubmit Hooks 建立自動化品質與安全閘門。違規回傳 Exit Code 2 阻擋並把錯誤訊息回饋給 Agent。
**注意：本 skill 只提供範本，不主動寫入 settings.json。**
詳見 `references/03-mechanical-enforcement.md`。

### 3.4 MCP Connectivity（精準工具連接）
需要存取外部資源（Jira / 資料庫 / 日誌）時，透過 MCP server 取得結構化數據，而非讓 Agent 盲目猜測 API。
詳見 `references/04-mcp-integration.md`。

### 3.5 Self-Improving Loop（自我改善迴圈）
`learnings.md`（持久經驗）+ `eval.json`（二元驗證）= 越用越聰明。Stop hook 在任務結束時根據 eval 結果寫回 learnings。
詳見 `references/05-self-improving-loop.md`。

---

## 4. 個人鷹架融合流程（Golden 專屬需求）

**核心差異點：每個專案必有以下鷹架，使用者已明確要求。**

### 步驟 1：建立 `plan.md`
真實任務必須先做計畫再動手。從 `templates/plan.md.tmpl` 複製，包含：目標 / 驗收條件 / Phase 1–N（產出物、預估工時、阻塞風險）/ 未決問題。

### 步驟 2：建立 `input/backlog.md`（Single Source of Truth）
工項狀態的唯一來源。從 `templates/backlog.md.tmpl` 複製，格式為表格：ID / 說明 / 狀態（⬜🔨✅🚫⏸）/ 依賴 / 完成日。
**規則：phase 細節檔只存規格說明，不含 checkbox；所有狀態異動只改此檔。**

### 步驟 3：建立 `status.md`
跨日協作恢復用。從 `templates/status.md.tmpl` 複製，格式為「當前工項 ID 指針 + 下一步指令」，不再維護 checkbox 清單。
**建議在 `.gitignore` 排除（個人狀態）或保留追蹤（團隊共享）—— 詢問使用者偏好。**

### 步驟 4：建立 `learnings.md`
**For Agent，非 for human。** 從 `templates/learnings.md.tmpl` 複製。條目格式：
```
[YYYY-MM-DD] 情境 → 錯誤 → 根因 → 規避規則
```
Agent 在每次 session 開始時應主動讀取，避免重複犯錯浪費 token。

### 步驟 5：建立 `README.md`
人類向。從 `templates/README.md.tmpl` 複製，包含：一句話簡介 / 安裝程序（或安裝文件路徑）/ 啟停用方法（或文件路徑）/ 目錄樹 / 連結到 `/docs/`。
**規則：README 過長（> 200 行）時，內容外推到 `/docs`，README 只放路徑連結。**

### 步驟 6：建立 `/docs`、`/notes`、`/status-history` 三目錄
- `/docs/`：人類可閱讀的專案文件（架構、API、部署、疑難排解）。複製 `templates/docs/README.md.tmpl`。
- `/notes/`：成果分享素材庫，含初始 / 過程提示詞、套件依賴、skill 依賴、成效數據（md 格式），會餵給 `pptx-generator` 產出簡報。複製 `templates/notes/README.md.tmpl`。

---

## 5. 與 pptx-generator 銜接

`/notes/` 的素材會被既有的 `pptx-generator` skill 取用產出簡報。檔案命名 `YYYYMMDD-topic.md`，必含欄位：
- 題目 / 一句話定位
- 初始 prompt（驅動專案的最初指令）
- 過程 prompt 摘要（重要轉折點）
- 套件依賴（package.json / requirements.txt 摘錄）
- skill 依賴（用到哪些 .agent/skills 或 .claude/skills）
- 成效數據（量化結果、截圖路徑）

詳細 schema 與範例見 `references/pptx-handoff.md`。

---

## 6. 執行輸出檢查清單

完成後向使用者輸出 Markdown checklist：

```markdown
## Harness 實作檢查清單

- [ ] CLAUDE.md（Agent 地圖）
- [ ] plan.md（任務階段化規劃）
- [ ] input/backlog.md（唯一工項狀態來源）
- [ ] status.md（當前工項 ID 指針）
- [ ] learnings.md（Agent 經驗檔）
- [ ] README.md（人類可讀）
- [ ] docs/（人類向文件目錄）
- [ ] notes/（pptx-generator 素材源）
- [ ] status-history/（已完成 checkpoint 歸檔）
- [ ] .claude/hooks/（Hook 範本已複製，settings 由使用者自行啟用）
- [ ] .gitignore（status.md 是否需排除 — 已詢問）
- [ ] 初次 commit 訊息建議：`chore: bootstrap harness via harness-engineer skill`
```

---

## 7. 回報格式

完成後輸出三段：

1. **已建立項目**：列出實際寫入的檔案路徑
2. **下一步建議**（最多三條）：例如「先填 plan.md 的 Phase 1」「啟用 stop-status-snapshot hook」「連接專案需要的 MCP server」
3. **未做事項**：例如 audit 模式發現的差異、或使用者拒絕的選項

---

## 執行流程（Agent 行動指引）

1. **偵測**：用 Glob 列出當前目錄的鷹架檔狀態，決定 `init` / `audit` / `migrate` 模式
2. **詢問**（init 模式必問）：
   - 專案名稱（用於 `{{PROJECT_NAME}}`）
   - 一句話定位（用於 `{{PROJECT_TAGLINE}}`）
   - 技術棧（用於 `{{TECH_STACK}}`）
   - status.md 是否加入 .gitignore
3. **執行**：
   - init：呼叫 `scripts/init-scaffold.ps1`，或直接用 Read+Write 複製範本並替換變數
   - audit：呼叫 `scripts/check-harness.ps1`，輸出健檢報告
4. **回報**：依第 6、7 節格式輸出

---

## 範本變數

範本中的占位符由 `scripts/render-template.ps1` 替換：
- `{{PROJECT_NAME}}` — 專案名稱
- `{{PROJECT_TAGLINE}}` — 一句話定位
- `{{TODAY}}` — 今日日期（YYYY-MM-DD）
- `{{TECH_STACK}}` — 技術棧
- `{{AUTHOR}}` — 作者（預設 Golden）
