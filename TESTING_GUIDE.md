# Руководство по тестированию игры

## 🎮 Готово к тестированию!

Игра полностью реализована и готова к запуску в Roblox Studio!

## Запуск игры

### 1. Запустите Rojo сервер
```bash
rojo serve
```

### 2. Откройте Roblox Studio
1. Откройте Roblox Studio
2. Создайте новое место или откройте существующее
3. Установите Rojo plugin (если ещё не установлен)
4. Нажмите "Connect" в Rojo plugin
5. Подключитесь к `localhost:34872`

### 3. Нажмите Play (F5)

Игра загрузится автоматически!

## Что вы увидите

### HUD (левый верхний угол)
```
RPG GRIND GAME
Level: 1
XP: 0 / 100
Rebirth: 0
💰 Coins: 0
💎 Gems: 0
⚔️ Strength: 10
📍 Starter Plains
```

### Кнопки меню (правая сторона)
- 🛒 **Shop** - Покупка улучшений
- 🗺️ **Zones** - Выбор зон для телепортации
- 🐾 **Pets** - Питомцы (пока не реализовано)
- ♻️ **Rebirth** - Система перерождения
- 🎁 **Daily** - Ежедневные награды (пока не реализовано)

### Мобы
В мире появятся разноцветные кубики - это мобы:
- **Красные** (Slime Lv.1) - стартовая зона
- **Красные** (Goblin Lv.5) - стартовая зона
- **Оранжевые** (Wolf Lv.10, Orc Lv.15) - лес и горы
- **Фиолетовые** (Troll Lv.20) - горы
- **Чёрные** (Dragon Lv.30) - вулкан

## Основной геймплей

### 1. Атака мобов
- **Кликните мышкой** на любого моба
- Вы увидите **летящие цифры урона**
- При критическом ударе: **"XXX CRIT!"** красным цветом
- После смерти моба получите XP и монеты

### 2. Прокачка уровня
- Убивайте мобов для получения XP
- При накоплении достаточного XP появится **анимация Level Up!**
- Ваши статы автоматически увеличатся
- Проверьте новый уровень в HUD

### 3. Покупка улучшений
1. Нажмите кнопку **🛒 Shop**
2. Откроется магазин с улучшениями:
   - Strength Upgrade
   - Speed Upgrade
   - Defense Upgrade
   - Crit Chance Upgrade
   - Crit Multiplier Upgrade
3. Кликните **BUY** на любом улучшении
4. Если хватает монет - улучшение будет куплено
5. Уровень улучшения увеличится, цена вырастет

### 4. Смена зон
1. Нажмите кнопку **🗺️ Zones**
2. Увидите все зоны:
   - **Starter Plains** (Lv.1) - доступна сразу
   - **Dark Forest** (Lv.10) - разблокируется на 10 уровне
   - **Rocky Mountains** (Lv.20)
   - **Volcanic Wasteland** (Lv.30, Rebirth 1)
3. Зелёные = разблокированы, красные = заблокированы
4. Нажмите **TELEPORT** чтобы телепортироваться

### 5. Перерождение (Rebirth)
1. Достигните **уровня 50**
2. Нажмите кнопку **♻️ Rebirth**
3. Увидите информацию о бонусах:
   - +10% урона навсегда
   - +15% XP навсегда
   - +10% монет навсегда
4. Нажмите **PERFORM REBIRTH**
5. Ваш уровень сбросится до 1, но бонусы останутся!

## Тестовые сценарии

### ✅ Сценарий 1: Первый бой
1. Запустите игру (F5)
2. Подождите загрузки профиля
3. Найдите красного слайма
4. Кликните на него
5. **Ожидаемое**: Увидите цифры урона, моб умрёт, получите XP и монеты

### ✅ Сценарий 2: Level Up
1. Убейте 20 слаймов
2. **Ожидаемое**:
   - Анимация "🎉 LEVEL UP! Level 2"
   - Strength увеличился до 12
   - Speed увеличился до 12
   - Defense увеличился до 6

### ✅ Сценарий 3: Покупка улучшения
1. Накопите 100+ монет
2. Откройте магазин (🛒)
3. Купите Strength Upgrade
4. **Ожидаемое**:
   - Монеты уменьшились на 100
   - Strength увеличился на 5
   - Level улучшения стал 1
   - Цена увеличилась до 115

### ✅ Сценарий 4: Разблокировка зоны
1. Достигните уровня 10
2. **Ожидаемое**: Уведомление "Zone unlocked: ForestZone"
3. Откройте меню зон
4. Dark Forest теперь разблокирован (зелёный)
5. Телепортируйтесь туда

### ✅ Сценарий 5: Сохранение прогресса
1. Играйте 5 минут
2. Запомните уровень и монеты
3. Остановите игру (Shift+F5)
4. Снова запустите (F5)
5. **Ожидаемое**: Весь прогресс сохранился!

