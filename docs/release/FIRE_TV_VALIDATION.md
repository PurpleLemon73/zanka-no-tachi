# Fire TV validation status

No physical Fire TV or Fire Stick was available for M16. That historical
deferral is superseded for the corrected pre-RC production build: the maintainer
confirmed startup and primary product flows on a Fire TV Stick (and Samsung
phone) after the WorkManager/R8 fix at `98d3b2e`. Exact device/OS and per-action
evidence were not supplied. This is not certification of all Fire devices.

On 2026-09-24 the maintainer reported RC testing complete and approved promotion
to stable 1.0.0. The RC checklist covers in-place update/data preservation,
remote navigation, playback/resume, HOME/return and cold reopen; individual
results, device/OS details and disposable backup/onboarding evidence were not
supplied. Record this as maintainer RC acceptance, not an independently observed
pass for every checklist item or certification of other Fire devices.

**The exact stable 1.0.0 artifact still requires physical verification.** Test
it as an in-place update, without uninstalling or clearing existing app data.
The single adaptive APK and absence of a core Google Play Services requirement
are unchanged. Check:

- launcher banner and TV category visibility;
- first-run onboarding and D-pad focus on a separate disposable installation;
- Search, Library, landscape Details and shared Smart Resume;
- lawful local video plus an available live AnimeWorld episode;
- play/pause, seek, media keys, audio focus and exact timestamp resume;
- HOME/background/return lifecycle and natural-end autoplay;
- backup/export access and a cold relaunch;
- package/version/signer fingerprint collected with ADB.

Record device/model, Fire OS version, APK SHA-256 and pass/fail observations.
Do not claim certification from emulator evidence.
