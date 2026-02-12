---
name: github
entry: github.sh
description: "Comprehensive GitHub CLI wrapper. Manage repos, issues, PRs, workflows, releases, gists, and more via the gh CLI."
---

# GitHub Skill

Full-featured GitHub CLI wrapper for managing repositories, issues, pull requests, CI/CD workflows, releases, and more.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GITHUB_TOKEN` | Optional | GitHub personal access token for authentication |
| `GH_REPO` | Optional | Default repository (format: `owner/repo`) |

## Quick Reference

```bash
# Issues
github issue list --repo owner/repo
github issue view 42 --repo owner/repo
github issue create --repo owner/repo --title "Bug" --body "Details..."

# Pull Requests
github pr list --repo owner/repo
github pr checks 55 --repo owner/repo
github pr merge 55 --repo owner/repo --squash

# CI/CD Workflows
github run list --repo owner/repo --limit 10
github run view 12345678 --repo owner/repo --log-failed
github run watch 12345678 --repo owner/repo

# Releases
github release list --repo owner/repo
github release create v1.0.0 --repo owner/repo --title "Version 1.0"

# Search
github search repos "topic:ai language:typescript"
github search code "function authenticate repo:owner/repo"
github search issues "is:open label:bug"
```

---

## Repository Commands

### View Repository Info
```bash
github repo view owner/repo
github repo view owner/repo --json name,description,stargazers_count
```

### List Your Repositories
```bash
github repo list
github repo list --limit 50 --source  # exclude forks
```

### Clone a Repository
```bash
github repo clone https://github.com/owner/repo
github repo clone owner/repo my-local-name
```

### Fork a Repository
```bash
github repo fork owner/repo
github repo fork owner/repo --clone --remote
```

---

## Issue Commands

### List Issues
```bash
github issue list --repo owner/repo
github issue list --repo owner/repo --state all --limit 20
github issue list --repo owner/repo --label bug --label "help wanted"
```

### View Issue Details
```bash
github issue view 42 --repo owner/repo
github issue view 42 --repo owner/repo --comments
```

### Create an Issue
```bash
github issue create --repo owner/repo
github issue create --repo owner/repo --title "Found a bug" --body "Description..."
github issue create --repo owner/repo --title "Bug" --label bug --assignee @me
```

### Manage Issues
```bash
github issue close 42 --repo owner/repo
github issue reopen 42 --repo owner/repo
github issue comment 42 --repo owner/repo "Thanks for reporting!"
```

---

## Pull Request Commands

### List PRs
```bash
github pr list --repo owner/repo
github pr list --repo owner/repo --state merged --limit 10
github pr list --repo owner/repo --author username
```

### View PR Details
```bash
github pr view 55 --repo owner/repo
github pr view 55 --repo owner/repo --json number,title,state,mergeStateStatus
```

### Check PR CI Status
```bash
github pr checks 55 --repo owner/repo
github pr checks 55 --repo owner/repo --json state,name
```

### Create a PR
```bash
github pr create --repo owner/repo
github pr create --repo owner/repo --title "Fix bug" --body "Description..."
github pr create --repo owner/repo --draft --base main
```

### Merge a PR
```bash
github pr merge 55 --repo owner/repo
github pr merge 55 --repo owner/repo --squash --delete-branch
github pr merge 55 --repo owner/repo --rebase --auto
```

### Review a PR
```bash
github pr review 55 --repo owner/repo --approve
github pr review 55 --repo owner/repo --request-changes --body "Needs work"
github pr review 55 --repo owner/repo --comment --body "Question about..."
```

### Checkout a PR Locally
```bash
github pr checkout 55 --repo owner/repo
github pr checkout 55 --repo owner/repo --branch pr-55
```

### View PR Diff
```bash
github pr diff 55 --repo owner/repo
github pr diff 55 --repo owner/repo --name-only
```

### Close a PR
```bash
github pr close 55 --repo owner/repo
github pr close 55 --repo owner/repo --delete-branch
```

---

## Workflow Commands

### List Recent Runs
```bash
github run list --repo owner/repo
github run list --repo owner/repo --workflow ci.yml --limit 20
```

### View Run Details
```bash
github run view 12345678 --repo owner/repo
github run view 12345678 --repo owner/repo --json conclusion,status
```

### View Run Logs
```bash
github run logs 12345678 --repo owner/repo
github run failed 12345678 --repo owner/repo  # Failed steps only
```

### Watch Run Progress
```bash
github run watch 12345678 --repo owner/repo
```

### Rerun or Cancel
```bash
github run rerun 12345678 --repo owner/repo
github run rerun 12345678 --repo owner/repo --failed  # Rerun failed jobs only
github run cancel 12345678 --repo owner/repo
```

---

## Release Commands

### List Releases
```bash
github release list --repo owner/repo
github release list --repo owner/repo --limit 10
```

### View a Release
```bash
github release view v1.0.0 --repo owner/repo
```

### Create a Release
```bash
github release create v1.0.0 --repo owner/repo
github release create v1.0.0 --repo owner/repo --title "Version 1.0" --notes "Changes..."
github release create v1.0.0 --repo owner/repo --generate-notes --prerelease
```

### Upload Assets
```bash
github release upload v1.0.0 --repo owner/repo ./dist/app.zip
```

### Download Release Assets
```bash
github release download v1.0.0 --repo owner/repo
```

---

## Gist Commands

### List Your Gists
```bash
github gist list
github gist list --limit 20 --public
```

### View a Gist
```bash
github gist view GIST_ID
github gist view GIST_ID --raw
```

### Create a Gist
```bash
github gist create file.txt
github gist create file.txt --public --desc "My snippet"
github gist create "*.md" --desc "Documentation snippets"
```

---

## Search Commands

### Search Repositories
```bash
github search repos "machine learning"
github search repos "topic:ai language:python stars:>1000"
github search repos "org:facebook react"
```

### Search Code
```bash
github search code "function authenticate"
github search code "TODO filename:main.go repo:owner/repo"
github search code "class User language:typescript"
```

### Search Issues
```bash
github search issues "is:open label:bug"
github search issues "created:>2024-01-01 repo:owner/repo"
github search issues "involves:username state:closed"
```

### Search Pull Requests
```bash
github search prs "is:open is:pr review:required"
github search prs "is:merged base:main author:username"
```

---

## API Commands

### Direct API Calls
```bash
github api repos/owner/repo/pulls/55
github api repos/owner/repo/issues --jq '.[].title'
github api repos/owner/repo/pulls/55 --method PATCH --field state=closed
```

### GraphQL Queries
```bash
github api-graphql 'query { viewer { login name } }'
```

### Common API Patterns

Get PR with specific fields:
```bash
github api repos/owner/repo/pulls/55 --jq '.title, .state, .user.login, .merged'
```

Get repository statistics:
```bash
github api repos/owner/repo --jq '.stargazers_count, .forks_count, .open_issues_count'
```

List collaborators:
```bash
github api repos/owner/repo/collaborators --jq '.[].login'
```

---

## Authentication Commands

### Check Status
```bash
github auth status
github whoami
```

### Login
```bash
github auth login
```

### Get Token
```bash
github auth token
```

### Check Rate Limits
```bash
github rate-limit
```

---

## JSON Output & Filtering

Most commands support `--json` for structured output and `--jq` for filtering:

```bash
# Get specific fields as JSON
github pr list --repo owner/repo --json number,title,author,state

