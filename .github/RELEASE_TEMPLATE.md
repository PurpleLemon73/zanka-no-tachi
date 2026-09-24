## Zanka no Tachi 1.0.0

Stable release draft only. Do not tag, publish or upload the APK until the
maintainer verifies this exact artifact and explicitly authorizes publication.

### Stable artifact

- Version: `1.0.0` (`versionCode 7`)
- Production APK: `zanka-no-tachi-v1.0.0.apk`
- Package: `dev.zanka.notachi`
- Signer SHA-256: `3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41`
- Source commit: **fill from the clean preparation commit**
- APK bytes and SHA-256: **fill from the verified stable artifact, never RC.1**

The first stable release promotes the maintainer-approved RC.1 without product,
dependency, schema or toolchain changes. See `docs/release/v1.0.0.md` for the
release notes and evidence boundaries.

### Product and upgrade boundaries

One adaptive production APK supports phone and TV. It excludes demo assets and
Developer UI. `video_player` is the only selectable production engine; Better
Player's native/transitive dependencies remain packaged. Database schema 6 and
data-only backup format 3 are unchanged. Backups exclude media bytes.

Update production-signed beta.2+ or RC.1 in place with the permanent signer; do not
uninstall or clear data. Legacy debug-signed beta.1 has its own migration guide.
The WorkManager/Room constructor fix and APK startup guard remain enabled,
without disabling shrinking.

### Publication gates — record exact stable artifact evidence

- [ ] clean preparation commit; formatter, analyzer, development and production tests
- [ ] signed production pipeline; expected package, versionCode, signer and checksum
- [ ] packaged WorkDatabase constructor; no production demo assets or Developer UI
- [ ] stable Samsung in-place update and retained library/progress/resume
- [ ] stable Fire Stick in-place update, remote navigation and HOME/return
- [ ] stable cold startup/reopen; retain scoped onboarding/backup evidence separately
- [ ] explicit maintainer approval to tag, publish and distribute this exact APK

The maintainer confirmed pre-RC Samsung/Fire startup and primary flows, then
reported RC testing complete and approved stable preparation on 2026-09-24.
No per-action RC log was supplied: do not invent individual checklist results.
That acceptance and emulator results do not mark the stable physical gates as
passed. Record device/OS and APK SHA-256 for each physical check. Never clear
existing physical-device data to obtain fresh-install or restore evidence.

Provider availability and formats vary. Advanced selectable tracks, cloud sync,
background playback and Vega OS are not promised. Zanka remains independent and
unofficial and grants no rights to third-party content.
