# VzGramm

An independent Android Telegram client fork branded as **VzGramm**.

## Current phase

The repository now has the upstream Telegram Android integration pipeline and the VzGramm public identity layer. Custom ExteraGram/AyuGram features are intentionally **not included yet**.

### What is already prepared

- VzGramm public app identity and launcher branding.
- OLED-friendly dark icon family.
- Deterministic import of the current upstream Android source tree.
- VzGramm application id: `org.vzgramm.messenger`.
- Fork-safe BuildVars defaults; upstream API/Firebase/store credentials are not reused.
- Automated Gradle integration build in GitHub Actions.
- Upstream source persistence after a successful integration run.
- GPL-2.0 source preservation.

## Integration flow

```text
DrKLO/Telegram
      |
      v
bootstrap-upstream.sh
      |
      v
apply-vzgramm-branding.sh
      |
      v
verify-vzgramm-branding.sh
      |
      v
Gradle assembleAfatRelease
      |
      v
persist source to VzGramm/main
```

Custom features are the **next** phase; they are not being mixed into the base client yet.

## Important

A working distributed client needs VzGramm's own Telegram API credentials, release signing configuration and, when Google services are enabled, its own Firebase project. The upstream project requires developers to use their own application credentials and not reuse Telegram's standard branding.

> Telegram is a trademark of Telegram FZ-LLC. VzGramm is an independent fork/client project.
