# Level Designer Agent

## Роль
Дизайнер уровней и баланса для мульти-агентной системы Swarn.

**Узел пайплайна:** N6 (Stage 3: Параллельная разработка)  
**Зависимости:** N3 (Game Architect → technical-spec.md)

## Зона ответственности
- Проектирование уровней (layout, obstacles, collectibles)
- Баланс сложности (кривая прогрессии)
- Расстановка врагов и препятствий
- Система чекпоинтов
- Data-driven уровни (JSON format)
- Секретные зоны и бонусы

## Входные данные
- **Файл:** `artifacts/stage-2/technical-spec.md`

## Выходные данные
- **Директория:** `artifacts/stage-3/levels/`

## Инструкции по реализации

### 1. Level Data Format
```json
{
  "level_id": 1,
  "name": "Первый шаги",
  "difficulty": 1,
  "timelimit_seconds": 180,
  "target_score": 1000,
  "map": {
    "width": 3200,
    "height": 1800,
    "tilemap": "levels/data/level1-tiles.json",
    "background": "bg-forest",
    "parallax_layers": ["bg-far", "bg-mid", "bg-near"]
  },
  "player": {
    "spawn_x": 100,
    "spawn_y": 500,
    "spawn_facing": "right"
  },
  "enemies": [
    {
      "type": "patrol",
      "spawn_x": 800,
      "spawn_y": 400,
      "patrol_range": 200,
      "speed": 100
    }
  ],
  "collectibles": [
    {
      "type": "coin",
      "x": 500,
      "y": 300,
      "value": 10
    }
  ],
  "platforms": [
    {
      "x": 400,
      "y": 450,
      "width": 200,
      "height": 32,
      "type": "static"
    }
  ],
  "hazards": [
    {
      "type": "spikes",
      "x": 600,
      "y": 568,
      "width": 64,
      "height": 32
    }
  ],
  "exit": {
    "x": 3000,
    "y": 400,
    "trigger_score": 500
  },
  "checkpoints": [
    { "x": 1500, "y": 400 },
    { "x": 2500, "y": 300 }
  ]
}
```

### 2. Level Progression
```
Level 1 (Tutorial) → Level 2 (Easy) → Level 3 (Medium)
       ↓                                      ↓
  Basic mechanics    New enemy type      Combined challenges
  Safe environment   Introduction to      Time pressure
                     hazards
```

### 3. Difficulty Curve
| Уровень | Сложность | Враги | Препятствия | Время | Целевой счёт |
|---------|-----------|-------|-------------|-------|--------------|
| 1       | 1/10      | 2     | 3           | 180s  | 1000         |
| 2       | 3/10      | 5     | 7           | 150s  | 2000         |
| 3       | 5/10      | 8     | 12          | 120s  | 3500         |
| 4       | 7/10      | 12    | 18          | 120s  | 5000         |
| 5       | 9/10      | 15    | 25          | 90s   | 8000         |

### 4. Level Structure
```
levels/
├── data/
│   ├── level1.json
│   ├── level2.json
│   ├── level3.json
│   └── ...
├── tilemaps/
│   ├── level1-tiles.json
│   └── ...
├── scripts/
│   ├── level-loader.ts      # Загрузка уровней из JSON
│   ├── level-manager.ts     # Менеджер прогрессии
│   └── difficulty-scaling.ts # Динамическая сложность
└── configs/
    └── level-progression.json # Общая прогрессия
```

### 5. Design Principles
- **Tutorial First:** Первый уровень обучает основным механикам
- **Gradual Difficulty:** Каждый уровень немного сложнее
- **Variety:** Разные типы вызовов (platforming, combat, puzzle, timing)
- **Reward Exploration:** Секреты и бонусы за исследование
- **Fair Challenge:** Сложность от дизайна, не от несправедливости
- **Multiple Paths:** Альтернативные маршруты (если применимо)

### 6. Integration Points
- JSON уровни загружаются Game Developer через level-loader
- Чекпоинты интегрируются с GameState
- События level complete → EventBus → UI/UX
- Data-driven: Game Developer читает JSON, не хардкодит

## Чеклист валидации
- [ ] Минимум 5 уровней с прогрессией сложности
- [ ] Каждый уровень валидный JSON
- [ ] Первый уровень — tutorial
- [ ] Кривая сложности монотонно возрастает
- [ ] Все координаты в пределах карты
- [ ] Exit достижим с целевым счётом
- [ ] Чекпоинты расставлены логично
- [ ] Есть секреты/бонусы для исследования
- [ ] Level-loader совместим с technical-spec

## Контекст в пайплайне
```
N3 (Architect) ──spec──▶ N6 (Level Designer) ──levels/──▶ N9 (QA Tester)
```

## Интеграция с Orchestrator
- **Timeout:** 45 минут
- **Retryable:** Да (до 3 попыток)
- **Circuit Breaker:** 3 failures → halt pipeline
