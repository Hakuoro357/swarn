# Swarn Orchestrator — Спецификация

## Обзор
Система мульти-агентной разработки игр с DAG-оркестратором, управляющим зависимостями между этапами и обеспечивающим параллельное выполнение задач.

## Архитектура

### 4-стадийный конвейер

```
┌─────────────────────────────────────────────────────────────────────┐
│                        STAGE 1: КОНЦЕПТ                             │
│  ┌──────────────┐    dependency    ┌──────────────────────┐         │
│  │ Market       │ ───────────────▶ │ Game Concept         │         │
│  │ Analyst      │                  │ Designer             │         │
│  └──────────────┘                  └──────────────────────┘         │
│         │                                     │                     │
│         └──────────── ▶ GDD ◀ ───────────────┘                     │
└─────────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     STAGE 2: АРХИТЕКТУРА                            │
│  ┌──────────────────────────────────────────────────────┐           │
│  │  Game Architect                                      │           │
│  │  Вход: GDD                                           │           │
│  │  Выход: Technical Spec                               │           │
│  └──────────────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│              STAGE 3: ПАРАЛЛЕЛЬНАЯ РАЗРАБОТКА (5-6)                 │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐       │
│  │ Game       │ │ UI/UX      │ │ Level      │ │ Audio      │       │
│  │ Developer  │ │ Designer   │ │ Designer   │ │ Engineer   │       │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘       │
│  ┌────────────┐ ┌────────────┐                                     │
│  │ Asset      │ │ (доп. по   │                                     │
│  │ Manager    │ │  мере)     │                                     │
│  └────────────┘ └────────────┘                                     │
│                                                                     │
│  Все агенты получают: Technical Spec                                │
│  Выход: Game Build (объединённый)                                   │
└─────────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│               STAGE 4: КАЧЕСТВО И ОПТИМИЗАЦИЯ                       │
│  ┌────────────┐    dependency    ┌──────────────────────┐           │
│  │ QA Tester  │ ───────────────▶ │ Performance          │           │
│  │            │                  │ Profiler             │           │
│  └────────────┘                  └──────────────────────┘           │
│         │                                     │                     │
│         └────── ▶ Test Reports ◀ ────────────┘                     │
└─────────────────────────────────────────────────────────────────────┘
```

## DAG-Конфигурация

### Узлы (Nodes)
| ID | Агент | Стадия | Входные артефакты | Выходные артефакты |
|----|-------|--------|-------------------|---------------------|
| N1 | Market Analyst | 1 | - | market-analysis.json |
| N2 | Game Concept Designer | 1 | market-analysis.json | gdd.md |
| N3 | Game Architect | 2 | gdd.md | technical-spec.md |
| N4 | Game Developer | 3 | technical-spec.md | src/ |
| N5 | UI/UX Designer | 3 | technical-spec.md | ui/ |
| N6 | Level Designer | 3 | technical-spec.md | levels/ |
| N7 | Audio Engineer | 3 | technical-spec.md | audio/ |
| N8 | Asset Manager | 3 | technical-spec.md | assets/ |
| N9 | QA Tester | 4 | game-build/ | test-reports.md |
| N10 | Performance Profiler | 4 | test-reports.md, game-build/ | perf-report.md |

### Рёбра (Dependencies)
```
N1 → N2  (Market Analysis → Concept)
N2 → N3  (GDD → Architecture)
N3 → N4  (Tech Spec → Developer)
N3 → N5  (Tech Spec → UI/UX)
N3 → N6  (Tech Spec → Level Design)
N3 → N7  (Tech Spec → Audio)
N3 → N8  (Tech Spec → Assets)
N4 → N9  (Build → QA)
N5 → N9  (UI → QA)
N6 → N9  (Levels → QA)
N7 → N9  (Audio → QA)
N8 → N9  (Assets → QA)
N9 → N10 (Test Reports → Profiling)
```

### Параллельные группы
- **Group A (Stage 3)**: N4, N5, N6, N7, N8 — запускаются параллельно (5 задач)
- **Group B (Stage 4)**: N10 ждёт завершения N9

## Система артефактов

