#!/bin/bash
# Briefing Skill — Context Curator / State Keeper
# Generates situation reports so you wake up oriented, not lost.
# No LLM tokens burned — pure bash.
set -e

# ── Paths ──────────────────────────────────────────────────────────
WORKSPACE="$HOME/.openclaw/workspace"
SITREP="$WORKSPACE/SITREP.md"
MEMORY="$WORKSPACE/MEMORY.md"
XMETAV="$HOME/XmetaV"
REPOS=("$XMETAV" "$HOME/basedintern" "$HOME/akua")
REPO_NAMES=("XmetaV" "basedintern" "akua")

# ── Supabase (optional — graceful if missing) ─────────────────────
ENV_FILE="$XMETAV/dashboard/bridge/.env"
if [ -f "$ENV_FILE" ]; then
  export $(grep -E '^(SUPABASE_URL|SUPABASE_SERVICE_ROLE_KEY)=' "$ENV_FILE" 2>/dev/null | xargs) 2>/dev/null || true
fi

supa_query() {
  local table="$1" select="$2" filter="${3:-}" limit="${4:-5}"
  if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo "[]"
    return 0
  fi
  local url="$SUPABASE_URL/rest/v1/$table?select=$select&order=created_at.desc&limit=$limit"
  [ -n "$filter" ] && url="$url&$filter"
  curl -sS "$url" \
    -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Accept: application/json" 2>/dev/null || echo "[]"
}

# ── Helpers ────────────────────────────────────────────────────────
now_utc() { date -u '+%Y-%m-%d %H:%M UTC'; }
divider() { echo ""; echo "---"; echo ""; }
section() { echo "## $1"; echo ""; }

git_status_for() {
  local dir="$1" name="$2"
  if [ ! -d "$dir/.git" ]; then
    echo "  $name — not a git repo"
    return
  fi
  cd "$dir"
  local branch dirty ahead behind last_msg last_time status_line
  branch=$(git branch --show-current 2>/dev/null || echo "???")
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "?")
  behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "?")
  last_msg=$(git log -1 --format='%s' 2>/dev/null || echo "no commits")
  last_time=$(git log -1 --format='%ar' 2>/dev/null || echo "unknown")

  status_line="  **$name** (\`$branch\`)"
  if [ "$dirty" -gt 0 ]; then
    status_line="$status_line — $dirty uncommitted"
  else
    status_line="$status_line — clean"
  fi
  if [ "$ahead" != "?" ] && [ "$ahead" -gt 0 ]; then
    status_line="$status_line, $ahead ahead"
  fi
  if [ "$behind" != "?" ] && [ "$behind" -gt 0 ]; then
    status_line="$status_line, $behind behind"
  fi
  echo "$status_line"
  echo "  Last: \"$last_msg\" ($last_time)"
}

