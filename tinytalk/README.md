# TinyTalk

TinyTalk is a Flutter foundation for a modern first-words learning app for babies and toddlers.

## Setup

Flutter is not currently available in this machine's PATH. After installing Flutter:

```powershell
cd C:\Users\Delfos\Documents\BabyHabla\tinytalk
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

If Flutter says the project is missing platform files, create a temporary Flutter shell and copy only the native folders into this project:

```powershell
cd C:\Users\Delfos\Documents\BabyHabla
flutter create --project-name tinytalk tinytalk_shell
Copy-Item -Recurse tinytalk_shell\android tinytalk\
Copy-Item -Recurse tinytalk_shell\ios tinytalk\
Copy-Item -Recurse tinytalk_shell\web tinytalk\
Copy-Item -Recurse tinytalk_shell\windows tinytalk\
Copy-Item tinytalk_shell\.metadata tinytalk\
```

This keeps the custom architecture, `pubspec.yaml`, and `lib/` files intact.
