# goldens-claude-skills 開發計畫

> 建立日期：2026-05-05
> 作者：Golden

## 目標

維護 Claude Code 全域 skill 集合，並建立可持續迭代的版本/升級機制，讓套用 skill 的下游專案能在 skill 更新時順暢同步。

## 驗收條件

- [x] harness-engineer 0.1.0 上線並可被新專案 init
- [x] manifest.json 標記範本 kind（seed / optional-core / tool）
- [x] init-scaffold.ps1 寫入 `.harness-version` 到專案根
- [x] CHANGELOG.md 建立並開始維護
- [ ] 第二個專案套用此 skill 時升級流程順暢（需 `upgrade-harness.ps1`）
- [ ] 至少一個下游專案曾成功從 v0.1.x → v0.2.x

---

## Phase 1：MVP 升級基礎建設 ✅

- **產出物**：manifest.json、`.harness-version` 寫入機制、CHANGELOG.md
- **預估工時**：1 小時（實際 ~45 分）
- **狀態**：✅ 完成（2026-05-05）

---

## Phase 2：實際升級執行器（待觸發）

- **產出物**：`scripts/upgrade-harness.ps1`、`references/06-versioning.md`
- **預估工時**：3-4 小時
- **狀態**：⏳ Deferred — 詳見下方觸發條件

---

## 未決問題

- [x] ~~`~/.claude/skills/harness-engineer` 改成 symlink 指向 repo 端~~ — 2026-05-05 改用 Junction（symlink 需 admin/開發者模式，Junction 不需要），舊副本歸檔至 `D:\dev\__archive\harness-engineer-pre-junction-2026-05-05\`
- [ ] CHANGELOG 是否拆成「repo 級」與「每個 skill 級」兩份？目前先合併在 repo root 一份

## Deferred（延後決策）

> 開發過程中浮現「現在不做、未來可能要做」的工程改進。每條目必填可驗證的觸發條件。

### [2026-05-05] 完整 `upgrade-harness.ps1`
- **想法**：讀專案的 `.harness-version` → 比對 skill 當前版本 → 列 changelog → 對 `optional-core` 自動覆蓋（含 backup 到 `.harness-backup/`）、對 `seed` 只 diff 提示由人類決定
- **不做的理由**：目前只有自家在 dogfood，沒有真實升級需求 = 過度工程；`.harness-version` + manifest 已先鋪路，未來實作不會被卡住
- **重新評估觸發**（任一達成）：
  - 第二個下游專案開始套用 harness-engineer
  - skill repo 累積超過 5 個帶範本/scripts 變動的 commit
  - 任何專案的 `.harness-version` 落後當前版本 ≥ 2 個 minor
  - 出現第一次破壞性變更（MAJOR）
- **預估成本**：3-4 小時（含 dry-run 機制與測試）
- **連結**：未來新增 `harness-engineer/references/06-versioning.md`

### [2026-05-05] dogfood：repo 自身完整套用 harness 鷹架
- **想法**：在 `D:\dev\goldens-claude-skills\` 跑完整 init-scaffold（補 status.md / learnings.md / CLAUDE.md / docs/ / notes/），自家開發過程也用全套
- **不做的理由**：目前 `plan.md` + `CHANGELOG.md` 已涵蓋必要追蹤；dogfood 全套狗糧效益尚未明顯
- **重新評估觸發**（任一達成）：
  - 開始開發第二個 skill（會有跨 skill 依賴與設計討論）
  - 累積 commit > 10 / 跨日協作出現失憶
  - 出現多人協作或要轉交他人接手
- **預估成本**：30 分鐘

### [2026-05-05] CI / lint：檔案編碼與範本變數檢查
- **想法**：GitHub Actions 跑（1）所有 `.ps1` / `.ps1.tmpl` 必須是 UTF-8 BOM；（2）`templates/*.tmpl` 的 `{{VAR}}` 必須在 init-scaffold 的變數表中存在
- **不做的理由**：repo 還小、commit 頻率低，人工檢查可控
- **重新評估觸發**：第一次因編碼或變數不一致導致 init 失敗
- **預估成本**：1 小時

## 變更紀錄

- 2026-05-05 初版建立，完成 MVP 升級基礎建設規劃與執行
