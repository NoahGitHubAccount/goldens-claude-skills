# Changelog

本 repo 的版本變動紀錄。遵循 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/) 風格與 [Semantic Versioning](https://semver.org/lang/zh-TW/)。

skill 版本獨立管理，個別版本標記於各 skill 目錄下的 `manifest.json`。

## [Unreleased]

## [integration-test-authoring 0.1.0] — 2026-06-25

### Added
- integration-test-authoring skill 初版，情境式整合測試案例撰寫，三層 progressive disclosure
  - `SKILL.md`：主協定（四大核心觀念：端到端 / 角色驅動 / 狀態流轉 / 需求追溯；三段式步驟：前置準備 / 驗測情境步驟 / 結果檢視；品質檢核表 7 項）
  - `references/format-and-examples.md`：欄位定義、寫法規範、3 個黃金範例（以訂單出貨系統通用化示意）、狀態機參考
  - `references/extraction-by-input-type.md`：6 類輸入素材（SA / User Story / 截圖 / 操作手冊 / 程式碼 / 單元測試）的抽取策略與陷阱
  - `references/automation-and-reporting.md`：對齊既有單元測試架構、案例↔pytest 結構對應、報告 md→docx 管線
- `manifest.json`：標記 skill 版本與檔案清單

### Notes
- 範例全數通用化（不含任何特定產品 / 客戶 specifics），適合公開分享

## [harness-engineer 0.1.0] — 2026-05-05

### Added
- harness-engineer skill 初版，含三層 progressive disclosure 架構
  - `SKILL.md`：主協定（YAML metadata + 觸發判斷 + 五維度建構協定）
  - `references/`：七份指南（context-map / modular-skills / mechanical-enforcement / mcp-integration / self-improving-loop / personal-scaffold-spec / pptx-handoff）
  - `templates/`：七份範本（CLAUDE.md / plan.md / status.md / learnings.md / README.md / docs/README.md / notes/README.md）
  - `scripts/`：三支工具（init-scaffold / check-harness / render-template）
  - `assets/`：五份 hook 範本 + settings.local.json.tmpl + eval.json.tmpl
- `plan.md.tmpl` 加入 **Deferred（延後決策）** 區塊，要求每條目必填可驗證的觸發條件
- `manifest.json`：標記範本檔的 kind（seed / optional-core / tool），為未來 upgrade 機制鋪路
- `init-scaffold.ps1` 在專案根寫入 `.harness-version`，記錄裝的 skill 版本與時間

### Compatibility notes
- 所有 `.ps1` / `.ps1.tmpl` 已預先以 UTF-8 with BOM 儲存，相容 Windows PowerShell 5.1
- Hook 範本不主動寫入 `settings.local.json`，由使用者自行貼用

### Deferred（待後續版本）
- `upgrade-harness.ps1`：實際的升級執行器（讀 .harness-version → diff → 選擇性覆蓋）。觸發條件詳見 [plan.md](./plan.md) 的 Deferred 區塊。
