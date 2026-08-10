# 🍕 Pizzaro

<p align="center">
  <img src="https://github.com/HammasT1/Pizzaro/blob/main/android/app/src/main/res/playstore.png?raw=true" width="120" alt="Pizzaro app icon" />
</p>

A production-style Flutter app for browsing and customizing pizzas, built around
native, hand-tuned animations — Hero flights, a drag-responsive fake-3D pizza
viewer, spring/elastic size transitions, and sequenced screen reveals — using
only Flutter's own animation APIs.

<p align="center">
  <img src="https://github.com/HammasT1/Pizzaro/blob/main/assets/images/pizzas/main-screen.jpeg?raw=true" width="30%" alt="Main Screen" />
  <img src="https://github.com/HammasT1/Pizzaro/blob/main/assets/images/pizzas/Menu-screen.jpeg?raw=true" width="30%" alt="Menu Screen" />
  <img src="https://github.com/HammasT1/Pizzaro/blob/main/assets/images/pizzas/Add%20-to-cart.jpeg?raw=true" width="30%" alt="Add to Cart Screen" />
</p>

## Demo

<p align="center">
  <img src="https://github.com/HammasT1/Pizzaro/blob/main/assets/images/pizzas/pizzaro-GIF-compressed.gif?raw=true" width="60%" alt="Pizzaro demo GIF" />
</p>

<p align="center"><em>Live run of the app — home grid, hero-flight detail screen, drag-to-rotate 3D viewer, and cart, all in motion.</em></p>

## App Icon (Mobile View)

<p align="center">
  <img src="https://github.com/HammasT1/Pizzaro/blob/main/assets/images/pizzas/App-Icon-Mobile-View.jpeg?raw=true" width="200" alt="Pizzaro app icon on mobile home screen" />
</p>

## Overview

Pizzaro is a mobile-first menu/ordering flow: a filterable pizza grid, a
detail screen where the pizza image behaves like a lightweight 3D object you
can drag and resize, and a cart with animated inserts and a live total. There
is no backend — a mock repository stands in for one, structured so a real API
can be swapped in later without touching any UI code.

## Tech stack

| Layer            | Choice                                                         |
| ----------------- | --------------------------------------------------------------- |
| Framework          | Flutter 3.44.7 (stable)                                        |
| Language           | Dart 3.12.2                                                     |
| State management   | [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) 3.4.x (`Notifier` / `NotifierProvider`, `FutureProvider`) |
| Animation          | Native Flutter APIs only — `AnimationController`, `Tween`, `CurvedAnimation`, `Hero`, `AnimatedBuilder`, `Matrix4` |
| Architecture       | Clean-ish layering: `domain/` → `data/` → `presentation/`      |
| Data source        | Local mock repository (`MockPizzaRepository`), interface-swappable for a real API |
| Testing            | `flutter_test` (widget test), `flutter analyze` (zero lints)   |
| Targets            | Android & iOS (mobile-first, responsive 2–4 column grid)       |

No third-party animation, icon, or font packages are used — every motion in
the app is a hand-built `AnimationController`/`Tween`/`Curve`, and every icon
is a bundled Material icon (`uses-material-design: true`), not a downloaded
asset.

## Feature tour

- **Home / Menu** — responsive grid (2–4 columns by screen width), category
  filter chips (Veg / Non-Veg / Specialty / All), staggered fade + slide-up
  entrance for the cards on first load.
- **Pizza Detail** — Hero transition flies the tapped card's image into a
  large centered stage; a `Pizza3DViewer` then takes over: drag to rotate via
  a perspective `Matrix4`, a slow idle "breathing" loop so it's never static,
  a spring-back on release, and a ground shadow that scales/dims with size
  and tilt. The details panel fades/slides in *after* the Hero flight
  finishes — sequenced, not simultaneous.
- **Size selector** — Small / Medium / Large animates the pizza's scale with
  `Curves.elasticOut` for a tactile, physical feel, and the price counts up
  or down alongside it.
- **Add to Cart** — a single button morphs idle → spinner → checkmark → idle
  using `AnimatedContainer` + `AnimatedSwitcher`.