recent_commits_for() {
  local dir="$1" name="$2" hours="${3:-24}"
  if [ ! -d "$dir/.git" ]; then return; fi
  cd "$dir"
  local since commits total
  since=$(date -u -d "$hours hours ago" '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -u '+%Y-%m-%dT00:00:00')
  commits=$(git log --since="$since" --oneline 2>/dev/null || true)
  if [ -n "$commits" ]; then
    echo "**$name** (last ${hours}h):"
    echo "$commits" | head -10 | while read -r line; do
      echo "  - $line"
    done
    total=$(echo "$commits" | wc -l | tr -d ' ')
    [ "$total" -gt 10 ] && echo "  ... and $((total - 10)) more"
    echo ""
  fi
}

# ── Command: sitrep ────────────────────────────────────────────────
do_sitrep() {
  {
    echo "# SITREP — Situation Report"
    echo ""
    echo "_Generated: $(now_utc)_"
    echo ""
    echo "> Read this first. It's your memory."

    divider
    section "Repos"

    for i in "${!REPOS[@]}"; do
      git_status_for "${REPOS[$i]}" "${REPO_NAMES[$i]}"
      echo ""
    done

    divider
    section "Recent Commits (24h)"

    local has_commits=false
    for i in "${!REPOS[@]}"; do
      local result
      result=$(recent_commits_for "${REPOS[$i]}" "${REPO_NAMES[$i]}" 24)
      if [ -n "$result" ]; then
        echo "$result"
        has_commits=true
      fi
    done
    if [ "$has_commits" = "false" ]; then
      echo "_No commits in the last 24 hours._"
      echo ""
    fi

    divider
    section "Dashboard & Bridge"

    if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_SERVICE_ROLE_KEY" ]; then
      # Bridge heartbeat
      local hb
      hb=$(supa_query "agent_sessions" "agent_id,status,last_heartbeat" "agent_id=eq.bridge" 1)
      echo "$hb" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data and len(data) > 0:
        from datetime import datetime, timezone
        hb_str = data[0].get('last_heartbeat', '')
        status = data[0].get('status', 'unknown')
        if hb_str:
            hb_time = datetime.fromisoformat(hb_str.replace('Z', '+00:00'))
            age = (datetime.now(timezone.utc) - hb_time).total_seconds()
            if age < 120:
                print(f'  Bridge: **online** (heartbeat {int(age)}s ago)')
            else:
                print(f'  Bridge: **stale** (last heartbeat {int(age/60)}m ago)')
        else:
            print(f'  Bridge: {status}')
    else:
        print('  Bridge: no heartbeat data')
except:
    print('  Bridge: (could not parse)')
" 2>/dev/null || echo "  Bridge: (could not query)"

      # Active commands
      local active active_count
      active=$(supa_query "agent_commands" "id,agent_id,message,status" "status=in.(pending,running)" 10)
      active_count=$(echo "$active" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d) if isinstance(d,list) else 0)" 2>/dev/null || echo "?")
      echo "  Active commands: $active_count"

      if [ "$active_count" != "0" ] && [ "$active_count" != "?" ]; then
        echo "$active" | python3 -c "
import sys, json
for cmd in json.load(sys.stdin):
    aid = cmd.get('agent_id','?')
    msg = cmd.get('message','')[:60]
    st = cmd.get('status','?')
    print(f'    - [{st}] {aid}: {msg}')
" 2>/dev/null || true
      fi

      # Pending swarm runs
      local swarms swarm_count
      swarms=$(supa_query "swarm_runs" "id,name,mode,status" "status=in.(pending,running)" 5)
      swarm_count=$(echo "$swarms" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d) if isinstance(d,list) else 0)" 2>/dev/null || echo "0")
      echo "  Pending/running swarms: $swarm_count"
    else
      echo "  (Supabase not configured — skipping dashboard checks)"
    fi

    echo ""

    divider
    section "Memory (Recent)"

    if [ -f "$MEMORY" ]; then
      local mem_lines
      mem_lines=$(wc -l < "$MEMORY" | tr -d ' ')
      echo "_${mem_lines} lines in MEMORY.md — showing recent:_"
      echo ""
      echo '```'
      tail -20 "$MEMORY"
      echo '```'
    else
      echo "_No MEMORY.md found. Run \`briefing distill\` to start one._"
    fi

    echo ""

    divider
    section "In-Flight / Blocked"

    echo "_Review and update manually:_"
    echo ""
    echo "- [ ] _(add items that are in progress)_"
    echo "- [ ] _(add items that are blocked)_"
    echo ""
    echo "> Tip: Edit this section directly in SITREP.md to track your state between sessions."

    divider

    echo "_End of SITREP. Generated by \`briefing sitrep\`. Re-run anytime._"

  } > "$SITREP"

  cat "$SITREP"
  echo ""
  echo "--- Written to: $SITREP ---"
}

# ── Command: quick ─────────────────────────────────────────────────
do_quick() {
  echo "=== QUICK BRIEFING — $(now_utc) ==="
  echo ""
  for i in "${!REPOS[@]}"; do
    git_status_for "${REPOS[$i]}" "${REPO_NAMES[$i]}"
  done
  echo ""
  if [ -f "$MEMORY" ]; then
    echo "--- Last 5 memory entries ---"
    tail -5 "$MEMORY"
  fi
  echo ""
  echo "Run 'briefing sitrep' for full report."
}

# ── Command: commits ───────────────────────────────────────────────
do_commits() {
  local hours="${1:-24}"
  echo "=== COMMITS (last ${hours}h) — $(now_utc) ==="
  echo ""
  for i in "${!REPOS[@]}"; do
    recent_commits_for "${REPOS[$i]}" "${REPO_NAMES[$i]}" "$hours"
  done
}

