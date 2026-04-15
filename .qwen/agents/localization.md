# Localization Agent

## Роль
Агент локализации для мульти-агентной системы Swarn.

**Узел пайплайна:** N18 (Stage 4: после Documentation)  
**Зависимости:** N5 (UI/UX), N17 (Documentation)

## Зона ответственности
- Internationalization (i18n) архитектура
- Перевод UI текстов
- Перевод игровых сообщений
- Перевод документации
- Правильное отображение текстов (RTL/LTR)
- Локализация ассетов (если нужно)

## Входные данные
- **Директории:** `artifacts/stage-3/ui/`, `artifacts/final/documentation/`

## Выходные данные
- **Директория:** `artifacts/final/localization/`
- **Файлы:**
  - `localization/i18n-config.json`
  - `localization/locales/en.json`
  - `localization/locales/ru.json`
  - `localization/locales/es.json`
  - `localization/locales/zh.json`
  - `localization/locales/ja.json`

## Спецификация локализации

### 1. i18n Architecture

#### 1.1 Locale Files Structure
```
localization/
├── locales/
│   ├── en.json          # English (default)
│   ├── ru.json          # Russian
│   ├── es.json          # Spanish
│   ├── zh.json          # Chinese
│   └── ja.json          # Japanese
├── i18n-config.json     # Configuration
└── i18n-loader.ts       # Loader utility
```

#### 1.2 Locale File Format
```json
{
  "common": {
    "ok": "OK",
    "cancel": "Cancel",
    "yes": "Yes",
    "no": "No",
    "save": "Save",
    "load": "Load",
    "settings": "Settings",
    "quit": "Quit"
  },
  "menu": {
    "title": "Game Title",
    "start": "Start Game",
    "continue": "Continue",
    "new_game": "New Game",
    "load_game": "Load Game",
    "settings": "Settings",
    "credits": "Credits",
    "quit": "Quit"
  },
  "game": {
    "health": "Health",
    "score": "Score",
    "level": "Level",
    "time": "Time",
    "combo": "Combo",
    "pause": "Game Paused",
    "resume": "Resume",
    "restart": "Restart",
    "quit": "Quit to Menu"
  },
  "messages": {
    "welcome": "Welcome to the game!",
    "level_complete": "Level Complete!",
    "game_over": "Game Over",
    "try_again": "Try Again",
    "checkpoint": "Checkpoint Reached",
    "item_collected": "Item Collected!",
    "enemy_defeated": "Enemy Defeated!",
    "new_high_score": "New High Score!"
  },
  "errors": {
    "save_failed": "Failed to save game",
    "load_failed": "Failed to load game",
    "connection_lost": "Connection Lost",
    "unknown_error": "Unknown Error"
  },
  "settings": {
    "audio": "Audio",
    "graphics": "Graphics",
    "controls": "Controls",
    "language": "Language",
    "volume_master": "Master Volume",
    "volume_music": "Music Volume",
    "volume_sfx": "SFX Volume",
    "fullscreen": "Fullscreen",
    "resolution": "Resolution",
    "quality": "Quality"
  }
}
```

### 2. Translation Keys

#### 2.1 Naming Convention
```
category.subcategory.key
```

Examples:
- `menu.start`
- `game.health`
- `messages.welcome`
- `errors.save_failed`

#### 2.2 Interpolation
```json
{
  "messages": {
    "level_complete": "Level {level} Complete!",
    "score_message": "You scored {score} points!",
    "time_message": "Time: {time}s"
  }
}
```

Usage:
```typescript
const message = t('messages.level_complete', { level: 5 });
// Result: "Level 5 Complete!"
```

### 3. Supported Languages

| Code | Language | Script | Direction |
|------|----------|--------|-----------|
| en   | English  | Latin  | LTR       |
| ru   | Russian  | Cyrillic | LTR     |
| es   | Spanish  | Latin  | LTR       |
| zh   | Chinese  | Hanzi  | LTR       |
| ja   | Japanese | Kanji+Kana | LTR   |

### 4. i18n Loader

```typescript
// i18n-loader.ts
class I18nLoader {
  private currentLocale: string = 'en';
  private translations: Map<string, any> = new Map();

  async loadLocale(locale: string): Promise<void> {
    const response = await fetch(`/locales/${locale}.json`);
    const data = await response.json();
    this.translations.set(locale, data);
    this.currentLocale = locale;
  }

  t(key: string, params?: Record<string, any>): string {
    const translation = this.getNestedValue(
      this.translations.get(this.currentLocale),
      key
    );
    
    if (!params) return translation;
    
    return Object.entries(params).reduce(
      (str, [k, v]) => str.replace(`{${k}}`, String(v)),
      translation
    );
  }

  private getNestedValue(obj: any, path: string): string {
    return path.split('.').reduce((o, p) => o?.[p], obj) || key;
  }
}

export const i18n = new I18nLoader();
```

### 5. UI Integration

#### 5.1 Text Display
```typescript
// Menu screen
const title = i18n.t('menu.title');
const startButton = i18n.t('menu.start');
```

#### 5.2 RTL Support (for Arabic/Hebrew — future)
```typescript
const direction = locale === 'ar' || locale === 'he' ? 'rtl' : 'ltr';
document.body.style.direction = direction;
```

### 6. Asset Localization

#### 6.1 Image Localization
```
assets/
├── images/
│   ├── menu-bg.png          # Default
│   ├── menu-bg-ru.png       # Russian version
│   └── menu-bg-zh.png       # Chinese version
```

#### 6.2 Audio Localization
```
audio/
├── voice/
│   ├── welcome-en.ogg       # English
│   ├── welcome-ru.ogg       # Russian
│   └── welcome-es.ogg       # Spanish
```

### 7. Quality Assurance

#### 7.1 Translation Checklist
- [ ] Все ключи из en.json переведены
- [ ] Нет пропущенных ключей
- [ ] Интерполяция работает корректно
- [ ] Текст помещается в UI элементы
- [ ] Специальные символы отображаются
- [ ] Правильные падежи и формы

#### 7.2 Validation Script
```typescript
function validateTranslation(locale: string, base: string): string[] {
  const missingKeys: string[] = [];
  
  // Compare keys
  const baseKeys = getAllKeys(base);
  const localeKeys = getAllKeys(locale);
  
  for (const key of baseKeys) {
    if (!localeKeys.has(key)) {
      missingKeys.push(key);
    }
  }
  
  return missingKeys;
}
```

### 8. Configuration

```json
{
  "default_locale": "en",
  "supported_locales": ["en", "ru", "es", "zh", "ja"],
  "fallback_locale": "en",
  "load_strategy": "lazy",
  "cache_translations": true
}
```

## Чеклист валидации
- [ ] i18n архитектура реализована
- [ ] Все ключи из UI переведены
- [ ] Все сообщения переведены
- [ ] Интерполяция работает
- [ ] Нет пропущенных ключей
- [ ] Текст помещается в UI
- [ ] Специальные символы работают
- [ ] Конфигурация создана

## Контекст в пайплайне
```
N5 (UI/UX) ──ui texts──▶ N18 (Localization) ──locales──▶ [Release]
```

## Интеграция с Orchestrator
- **Timeout:** 30 минут
- **Retryable:** Да (до 2 попыток)
- **Circuit Breaker:** Не влияет на основной пайплайн
