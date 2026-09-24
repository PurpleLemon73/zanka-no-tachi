# Install Zanka no Tachi

Zanka uses one adaptive Android APK for phones, tablets, Android
TV, Google TV, and Fire TV. The app selects its presentation from Android's
semantic television capability; screen size alone does not activate TV mode.

## Verify the download

Stable 1.0.0 is prepared for final verification, **not yet a GitHub Release**.
Use the handed-off `zanka-no-tachi-v1.0.0.apk` and matching `.sha256`, generated
locally under `artifacts/`. The last published beta remains `v0.2.0-beta.4`. Do not confuse
that older public APK/checksum with stable 1.0.0. Compare the artifact locally:

```bash
shasum -a 256 zanka-no-tachi-v1.0.0.apk
```

The release notes state the artifact's actual signing status. Android may warn
about installing an app from outside the store. Do not continue if the checksum
or signer differs from the release information.

Stable must report `dev.zanka.notachi`, version `1.0.0`, build `7`, and the
[permanent production certificate](PRODUCTION_SIGNING.md). Existing production
beta.2+ and RC.1 installations update in place; do not uninstall or clear data.
The development ID `dev.zanka.notachi.debug` is separate. A production-flavor
debug APK is not a substitute for the signed release.

## Phone or tablet

Enable installation from your chosen file manager and open the downloaded APK,
or connect ADB and run:

```bash
adb -s SAMSUNG_SERIAL install -r zanka-no-tachi-v1.0.0.apk
```

On an existing installation, verify Library, preferences and exact reader/player
resume survive the update and cold reopen. On a separate disposable fresh
installation, verify onboarding and import your own lawful CBZ/video; production
has no sample installers or Developer UI. See the [stable checklist](v1.0.0.md#stable-artifact-handoff-checklist).

## Android TV or Google TV

Enable Developer options and network/USB debugging, connect ADB, then install
the same APK:

```bash
adb connect TV_ADDRESS
adb -s TV_SERIAL install -r zanka-no-tachi-v1.0.0.apk
```

Open Zanka from Apps. It advertises the Leanback launcher category, has a TV
banner, does not require a touchscreen, and uses the remote-first shell.

## Fire TV

Enable ADB debugging in Fire TV developer settings and install the same APK over
ADB or with a trusted sideloading workflow. Zanka's core TV path does not depend
on Google Play Services. After connecting to the intended Fire Stick, update
with `adb -s FIRE_SERIAL install -r zanka-no-tachi-v1.0.0.apk`.
The maintainer confirmed pre-RC primary flows and subsequently approved RC
testing. The exact stable APK still needs physical verification. Record model,
Fire OS version and the stable checksum; see [Fire validation](FIRE_TV_VALIDATION.md).

## Backup and fresh-install checks

Export a data-only backup outside private app storage before updating. Backups
use format 3 and the database uses schema 6; stable 1.0.0 does not change either.
Test restore only on a disposable installation, reviewing its preview first.
Media bytes are not backed up: restored local assets are missing/repairable.
Keep originals separately. Restore is additive and retains newer progress;
device-local engine/display preferences remain those of the receiving device.
Verify fresh production onboarding on a separate disposable installation,
never by clearing the Samsung or Fire Stick's existing production data.

## Remote controls

| Input | Browse/details | Player |
| --- | --- | --- |
| D-pad | Move focus | Show controls / move focus |
| OK / Select | Open focused item | Play or pause |
| Left / Right | Move through rows/actions | Move player focus; reveal and seek when hidden |
| Play / Pause | — | Play or pause |
| Back | Return | Hide controls, then return |
| Home | Leave app | Pauses through Android lifecycle handling |

Returning to an episode uses canonical completion plus the exact timestamp for
the selected source. Switching sources deliberately does not assume equivalent
timestamps.
