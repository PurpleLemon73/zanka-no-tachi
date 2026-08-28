## Zanka no Tachi v0.2.0-beta.2 — Production-Signed Beta

### Important upgrade note

Beta.1 was debug-signed. Android cannot install beta.2 over it. Beta.1 users
must export a Zanka backup outside app storage, uninstall beta.1, install
beta.2, then restore. Future production-signed releases should update normally.

### Artifact

- `zanka-no-tachi-v0.2.0-beta.2.apk`
- Package: `dev.zanka.notachi`
- Version: `0.2.0-beta.2` (`versionCode 3`)
- Signer SHA-256: `3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41`
- APK SHA-256: `3f7dcfd79e41e6efa7ac447899b84c13d937da38bdab5738b7a2894c8b134d23`

### Release gates

- [ ] clean-tree release pipeline passed
- [ ] format/analyze/158 tests/debug and release APK builds passed
- [ ] backup/restore migration passed
- [ ] Samsung fresh-install UX gate passed
- [ ] Television_4K 3840×2160 gate passed
- [ ] signer and downloaded APK checksum independently verified

Physical Fire TV validation remains deferred. Zanka is architecturally Fire
OS-compatible without Google Play Services, but this is not certification.

Production playback remains `video_player`; the M16 player-engine experiment is
not included in beta.2.