# Filter and format with jq
github issue list --repo owner/repo --json number,title --jq '.[] | "#\(.number): \(.title)"'

# Complex jq filtering
github run list --repo owner/repo --json name,status,conclusion --jq '.[] | select(.conclusion=="failure") | .name'
```

---

## Tips & Best Practices

### Set Default Repository
Avoid typing `--repo` repeatedly:
```bash
export GH_REPO="owner/repo"
github pr list  # uses default repo
github issue list  # uses default repo
```

### Combine with Other Tools
```bash
# Get failing PRs
github pr list --repo owner/repo --json number,title,statusCheckRollup | jq '.[] | select(.statusCheckRollup[].state=="FAILURE")'

# Open PR in browser
github pr view 55 --repo owner/repo --web
```

### Common Workflows

**Review and merge a passing PR:**
```bash
github pr checks 55 --repo owner/repo && \
github pr review 55 --repo owner/repo --approve && \
github pr merge 55 --repo owner/repo --squash --delete-branch
```

**Quick bug fix workflow:**
```bash
github issue view 42 --repo owner/repo
github issue close 42 --repo owner/repo --comment "Fixed in PR #55"
```

**Monitor deployment:**
```bash
github run list --repo owner/repo --workflow deploy.yml --limit 1
github run watch <run-id> --repo owner/repo
```

---

## Help

```bash
github help              # Show all commands
github repo help         # Show repo subcommands
github issue help        # Show issue subcommands
github pr help           # Show PR subcommands
```
