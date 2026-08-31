## Zanka no Tachi v0.2.0-beta.3 — Player UI v2

### Highlights

- New Player UI v2: Previous/Next Episode, Replay, a prominent completion CTA,
  end-of-available-content state, in-player episode picker, timeline, and
  ±10-second seeking.
- TV-first D-pad navigation with mobile touch adaptation.
- Engine-neutral player architecture internally; `video_player` remains the
  sole production engine.
- The rejected experimental `media_kit` runtime is not included in this APK.

### Upgrade note

Beta.2 and beta.3 use the same permanent production signer, so Android updates
normally in place. Beta.1 was debug-signed and still requires the documented
backup → uninstall → install → restore migration.

### Artifact

- `zanka-no-tachi-v0.2.0-beta.3.apk`
- Package: `dev.zanka.notachi`
- Version: `0.2.0-beta.3` (`versionCode 4`)
- Signer SHA-256: `3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41`
- APK size: `91,913,516` bytes
- APK SHA-256: `2b49c7892490d9889c015fff8a7de757be104d1c5163fce9f09d6a3ba389b356`

### Release gates

- [x] clean-tree release pipeline passed
- [x] clean-tree signed release pipeline passed
- [x] Samsung beta.2 → beta.3 in-place update gate passed
- [x] Television_4K Leanback/update gate passed
- [ ] signer and downloaded APK checksum independently verified

Physical Fire TV validation remains deferred. Zanka is architecturally Fire
OS-compatible without Google Play Services, but this is not certification.

Advanced selectable embedded audio/subtitle tracks are not exposed by the
production engine. Physical Fire TV validation remains deferred, and Vega OS is
unsupported.
