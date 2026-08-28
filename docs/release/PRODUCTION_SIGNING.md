# Production Android signing

Zanka's permanent Android upgrade identity begins with `v0.2.0-beta.2`.

- Alias: `zanka-release`
- Key: RSA 4096-bit
- Certificate subject: `CN=Zanka no Tachi Release, OU=Open Source Project, O=Zanka no Tachi`
- Certificate SHA-256: `3F:4A:86:F7:F4:DD:A3:98:E0:4D:D0:59:DD:33:D7:FC:27:4C:AC:B3:62:17:A4:68:B6:D8:D7:C7:07:4C:13:41`

The keystore and passwords are maintainer-controlled secrets. They live outside
the repository. The ignored `android/key.properties` contains only local paths
and credentials and must remain mode `0600`. Never attach either file to an
issue, release, backup, diagnostic report or CI log.

## Secure backup and recovery

Keep at least two encrypted, offline copies of the keystore and a separately
protected password record. Test that each backup can list the alias and expected
certificate fingerprint without exposing passwords. Record custody changes.

Losing either the keystore or its credentials permanently prevents future APKs
from updating installations signed with this identity. Replacing it would force
another uninstall/reinstall migration and lose app-private state unless users
exported a Zanka backup first. Never rotate this key casually.

## Release verification

From a clean tracked tree, run:

```bash
tool/release_android.sh
```

The script runs formatting, analysis and all tests; builds the release APK;
verifies package/version/signing; requires the fingerprint above; and emits a
deterministically named APK plus SHA-256 file under ignored `artifacts/`.
Release builds never fall back to Android's debug key.
