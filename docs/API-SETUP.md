# VzGramm Telegram API setup

VzGramm uses the Telegram MTProto API through the imported Telegram Android client.

## 1. Create VzGramm's own API credentials

Open Telegram's official API development page and create an application for VzGramm. Telegram requires third-party clients to obtain their own `api_id` and `api_hash`; the sample credentials shipped with the upstream source are limited and are not suitable for a published client.

Record:
- `api_id` — numeric application ID
- `api_hash` — application hash

Do not commit either value to the repository.

## 2. Add them to GitHub Actions

In the VzGramm repository:

**Settings → Secrets and variables → Actions → New repository secret**

Create exactly:

- `VZGRAMM_API_ID`
- `VZGRAMM_API_HASH`

The build workflow reads these secrets only during CI and injects them into `BuildVars.java`. They are not written to the repository.

## 3. Login flow

The upstream login implementation is retained. Once valid credentials are present, the expected flow is:

**phone number → verification code → 2FA password if enabled → signed-in account**

Telegram documents the same authorization sequence, including `auth.sendCode`, `auth.signIn`, and the 2FA password flow.

## 4. Important

Do not use another developer's API credentials. Do not paste the `api_hash` into public issues, commits, README files, screenshots, or chat logs.

For a production release, keep the API credentials in GitHub Actions secrets and keep the application signing key in a protected secret-backed release setup as well.
