# MSU - Martian Survival In The Unknown

## 🎮 Про проєкт
Retro PS1-style survival horror гра на Марсі. Top-down 3D з атмосферою Lethal Company.

## 📁 Структура проєкту
```
MSU/
├── src/
│   ├── core/          # Основні системи (main scene, game manager)
│   ├── entities/      # Гравець, вороги, NPC
│   ├── ui/            # Інтерфейс користувача
│   ├── systems/       # Ігрові системи (інвентар, крафт, AI)
│   ├── shaders/       # PS1 шейдери та пост-обробка
│   └── assets/        # Моделі, текстури, звуки
├── project.godot      # Конфігурація Godot
└── icon.svg           # Іконка проєкту
```

### Що створено:
1. **project.godot** - Налаштування проєкту (Forward+ renderer, 1920x1080)
2. **src/core/main.tscn** - Головна сцена з:
   - SubViewportContainer (640x360 для ретро-вигляду)
   - WorldEnvironment (марсіанський туман, volumetric fog)
   - DirectionalLight3D (тепле сонячне світло)
   - Camera3D (ортогональна, top-down)
   - TestGround (тестова поверхня 50x50)

3. **src/core/main.gd** - Контролер головної сцени
4. **src/shaders/viewport_pixelate.gdshader** - Пікселізація viewport
5. **src/shaders/ps1_retro.gdshader** - PS1 ефекти (vertex snapping, dithering, affine mapping)

### 🎨 Візуальні ефекти:
- ✅ Низька роздільність (640x360) з масштабуванням
- ✅ Пікселізація через shader
- ✅ Volumetric Fog (густий марсіанський пил)
- ✅ Тепла колірна палітра (помаранчево-червоний Марс)
- ✅ Glow та Bloom для атмосфери

## 📋 ЩО РОБИТИ ДАЛІ:

### У Godot Editor:
1. Відкрий **Godot_v4.6.2-stable_win64.exe** з Desktop
2. Натисни **"Import"** або **"Scan"**
3. Знайди папку `C:\Users\artem\Desktop\MSU`
4. Відкрий проєкт
5. Запусти сцену (F5) - побачиш сіру поверхню з марсіанським туманом

### Перевірка:
- Має бути помаранчевий туман
- Низька роздільність (пікселізований вигляд)
- Ортогональна камера зверху

---
**Статус:** КРОК 1 завершено. Чекаю підтвердження для переходу до КРОКУ 2.
