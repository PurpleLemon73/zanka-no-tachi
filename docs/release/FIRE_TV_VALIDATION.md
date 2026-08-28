# Deferred physical Fire TV validation

No physical Fire TV or Fire Stick was available for M16. Fire OS remains
architecturally supported based on the M14 single-APK design and its lack of a
Google Play Services requirement, but it is not physically certified.

When hardware is available, validate the production-signed APK with:

- launcher banner and TV category visibility;
- first-run onboarding and D-pad focus from a clean install;
- Search, Library, landscape Details and shared Smart Resume;
- lawful local video plus an available live AnimeWorld episode;
- play/pause, seek, media keys, audio focus and exact timestamp resume;
- HOME/background/return lifecycle and natural-end autoplay;
- backup/export access and a cold relaunch;
- package/version/signer fingerprint collected with ADB.

Record device/model, Fire OS version, APK SHA-256 and pass/fail observations.
Do not claim certification from emulator evidence.
