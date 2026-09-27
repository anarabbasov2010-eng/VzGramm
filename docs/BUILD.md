# VzGramm build

The repository uses the upstream Telegram Android build system rather than maintaining a parallel miniature Android shell.

## Automated integration

GitHub Actions:

1. clones the upstream source recursively;
2. applies the VzGramm public identity;
3. removes upstream Firebase project configuration and official-only BuildVars defaults;
4. verifies the public identity;
5. runs the Gradle `assembleAfatRelease` build;
6. persists the imported source into `main` when the run succeeds.

The upstream repository currently documents Android Studio 2025.1.4, NDK 27.2.12479018 and SDK 36 for its build. citeturn0search0

## Credentials

Do **not** put personal API hashes, Firebase configuration, or release keystore passwords into Git.

The branding stage intentionally starts with:

- `APP_ID = 0`
- empty `APP_HASH`
- empty Google/Huawei/SafetyNet credentials
- passkey support disabled

These values are safe build defaults, not production credentials. Before a real login/release build, replace them with VzGramm's own configuration.

Custom ExteraGram/AyuGram features are deliberately not present in this phase.
