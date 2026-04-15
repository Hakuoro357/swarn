# Алгоритм поиска релевантных записей

## Вход
- `agent_type`: тип запускаемого агента (e.g., "game-developer")
- `task_tags`: теги текущей задачи (e.g., ["physics", "collision"])
- `max_results`: сколько записей вернуть (default: 3 success + 3 failure)

## Алгоритм

### 1. Загрузка候选 (candidates)
```
For each case in knowledge-base/cases/{success,failure}/:
  Parse frontmatter (tags, agent, date, score)
  Compute relevance_score(case)
  If relevance_score > threshold:
    Add to candidates
```

### 2. Расчёт релевантности
```python
def relevance_score(case, agent_type, task_tags):
    # Tag matching (40%)
    tag_matches = len(set(case.tags) & set(task_tags))
    tag_score = tag_matches / max(len(task_tags), 1)
    
    # Agent type matching (30%)
    agent_match = 1.0 if case.agent == agent_type else 0.3
    
    # Recency (15%) — newer cases slightly preferred
    days_old = (today - case.date).days
    recency = max(0, 1 - days_old / 365)  # 1 year decay
    
    # Confidence / quality (15%)
    confidence = case.relevance_score / 10.0  # for success
    confidence = 1.0 - (case.severity_score / 10.0)  # for failure
    
    return (
        0.4 * tag_score +
        0.3 * agent_match +
        0.15 * recency +
        0.15 * confidence
    )
```

### 3. Ранжирование и выборка
```
Sort candidates by relevance_score DESC
Return top max_results success + top max_results failure
```

### 4. Форматирование контекста
```markdown
## Relevant Experience for [Agent Type]

### Success Cases (apply these patterns)
[Top-3 success cases with full content]

### Failure Cases (avoid these mistakes)  
[Top-3 failure cases with full content]

### Active Patterns
[Relevant patterns from patterns/]

### Active Anti-Patterns
[Relevant anti-patterns from anti-patterns/]
```

## Выход
Markdown-блок, который добавляется к prompt агента перед запуском.

## Оптимизация
- Индексация по тегам для быстрого поиска
- Кэширование результатов для одинаковых task_tags
- Lazy load: сначала только frontmatter, full content по необходимости
