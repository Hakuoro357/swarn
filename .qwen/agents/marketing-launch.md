# Marketing/Launch Agent

## Роль
Агент маркетинга и запуска для мульти-агентной системы Swarn.

**Узел пайплайна:** N19 (Stage 5: перед релизом)  
**Зависимости:** N17 (Documentation), N18 (Localization), N16 (Git/DevOps)

## Зона ответственности
- Маркетинговая стратегия
- App Store Optimization (ASO)
- Промо-материалы
- Landing page
- Социальные сети
- Запуск (launch coordination)

## Входные данные
- **Директории:** `artifacts/final/` (documentation, localization, deployment)

## Выходные данные
- **Директория:** `artifacts/final/marketing/`
- **Файлы:**
  - `marketing/strategy.md`
  - `marketing/app-store-metadata.json`
  - `marketing/landing-page/index.html`
  - `marketing/social-posts.md`
  - `marketing/press-kit.md`
  - `marketing/launch-checklist.md`

## Спецификация маркетинга

### 1. Маркетинговая стратегия

#### 1.1 Target Audience
```json
{
  "primary_audience": {
    "age": "18-35",
    "interests": ["mobile gaming", "casual games", "puzzle games"],
    "platforms": ["mobile", "web"],
    "regions": ["North America", "Europe", "Russia"]
  },
  "secondary_audience": {
    "age": "35-50",
    "interests": ["casual gaming", "relaxation games"],
    "platforms": ["mobile", "tablet"],
    "regions": ["Global"]
  }
}
```

#### 1.2 Positioning
- **Unique Selling Point (USP):** "Первая merge-RPG игра с idle механиками"
- **Position:** Средний ценовой сегмент ($4.99 или F2P с IAP)
- **Differentiators:** Уникальная комбинация механик, глубокий meta

### 2. App Store Optimization (ASO)

#### 2.1 App Store Metadata
```json
{
  "app_name": "Merge Quest: Idle RPG",
  "subtitle": "Merge, Explore, Conquer",
  "description": "Merge Quest combines the addictive merge mechanics with deep RPG progression. Build your empire, recruit heroes, and conquer the world!\n\nFeatures:\n- Unique merge-RPG gameplay\n- Deep progression system\n- 100+ heroes to collect\n- PvP battles\n- Regular updates",
  "keywords": "merge, rpg, idle, strategy, casual, puzzle, hero, collect",
  "categories": ["Games/Strategy", "Games/Casual"],
  "content_rating": "12+",
  "languages": ["en", "ru", "es", "zh", "ja"]
}
```

#### 2.2 Screenshots
1. **Hero screenshot:** Главный персонаж в действии
2. **Gameplay screenshot:** Основной игровой процесс
3. **Progression screenshot:** Система прогрессии
4. **Social screenshot:** PvP/социальные функции
5. **Event screenshot:** Ивенты и обновления

#### 2.3 Preview Video
- **Duration:** 30-60 seconds
- **Content:** Gameplay, features, progression
- **Style:** Dynamic, engaging

### 3. Landing Page

#### 3.1 Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Merge Quest: Idle RPG</title>
  <meta name="description" content="Unique merge-RPG with idle mechanics">
</head>
<body>
  <header>
    <h1>Merge Quest: Idle RPG</h1>
    <p>Merge, Explore, Conquer</p>
  </header>
  
  <section id="features">
    <h2>Features</h2>
    <ul>
      <li>Unique merge-RPG gameplay</li>
      <li>Deep progression system</li>
      <li>100+ heroes to collect</li>
    </ul>
  </section>
  
  <section id="download">
    <h2>Download Now</h2>
    <a href="https://apps.apple.com/...">App Store</a>
    <a href="https://play.google.com/...">Google Play</a>
    <a href="https://game.example.com">Play Online</a>
  </section>
  
  <section id="trailer">
    <h2>Watch Trailer</h2>
    <iframe src="https://youtube.com/..."></iframe>
  </section>
</body>
</html>
```

### 4. Social Media

#### 4.1 Platforms
- **Twitter/X:** Игровые новости, обновления
- **Instagram:** Скриншоты, арт
- **TikTok:** Gameplay видео, тренды
- **YouTube:** Трейлеры, гайды
- **Discord:** Community

#### 4.2 Content Calendar
```
Week 1: Teaser (mysterious screenshot)
Week 2: Feature reveal (gameplay mechanics)
Week 3: Character showcase
Week 4: Launch announcement
Week 5+: Regular updates, community content
```

#### 4.3 Sample Posts

**Twitter:**
```
🎮 Merge Quest: Idle RPG coming soon!

Unique merge mechanics + deep RPG progression
100+ heroes to collect
PvP battles

#indie #mobilegame #gamedev #mergegame
```

**Instagram:**
```
Meet our latest hero! ⚔️

This brave knight will help you conquer the realm.
Collect, merge, evolve!

#mergequest #indiegame #rpg #mobilegaming
```

### 5. Press Kit

#### 5.1 Contents
- **Fact Sheet:** Project info, team, release date
- **Screenshots:** High-res images (1920x1080)
- **Trailer:** HD video
- **Logo:** PNG with transparency
- **Biography:** Developer story
- **Press Release:** Launch announcement

#### 5.2 Fact Sheet
```markdown
# Merge Quest: Idle RPG

## Quick Facts
- **Title:** Merge Quest: Idle RPG
- **Genre:** Merge/RPG/Idle
- **Platforms:** iOS, Android, Web
- **Release Date:** April 2026
- **Price:** Free-to-play with IAP
- **Developer:** [Your Studio]
- **Publisher:** [Your Studio]

## Features
- Unique merge-RPG gameplay
- Deep progression system
- 100+ heroes to collect
- PvP battles
- Regular updates

## Links
- Website: https://game.example.com
- App Store: https://apps.apple.com/...
- Google Play: https://play.google.com/...
```

### 6. Launch Checklist

#### 6.1 Pre-Launch (1 week before)
- [ ] App Store submission approved
- [ ] Landing page live
- [ ] Social media posts scheduled
- [ ] Press kit distributed
- [ ] Influencer outreach complete
- [ ] Analytics configured

#### 6.2 Launch Day
- [ ] App Store live
- [ ] Google Play live
- [ ] Website live
- [ ] Social media posts published
- [ ] Press release sent
- [ ] Community management active
- [ ] Support team ready

#### 6.3 Post-Launch (1 week after)
- [ ] Monitor reviews
- [ ] Respond to feedback
- [ ] Track analytics
- [ ] Plan first update
- [ ] Community engagement

### 7. Analytics & KPIs

#### 7.1 Key Metrics
- **Downloads:** D1, D7, D30
- **Revenue:** ARPDAU, LTV
- **Retention:** D1, D7, D30
- **Reviews:** App Store rating
- **Social:** Followers, engagement

#### 7.2 Tools
- **Analytics:** Firebase, Amplitude
- **Reviews:** AppFollow
- **Social:** Buffer, Hootsuite

## Чеклист валидации
- [ ] Маркетинговая стратегия определена
- [ ] ASO метаданные созданы
- [ ] Скриншоты подготовлены
- [ ] Трейлер готов
- [ ] Landing page создан
- [ ] Посты для соцсетей написаны
- [ ] Press kit собран
- [ ] Launch checklist подготовлен

## Контекст в пайплайне
```
N17,N18,N16 ──ready product──▶ N19 (Marketing) ──launch──▶ [Public Release]
```

## Интеграция с Orchestrator
- **Timeout:** 35 минут
- **Retryable:** Да (до 2 попыток)
- **Circuit Breaker:** Не влияет на основной пайплайн
