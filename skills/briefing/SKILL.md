---
name: briefing
entry: briefing.sh
description: "Generate a situation report (SITREP.md) with project health, git status, in-flight work, and distilled memory. Read this first every session."
---

# Briefing Skill — Context Curator

Your external hard drive. Generates a live situation report so you don't waste half a session figuring out where you left off.

## Commands

### Generate full situation report
```bash
briefing sitrep
```

Writes `~/.openclaw/workspace/SITREP.md` with:
- Timestamp and session info
- Git status across all repos (XmetaV, basedintern, akua)
- Open branches, uncommitted changes, recent commits
- Dashboard/bridge health (Supabase query)
- Active commands and pending swarm runs
- Distilled memory (last 48h from MEMORY.md)
- Blocked items and open TODOs

### Quick status (stdout only, no file write)
```bash
briefing quick
```

Prints a compact one-screen summary to stdout.

### Show recent commits across all repos
```bash
briefing commits [hours]
```

Default: last 24 hours. Shows commits across XmetaV, basedintern, akua.

### Check project health
```bash
briefing health
```

Checks git status, dashboard, bridge heartbeat, Supabase connectivity.

### Distill memory (move recent entries to long-term)
```bash
briefing distill
```

Scans daily logs and recent activity, appends important entries to `MEMORY.md`, archives old content.

## Output

SITREP is written to `~/.openclaw/workspace/SITREP.md` and also printed to stdout.

## Wake-Up Protocol

Add this to your session start routine:
```
1. Read SITREP.md first
2. If stale (>6h), run: briefing sitrep
3. Then proceed with the task
```

## Notes

- No LLM tokens burned — pure bash + git + curl
- Supabase credentials loaded from bridge `.env`
- Safe to run frequently (idempotent, overwrites SITREP.md)
- Memory distillation is append-only (never deletes from MEMORY.md)
