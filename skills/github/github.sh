#!/bin/bash
# GitHub Skill Entrypoint

if [[ "$1" == "help" ]]; then
  echo "GitHub Skill: Use 'gh' CLI for issues, PRs, runs, and API queries."
  echo "Examples:"
  echo "  gh issue list --repo owner/repo"
  echo "  gh pr checks <pr-number> --repo owner/repo"
  echo "  gh run list --repo owner/repo --limit 10"
  echo "  gh api repos/owner/repo/pulls/<pr-number> --jq '.title, .state, .user.login'"
  exit 0
fi

echo "GitHub Skill: Unknown command. Try 'help'."
exit 1
