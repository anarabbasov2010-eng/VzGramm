# Upstream integration

The official Telegram Android repository contains multiple Android modules and requires recursive submodules for a complete checkout. citeturn0search0turn2search0

VzGramm now has a deterministic bootstrap that downloads that source tree and applies the VzGramm branding layer.

## Rules

- Preserve the upstream GPL-2.0 license and notices.
- Use VzGramm's own API credentials before distribution.
- Do not use Telegram's standard logo.
- Keep release signing and service credentials outside Git.
- Do not blindly rename protocol identifiers or deep-link schemes.

The upstream README documents the current Android/NDK requirements and credential setup. citeturn2search1turn2search2
