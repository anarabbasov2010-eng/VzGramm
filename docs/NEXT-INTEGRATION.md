# Next integration step

The repository now has a real Android module and a consistent VzGramm identity.

The next operation is to bring the upstream Telegram Android source into the repository and make the VzGramm application module/build consume that source.

Required sequence:

1. Preserve upstream GPL-2.0 notices.
2. Import the upstream Gradle/project structure.
3. Change application identifiers and product strings systematically.
4. Replace launcher resources with the VzGramm master asset.
5. Verify every Android variant resolves the same icon geometry.
6. Build debug before adding any custom feature.
