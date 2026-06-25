# 自動化橋接與報告產出（選用）

當專案要把「情境式測試案例」落地為**可執行自動化測試**並產出報告時，套用本檔。核心原則：**對齊該專案既有的單元測試架構與工具，不另立一套**。先偵測專案慣例（pytest / Playwright / page object / fixtures / marker / 報告器），再讓整合測試沿用。

---

## 一、對齊既有單元測試架構（落地前必做）

動工前先盤點專案既有慣例，整合測試一律沿用同一套：

| 面向 | 盤點什麼 | 整合測試的做法 |
|---|---|---|
| 測試框架 | pytest？Playwright？ | 沿用，不引入新依賴 |
| selector 集中管理 | 有無 page object（如 `lib/selectors.py`）？ | 新畫面的 selector 加進同一處，沿用既有定位策略（語意錨點優先） |
| 共用 helper | 有無 `_shared.py`（填值/讀值/存檔/捲動）？ | 沿用；整合特有的多步操作再擴充 |
| fixtures | conftest 提供什麼（config / 登入 session / 報告附掛）？ | 沿用 `config`、登入還原、`report_attach` 等 |
| 標記 | 工項 marker（如 `@pytest.mark.wbs(...)`）？ | 每個案例掛對應 marker，串回需求追溯 |
| 報告器 | 自製 reporter？截圖模式？ | 沿用，讓整合測試報告與單元測試同格式 |

> 一個 pytest + Playwright 專案的對照範例：`lib/selectors.py` page object（語意錨點，不用框架動態 ID / utility class）；`tests/**/_shared.py` helper；conftest 提供 `config` / 登入 session 還原 / `report_attach`；工項 marker（如 `@pytest.mark.wbs(...)`）；自製報告器（如 `lib/md_reporter.py`）+ 截圖模式旗標（如 `--shot`）。實際名稱依專案而定，重點是「沿用既有那一套」。

## 二、案例 ↔ pytest 結構對應

情境式案例的每個元素，都有自動化對應物：

| 案例元素 | pytest 落地 |
|---|---|
| 一個情境 | 一個測試模組（檔案） |
| 使用角色 | fixture / 獨立 browser context（跨角色用不同 context 隔離 session） |
| 前置準備 | session/module fixture、預先登入（warm-login）、`config` 前置檢查 |
| 每個步驟（代號 C1/V1/R1…） | 一個 test function，docstring 寫該步驟說明 |
| 步驟的可觀察結果 | `assert` + `report_attach(expected=…, actual=…, url=…)` |
| 跨角色交接 / 跨 phase 傳遞狀態 | module-level 共用字典（如 `_S = {}`）存 pkid / url；後續 phase 無前提則 `skip` |
| 反例情境 / 未實作功能 | `pytest.xfail(reason=…)`，條件備妥後自動解鎖（**勿刪測試**） |
| 需求追溯編號 | marker 參數，報告器據此分組 |

**整合測試的紀律**：
- phase 有順序依賴 → 前一步沒產出（如無 pkid）就 `skip` 後續，不讓它假紅/假綠。
- 跨角色務必用獨立 context，避免 admin session 污染 citizen 操作。
- selector 未經真實 DOM 驗證的，先標 `（待驗證）`，走 dump→對照流程後才寫死；**禁止對 live DOM 盲試猜 selector**。

## 三、報告：先 md，再轉 docx

報告管線固定兩段：

1. **產 md**：沿用專案報告器（範例：reporter 於 `reports/<run_id>_run/` 產每工項 md + `_summary.md`，含總覽表、失敗詳情、inline 截圖）。整合測試報告與單元測試**同格式同目錄**，便於彙整。
2. **轉 docx**：md → Word 交付。專案若自帶轉檔腳本（如 `tools/md_to_docx.py`）沿用之；通用情況用 **md-to-word skill**：
   ```
   python "<md-to-word skill 目錄>/convert.py" "<input.md>" ["<output.docx>"]
   ```
   md-to-word 會把 `#`/`##` 對應 Word 標題樣式、`---` 轉換頁、圖片鑲嵌、套標楷體。

> 報告內容（情境名稱、步驟、預期/實際、截圖、需求編號）由情境式案例天然提供——案例寫得好，報告就齊全。

## 四、落地順序建議
1. 先有「情境式測試案例」（本 skill 主產物，經人類確認）。
2. 盤點專案既有架構（第一節表格）。
3. 逐情境建測試模組，步驟對應 test function，掛 marker、補 `report_attach`。
4. 未驗證 selector 標 `（待驗證）`，走 dump→對照修正。
5. 跑測試 → 產 md 報告 → 轉 docx 交付。
