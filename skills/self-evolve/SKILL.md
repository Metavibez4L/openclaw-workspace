---
name: self-evolve
description: Self-evolving demo skill — append/replace/backup/restore/list-backups.
metadata: {"clawdbot":{"requires":{"bins":["bash"]}}}
---

Use the embedded skill commands via OpenClaw or run the script directly:
- `/self-evolve show`
- `/self-evolve append <text>`
- `/self-evolve replace <old> <new>`
- `/self-evolve list-backups`
- `/self-evolve restore-backup <timestamp>`

If the embedded agent run triggers an LLM and fails, run the script directly:
`/home/manifest/.openclaw/workspace/skills/self-evolve/self_evolve.sh show`
