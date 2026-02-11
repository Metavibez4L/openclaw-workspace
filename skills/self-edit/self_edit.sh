#!/bin/bash
# Usage: ./self_edit.sh append <text>
#        ./self_edit.sh replace <old> <new>
SKILL_MD="$(dirname "$0")/SKILL.md"
if [[ "$1" == "append" ]]; then
  shift
  echo "$*" >> "$SKILL_MD"
  echo "Appended to SKILL.md."
elif [[ "$1" == "replace" ]]; then
  old="$2"; new="$3"
  sed -i "s/${old}/${new}/g" "$SKILL_MD"
  echo "Replaced '$old' with '$new' in SKILL.md."
else
  echo "Usage: $0 append <text> | replace <old> <new>"
  exit 1
fi
