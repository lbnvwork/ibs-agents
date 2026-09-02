#!/usr/bin/env bash
# Развёртывание настроек агентов (скиллы + правила) из репо ibs-agents.
# Создаёт симлинки: глобальные (~/.cline/skills) и проектные (ibs-*/.cline, .clinerules).
# Запуск из корня ibs-agents: ./setup.sh [--dry-run]
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(pwd)"
AGENTS_DIR="$(dirname "$ROOT")"   # /home/max/work/ibs/projects
DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

GLOBAL_SKILLS=(explain-db git-workflow make-postman run-tests write-adr write-e2e-scenario write-instruction)
PROJECT_COMMON=(review-code sync-status write-aquarium)
STATUS_BRIEFING=status-briefing
NO_STATUS_BRIEFING="feb jul"

declare -A AGENT_ROLE=(
  [ibs-pm-jan]=jan [ibs-analyst-feb]=feb [ibs-lead-apr]=apr
  [ibs-dev-may]=may [ibs-dev-jun]=jun [ibs-tester-mar]=mar [ibs-devops-jul]=jul
)

link() { if [ "$DRY" = 1 ]; then echo "  ln -sfn '$1' '$2'"; else ln -sfn "$1" "$2"; fi; }

echo "== Глобальные (~/.cline/skills) =="
mkdir -p ~/.cline/skills
for s in "${GLOBAL_SKILLS[@]}"; do
  link "$ROOT/skills/$s" "$HOME/.cline/skills/$s"
done

echo "== Проектные (ibs-*/.cline) =="
for agent in "${!AGENT_ROLE[@]}"; do
  role="${AGENT_ROLE[$agent]}"
  d="$AGENTS_DIR/$agent"
  [ -d "$d" ] || { echo "  SKIP $agent"; continue; }
  mkdir -p "$d/.cline" "$d/.clinerules"
  [ "$DRY" = 1 ] || rm -rf "$d/.cline/skills"
  mkdir -p "$d/.cline/skills"
  for s in "${GLOBAL_SKILLS[@]}" "${PROJECT_COMMON[@]}"; do
    link "$ROOT/skills/$s" "$d/.cline/skills/$s"
  done
  if [[ "$NO_STATUS_BRIEFING" != *"$role"* ]]; then
    link "$ROOT/skills/$STATUS_BRIEFING" "$d/.cline/skills/$STATUS_BRIEFING"
  fi
  for f in "$ROOT"/clinerules/*.md; do
    link "$f" "$d/.clinerules/$(basename "$f")"
  done
  link "$ROOT/roles/$role/00-role.md" "$d/.clinerules/00-role.md"
  echo "  OK $agent ($role)"
done
echo "Готово."