- **Cart** — `AnimatedList`-backed inserts/removals, per-row quantity
  steppers, and an animated running total.

## Architecture

```
lib/
  main.dart                     # entry point, wraps app in ProviderScope
  app.dart                      # MaterialApp, theme, initial route
  core/
    theme/                      # AppTheme, AppColors
    constants/                  # AppSpacing, AppDurations, AppCurves
    utils/                      # currency_formatter
  domain/
    models/                     # PizzaModel, PizzaSize, PizzaCategory, CartItem
  data/
    datasources/                # pizza_mock_data.dart (local mock menu)
    repositories/                # PizzaRepository (interface) + Mock impl
  presentation/
    providers/                  # Riverpod providers (menu, filter, cart)
    home/                       # Home screen + widgets
    detail/                     # Pizza detail screen + 3D viewer + widgets
    cart/                       # Cart screen + widgets
```

`domain/` has zero Flutter imports — it's plain Dart models.
`data/repositories/PizzaRepository` is an interface; `MockPizzaRepository` is
the only implementation today, so swapping in a real backend later means
adding a new class, not touching any screen.

## Animation techniques, by feature

| Feature | Technique | File |
|---|---|---|
| Card entrance | One shared `AnimationController` + per-item `Interval` (no controller-per-card) | [`staggered_entrance.dart`](lib/presentation/home/widgets/staggered_entrance.dart) |
| Card → detail | `Hero` with a per-pizza tag, custom `PageRouteBuilder` with an explicit `transitionDuration` | [`pizza_detail_route.dart`](lib/presentation/detail/pizza_detail_route.dart) |
| Fake 3D pizza | Perspective `Matrix4` (`setEntry(3,2,…)`) driven by drag, idle breathing loop, spring-back, ground shadow | [`pizza_3d_viewer.dart`](lib/presentation/detail/widgets/pizza_3d_viewer.dart) |
| Panel reveal | Delayed `AnimationController.forward()` timed to the Hero flight duration | [`pizza_detail_screen.dart`](lib/presentation/detail/pizza_detail_screen.dart) |
| Size change | `Tween` + `Curves.elasticOut` on the 3D viewer's scale | [`pizza_3d_viewer.dart`](lib/presentation/detail/widgets/pizza_3d_viewer.dart) |
| Price count-up | Explicit `AnimationController` re-targeted in `didUpdateWidget` | [`animated_price.dart`](lib/presentation/detail/widgets/animated_price.dart) |
| CTA morph | `AnimatedContainer` (shape/size) + `AnimatedSwitcher` (icon/label) | [`add_to_cart_button.dart`](lib/presentation/detail/widgets/add_to_cart_button.dart) |
| Cart list | `AnimatedList` with explicit insert/remove diffing against Riverpod state | [`cart_screen.dart`](lib/presentation/cart/cart_screen.dart) |

Every duration and curve is centralized in
[`app_motion.dart`](lib/core/constants/app_motion.dart) — no animation in the
app uses a bare literal duration or the default linear curve.

## Assets

Only what already exists in `assets/images/pizzas/` is used
(`1.png`–`8.png`). There are no ingredient icons, custom fonts, or Lottie
files in the project yet, so:

- UI icons are Flutter's bundled Material icons.
- Ingredients render as text pills, not icons.
- Typography uses the platform default font via a custom `TextTheme`.
- `PizzaModel.hasTransparentBackground` (default `true`) lets a future
  non-transparent image opt into a soft backing disc on the detail screen
  instead of relying on alpha transparency — none of the current 8 images
  need it.

Menu copy (names, descriptions, prices, categories) in
[`pizza_mock_data.dart`](lib/data/datasources/pizza_mock_data.dart) is
placeholder content — swap it for real menu data whenever it's available.

## Getting started

```bash
flutter pub get
flutter run            # pick a connected device/emulator
```

Run analysis and tests:

```bash
flutter analyze
flutter test
```

## Status

Functional prototype with mock data — no backend, no persistence, no auth.
The repository layer is structured so a real API can be dropped in behind
`PizzaRepository` without changing any screen.
