# Fire TV validation status

No physical Fire TV or Fire Stick was available for M16. That historical
deferral is superseded for the corrected pre-RC production build: the maintainer
confirmed startup and primary product flows on a Fire TV Stick (and Samsung
phone) after the WorkManager/R8 fix at `98d3b2e`. Exact device/OS and per-action
evidence were not supplied. This is not certification of all Fire devices.

**RC.1 physical validation remains pending.** Test the exact newly packaged APK
as an in-place update, without uninstalling or clearing existing app data.
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
