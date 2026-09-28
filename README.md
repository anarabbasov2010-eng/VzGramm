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


## Feature inspiration / credits

VzGramm is an independent client. Its experimental feature roadmap is informed by publicly documented ideas found in **AyuGram** and **exteraGram**, including privacy controls, message-history tooling, anti-recall concepts, filters, streamer-oriented presentation and UI customization. These names are attribution/reference points, not a claim of affiliation or endorsement.

- AyuGram: publicly documents ghost mode, deleted-message history, message filters and customization. citeturn0search8turn0search15
- exteraGram: publicly documented Android releases include UI customization, tab/title styles, solar icons, translation-before-send, speed controls and updater improvements. citeturn0search0

VzGramm will implement its own code and UX rather than copying proprietary assets or pretending to be an official AyuGram/exteraGram build.
