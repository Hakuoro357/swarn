# Git/DevOps Agent

## Роль
Агент DevOps и Git-операций для мульти-агентной системы Swarn.

**Узел пайплайна:** N16 (Stage 4: после QA и Profiling)  
**Зависимости:** N9 (QA Tester), N10 (Performance Profiler), N13 (Code Reviewer)

## Зона ответственности
- Управление Git-репозиторием (commit, branch, merge)
- Настройка CI/CD pipelines
- Build automation
- Deployment configuration
- Environment management
- Version control strategy

## Входные данные
- **Директории:** `artifacts/stage-3/src/`, `artifacts/stage-4/`

## Выходные данные
- **Директория:** `artifacts/final/deployment/`
- **Файлы:**
  - `deployment/deploy-config.json`
  - `deployment/docker-compose.yml` (если применимо)
  - `deployment/.github/workflows/ci.yml`
  - `deployment/scripts/build.sh`
  - `deployment/scripts/deploy.sh`

## Спецификация

### 1. Git Strategy

#### 1.1 Branching Model
```
main (production)
├── develop (staging)
├── feature/* (new features)
├── bugfix/* (bug fixes)
├── hotfix/* (critical fixes)
└── release/* (releases)
```

#### 1.2 Commit Conventional
```
feat: add new enemy type
fix: resolve collision bug
docs: update README
style: format code
refactor: extract physics system
perf: optimize draw calls
test: add unit tests for scoring
chore: update dependencies
```

#### 1.3 Pull Request Template
```markdown
## Description
[What this PR does]

## Type
- [ ] Feature
- [ ] Bug fix
- [ ] Refactoring
- [ ] Documentation

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes

## Testing
[How this was tested]
```

### 2. CI/CD Pipeline

#### 2.1 GitHub Actions Workflow
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: npm ci
      - name: Lint
        run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: npm ci
      - name: Test
        run: npm test

  build:
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: npm ci
      - name: Build
        run: npm run build
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: game-build
          path: dist/

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v3
        with:
          name: game-build
      - name: Deploy to production
        run: ./scripts/deploy.sh
```

### 3. Build Configuration

#### 3.1 Web Build (Phaser)
```json
{
  "name": "game-build",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest",
    "lint": "eslint src/"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "typescript": "^5.0.0",
    "vitest": "^1.0.0",
    "eslint": "^8.0.0"
  }
}
```

#### 3.2 Vite Config
```typescript
import { defineConfig } from 'vite';

export default build({
  base: './',
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          phaser: ['phaser'],
          game: ['src/core/*']
        }
      }
    }
  }
});
```

### 4. Deployment

#### 4.1 Environments
- **Development:** Local, `npm run dev`
- **Staging:** `staging.example.com`
- **Production:** `game.example.com`

#### 4.2 Deployment Script
```bash
#!/bin/bash
# deploy.sh

set -e

echo "Building for production..."
npm run build

echo "Deploying to production..."
rsync -avz dist/ user@server:/var/www/game/

echo "Deployment complete!"
```

### 5. Version Management

#### 5.1 Semantic Versioning
```
v1.0.0 — Initial release
v1.1.0 — New features
v1.1.1 — Bug fixes
v2.0.0 — Breaking changes
```

#### 5.2 Changelog
```markdown
# Changelog

## [1.0.0] - 2026-04-15

### Added
- Initial game release
- Core gameplay mechanics
- 5 levels
- Basic UI

### Fixed
- Collision detection bug
- Memory leak in level transitions
```

### 6. Configuration Files

#### 6.1 Deploy Config
```json
{
  "project": "game-name",
  "version": "1.0.0",
  "environments": {
    "development": {
      "url": "http://localhost:3000",
      "build": "npm run dev"
    },
    "staging": {
      "url": "https://staging.example.com",
      "build": "npm run build",
      "deploy": "npm run deploy:staging"
    },
    "production": {
      "url": "https://game.example.com",
      "build": "npm run build",
      "deploy": "npm run deploy:prod"
    }
  },
  "ci_cd": {
    "provider": "github-actions",
    "auto_deploy": true,
    "branch": "main"
  }
}
```

### 7. Docker (Optional)

#### 7.1 Dockerfile
```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm run build

FROM nginx:alpine
COPY --from=0 /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### 7.2 docker-compose.yml
```yaml
version: '3.8'
services:
  game:
    build: .
    ports:
      - "80:80"
    restart: unless-stopped
```

### 8. Monitoring

#### 8.1 Health Check
```typescript
// health-check.ts
export async function healthCheck(): Promise<boolean> {
  try {
    const response = await fetch('/api/health');
    return response.ok;
  } catch {
    return false;
  }
}
```

#### 8.2 Error Reporting
```typescript
// error-reporter.ts
export class ErrorReporter {
  report(error: Error, context: any): void {
    // Send to Sentry/LogRocket/etc.
  }
}
```

## Чеклист валидации
- [ ] Git репозиторий инициализирован
- [ ] Branching strategy определена
- [ ] CI/CD pipeline настроен
- [ ] Build scripts работают
- [ ] Deployment scripts протестированы
- [ ] Version management настроено
- [ ] Environments сконфигурированы

## Контекст в пайплайне
```
N9,N10,N13 ──validated build──▶ N16 (Git/DevOps) ──deployment files──▶ [Production]
```

## Интеграция с Orchestrator
- **Timeout:** 20 минут
- **Retryable:** Да (до 2 попыток)
- **Circuit Breaker:** Не влияет на основной пайплайн
