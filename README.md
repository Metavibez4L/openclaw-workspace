# OpenClaw Workspace

A personalized OpenClaw agent workspace with custom skills and configurations.

## Overview

This repository contains a custom OpenClaw agent configuration including:
- **Agent identity and personality** defined in `SOUL.md` and `IDENTITY.md`
- **User context** stored in `USER.md`
- **Memory management** via daily logs and long-term memory
- **Custom skills** for extending agent capabilities

## Project Structure

```
.
├── AGENTS.md           # Workspace guidelines and conventions
├── SOUL.md            # Agent personality and behavior
├── IDENTITY.md        # Agent identity (name, creature, emoji)
├── USER.md            # User preferences and context
├── TOOLS.md           # Local environment notes
├── BOOTSTRAP.md       # First-run guide (safe to delete after setup)
├── HEARTBEAT.md       # Periodic task checklist
├── memory/            # Daily conversation logs (YYYY-MM-DD.md)
├── skills/            # Custom OpenClaw skills
│   ├── github/        # GitHub CLI integration
│   ├── sonoscli/      # Sonos speaker control
│   ├── self-edit/     # Self-modifying skill demo
│   ├── self-evolve/   # Self-evolving skill with backup/restore
│   ├── agent-factory/ # (empty - skill template)
│   └── swarm/         # (empty - skill template)
└── README.md          # This file
```

## Skills Included

### 🔧 github
Interact with GitHub using the `gh` CLI.

**Quick examples:**
```bash
# Check PR CI status
gh pr checks 55 --repo owner/repo

# List recent workflow runs
gh run list --repo owner/repo --limit 10

# View failed run logs
gh run view <run-id> --repo owner/repo --log-failed

# API queries with JSON filtering
gh api repos/owner/repo/pulls/55 --jq '.title, .state, .user.login'
```

### 🔊 sonoscli
Control Sonos speakers on your local network.

**Quick examples:**
```bash
# Discover speakers
sonos discover

# Control playback
sonos play --name "Kitchen"
sonos pause --name "Kitchen"
sonos volume set 25 --name "Kitchen"

# Group management
sonos group party  # Group all speakers
sonos group solo   # Ungroup all

# Favorites and queue
sonos favorites list
sonos queue list
```

### 📝 self-edit
Demonstrates self-modifying automation. The skill can edit its own `SKILL.md` file.

**Commands:**
- `/self-edit append <text>` - Append text to SKILL.md
- `/self-edit replace <old> <new>` - Replace text in SKILL.md

### 🔄 self-evolve
Self-evolving skill with backup and restore capabilities.

**Commands:**
- `/self-evolve show` - Display current SKILL.md
- `/self-evolve append <text>` - Append content
- `/self-evolve replace <old> <new>` - Replace content
- `/self-evolve list-backups` - Show available backups
- `/self-evolve restore-backup <timestamp>` - Restore from backup

## Setup Instructions

### Prerequisites
- [OpenClaw](https://github.com/openclaw/openclaw) installed
- Node.js 22+ (for running the agent)
- Git (for skill management)

### Installation

1. **Clone this workspace:**
   ```bash
git clone <repository-url> ~/.openclaw/workspace
   cd ~/.openclaw/workspace
   ```

2. **Install skill dependencies:**
   
   For GitHub skill:
   ```bash
   # Install GitHub CLI
   # macOS: brew install gh
   # Ubuntu: sudo apt install gh
   # Then authenticate: gh auth login
   ```
   
   For Sonos skill:
   ```bash
   go install github.com/steipete/sonoscli/cmd/sonos@latest
   ```

3. **Configure the agent:**
   - Edit `IDENTITY.md` - Set your agent's name, creature type, vibe, and emoji
   - Edit `USER.md` - Add your name, timezone, and preferences
   - Review `SOUL.md` - Adjust personality and behavior guidelines

4. **Start the agent:**
   ```bash
   openclaw
   ```

## Usage Examples

### Basic Agent Interaction
```bash
# Start a chat session
openclaw chat

# Run a specific skill
openclaw skill github --help
openclaw skill sonoscli discover
```

### Managing Memory

The agent maintains two types of memory:

1. **Daily logs** - Auto-created in `memory/YYYY-MM-DD.md`
   - Raw conversation history
   - Decisions and context from each session

2. **Long-term memory** - Curated in `MEMORY.md`
   - Important lessons, preferences, ongoing projects
   - Review periodically and update from daily logs

### Creating New Skills

To add a new skill:

1. Create a directory under `skills/`:
   ```bash
   mkdir skills/my-skill
   ```

2. Add a `SKILL.md` with metadata:
   ```yaml
   ---
   name: my-skill
   description: What this skill does
   ---
   
   # Documentation here
   ```

3. (Optional) Add executable scripts

### Working with Git

Since this is a git repository, commit your changes:

```bash
# Add new skills or config changes
git add skills/my-new-skill/
git commit -m "Add my-new-skill for X purpose"

# Push to remote
git push origin main
```

## Configuration Files Reference

| File | Purpose | Edit? |
|------|---------|-------|
| `AGENTS.md` | Workspace guidelines | Read-only reference |
| `SOUL.md` | Agent personality | Yes - customize behavior |
| `IDENTITY.md` | Agent metadata (name, emoji) | Yes - fill in during setup |
| `USER.md` | User information | Yes - add your details |
| `TOOLS.md` | Environment notes | Yes - add your device info |
| `HEARTBEAT.md` | Periodic tasks | Yes - customize checks |
| `BOOTSTRAP.md` | First-run guide | Delete after setup |

## Safety & Privacy

- **Private data stays in this workspace** - Never expose tokens, keys, or personal info
- **Review before external actions** - The agent asks before sending emails, tweets, etc.
- **Group chat awareness** - MEMORY.md is NOT loaded in shared contexts for security
- **Use `trash` over `rm`** - Recoverable beats gone forever

## Resources

- [OpenClaw Docs](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Skill Hub](https://clawhub.com)
- [Discord Community](https://discord.com/invite/clawd)

---

*This workspace evolves over time. Update these files as you and your agent learn and grow.*
