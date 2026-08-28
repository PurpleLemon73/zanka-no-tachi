## Zanka no Tachi v0.2.0-beta.1 — First Public Beta

### Highlights

- One adaptive APK for Android phone/tablet and Android TV / Google TV / Fire TV
- Canonical multi-source library, Smart Resume, and exact source resume
- Live MangaWorld reader and AnimeWorld player where public delivery is verified
- Lawful local manga/video import, repair, playback, and portable backup

### Artifact

- `zanka-no-tachi-v0.2.0-beta.1.apk`
- Signing: **debug-signed development APK; not production signed**
- SHA-256: `84ee53798fc19d46b501539403601b5cad17af0db4ceb7f918bae8998a908e6e`

### Validation

- [ ] CI green
- [ ] Full Flutter tests/analyze green
- [ ] Samsung Android 16 smoke test complete
- [ ] Google TV validation evidence reviewed
- [ ] APK SHA-256 verified after download
- [ ] Full reachable Git history/public-hygiene audit passed

Physical Fire TV validation remains outstanding. The core TV path does not
require Google Play Services, but this is not a physical certification claim.

### Known limitations

- Provider availability and public delivery shapes may change independently.
- Protected-content extraction, auth/CAPTCHA/anti-bot bypass, DRM circumvention,
  and automatic domain discovery are intentionally unsupported.
- No cloud sync, background playback, TV recommendations, or TV manga redesign.

All screenshots and showcase media use the original fictional Ashen Blade and
Nova Pulse assets created specifically for Zanka. Zanka is independent and
unofficial and grants no rights to third-party content.
