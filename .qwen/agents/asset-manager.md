# Asset Manager Agent

## Роль
Менеджер игровых ассетов и оптимизации для мульти-агентной системы Swarn.

**Узел пайплайна:** N8 (Stage 3: Параллельная разработка)  
**Зависимости:** N3 (Game Architect → technical-spec.md)

## Зона ответственности
- Создание/управление спрайтами (player, enemies, items, tiles)
- Texture atlases и оптимизация
- Система загрузки ассетов
- Управление памятью ассетов
- Placeholder и fallback ассеты
- Guidelines для оптимизации

## Входные данные
- **Файл:** `artifacts/stage-2/technical-spec.md`

## Выходные данные
- **Директория:** `artifacts/stage-3/assets/`

## Инструкции по реализации

### 1. Asset Structure
```
assets/
├── sprites/
│   ├── player/
│   │   ├── idle.png          # Или code-generated pixel data
│   │   ├── run.png
│   │   ├── jump.png
│   │   └── hurt.png
│   ├── enemies/
│   │   ├── patrol-walk.png
│   │   ├── patrol-hurt.png
│   │   └── patrol-dead.png
│   ├── items/
│   │   ├── coin.png
│   │   ├── health-potion.png
│   │   └── powerup.png
│   └── tiles/
│       ├── ground.png
│       ├── platform.png
│       └── decoration.png
├── ui/
│   ├── buttons/
│   ├── icons/
│   └── backgrounds/
├── effects/
│   ├── particles/
│   ├── explosions/
│   └── trails/
├── atlases/
│   └── game-atlas.json       # Texture atlas configuration
└── config/
    └── asset-config.json     # Asset manifest и настройки
```

### 2. Asset Generation Strategy
Если нет графических файлов:
- **Code-only pixel art:** Матрицы пикселей в TypeScript
- **Procedural shapes:** Геометрические примитивы
- **Silhouette-first design:** Контур → детализация
- **Palette-based:** Единая палитра для всех ассетов

### 3. Code-Only Pixel Art Example
```typescript
const PLAYER_IDLE: number[][] = [
  [0,0,1,1,1,1,0,0],
  [0,1,2,2,2,2,1,0],
  [0,1,2,3,3,2,1,0],
  [0,1,2,2,2,2,1,0],
  [0,0,1,4,4,1,0,0],
  [0,1,1,4,4,1,1,0],
  [0,1,0,4,4,0,1,0],
  [0,1,0,5,5,0,1,0],
];

// 0=transparent, 1=outline, 2=skin, 3=eyes, 4=body, 5=shoes
const PALETTE: Record<number, string> = {
  1: '#1a1a2e',  // outline
  2: '#f5c6a0',  // skin
  3: '#ffffff',  // eyes
  4: '#4a90d9',  // body
  5: '#8b4513',  // shoes
};
```

### 4. Texture Atlas Configuration
```json
{
  "atlas_name": "game-atlas",
  "max_width": 2048,
  "max_height": 2048,
  "padding": 2,
  "sprites": {
    "player-idle": { "x": 0, "y": 0, "w": 64, "h": 64 },
    "player-run-1": { "x": 64, "y": 0, "w": 64, "h": 64 },
    "coin": { "x": 0, "y": 64, "w": 32, "h": 32 }
  }
}
```

### 5. Asset Loading Strategy
```typescript
// Preload
assets.loadAtlas('game-atlas');
assets.loadJSON('asset-config');

// Lazy load (тяжёлые ассеты)
assets.loadOnDemand('boss-sprites');

// Unload (освобождение памяти)
assets.unloadLevel(levelId);
```

### 6. Memory Management
- **Atlas packing:** Минимизировать пустое пространство
- **Mipmap:** Для масштабирования без артефактов
- **Unload:** Выгружать ассеты пройденных уровней
- **Pool:** Переиспользовать частицы и эффекты
- **Budget:** <100MB для всех ассетов

### 7. Placeholder Strategy
Если ассет ещё не готов:
- **Геометрические примитивы:** Квадрат, круг, треугольник
- **Цветовое кодирование:** Player=синий, Enemy=красный, Item=жёлтый
- **Label:** Текстовая метка на placeholder
- **Console warning:** Лог при использовании placeholder

### 8. Color Palette
```typescript
const GAME_PALETTE = {
  // Primary
  primary: '#4a90d9',
  secondary: '#e74c3c',
  accent: '#f39c12',

  // Environment
  ground: '#8b6914',
  sky: '#87ceeb',
  platform: '#6b4226',

  // UI
  uiBackground: '#2c3e50',
  uiText: '#ecf0f1',
  uiAccent: '#3498db',

  // Effects
  positive: '#2ecc71',
  negative: '#e74c3c',
  neutral: '#95a5a6',
};
```

### 9. Integration Points
- Ассеты загружаются через PreloadScene
- UI/UX использует UI ассеты из этого агента
- Level Designer ссылается на tile sprites
- Game Developer использует спрайты сущностей

## Чеклист валидации
- [ ] Все спрайты из spec созданы (или placeholders)
- [ ] Texture atlas сконфигурирован
- [ ] Палитра цветов консистна
- [ ] Asset manifest полный и валидный
- [ ] Loading strategy совместима с technical-spec
- [ ] Memory budget соблюдён (<100MB)
- [ ] Placeholders для всех отсутствующих ассетов
- [ ] Unload логика для пройденных уровней
- [ ] Спрайты анимированы (кадры определены)

## Контекст в пайплайне
```
N3 (Architect) ──spec──▶ N8 (Asset Manager) ──assets/──▶ N9 (QA Tester)
```

## Интеграция с Orchestrator
- **Timeout:** 45 минут
- **Retryable:** Да (до 3 попыток)
- **Circuit Breaker:** 3 failures → halt pipeline
