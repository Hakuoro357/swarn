# Система Самообучения — Спецификация

## Обзор
Система накопления и использования опыта в мульти-агентном пайплайне Swarn. Каждый успешный и неуспешный кейс записывается, классифицируется и автоматически используется при будущих задачах.

## Архитектура базы знаний

```
knowledge-base/
├── cases/                    # Записи конкретных кейсов
│   ├── success/              # Успешные кейсы
│   │   ├── CASE-001.md
│   │   └── ...
│   └── failure/              # Неуспешные кейсы
│       ├── FAIL-001.md
│       └── ...
├── patterns/                 # Успешные паттерны
│   ├── PATTERN-001.md
│   └── ...
├── anti-patterns/            # Антипаттерны (чего НЕ делать)
│   ├── ANTIPATTERN-001.md
│   └── ...
├── INDEX.md                  # Индекс всех записей
└── SEARCH.md                 # Алгоритм поиска релевантных записей
```

## Формат кейса успеха

```markdown
---
id: CASE-001
type: success
agent: game-developer
date: 2026-04-15
tags: [physics, collision, object-pool]
relevance_score: 9
---

# Контекст
Реализация системы столкновений с object pooling для пуль.

## Задача
Создать систему стрельбы с 100+ одновременными пулями без деградации FPS.

## Решение
Использовать Object Pool с pre-allocated буфером на 200 объектов.
[Описание реализации]

## Результат
- FPS: стабильные 60 при 200 пулях
- Memory: 12MB стабильно, нет GC spikes
- Draw calls: 8 (batched через atlas)

## Ключевые решения
1. Object Pool вместо new/destroy
2. Pre-warm при инициализации
3. Circular buffer для recycling

## Применимость
Применять для любых часто создаваемых/удаляемых объектов:
пули, частицы, враги, collectibles.
```

## Формат кейса неудачи

```markdown
---
id: FAIL-001
type: failure
agent: game-developer
date: 2026-04-15
tags: [memory-leak, event-listener]
severity: high
resolved: true
resolution: CASE-002
---

# Проблема
Memory leak при переключении уровней — рост heap на 15MB/level.

## Контекст
При переходе между уровнями память стабильно росла.

## Причина
EventBus listeners не отписывались при destroy сцены.

## Симптомы
- Heap growth: +15MB per level transition
- GC not reclaiming
- FPS stable but memory >200MB after 10 levels

## Решение
Добавить cleanup в Scene.destroy():
```typescript
destroy() {
  EventBus.offAll();  // отписка всех listeners
  super.destroy();
}
```

## Урок
ВСЕГДА отписывать EventBus listeners в destroy().
НИКОГДА не полагаться на garbage collection для event listeners.

## Предотвращение
Добавить в QA чеклист: memory leak test с 10+ level transitions.
```

## Формат паттерна

```markdown
---
id: PATTERN-001
name: Object Pool for Game Objects
category: performance
confidence: high
used_in_cases: [CASE-001, CASE-015, CASE-023]
---

# Object Pool Pattern

## Когда использовать
- Частое создание/удаление объектов (>10/сек)
- Объекты с коротким жизненным циклом
- Пули, частицы, эффекты, spawn/despawn enemies

## Реализация
[Код и примеры]

## Результаты в проектах
| Кейс | Объектов/сек | FPS до | FPS после |
|------|-------------|--------|-----------|
| CASE-001 | 200 | 38 | 60 |
| CASE-015 | 500 | 25 | 55 |

## Противопоказания
- Редко создаваемые объекты (singleton лучше)
- Постоянные объекты (просто оставить)
```

## Формат антипаттерна

```markdown
---
id: ANTIPATTERN-001
name: Creating Objects in Game Loop
category: performance
severity: critical
seen_in_failures: [FAIL-001, FAIL-007]
---

# Создание объектов в game loop

## Описание
```typescript
// ПЛОХО — new каждый кадр
update() {
  const bullet = new Bullet();  // GC nightmare
  const event = { type: 'hit' }; // object allocation
}
```

## Почему плохо
- Allocation в game loop → GC pressure
- GC pauses → frame drops
- Memory fragmentation over time

## Что делать вместо этого
```typescript
// ХОРОШО — object pool
update() {
  const bullet = BulletPool.acquire();
  // ...
  BulletPool.release(bullet);
}
```

## Затронутые кейсы
- FAIL-001: FPS drop с 60 до 30 при стрельбе
- FAIL-007: GC pauses 50ms каждые 2 секунды
```

## Механизм самообучения

### 1. Запись кейса (Post-Task)
После завершения каждого узла:
- Оркестратор анализирует результат
- Если успех → создаёт CASE-XXX.md в success/
- Если провал → создаёт FAIL-XXX.md в failure/
- Извлекает паттерны/антипаттерны

### 2. Извлечение уроков (Learning Agent)
Отдельный Learning Agent анализирует:
- Повторяющиеся успехи → повышает confidence паттерна
- Повторяющиеся провалы → создаёт anti-pattern
- Связи между кейсами → обновляет INDEX.md

### 3. Использование опыта (Pre-Task)
Перед запуском агента:
- Поиск релевантных кейсов по tags + agent type
- Чтение top-3 success cases (применить паттерны)
- Чтение top-3 failure cases (избежать ошибок)
- Передача контекста агенту через prompt

### 4. Ранжирование релевантности

```
relevance_score = 
  tag_match_weight * 0.4 +
  agent_type_match * 0.3 +
  recency_weight * 0.15 +
  confidence_weight * 0.15
```

## Интеграция с Orchestrator

### Pre-Task Hook
```
Before launching agent N4 (Game Developer):
1. Search knowledge-base for tags: [gameplay, physics, etc.]
2. Load top-3 success cases → append to agent prompt
3. Load top-3 failure cases → append as "AVOID" warnings
4. Launch agent with enriched context
```

### Post-Task Hook
```
After agent N4 completes:
1. Analyze output (test results, perf metrics)
2. If tests pass + perf OK → success case
3. If tests fail or perf bad → failure case
4. Extract patterns → update knowledge-base
5. Run Learning Agent to consolidate
```

## Learning Agent

Роль: Анализатор базы знаний
- Периодически запускается (после каждого stage)
- Агрегирует новые кейсы
- Обновляет confidence scores
- Создаёт/обновляет паттерны и антипаттерны
- Поддерживает актуальность INDEX.md

## INDEX.md формат

```markdown
# Knowledge Base Index

## Success Cases
| ID | Agent | Tags | Score | Date |
|----|-------|------|-------|------|

## Failure Cases
| ID | Agent | Tags | Severity | Resolved | Date |
|----|-------|------|----------|----------|------|

## Patterns
| ID | Name | Category | Confidence | Used In |
|----|------|----------|------------|---------|

## Anti-Patterns
| ID | Name | Category | Severity | Seen In |
|----|------|----------|----------|---------|
```

## Эволюция системы

### Фаза 1: Ручная запись
- Агенты (через orchestrator) записывают кейсы вручную
- Learning Agent агрегирует

### Фаза 2: Автоматическое извлечение
- Паттерны автоматически извлекаются из кода
- Anti-patterns детектятся по симптомам

### Фаза 3: Прогностическая
- По historical data предсказывает риски
- Рекомендует подходы до начала задачи
