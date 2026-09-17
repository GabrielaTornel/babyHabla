# Next Steps

1. Install Flutter and confirm `flutter --version` works.
2. Run `flutter pub get`.
3. Run `dart run build_runner build --delete-conflicting-outputs`.
4. Add real images, audio, and Lottie files under `assets/`.
5. Run the app and refine the Home, Category, and Word Detail screens.
6. Add the real BabyHabla logo as `assets/images/branding/babyhabla_logo.png`.

## Asset naming

Keep asset paths predictable:

```text
assets/images/animals/dog.png
assets/audio/animals/dog.mp3
assets/lottie/dog.json
```

The JSON word data should point to those paths.
