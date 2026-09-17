# TinyTalk Architecture

TinyTalk starts offline-first. The UI reads from Riverpod providers, providers talk to repositories, and repositories decide where data comes from.

```text
Screen or Widget
  -> Riverpod Provider
    -> Repository Interface
      -> Local JSON Repository
        -> assets/data/words.json
```

## Why this shape?

- `app/` owns global app setup: routing, theme, constants, and the root widget.
- `core/` owns reusable tools that do not belong to one feature, like image widgets and audio/TTS services.
- `features/` owns screens and widgets grouped by product area.
- `shared/` owns cross-feature models, repositories, and providers.
- `assets/` keeps learning content available offline.
- `assets/images/branding/` keeps logo and brand visuals separate from learning images.

## Firebase later

When TinyTalk is ready for Firebase, create a `FirebaseWordRepository` that implements `WordRepository`. The UI should not change because screens already depend on the repository interface through Riverpod.

## Beginner mistakes to avoid

- Do not put data loading directly inside widgets.
- Do not put every screen in `main.dart`.
- Do not hardcode colors and typography in every widget.
- Do not add Firebase before the offline version feels good.
- Do not let missing audio or images crash the learning flow.
