# VzGramm updates

VzGramm keeps a stable application ID (\`org.vzgramm.messenger\`) and reuses the VzGramm development signing identity in CI. New alpha APKs therefore install as Android updates rather than as a second app.

## User flow

1. Open **Settings → VzGramm Lab**.
2. Tap **Check for update**.
3. Download the newest \`VzGramm.apk\` from GitHub Releases.
4. Android installs it over the existing VzGramm installation after user confirmation.
5. App data and login state remain associated with the same package.

The CI stores the development keystore as a short-lived GitHub Actions artifact so subsequent builds can reuse the same signing identity. For a long-lived public release channel, replace this with a repository/organization secret-backed production keystore.

## Fast APK

CI builds an \`arm64-v8a\` VzGramm APK for modern 64-bit Android phones. This avoids shipping unused x86/32-bit native libraries and reduces download/install size. A universal APK can be added later for broader device coverage.

## Credentials

Telegram API credentials are intentionally not copied from the official client. A production VzGramm build must use its own API ID/hash and its own release keystore.
