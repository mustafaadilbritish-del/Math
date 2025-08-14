# Dash - Times Tables (Flutter)

This app teaches multiplication and division tables (2–12) with a playful, Duolingo‑inspired flow.

Run locally

```bash
flutter pub get
flutter run -d chrome
```

What’s in this build

- Learning path grid for ×2..×12 and ÷2..÷12
- Lesson with 10 questions, 3 lives, streak, stars awarded at the end
- Three question types
  - Number entry (keypad)
  - Multiple choice
  - Follow the pattern (like the screenshots)
- Adaptive difficulty based on streak
- Local progress storage via SharedPreferences + Hive profile model (optional)
- Sound/haptics feedback stubs
- Rive-friendly placeholders with `SafeRive`

Notes

- Assets under `assets/animations` can be replaced with real `.riv` files and wired where needed.
- UI is intentionally kid‑friendly and responsive.
