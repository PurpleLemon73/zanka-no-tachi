# Local Library and Backup

## 1. Asset ownership model

`LocalAsset` records physical-content lifecycle separately from canonical media. Its opaque ID, kind, ownership, state, source-binding key, canonical media/installment IDs, display filename, managed relative path, size, and timestamps are persisted in schema version 4. Ownership is `appOwnedCopy`, `externalReference`, or `bundledSample`; state is available, missing, unreadable, unsupported, or pending preparation. A path is never an identity.

## 2. Import flows

Settings → Local media imports CBZ archives, top-level image folders, and local video. Image folders are normalized into a CBZ. The user supplies a title and chapter/episode label, with an optional manga volume. The user may create canonical media or deliberately attach to an existing item of the same kind; title similarity never attaches automatically. Validation precedes registration and a foreground busy state covers preparation.

## 3. Copy/reference policy

Production imports default to app-owned copies under application-support storage. Each destination uses an opaque asset directory, preventing filename collisions and insulating identity from file moves. A `.partial-*` staging file is renamed only after copying; failures clean staging and destination artifacts. Durable external URI permissions are inconsistent across Flutter platforms, so the product does not promise external-reference durability. The model retains that ownership mode for a future platform-specific implementation. Data-only backups omit media bytes; full local-media backup is deferred.

## 4. Source-binding integration

Imports use ordinary canonical bindings. Manga uses `local-import-manga`; video uses `local-import-video`. Media and chapter/episode bindings participate in M3 availability. Configured M5 `LocalCbzReaderSource` and M6 `LocalVideoPlaybackSource` instances resolve them, so normal reader/player widgets remain provider-agnostic.

## 5. Missing-file detection

Refresh checks every tracked managed path. Missing paths become `missing`; empty/unreadable files become `unreadable`; archives without supported images become `unsupported`. Reader/player capability checks also refuse absent locators and files. Canonical media, Library state, and canonical progress remain intact.

## 6. Repair semantics

Repair validates a replacement, copies it into the managed asset location, and updates the existing binding locator and asset state without changing asset, media, installment, or binding identity. Canonical progress and exact source resume survive because repair means “same reviewed source asset, replacement payload.” A semantically different chapter/episode should be a new import.

## 7. Removal semantics

Library membership, local-source removal, and physical deletion are separate. Library removal elsewhere does not touch files. Local removal deletes the installment binding and exact-source resume, but preserves canonical entities, Library state, and canonical progress. The final asset also removes stale media-level local availability. App-owned bytes are deleted only after explicit confirmation; “Keep physical file” removes tracking/bindings while leaving bytes. Canonical-media deletion is not offered here.

## 8. Storage accounting

Local media reports tracked asset count, missing count, app-owned manga bytes, app-owned video bytes, and per-item size. It deliberately does not scan or claim untracked device storage.

## 9. Backup format and versioning

The data-only file is a ZIP conventionally named `*.zanka-backup.zip`. Version 1 contains `manifest.json` (format, version, mode, creation time) and `state.json`. State contains canonical media/installments, source bindings, aliases and sanitized merge audits, Library, canonical progress, exact-source resumes, preferred providers, reader/player settings, and local-asset descriptors. Local locators and absolute paths in reconciliation snapshots are removed. Provider configuration is runtime-only today, so no secrets or unstable base URLs are exported.

## 10. Restore and conflict policy

Preview validates the ZIP, format, and supported version and reports counts. Database restoration is one transaction. Missing entities/bindings are added; current records absent from backup remain. Saved/favorite flags form a union. Newest timestamped progress wins. Binding ownership conflicts are skipped and surfaced. Existing source preferences win; backup preferences fill gaps. Restored local assets have no managed path and are explicitly `missing`. Reader/player preferences apply only after the transaction succeeds. Malformed and future-version files are rejected before mutation.

## 11. Product UX

Settings exposes Local media without Developer mode. It provides import actions, storage summary, asset state/ownership, repair, two explicit removal choices, data-only backup export, restore preview, and conflict feedback. Import states that Zanka creates an app-owned copy.

### Deterministic offline validation

1. Put a lawful CBZ containing at least one JPG/PNG and a lawful MP4 in device Downloads.
2. Launch Zanka and open Settings → Local media.
3. Choose Import CBZ, select the archive, keep “Create new canonical media,” enter a title/chapter label, and import.
4. Open Library → the new manga → its chapter. Confirm the M5 reader renders pages; return after changing page so progress is saved.
5. Choose Import video, select the MP4, enter a title/episode label, and import.
6. Open Library → the new anime → its episode. Confirm M6 plays it; seek, return, reopen, and confirm resume.
7. Return to Local media and verify two tracked assets, zero missing, and nonzero separated manga/video sizes.
8. In media details, remove one item from Library. Confirm its Local media asset remains; add it to Library again.
9. For a debug validation only, move one app-owned file out of Zanka's managed asset directory, reopen Local media, and confirm `missing`. Choose Repair / replace and select the original lawful source. Confirm the state returns to available and canonical progress is unchanged.
10. Open an asset menu → Remove local source. First choose Keep physical file and confirm Library/progress remain. With another disposable import, choose Delete copy and source and confirm the warning before deletion.
11. Choose Create data-only backup and save `zanka-data.zanka-backup.zip` to Downloads.
12. Change Library/progress, choose Restore backup, select that ZIP, inspect the counts and “kept and merged” warning, then restore. Confirm newer local progress is not rolled back.
13. Force-stop and relaunch Zanka. Confirm Library, canonical progress, preferences, and imported bindings persist. A data-only restore on a different install intentionally shows local assets as missing until repaired/re-imported.

## 12. Platform limitations

Native picker behavior and playable codecs vary by platform. Folder picking exists only where supported. Preparation is asynchronous with visible foreground state, but has no OS background job or byte-level cancellation. Durable external references and full-media backup are intentionally not claimed.

## 13. Future integration points

M8 can add durable document grants, byte-level progress/cancellation, batch metadata, thumbnails, full lawful-media backup with size planning, and codec probing. Adapter capabilities should continue to advertise metadata, reader, and playback independently while preserving the canonical/binding boundary.
