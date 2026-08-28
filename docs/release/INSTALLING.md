# Install Zanka no Tachi

Zanka's first beta uses one adaptive Android APK for phones, tablets, Android
TV, Google TV, and Fire TV. The app selects its presentation from Android's
semantic television capability; screen size alone does not activate TV mode.

## Verify the download

Download `zanka-no-tachi-v0.2.0-beta.2.apk` and its published SHA-256 value from
the same GitHub Release. Compare locally:

```bash
shasum -a 256 zanka-no-tachi-v0.2.0-beta.2.apk
```

The release notes state the artifact's actual signing status. Android may warn
about installing an app from outside the store. Do not continue if the checksum
or signer differs from the release information.

## Phone or tablet

Enable installation from your chosen file manager and open the downloaded APK,
or connect ADB and run:

```bash
adb install zanka-no-tachi-v0.2.0-beta.2.apk
```

Open Zanka, complete onboarding, then import your own local media or configure a
source in Settings. Android's normal app-data removal semantics apply when the
app is uninstalled; create a backup first if you need to retain library state.

## Android TV or Google TV

Enable Developer options and network/USB debugging, connect ADB, then install
the same APK:

```bash
adb connect TV_ADDRESS
adb install zanka-no-tachi-v0.2.0-beta.2.apk
```

Open Zanka from Apps. It advertises the Leanback launcher category, has a TV
banner, does not require a touchscreen, and uses the remote-first shell.

## Fire TV

Enable ADB debugging in Fire TV developer settings and install the same APK over
ADB or with a trusted sideloading workflow. Zanka's core TV path does not depend
on Google Play Services. Physical Fire TV validation is still outstanding for
this beta, so report device model and Fire OS version with any issue.

## Remote controls

| Input | Browse/details | Player |
| --- | --- | --- |
| D-pad | Move focus | Show controls / move focus |
| OK / Select | Open focused item | Play or pause |
| Left / Right | Move through rows/actions | Seek while controls are visible |
| Play / Pause | — | Play or pause |
| Back | Return | Hide controls, then return |
| Home | Leave app | Pauses through Android lifecycle handling |

Returning to an episode uses canonical completion plus the exact timestamp for
the selected source. Switching sources deliberately does not assume equivalent
timestamps.
