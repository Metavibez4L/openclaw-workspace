#!/bin/bash
# GitHub Skill Entrypoint - Enhanced Version
# Provides comprehensive GitHub CLI wrapper functionality

set -e

COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
  help|--help|-h)
    cat << 'EOF'
GitHub Skill - Comprehensive gh CLI Wrapper

USAGE: github <command> [options]

REPOSITORY COMMANDS:
  repo view [owner/repo]          Show repository details
  repo list [--limit N]           List your repos
  repo clone <url> [dir]          Clone a repository
  repo fork <owner/repo>          Fork a repository

ISSUE COMMANDS:
  issue list [owner/repo]         List open issues
  issue view <number> [owner/repo] View issue details
  issue create [owner/repo]       Create a new issue (interactive)
  issue close <number> [owner/repo] Close an issue
  issue reopen <number> [owner/repo] Reopen an issue
  issue comment <number> [owner/repo] <text> Add comment

PR COMMANDS:
  pr list [owner/repo]            List open PRs
  pr view <number> [owner/repo]   View PR details
  pr checks <number> [owner/repo] View PR CI checks
  pr create [owner/repo]          Create PR from current branch
  pr merge <number> [owner/repo] [--squash|--rebase] Merge a PR
  pr close <number> [owner/repo]  Close a PR
  pr checkout <number> [owner/repo] Checkout PR locally
  pr review <number> [owner/repo] [--approve|--request-changes] Review PR

WORKFLOW COMMANDS:
  run list [owner/repo]           List recent workflow runs
  run view <id> [owner/repo]      View run details
  run logs <id> [owner/repo]      View run logs
  run failed <id> [owner/repo]    View failed step logs
  run watch <id> [owner/repo]     Watch run in real-time

RELEASE COMMANDS:
  release list [owner/repo]       List releases
  release view <tag> [owner/repo] View release details
  release create [owner/repo] <tag> Create release

GIST COMMANDS:
  gist list                       List your gists
  gist view <id>                  View a gist
  gist create <file> [--public]   Create a gist from file

SEARCH COMMANDS:
  search repos <query>            Search repositories
  search code <query>             Search code
  search issues <query>           Search issues
  search prs <query>              Search pull requests

API COMMANDS:
  api <endpoint> [--jq <filter>]  Make direct API calls
  api-graphql <query>             Make GraphQL queries

AUTH COMMANDS:
  auth status                     Check authentication status
  auth login                      Authenticate with GitHub
  auth logout                     Sign out

HELPERS:
  whoami                          Show current user
  rate-limit                      Check API rate limits

ENVIRONMENT:
  GITHUB_TOKEN                    Personal access token (optional)
  GH_REPO                         Default repository (owner/repo)

EXAMPLES:
  github pr checks 42 --repo myorg/myapp
  github issue list --repo owner/repo --limit 20
  github run view 12345678 --repo owner/repo --log-failed
  github api repos/kubernetes/kubernetes/pulls/1 --jq '.title, .state'
EOF
    ;;

  # Repository commands
  repo)
    SUBCMD="${1:-view}"
    shift || true
    case "$SUBCMD" in
      view) gh repo view "$@" ;;
      list) gh repo list --limit "${1:-30}" ;;
      clone) gh repo clone "$@" ;;
      fork) gh repo fork "$@" ;;
      *) echo "Unknown repo subcommand: $SUBCMD" >&2; exit 1 ;;
    esac
    ;;

  # Issue commands
  issue)
    SUBCMD="${1:-list}"
    shift || true
    case "$SUBCMD" in
      list) gh issue list "$@" ;;
      view) gh issue view "$@" ;;
      create) gh issue create "$@" ;;
      close) gh issue close "$@" ;;
      reopen) gh issue reopen "$@" ;;
      comment) 
        ISSUE="$1"
        shift
        gh issue comment "$ISSUE" --body "$@"
        ;;
      *) echo "Unknown issue subcommand: $SUBCMD" >&2; exit 1 ;;
    esac
    ;;

  # PR commands
  pr)
    SUBCMD="${1:-list}"
    shift || true
    case "$SUBCMD" in
      list) gh pr list "$@" ;;
      view) gh pr view "$@" ;;
      checks) gh pr checks "$@" ;;
      create) gh pr create "$@" ;;
      merge) gh pr merge "$@" ;;
      close) gh pr close "$@" ;;
      checkout) gh pr checkout "$@" ;;
      review) gh pr review "$@" ;;
      diff) gh pr diff "$@" ;;
      *) echo "Unknown pr subcommand: $SUBCMD" >&2; exit 1 ;;
    esac
    ;;

  # Workflow/run commands
  run)
    SUBCMD="${1:-list}"
    shift || true
    case "$SUBCMD" in
      list) gh run list "$@" ;;
      view) gh run view "$@" ;;
      logs) gh run view "$@" --logs ;;
      failed) gh run view "$@" --log-failed ;;
      watch) gh run watch "$@" ;;
      rerun) gh run rerun "$@" ;;
      cancel) gh run cancel "$@" ;;
      *) echo "Unknown run subcommand: $SUBCMD" >&2; exit 1 ;;
    esac
    ;;

  # Release commands
  release)
    SUBCMD="${1:-list}"
    shift || true
    case "$SUBCMD" in
      list) gh release list "$@" ;;
      view) gh release view "$@" ;;
      create) gh release create "$@" ;;
      delete) gh release delete "$@" ;;
      upload) gh release upload "$@" ;;
      download) gh release download "$@" ;;
      *) echo "Unknown release subcommand: $SUBCMD" >&2; exit 1 ;;
    esac
    ;;

  # Gist commands
  gist)
    SUBCMD="${1:-list}"
    shift || true
    case "$SUBCMD" in
      list) gh gist list "$@" ;;
      view) gh gist view "$@" ;;
      create) gh gist create "$@" ;;
      edit) gh gist edit "$@" ;;
      delete) gh gist delete "$@" ;;
      clone) gh gist clone "$@" ;;
      *) echo "Unknown gist subcommand: $SUBCMD" >&2; exit 1 ;;
    esac
    ;;

  # Search commands
  search)
    SUBCMD="${1:-repos}"
    shift || true
    case "$SUBCMD" in
      repos|repo|repositories) gh search repos "$@" ;;
      code) gh search code "$@" ;;
      issues|issue) gh search issues "$@" ;;
      prs|pr|pullrequests) gh search prs "$@" ;;
      commits|commit) gh search commits "$@" ;;
      *) echo "Unknown search subcommand: $SUBCMD" >&2; exit 1 ;;
    esac
    ;;

  # API commands
  api)
    gh api "$@"
    ;;

  api-graphql|graphql)
    gh api graphql -f query="$@"
    ;;

  # Auth commands
  auth)
    SUBCMD="${1:-status}"
    shift || true
    case "$SUBCMD" in
      status) gh auth status ;;
      login) gh auth login "$@" ;;
      logout) gh auth logout ;;
      token) gh auth token ;;
      refresh) gh auth refresh "$@" ;;
      *) echo "Unknown auth subcommand: $SUBCMD" >&2; exit 1 ;;
    esac
    ;;

  # Helper commands
  whoami)
    gh api user --jq '.login'
    ;;

  rate-limit)
    gh api rate_limit --jq '.resources'
    ;;

  # Alias for common quick commands
  status)
    gh auth status
    ;;

  # Unknown command
  *)
    echo "Unknown command: $COMMAND" >&2
    echo "Run 'github help' for usage information" >&2
    exit 1
    ;;
esac
