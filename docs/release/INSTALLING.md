# Install Zanka no Tachi

Zanka uses one adaptive Android APK for phones, tablets, Android
TV, Google TV, and Fire TV. The app selects its presentation from Android's
semantic television capability; screen size alone does not activate TV mode.

## Verify the download

RC.1 is a maintainer candidate, **not yet a GitHub Release**. Use the handed-off
`zanka-no-tachi-v1.0.0-rc.1.apk` and matching `.sha256`; locally they are generated
under `artifacts/`. The last published beta remains `v0.2.0-beta.4`. Do not confuse
that older public APK/checksum with this RC. Compare the candidate locally:

```bash
shasum -a 256 zanka-no-tachi-v1.0.0-rc.1.apk
```

The release notes state the artifact's actual signing status. Android may warn
about installing an app from outside the store. Do not continue if the checksum
or signer differs from the release information.

RC.1 must report `dev.zanka.notachi`, version `1.0.0-rc.1`, build `6`, and the
[permanent production certificate](PRODUCTION_SIGNING.md). Existing production
beta.2+ installations update in place; do not uninstall or clear their data.
The development ID `dev.zanka.notachi.debug` is separate. A production-flavor
debug APK is not a substitute for the signed release.

## Phone or tablet

Enable installation from your chosen file manager and open the downloaded APK,
or connect ADB and run:

```bash
adb -s SAMSUNG_SERIAL install -r zanka-no-tachi-v1.0.0-rc.1.apk
```

On an existing installation, verify Library, preferences and exact reader/player
resume survive the update and cold reopen. On a separate disposable fresh
installation, verify onboarding and import your own lawful CBZ/video; production
has no sample installers or Developer UI. See the [RC checklist](v1.0.0-rc.1.md#candidate-installation-checklist).

## Android TV or Google TV

Enable Developer options and network/USB debugging, connect ADB, then install
the same APK:

```bash
adb connect TV_ADDRESS
adb -s TV_SERIAL install -r zanka-no-tachi-v1.0.0-rc.1.apk
```

Open Zanka from Apps. It advertises the Leanback launcher category, has a TV
banner, does not require a touchscreen, and uses the remote-first shell.

## Fire TV

Enable ADB debugging in Fire TV developer settings and install the same APK over
ADB or with a trusted sideloading workflow. Zanka's core TV path does not depend
on Google Play Services. After connecting to the intended Fire Stick, update
with `adb -s FIRE_SERIAL install -r zanka-no-tachi-v1.0.0-rc.1.apk`.
The maintainer confirmed primary flows on the corrected pre-RC build, but
RC.1's physical gate is still pending. Record model, Fire OS version and the
candidate checksum; see [Fire validation](FIRE_TV_VALIDATION.md).

## Backup and fresh-install checks

Export a data-only backup outside private app storage before updating. Backups
use format 3 and the database uses schema 6; RC.1 does not change either.
Test restore only on a disposable installation, reviewing its preview first.
Media bytes are not backed up: restored local assets are missing/repairable.
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
