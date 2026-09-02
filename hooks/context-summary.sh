#!/usr/bin/env bash
# Cline hook: восстановить «конспект» в контекст агента — против забывчивости после компрессии.
# Подключить во вкладке Settings → Hooks на события: SessionStart и (если есть) PostCompact/AfterCompaction.
#
# Читает файл памяти текущего агента (по умолчанию <проект>/.cline/context.md),
# выводит additionalContext в JSON-формате Cline hooks.
#
# Использование (агент обновляет конспект через sync-env / команду «запомни»):
#   MEMORY_FILE=/путь/context.md ./context-summary.sh
set -uo pipefail

MEMORY_FILE="${MEMORY_FILE:-$PWD/.cline/context.md}"

if [ -f "$MEMORY_FILE" ]; then
  BODY="$(head -c 3000 "$MEMORY_FILE")"
else
  BODY="Конспект не найден ($MEMORY_FILE). Выполни скилл sync-env (команда «синхронизируйся»)."
fi

# экранируем для JSON (кавычки, бэкслэш, переводы строк)
BODY="${BODY//\\/\\\\}"
BODY="${BODY//\"/\\\"}"
BODY="${BODY//$'\n'/\\n}"

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$BODY"
