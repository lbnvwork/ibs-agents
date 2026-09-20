#!/usr/bin/env bash
# Развёртывание настроек агентов (скиллы + правила) из репо ibs-agents.
# Создаёт симлинки: глобальные (~/.cline/skills) и проектные (ibs-*/.cline, .clinerules).
# Запуск из корня ibs-agents: ./setup.sh [--dry-run]
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(pwd)"
AGENTS_DIR="$(dirname "$ROOT")"   # /home/max/work/ibs/projects
DRY=0
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --only) ONLY="${2:-}"; shift ;;
  esac
  shift
done

# Скиллы, доступные всем агентам (глобальный ~/.cline/skills + все клоны).
GLOBAL_SKILLS=(git-workflow sync-env write-instruction)

# Per-role скиллы: роль → список (симлинкуются только в клон агента).
# Матрица «скилл × роль» — см. README.md.
declare -A ROLE_SKILLS=(
  [jan]="review-code status-briefing find-dead-code"
  [apr]="run-tests explain-db write-aquarium write-adr review-code find-dead-code"
  [feb]=""
  [may]="run-tests explain-db write-aquarium find-dead-code"
  [jun]="run-tests explain-db write-aquarium find-dead-code"
  [mar]="run-tests make-postman write-e2e-scenario"
  [jul]="run-tests release find-dead-code"
)

# Скиллы, ранее глобальные, теперь per-role — вычистить из ~/.cline/skills.
STALE_GLOBAL=(explain-db make-postman run-tests write-adr write-e2e-scenario)

declare -A AGENT_ROLE=(
  [ibs-pm-jan]=jan [ibs-analyst-feb]=feb [ibs-lead-apr]=apr
  [ibs-dev-may]=may [ibs-dev-jun]=jun [ibs-tester-mar]=mar [ibs-devops-jul]=jul
)

link() { if [ "$DRY" = 1 ]; then echo "  ln -sfn '$1' '$2'"; else ln -sfn "$1" "$2"; fi; }
copy() { if [ "$DRY" = 1 ]; then echo "  cp -f '$1' '$2'"; else rm -f "$2"; cp -f "$1" "$2"; fi; }

echo "== Глобальные (~/.cline/skills) =="
mkdir -p ~/.cline/skills
for s in "${STALE_GLOBAL[@]}"; do
  [ "$DRY" = 1 ] || rm -rf "$HOME/.cline/skills/$s"
done
for s in "${GLOBAL_SKILLS[@]}"; do
  [ "$DRY" = 1 ] || rm -rf "$HOME/.cline/skills/$s"
  link "$ROOT/skills/$s" "$HOME/.cline/skills/$s"
done

echo "== Проектные (ibs-*/.cline) =="
for agent in "${!AGENT_ROLE[@]}"; do
  role="${AGENT_ROLE[$agent]}"
  d="$AGENTS_DIR/$agent"
  [ -d "$d" ] || { echo "  SKIP $agent"; continue; }
  [ -n "$ONLY" ] && [ "$agent" != "$ONLY" ] && continue
  mkdir -p "$d/.cline" "$d/.clinerules"
  [ "$DRY" = 1 ] || rm -rf "$d/.cline/skills"
  mkdir -p "$d/.cline/skills"
  for s in "${GLOBAL_SKILLS[@]}"; do
    link "$ROOT/skills/$s" "$d/.cline/skills/$s"
  done
  for s in ${ROLE_SKILLS[$role]:-}; do
    link "$ROOT/skills/$s" "$d/.cline/skills/$s"
  done
  for f in "$ROOT"/clinerules/*.md; do
    copy "$f" "$d/.clinerules/$(basename "$f")"
  done
  copy "$ROOT/roles/$role/00-role.md" "$d/.clinerules/00-role.md"
  echo "  OK $agent ($role)"
done
echo "Готово."
