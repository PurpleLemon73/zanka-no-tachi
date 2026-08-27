# Zanka no Tachi

Zanka no Tachi is a local-first Flutter manga and anime library. It keeps user
state against canonical media identities while interchangeable adapters supply
public metadata or lawful local reading/playback capabilities.

> This is an independent, unofficial open-source project. It is not affiliated
> with, endorsed by, or sponsored by Bleach rights holders or by configured
> content providers. The software grants no rights to third-party content.

## Status and screenshots

Version **0.1.0** is a pre-release candidate for Android. Screenshots will be
added after the visual identity is finalized; contributors can capture Home,
Library, Details, Reader and Player using the deterministic offline samples in
Settings.

The same Android APK includes a remote-first Android TV / Google TV presentation
and framework-only Fire OS compatibility. Google TV emulator validation is
complete; physical Fire TV validation remains outstanding.

## Features

- Canonical manga/anime records with many source bindings and reviewed merge/split
- Home, bounded provider Search, Library filters and media Details
- Local folder/CBZ reader and local video player with canonical progress
- Source-specific resume positions and safe source switching
- Managed local imports, missing-file repair, storage accounting and cleanup
- Versioned, data-only, non-destructive backup/restore
- Capability-driven adapter SDK, enrichment provenance and metadata overrides
- First-run onboarding and bounded, redacted, local-only diagnostics

Metadata-only adapters never pretend to provide pages or streams. The project
does not implement protected page/stream extraction, DRM bypass, anti-bot
circumvention or automatic alternate-domain discovery.

## Architecture

`CanonicalMedia` owns identity and user state. Provider IDs and locators live in
source bindings. UI talks to application repositories; HTTP/parsing and local
payload resolution stay behind adapter/reader/player contracts. Refresh is
idempotent and must preserve Library/progress. See [DOMAIN_MODEL.md](DOMAIN_MODEL.md),
[ADAPTER_PLATFORM.md](ADAPTER_PLATFORM.md), and [RELEASE_HARDENING.md](RELEASE_HARDENING.md).

Local CBZ/folder manga and local video files are imported as ordinary capable
source bindings; paths never become canonical IDs. Data-only backups omit media
bytes and absolute paths, so restored local assets are marked missing and can be
repaired on the destination device.

## Build and develop

Requirements: Flutter **3.35.4 stable**, Dart 3.9 or compatible, Android SDK,
and platform tooling required by Flutter.

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

Run with `flutter run`. Install the deterministic manga/anime samples from
Settings for a network-free reader/player check. Release steps and signing are
in [docs/RELEASING.md](docs/RELEASING.md).

## Adding an adapter

Implement the small contracts in `lib/adapter_platform/adapter_sdk.dart`, declare
an explicit descriptor/capability set, register it once, and test pagination,
failures, parsing and canonical bindings. Product UI and canonical core must not
change for a lawful new adapter. Title similarity alone is never a merge signal.

## Contributing, privacy and license

Read [CONTRIBUTING.md](CONTRIBUTING.md) before proposing changes. Current local
and network behavior is documented in [PRIVACY.md](PRIVACY.md). Project-authored
source is MIT licensed; bundled/generated samples and dependencies retain their
own applicable terms. Flutter's in-app Licenses page exposes package notices.
