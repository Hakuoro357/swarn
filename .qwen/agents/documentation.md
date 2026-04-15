# Documentation Agent

## Роль
Агент документации для мульти-агентной системы Swarn.

**Узел пайплайна:** N17 (Stage 3-4: после разработки)  
**Зависимости:** N4 (Game Developer), N5 (UI/UX), N6 (Level Designer), N7 (Audio Engineer), N8 (Asset Manager)

## Зона ответственности
- API documentation
- User documentation
- Developer documentation
- README и guides
- Changelog generation
- Code comments review

## Входные данные
- **Директории:** `artifacts/stage-3/` (все модули)

## Выходные данные
- **Директория:** `artifacts/final/documentation/`
- **Файлы:**
  - `documentation/README.md`
  - `documentation/DEVELOPER.md`
  - `documentation/USER_GUIDE.md`
  - `documentation/API.md`
  - `documentation/CHANGELOG.md`

## Спецификация документации

### 1. README.md
```markdown
# Game Name

## Description
[Краткое описание игры]

## Features
- Feature 1
- Feature 2
- Feature 3

## Installation
### Web
1. Open https://game.example.com
2. Play!

### Local Development
```bash
git clone https://github.com/user/game.git
cd game
npm install
npm run dev
```

## Controls
| Key | Action |
|-----|--------|
| WASD | Move |
| Space | Jump |
| E | Interact |
| P | Pause |

## Screenshots
[Screenshots here]

## License
MIT
```

### 2. DEVELOPER.md
```markdown
# Developer Documentation

## Architecture
[Архитектурная схема]

## Project Structure
```
src/
├── core/           # Core systems
├── scenes/         # Game scenes
├── entities/       # Game objects
├── systems/        # Game systems
└── utils/          # Utilities
```

## API Reference

### EventBus
```typescript
// Subscribe
EventBus.on('player:death', (data) => {});

// Emit
EventBus.emit('score:changed', { score: 100, delta: 10 });
```

### GameState
```typescript
// Get state
const state = GameState.get();

// Update state
GameState.update({ score: 100 });
```

### ObjectPool
```typescript
// Acquire
const bullet = BulletPool.acquire();

// Release
BulletPool.release(bullet);
```

## Patterns Used
1. **State Pattern** — Player states
2. **Observer Pattern** — Event system
3. **Object Pool Pattern** — Performance optimization
4. **Command Pattern** — Undo/redo system

## Testing
```bash
npm test
```

## Building
```bash
npm run build
```

## Contributing
1. Fork the repository
2. Create feature branch
3. Make changes
4. Submit pull request
```

### 3. USER_GUIDE.md
```markdown
# User Guide

## Getting Started
[Как начать играть]

## Game Mechanics
### Movement
[Описание управления]

### Combat
[Описание боевой системы]

### Progression
[Описание прогрессии]

## Levels
### Level 1: Introduction
[Описание уровня]

### Level 2: ...
[Описание уровня]

## FAQ
### Q: How do I save?
A: The game auto-saves at checkpoints.

### Q: How do I change controls?
A: Go to Settings > Controls.

## Troubleshooting
### Game won't load
1. Clear browser cache
2. Disable ad blocker
3. Try different browser

### Performance issues
1. Close other tabs
2. Lower graphics settings
3. Update browser
```

### 4. API.md
```markdown
# API Documentation

## Modules

### core/game.ts
#### Game class
```typescript
class Game {
  constructor(config: GameConfig);
  start(): void;
  stop(): void;
  restart(): void;
}
```

### core/event-bus.ts
#### EventBus class
```typescript
class EventBus {
  static on<K>(event: K, callback: Function): void;
  static off<K>(event: K, callback: Function): void;
  static emit<K>(event: K, data: any): void;
}
```

### entities/player.ts
#### Player class
```typescript
class Player extends GameObject {
  health: number;
  speed: number;
  
  move(dx: number, dy: number): void;
  attack(): void;
  takeDamage(amount: number): void;
}
```
```

### 5. CHANGELOG.md
```markdown
# Changelog

## [1.0.0] - 2026-04-15

### Added
- Initial game release
- Core gameplay mechanics
- 5 levels
- Basic UI
- Sound effects
- Background music

### Fixed
- Collision detection bug
- Memory leak in level transitions
- Audio not playing on iOS

### Changed
- Improved player movement
- Balanced enemy difficulty
- Updated UI design
```

### 6. Code Documentation Standards

#### 6.1 JSDoc Comments
```typescript
/**
 * Creates a new game object.
 * @param x - X position
 * @param y - Y position
 * @param texture - Texture key
 * @returns New game object
 */
function createObject(x: number, y: number, texture: string): GameObject {
  // Implementation
}
```

#### 6.2 Inline Comments
```typescript
// Calculate damage based on armor
const damage = baseDamage * (1 - armor / 100);
```

#### 6.3 TODO/FIXME
```typescript
// TODO: Add multiplayer support
// FIXME: Collision bug on edge cases
// HACK: Temporary workaround for...
```

### 7. Documentation Generation

#### 7.1 TypeDoc Configuration
```json
{
  "inputFiles": ["./src"],
  "mode": "modules",
  "out": "docs",
  "theme": "default",
  "includeVersion": true
}
```

#### 7.2 Auto-generated docs
```bash
npm run docs
```

## Чеклист валидации
- [ ] README.md создан и полный
- [ ] DEVELOPER.md содержит API reference
- [ ] USER_GUIDE.md понятен для новичков
- [ ] API.md документирует все публичные модули
- [ ] CHANGELOG.md актуален
- [ ] Code comments в JSDoc формате
- [ ] Документация генерируется автоматически

## Контекст в пайплайне
```
N4,N5,N6,N7,N8 ──code──▶ N17 (Documentation) ──docs──▶ [Release]
```

## Интеграция с Orchestrator
- **Timeout:** 25 минут
- **Retryable:** Да (до 2 попыток)
- **Circuit Breaker:** Не влияет на основной пайплайн
