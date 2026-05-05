# 04 - MCP Connectivity：精準工具連接

## 核心理念

當 Agent 需要存取外部資源（Jira / 資料庫 / 日誌 / GitHub），**不要讓它盲目猜測 API 或發送原始 HTTP 請求**。

Model Context Protocol（MCP）是 Anthropic 推出的標準協定，讓 Agent 透過結構化的 tool 呼叫取得外部數據。優點：
- **Deterministic by Design**：API 簽章固定，Agent 不會幻覺欄位名
- **權限可控**：MCP server 端可限制哪些操作允許
- **可重用**：同一個 MCP server 在多個 skill 共用

## 何時引入 MCP

| 場景 | 是否該用 MCP |
|---|---|
| 需要查 Jira / Linear 票證 | ✅ 用 MCP server |
| 需要查資料庫即時狀態 | ✅ 用 MCP server |
| 需要讀本地檔案 | ❌ 用內建 Read 工具 |
| 一次性 curl 某 API | ❌ 直接用 Bash |
| 需要長期可重複的外部查詢 | ✅ 包成 MCP server |

## 常見 MCP Server（依需求建議）

- **GitHub**：PR / Issue / Repo 操作
- **Atlassian**：Jira / Confluence
- **Linear**：產品工單
- **Notion**：知識庫文件
- **Google Drive / Gmail**：文件 / 郵件
- **Slack**：團隊溝通記錄
- **資料庫**：Postgres / MySQL / SQLite MCP servers
- **Asana / monday.com**：任務管理

## 設定方式

MCP server 在 `~/.claude/settings.json` 或專案 `.claude/settings.local.json` 的 `mcpServers` 欄位設定。本 skill 不主動寫入，僅提示。

當 Agent 偵測到專案需要外部資源時，應提示使用者：「此任務需要存取 X，建議連接 Y MCP server，請執行 `claude mcp add` 或編輯 settings 啟用。」

## 反模式

- ❌ Agent 盲目 curl 內部 API，遇到 403 才停下來問
- ❌ 把 access token 寫進 prompt 或 SKILL.md
- ❌ 用 Bash + jq 重新發明 MCP server 的功能
- ❌ 為一次性查詢建立 MCP server（成本不划算）

## 對 harness-engineer 的影響

`init` 模式時，**詢問使用者**：「這個專案需要連接哪些外部系統？（Jira / GitHub / 資料庫 / 無）」根據回答在輸出檢查清單提示對應 MCP server 設定，但不主動寫入。
