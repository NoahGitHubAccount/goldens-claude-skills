# 02 - Modular Skills：拆分原則與 Progressive Disclosure

## 三層結構

Agent Skill 不是 prompt，是**持久、可攜、版本控制的知識模組**。每個 skill 採三層架構，按需載入：

```
skill-name/
├── SKILL.md          # 第二層：主指令（Agent 觸發後讀取）
├── references/       # 第三層：詳細說明（執行特定步驟才讀）
├── scripts/          # 第三層：輔助腳本（特定步驟才呼叫）
├── templates/        # 第三層：範本檔
└── assets/           # 第三層：靜態資源
```

**第一層（YAML frontmatter）**：所有 skill 啟動時都載入，包含 `name` 與 `description`。Agent 用 description 判斷觸發。
**第二層（SKILL.md 主體）**：當任務匹配時載入完整指令。
**第三層（references/scripts/templates/assets）**：執行到對應步驟才載入。

## 何時拆分為獨立 skill

當以下任一條件成立時，把該任務從 CLAUDE.md / 大型文件中抽出來：
- 該任務在多個專案 / 多次 session 重複出現
- 該任務有明確輸入輸出（可重用）
- 該任務需要超過 30 行的指令說明
- 該任務有專屬腳本或範本

## YAML frontmatter 寫法

```yaml
---
name: skill-name                # 小寫、連字符
description: 一句話說明 + 觸發詞。Agent 用這欄判斷是否啟用。
allowed-tools: Read, Write, Bash # 限定工具，降低風險
---
```

**description 撰寫要訣：**
- 說明「在什麼情況下使用」（觸發語境）
- 列出常見觸發詞（「scaffolding / 鷹架 / 初始化」）
- 不要只寫「做 X 用」，而要寫「當 Y 發生時做 X」

## 漸進式揭露（Progressive Disclosure）的好處

- **節省 Token**：未觸發前只佔 100~200 tokens
- **降低錯誤觸發**：description 越具體，Agent 越不會誤用
- **可演化**：第三層更新不影響觸發判斷

## 反模式

- ❌ 把 5 個不相關任務塞進同一個 SKILL.md
- ❌ description 寫成「通用 helper」這種無觸發訊號的描述
- ❌ scripts/ 內放需要編輯才能用的範本（範本應放 templates/）
- ❌ 把長段內容塞進 SKILL.md 而非拆分到 references/

## 與專案級 skill 的分工

- **全域 skill**（`~/.claude/skills/`）：跨專案重用的工作流（如 harness-engineer 自己）
- **專案級 skill**（`<project>/.claude/skills/` 或 `<project>/.agent/skills/`）：該專案特有的領域知識（如 rfp-risk-assessment、n8n-skills）

新建 skill 時先問：「這個工作流，下個專案還會用嗎？」答是 → 全域；答否 → 專案級。
