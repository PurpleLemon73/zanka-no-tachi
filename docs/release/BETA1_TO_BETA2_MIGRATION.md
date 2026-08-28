# Migrating from beta.1 to beta.2

`v0.2.0-beta.1` was debug-signed. `v0.2.0-beta.2` starts Zanka's permanent
production signing identity. Android therefore cannot install beta.2 over
beta.1 even though the package ID remains `dev.zanka.notachi`.

If beta.1 contains library or progress worth preserving:

1. Open beta.1 and go to Settings → Local media.
2. Create a data-only Zanka backup.
3. Export/save the `.zanka-backup.zip` outside Zanka's private app storage.
4. Uninstall beta.1.
5. Install the production-signed beta.2 APK.
6. Open Settings → Local media → Restore backup and review the preview.
7. Restore, then verify Library, completion, reader pages and episode timestamps.
8. Repair local media paths as needed; media files are intentionally excluded
   from a data-only backup.

This path is covered by the backup compatibility suite: canonical IDs, saved
state, preferences, canonical progress and exact source resume are retained;
restore is non-destructive and omitted local assets become repairable/missing.
Future production-signed Zanka releases using the documented certificate should
install normally over beta.2.
