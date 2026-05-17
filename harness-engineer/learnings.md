# Skill Learnings — harness-engineer

> 記錄擴充或維護此 skill 時踩到的坑，供下次修改前參閱。

---

[2026-05-17] 新增範本時漏更新 manifest.json
- 情境：新增 `templates/backlog.md.tmpl`，同步更新了 SKILL.md / init-scaffold.ps1 / check-harness.ps1，但忘記在 manifest.json 補登
- 錯誤：主 commit 後才發現，需要第二個修補 commit
- 根因：manifest.json 不在修改範本的直覺心智清單內
- 規避規則：每次新增或刪除範本檔，必須同步更新 manifest.json 的 `files` 區塊；版本號一併升位
