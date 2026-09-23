## Zanka no Tachi 1.0.0 RC.1

Preparation template only. Do not publish until explicitly authorized and the
candidate gates below have evidence. This is not stable 1.0.

### Candidate

- Version: `1.0.0-rc.1` (`versionCode 6`)
- Production APK: `zanka-no-tachi-v1.0.0-rc.1.apk`
- Package: `dev.zanka.notachi`
- Signer SHA-256: `3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41`
- Source commit: **fill from the clean preparation commit**
- APK bytes and SHA-256: **fill from the verified candidate, never an older beta**

### Product and upgrade boundaries

One adaptive production APK supports phone and TV. It excludes demo assets and
Developer UI. `video_player` is the only selectable production engine; Better
Player's native/transitive dependencies remain packaged. Database schema 6 and
data-only backup format 3 are unchanged. Backups exclude media bytes.

Update production-signed beta.2+ in place with the permanent signer; do not
uninstall or clear data. Legacy debug-signed beta.1 has its own migration guide.
The WorkManager/Room constructor fix and APK startup guard remain enabled,
without disabling shrinking.

### Candidate gates — record exact artifact evidence

- [ ] clean preparation commit; formatter, analyzer, development and production tests
- [ ] signed production pipeline; expected package, versionCode, signer and checksum
- [ ] packaged WorkDatabase constructor; no production demo assets or Developer UI
- [ ] candidate Samsung in-place update and retained library/progress/resume
- [ ] candidate Fire Stick in-place update, remote navigation and HOME/return
- [ ] candidate cold startup/reopen and fresh onboarding on a disposable installation
- [ ] backup/restore tested only on a disposable installation

The maintainer confirmed startup/primary flows on Samsung and Fire Stick for
the corrected **pre-RC** APK at `98d3b2e`. Do not mark RC gates from that evidence
or from emulator results. Record device/OS and APK SHA-256 for each physical gate.

Provider availability and formats vary. Advanced selectable tracks, cloud sync,
background playback and Vega OS are not promised. Zanka remains independent and
unofficial and grants no rights to third-party content.