### ✅ Сценарий 6: Rebirth
1. Используйте консоль (F9) для быстрого теста:
```lua
-- Server Console
local player = game.Players:GetPlayers()[1]
local ProgressionService = require(game.ServerScriptService.Server.Services.ProgressionService)
ProgressionService.AwardExperience(player, 1000000) -- Быстрый level up
```
2. Достигните уровня 50
3. Откройте Rebirth меню
4. Выполните Rebirth
5. **Ожидаемое**: Level = 1, Rebirth Level = 1, бонусы активны

## Консольные команды для тестирования

### Server Console (F9, вкладка Server)

**Дать монеты и гемы:**
```lua
local player = game.Players:GetPlayers()[1]
local DataService = require(game.ServerScriptService.Server.Services.DataService)
DataService.UpdateData(player, function(data)
    data.Currencies.Coins += 10000
    data.Currencies.Gems += 1000
end)
```

**Быстрый level up:**
```lua
local player = game.Players:GetPlayers()[1]
local ProgressionService = require(game.ServerScriptService.Server.Services.ProgressionService)
ProgressionService.AwardExperience(player, 100000)
```

**Разблокировать все зоны:**
```lua
local player = game.Players:GetPlayers()[1]
local DataService = require(game.ServerScriptService.Server.Services.DataService)
DataService.UpdateData(player, function(data)
    data.Zones.UnlockedZones = {"StarterZone", "ForestZone", "MountainZone", "VolcanoZone"}
end)
```

**Посмотреть данные игрока:**
```lua
local player = game.Players:GetPlayers()[1]
local DataService = require(game.ServerScriptService.Server.Services.DataService)
print(DataService.GetData(player))
```

## Известные ограничения

### Пока не реализовано:
1. **Pet UI** - система питомцев работает на сервере, но нет UI
   - Можно использовать консольные команды для тестирования
2. **Daily Rewards UI** - можно вызвать через консоль
3. **Модели мобов** - пока простые кубики
4. **Анимации персонажа** - нет анимаций атаки
5. **Звуки** - нет звуковых эффектов

### Работает полностью:
✅ Боевая система
✅ Прокачка уровня
✅ Система улучшений
✅ Зоны и телепортация
✅ Rebirth система
✅ Сохранение данных
✅ HUD
✅ Все меню (Shop, Zones, Rebirth)
✅ Визуальные эффекты урона

## Проверка Output

В консоли (F9) вы должны видеть:

**При запуске сервера:**
```
[Server] RPG Game initializing...
[MobSpawner] Mobs spawned in all zones
[Server] RPG Game initialized!
```

**При входе игрока:**
```
[Server] Player YourName joining...
[Server] Profile loaded for YourName
[Client] RPG Game initializing...
[UIManager] Initialized
[HUD] Created
[MenuButtons] Created
[ShopScreen] Created
[ZoneScreen] Created
[RebirthScreen] Created
[Client] RPG Game initialized!
[Client] Received player data
[CombatController] Player data updated - Level: 1, Strength: 10
```

**При атаке моба:**
```
[Combat] Dealt 10 damage
[Combat] Mob killed! +15 XP, +8 Coins
```

**При покупке улучшения:**
```
[ShopScreen] Attempting to purchase Strength
[ShopScreen] Successfully purchased Strength
```

## Производительность

### Ожидаемые показатели:
- **FPS**: 60 (должно быть стабильно)
- **Ping**: Зависит от локального сервера (~10-50ms)
- **Memory**: ~200-300 MB

Если FPS низкий:
1. Уменьшите количество мобов в MobSpawner.luau
2. Проверьте что не запущены другие тяжёлые программы

## Следующие шаги для улучшения

### Краткосрочные:
1. Добавить Pet UI (просмотр и экипировка)
2. Добавить Daily Rewards UI
3. Заменить кубики на нормальные модели мобов
4. Добавить звуки

### Долгосрочные:
1. Анимации атак
2. Particle effects
3. Музыка
4. Leaderboards
5. Achievements
6. Tutorial

## Если что-то не работает

### Моб не атакуется:
- Проверьте что у моба есть StringValue "MobType"
- Проверьте Output на ошибки

### UI не появляется:
- Проверьте что Rojo подключён
- Перезапустите игру (Shift+F5 → F5)

### Данные не сохраняются:
- ProfileService может не работать в Studio
- Попробуйте опубликовать игру и протестировать в реальном Roblox

### Ошибки в Output:
- Скопируйте полный текст ошибки
- Проверьте что все зависимости установлены (`wally install`)

## Enjoy! 🎮

Игра полностью играбельна! Тестируйте, находите баги и добавляйте новые фичи!
