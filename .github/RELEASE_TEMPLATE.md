## Zanka no Tachi v0.2.0-beta.4 — Reader UI v2

### Highlights

- Manga Reader UI v2 with Previous/Next Chapter, a prominent completion action,
  and a bounded lazy canonical chapter picker.
- Truthful volume-aware chapter navigation without invented volume metadata.
- Exact source-specific page resume remains independent from canonical
  completion; manual Next starts at page one without overwriting saved resume.
- Live Video Display Mode controls with independent fit/aspect selection,
  presets, custom ratios, and Auto / Original as the safe default.
- `video_player` remains the sole production playback engine; no experimental
  player runtime is included in this APK.

### Upgrade note

Beta.2 through beta.4 use the same permanent production signer, so Android updates
normally in place. Beta.1 was debug-signed and still requires the documented
backup → uninstall → install → restore migration.

### Artifact

- `zanka-no-tachi-v0.2.0-beta.4.apk`
- Package: `dev.zanka.notachi`
- Version: `0.2.0-beta.4` (`versionCode 5`)
- Signer SHA-256: `3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41`
- APK size: `92,077,580` bytes
- APK SHA-256: `6e34c3fd89e535ff9d0cdb7e6a009075b356aa07cc259c3833c74fd162c327aa`

### Release gates

- [x] clean-tree signed release pipeline passed
- [x] Samsung beta.3 → beta.4 in-place update gate passed
- [x] Television_4K Leanback/update gate passed
- [ ] signer and downloaded APK checksum independently verified

Physical Fire TV validation remains deferred. Zanka is architecturally Fire
OS-compatible without Google Play Services, but this is not certification.

Advanced selectable embedded audio/subtitle tracks are not exposed by the
production engine. Physical Fire TV validation remains deferred, and Vega OS is
unsupported.
