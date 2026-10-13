# Хронопунктура ТКМ (chrono_acu) v2.1

Мобильное приложение на Flutter: суточный ритм Ци по правилу Цзы-У Лю-Чжу с расчётом
истинного солнечного времени (GPS + уравнение времени), атлас **364 точек** (361 точка
ВОЗ + 3 внемеридианные) с топографией, показаниями, глубиной введения иглы и мокса-
режимом для каждой точки, каталог из 22 синдромов ТКМ с рецептами, 14 классических
фитопрепаратов, таймер сеанса с вибрацией, дневник сеансов с экспортом в PDF и
трёхъязычный интерфейс (Русский / English / 中文).

## Структура

```
chrono_acu/
├── pubspec.yaml
├── .github/workflows/build.yml   # облачная сборка APK (GitHub Actions)
├── assets/fonts/                 # DejaVuSans (кириллица) + NotoSansSC (иероглифы) для PDF
└── lib/
    ├── main.dart               — вход, тема, 6 вкладок, хроно-калькулятор
    ├── l10n.dart               — трёхъязычный движок T3/Lang
    ├── meridian_data.dart      — 14 меридианов, солнечное время, окна Цзы-У
    ├── points_data.dart        — все 364 точки (код, название, иероглифы)
    ├── point_details.dart      — партия 1: 69 ключевых точек + общий поиск find()
    ├── point_details_2.dart    — партия 2: желудок ST45 + селезёнка SP21
    ├── point_details_3.dart    — партия 3: LU(5) + LI(14) + HT(5)
    ├── point_details_4.dart    — партия 4: SI(16) + PC(7)
    ├── point_details_5.dart    — партия 5: TE(19) + GB ч.1 (16)
    ├── point_details_6.dart    — партия 6: GB ч.2 (22) + LR(9)
    ├── point_details_7.dart    — партия 7: KI(22)
    ├── point_details_8.dart    — партия 8: BL ч.1 (20)
    ├── point_details_9.dart    — партия 9: BL ч.2 (32)
    ├── point_details_10.dart   — партия 10: GV(23) + CV(19)
    ├── points_screen.dart      — глобальный поиск, список точек меридиана, карточка точки
    ├── clinical_data.dart      — 22 синдрома ТКМ + 14 формул
    ├── clinic_screen.dart      — вкладка «Клиника»
    ├── atlas_screen.dart       — схема тела спереди/сзади (кликабельно)
    ├── zones_screen.dart       — 5 крупных зон тела
    ├── atlas_hub.dart          — переключатель Тело/Зоны
    ├── timer_screen.dart       — таймер сеанса (вибрация + звук)
    ├── diary_screen.dart       — дневник сеансов (shared_preferences)
    └── pdf_export.dart         — экспорт дневника в PDF (кириллица и иероглифы)
```

## Сборка APK — способ 1: на своём компьютере

```bash
flutter create . --org app.chrono --project-name chrono_acu   # создаст android/ios папки
flutter pub get
flutter build apk --release
```

Готовый файл: `build/app/outputs/flutter-apk/app-release.apk`

После `flutter create` добавьте разрешения в `android/app/src/main/AndroidManifest.xml`
(внутрь `<manifest>`, до `<application>`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

и в `android/app/build.gradle(.kts)` поставьте `minSdkVersion 23` (`minSdk = 23`).

## Сборка APK — способ 2: GitHub Actions (без Flutter на ПК)

1. Создайте репозиторий на github.com и загрузите туда всё содержимое этой папки
   (включая `.github/`).
2. Вкладка **Actions** → workflow **Build APK** → **Run workflow**.
3. Через 5–10 минут в завершившейся задаче появится артефакт **app-release-apk** —
   скачайте ZIP, внутри APK.

## Установка на телефон

1. Перекиньте APK на телефон (USB / мессенджер / облако).
2. Откройте файл — Android попросит разрешение «Устанавливать из неизвестных
   источников» — разрешите.
3. Play Protect может предупредить о неподписанном приложении — «Всё равно установить».

## Языки

При первом запуске выбирается язык (Русский / English / 中文), далее смена — кнопкой
глобуса в шапке. Выбор сохраняется на устройстве.

## Важно

Приложение носит информационный характер и не заменяет врача. При беременности
противопоказаны SP6, LI4, BL32 и точки живота; точки спины и груди колоть только
косо и неглубоко (риск пневмоторакса); GB20, GB21, GV16 — только поверхностно.
Стерильность игл обязательна. Реальная иглотерапия требует обучения и лицензии.