# ── Command: health ────────────────────────────────────────────────
do_health() {
  echo "=== HEALTH CHECK — $(now_utc) ==="
  echo ""

  # Git repos
  for i in "${!REPOS[@]}"; do
    local dir="${REPOS[$i]}" name="${REPO_NAMES[$i]}"
    if [ -d "$dir/.git" ]; then
      cd "$dir"
      local dirty
      dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      if [ "$dirty" -eq 0 ]; then
        echo "[OK]  $name — clean"
      else
        echo "[!!]  $name — $dirty uncommitted files"
      fi
    else
      echo "[--]  $name — not a git repo"
    fi
  done

  echo ""

  # Dashboard
  if curl -sS --max-time 3 http://localhost:3000 > /dev/null 2>&1; then
    echo "[OK]  Dashboard — running on :3000"
  else
    echo "[--]  Dashboard — not reachable"
  fi

  # Ollama
  if curl -sS --max-time 3 http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
    echo "[OK]  Ollama — running"
  else
    echo "[--]  Ollama — not reachable"
  fi

  # Gateway
  if command -v openclaw &>/dev/null && openclaw health > /dev/null 2>&1; then
    echo "[OK]  Gateway — healthy"
  else
    echo "[--]  Gateway — not healthy or openclaw not found"
  fi

  # Supabase
  if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    local test
    test=$(supa_query "agent_sessions" "agent_id" "" 1)
    if [ "$test" != "[]" ] && [ -n "$test" ]; then
      echo "[OK]  Supabase — connected"
    else
      echo "[--]  Supabase — no data or error"
    fi
  else
    echo "[--]  Supabase — not configured"
  fi
}

# ── Command: distill ───────────────────────────────────────────────
do_distill() {
  echo "=== MEMORY DISTILL — $(now_utc) ==="
  echo ""

  # Ensure MEMORY.md exists
  if [ ! -f "$MEMORY" ]; then
    cat > "$MEMORY" << 'MEMEOF'
# MEMORY.md — Long-Term Memory

_Auto-maintained by `briefing distill`. Append-only._

---

MEMEOF
    echo "Created MEMORY.md"
  fi

  # Gather recent commits as memory entries
  local entry_date new_entries=""
  entry_date=$(date -u '+%Y-%m-%d')

  for i in "${!REPOS[@]}"; do
    local dir="${REPOS[$i]}" name="${REPO_NAMES[$i]}"
    if [ ! -d "$dir/.git" ]; then continue; fi
    cd "$dir"
    local since commits
    since=$(date -u -d "48 hours ago" '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -u '+%Y-%m-%dT00:00:00')
    commits=$(git log --since="$since" --format='%s' 2>/dev/null | head -10 || true)
    if [ -n "$commits" ]; then
      while IFS= read -r msg; do
        new_entries="${new_entries}
- [$name] $msg"
      done <<< "$commits"
    fi
  done

  if [ -n "$new_entries" ]; then
    # Check if today's header already exists
    if ! grep -q "### $entry_date" "$MEMORY" 2>/dev/null; then
      {
        echo ""
        echo "### $entry_date"
        echo "$new_entries"
      } >> "$MEMORY"
      echo "Added entries for $entry_date to MEMORY.md"
    else
      echo "Entries for $entry_date already exist — skipping"
    fi
  else
    echo "No new activity to distill"
  fi

  # Show tail of memory
  echo ""
  echo "--- Recent memory ---"
  tail -15 "$MEMORY"
}

# ── Routing ────────────────────────────────────────────────────────
COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
  sitrep)   do_sitrep ;;
  quick)    do_quick ;;
  commits)  do_commits "$@" ;;
  health)   do_health ;;
  distill)  do_distill ;;
  help|--help|-h)
    cat << 'EOF'
Briefing Skill — Context Curator

Commands:
  briefing sitrep          Full situation report -> SITREP.md + stdout
  briefing quick           Compact summary (stdout only)
  briefing commits [hrs]   Recent commits across all repos (default: 24h)
  briefing health          System health check (git, dashboard, ollama, gateway)
  briefing distill         Distill recent activity into MEMORY.md

Files:
  SITREP.md    — Live situation report (overwritten each run)
  MEMORY.md    — Long-term memory (append-only)

Wake-up protocol:
  1. Read SITREP.md
  2. If stale, run: briefing sitrep
  3. Proceed with task
EOF
    ;;
  *)
    echo "Unknown command: $COMMAND" >&2
    echo "Run 'briefing help' for usage." >&2
    exit 1
    ;;
esac
