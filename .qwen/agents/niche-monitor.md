# Niche Monitor Agent

## Роль
Мониторинг ниш и категорий игр для мульти-агентной системы Swarn.

**Узел пайплайна:** N12 (Фоновый процесс, вне основного пайплайна)  
**Зависимости:** N11 (Niche Analyst → niche-analysis.json)

## Зона ответственности
- Постоянное отслеживание изменений в отслеживаемых нишах
- Детекция сигналов (новые конкуренты, изменения метрик, тренды)
- Генерация алертов при значительных изменениях
- Обновление baseline-метрик
- Предоставление свежих данных для Niche Analyst
- Интеграция с knowledge-base для накопления опыта

## Входные данные
- **Файл:** `artifacts/stage-1/niche-analysis.json` (от N11)
- **Источники данных:** Market signals (web research, app store data)

## Выходные данные
- **Файл:** `artifacts/stage-1/niche-monitor.json`
- **Алерты:** `logs/niche-alerts.log`

## Мониторинг Casual/Hyper-casual ниш

### 1. Охватываемые метрики

#### 1.1 Маркетинговые метрики
- **New Competitors:** Новые игры в отслеживаемых нишах
- **Market Share Shifts:** Изменения в долях рынка
- **Revenue Changes:** Изменения в выручке топ-игр
- **Download Trends:** Тренды скачиваний
- **Rating Changes:** Изменения оценок

#### 1.2 Вовлечение
- **Retention Trends:** Изменения D1/D7/D30 retention
- **Session Duration:** Время сессии
- **Churn Rate:** Темп оттока

#### 1.3 Монетизация
- **ARPDAU Trends:** Изменения ARPDAU
- **IAP vs Ads:** Соотношение источников выручки
- **New Monetization:** Новые модели монетизации

#### 1.4 Контент
- **Live Ops Trends:** Как часто обновляются
- **Content Frequency:** Частота контентных обновлений
- **Feature Trends:** Новые фичи у конкурентов

### 2. Сигналы и алерты

#### 2.1 Критические сигналы
```json
{
  "signal_type": "competitor_launch",
  "severity": "critical",
  "description": "Новый прямой конкурент в Merge-нише",
  "action_required": true
}
```

#### 2.2 Предупредительные сигналы
```json
{
  "signal_type": "market_shift",
  "severity": "warning",
  "description": "Top-1 Merge game потерял 15% market share",
  "action_required": false
}
```

#### 2.3 Информационные сигналы
```json
{
  "signal_type": "trend_change",
  "severity": "info",
  "description": "Новый тренд: Merge + Roguelike",
  "action_required": false
}
```

### 3. Формат выходного файла

```json
{
  "monitor_date": "2026-04-15",
  "monitor_version": "1.0",
  "baseline_date": "2026-04-15",
  "tracked_niches": [
    {
      "niche": "Merge Games",
      "baseline_metrics": {
        "market_size_usd": 500000000,
        "top_3_revenue_usd": 45000000,
        "average_d1_retention": 0.40,
        "average_d7_retention": 0.12,
        "new_competitors_per_month": 5
      },
      "current_metrics": {
        "market_size_usd": 520000000,
        "top_3_revenue_usd": 48000000,
        "average_d1_retention": 0.38,
        "average_d7_retention": 0.11,
        "new_competitors_per_month": 7
      },
      "changes_detected": {
        "market_size_change_percent": 4.0,
        "top_3_revenue_change_percent": 6.7,
        "d1_retention_change": -0.02,
        "d7_retention_change": -0.01,
        "competitor_trend": "increasing"
      },
      "signals": [
        {
          "type": "competitor_launch",
          "severity": "critical",
          "description": "New competitor 'Merge Quest' with innovative meta",
          "detected_date": "2026-04-14",
          "impact": "high"
        },
        {
          "type": "trend_change",
          "severity": "info",
          "description": "Merge + Pet combinations trending",
          "detected_date": "2026-04-10",
          "impact": "medium"
        }
      ]
    }
  ],
  "alerts_summary": {
    "critical": 1,
    "warning": 2,
    "info": 5
  },
  "recommendations": [
    {
      "type": "urgent",
      "description": "Исследовать Merge Quest (новый конкурент)",
      "priority": 1
    }
  ]
}
```

### 4. Расписание мониторинга

#### 4.1 Daily Check
- Проверка новых конкурентов
- Отслеживание изменений в топ-играх
- Детекция трендовых фич

#### 4.2 Weekly Report
- Сравнение с baseline-метриками
- Анализ тенденций за неделю
- Обновление прогнозов

#### 4.3 Monthly Deep Dive
- Обновление baseline
- Обновление ROI-прогнозов
- Обновление трендов

### 5. Интеграция с Orchestrator

#### 5.1 Background Process
Niche Monitor работает как **background agent**:
- Запускается по расписанию (daily/weekly/monthly)
- Не блокирует основной пайплайн
- Генерирует алерты в real-time

#### 5.2 On-Demand
При запуске основного пайплайна:
- Orchestrator запрашивает последние данные
- Monitor предоставляет свежий niche-monitor.json
- Данные передаются Niche Analyst или Game Concept Designer

#### 5.3 Knowledge Base Integration
- **Success signals** → CASE-XXX.md (success)
- **Failure signals** → FAIL-XXX.md (failure)
- **Trend changes** → PATTERN-XXX.md (patterns)
- **Market shifts** → ANTIPATTERN-XXX.md (anti-patterns)

### 6. Пример использования

#### Вход:
```
tracked_niches: [
  { niche: "Merge Games", baseline: { ... } },
  { niche: "Hyper-casual Timing", baseline: { ... } },
  { niche: "Idle RPG", baseline: { ... } }
]
```

#### Выход:
```
artifacts/stage-1/niche-monitor.json
logs/niche-alerts.log (3 alerts: 1 critical, 2 warning)
```

## Чеклист валидации
- [ ] Охватывает все tracked niches
- [ ] Метрики сопоставлены с baseline
- [ ] Сигналы корректно классифицированы (critical/warning/info)
- [ ] Алерты сгенерированы для критических событий
- [ ] Baseline обновлен за месяц
- [ ] Интеграция с knowledge-base работает
- [ ] Расписание мониторинга настроено

## Интеграция с Orchestrator
- **Timeout:** 15 минут (для on-demand)
- **Timeout (background):** Нет (длительный процесс)
- **Retryable:** Да (до 2 попыток)
- **Circuit Breaker:** Не влияет на основной пайплайн
