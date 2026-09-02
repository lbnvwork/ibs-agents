#!/usr/bin/env bash
# Cline hook: ПЕРЕД сжатием контекста (PreCompact) вставить КОРОТКИЙ конспект,
# чтобы после компрессии он попал в summary и агент не «забыл» ключевое.
# НЕ вешать на частые события (UserPromptSubmit/PostToolUse/TaskResume) — раздует контекст.
#
# Читает файл памяти текущего агента (по умолчанию <проект>/.cline/context.md),
# выводит additionalContext в JSON-формате Cline hooks.
#
# Использование (агент обновляет конспект через sync-env / команду «запомни»):
#   MEMORY_FILE=/путь/context.md ./context-summary.sh
set -uo pipefail

MEMORY_FILE="${MEMORY_FILE:-$PWD/.cline/context.md}"

if [ -f "$MEMORY_FILE" ]; then
  BODY="$(head -c 300 "$MEMORY_FILE") … (полный конспект: $MEMORY_FILE)"
else
  BODY="Конспект не найден ($MEMORY_FILE). Выполни скилл sync-env (команда «синхронизируйся»)."
fi

# экранируем для JSON (кавычки, бэкслэш, переводы строк)
BODY="${BODY//\\/\\\\}"
BODY="${BODY//\"/\\\"}"
BODY="${BODY//$'\n'/\\n}"

printf '{"hookSpecificOutput":{"hookEventName":"PreCompact","additionalContext":"%s"}}\n' "$BODY"
