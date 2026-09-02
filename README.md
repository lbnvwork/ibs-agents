# ibs-agents — настройки агентов

Единый источник настроек агентов (Cline): **скиллы + правила** вынесены из 7 клонов кода `ibs-*` сюда. Подключение — через **симлинки** (`setup.sh`), без git submodule и без дублирования.

## Структура
- `skills/` — 11 скиллов (единый исходник).
- `clinerules/` — общие правила `10-git … 50-dod` (6 файлов).
- `roles/<role>/00-role.md` — ролевой файл на каждого агента (7 ролей).
- `setup.sh` — развёртывание симлинков (глобальных + проектных).

## Уровни скиллов
| Категория | Скиллы | Куда | Кому |
|---|---|---|---|
| Глобальные (7) | explain-db, git-workflow, make-postman, run-tests, write-adr, write-e2e-scenario, write-instruction | `~/.cline/skills/` + `ibs-*/.cline/skills/` | всем |
| Проектные (3) | review-code, sync-status, write-aquarium | `ibs-*/.cline/skills/` | всем |
| Ролевые (1) | status-briefing | `ibs-*/.cline/skills/` | jan, apr, may, jun, mar (НЕ feb, jul) |

## Правила
- Общие `clinerules/10-git … 50-dod` — **копии** в каждый `ibs-*/.clinerules/` (Cline не следует симлинкам файлов — поэтому копии; синхронизируются `setup.sh`).
- Ролевой `roles/<role>/00-role.md` — **копия** в `ibs-*/.clinerules/00-role.md`.

## Регламенты
Регламенты остаются в `ibs-docs` (`docs/09-Служебное/Регламенты/`). Скиллы дают команду на их чтение (см. `git-workflow`, `sync-status`).

## Развёртывание
```bash
cd /home/max/work/ibs/projects/ibs-agents
./setup.sh            # применить
./setup.sh --dry-run  # показать, что изменится
```

## Обновление
Правка в `ibs-agents` → коммит (руководитель) → пуш (по отмашке). Скиллы (симлинки) видны агентам сразу. Правила (копии) — перезапустить `./setup.sh`, чтобы обновить копии у всех.