### Директория: `/artifacts/`
```
artifacts/
├── stage-1/
│   ├── market-analysis.json      # Анализ рынка и конкурентов
│   └── gdd.md                    # Game Design Document
├── stage-2/
│   └── technical-spec.md         # Техническая спецификация
├── stage-3/
│   ├── src/                      # Исходный код
│   ├── ui/                       # Интерфейсы
│   ├── levels/                   # Уровни
│   ├── audio/                    # Аудио
│   └── assets/                   # Ассеты
├── stage-4/
│   ├── test-reports.md           # Отчёты QA
│   └── perf-report.md            # Отчёт производительности
└── final/
    └── game-build/               # Финальная сборка
```

## Мониторинг и логирование

### Директория: `/logs/`
```
logs/
├── orchestrator.log              # Основной лог оркестратора
├── agents/
│   ├── market-analyst.log
│   ├── game-concept-designer.log
│   ├── game-architect.log
│   ├── game-developer.log
│   ├── ui-ux-designer.log
│   ├── level-designer.log
│   ├── audio-engineer.log
│   ├── asset-manager.log
│   ├── qa-tester.log
│   └── performance-profiler.log
└── artifacts/
    └── artifact-chain.json       # Цепочка создания артефактов
```

### Формат лога агента
```json
{
  "timestamp": "2026-04-15T10:30:00Z",
  "agent": "market-analyst",
  "node_id": "N1",
  "event": "start|progress|complete|error",
  "message": "Начало анализа рынка...",
  "artifact": null,
  "metadata": {
    "stage": 1,
    "parallel_group": null,
    "dependencies_met": []
  }
}
```

### Статусы агентов
- `pending` — ожидает зависимости
- `queued` — добавлен в очередь на запуск
- `running` — выполняется
- `paused` — приостановлен (ожидает ресурс)
- `completed` — успешно завершён
- `failed` — ошибка с описанием
- `retrying` — повторная попытка (до 3 раз)

## Протоколы оркестратора

### Запуск пайплайна
1. Прочитать DAG из конфигурации
2. Найти узлы без зависимостей (N1)
3. Запустить N1 (Market Analyst)
4. По завершении N1 → разблокировать N2
5. Запустить N2 (Game Concept Designer)
6. По завершении N2 → разблокировать N3
7. Запустить N3 (Game Architect)
8. По завершении N3 → запустить параллельную группу (N4-N8)
9. Дождаться всех из группы → объединить артефакты
10. Запустить N9 (QA Tester)
11. По завершении N9 → запустить N10 (Performance Profiler)
12. Финализация: собрать все отчёты

### Обработка ошибок
- **3-Failure Circuit Breaker**: После 3 провалов узла → остановка пайплайна
- **Retry Logic**: Автоматический повтор с увеличенным timeout
- **Error Escalation**: При критической ошибке → уведомление + сохранение состояния
- **Rollback**: Возможность отката к предыдущей стабильной версии артефакта

### Контрольные точки (Checkpoints)
После каждой стадии оркестратор сохраняет checkpoint:
```json
{
  "checkpoint": "stage-2-complete",
  "timestamp": "2026-04-15T12:00:00Z",
  "completed_nodes": ["N1", "N2", "N3"],
  "artifacts": {
    "gdd": "artifacts/stage-1/gdd.md",
    "technical_spec": "artifacts/stage-2/technical-spec.md"
  },
  "next_nodes": ["N4", "N5", "N6", "N7", "N8"]
}
```

## Интерфейс управления

### Команды оркестратора
```
/orchestrator start              — Запуск полного пайплайна
/orchestrator start --from N3    — Запуск с конкретного узла
/orchestrator status             — Текущий статус всех узлов
/orchestrator status N4          — Статус конкретного узла
/orchestrator pause              — Пауза пайплайна
/orchestrator resume             — Возобновление
/orchestrator retry N4           — Повтор узла
/orchestrator logs N4            — Логи конкретного агента
/orchestrator artifacts          — Список созданных артефактов
/orchestrator checkpoint list    — Список чекпоинтов
/orchestrator checkpoint restore <id> — Откат к чекпоинту
```

## Интеграция с Qwen Code агентами

Каждый агент описан в `.qwen/agents/<name>.md` и содержит:
- **Роль и зону ответственности**
- **Входные данные** (какие артефакты ожидает)
- **Выходные данные** (какие артефакты создаёт)
- **Специфичные инструкции** для задачи
- **Ссылки на навыки** (если использует .qwen/skills/)

Оркестратор вызывает агентов через `agent` tool с appropriate `subagent_type` и передаёт:
- Путь к входным артефактам
- Ожидаемые выходные артефакты
- Контекст из предыдущих стадий
