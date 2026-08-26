# Canonical Matching and Reconciliation

## 1. Matching evidence

`MatchCandidate` records both canonical IDs, confidence, review requirement,
and typed evidence. Current evidence includes media kind, normalized title,
anime format, observed airing year, explicit reviewed mapping, and a reserved
trusted external-ID fact. Provider-local IDs, hosts, and URLs are never
canonical evidence. Missing evidence remains unknown rather than negative.

## 2. Confidence policy

- `exactExplicit`: an explicit reviewed mapping or trusted canonical metadata
  ID agrees and strong metadata does not conflict.
- `highConfidenceCandidate`: title, anime format, and observed airing year agree.
  This still requires review.
- `ambiguousCandidate`: currently includes normalized title agreement without
  enough independent evidence.
- `notAMatch`: insufficient supporting evidence or a strong conflict.

Different media kinds reject. Conflicting known anime formats or airing years
reject. An unknown format/year does not invent a conflict.

## 3. Auto-merge policy

Title similarity never auto-merges. `mayAutoMerge` is true only for
`exactExplicit` evidence without a review requirement. M3 does not run a
background auto-merge worker; ingestion always creates a separate canonical
record for an unseen provider binding.

## 4. Reviewed/manual merge

`mergeCanonicalMedia(sourceId, targetId)` is explicit: `targetId` survives and
`sourceId` becomes historical. It rejects aliases, self-merge, incompatible
kinds/strong metadata, and duplicate provider media bindings. Target metadata
wins deterministic conflicts while source titles/provenance are retained as
alternate sourced facts. Bindings, compatible installments, library state,
progress, and preferences are reconciled in one operation.

## 5. Surviving canonical ID policy

There is no lexical, oldest, or provider-derived winner. The reviewer chooses
the target. This makes references and UI confirmation unambiguous.

## 6. Canonical aliases

An alias maps the retired ID to the surviving ID. Resolution follows chains
with a visited-ID guard. Self redirects and redirects that would resolve back
to the historical ID are rejected, preventing cycles. Active-media queries hide
aliased rows, while the retained historical row supports exact recovery.

## 7. Installment reconciliation

Chapters reconcile only after the parent manga is confirmed equal, only on an
exact normalized numeric value, and only when known volume labels agree.
`142`, `142.5`, and `142.50` retain their exact normalized digit semantics;
`142` never equals `142.5`. Specials/extras have no numeric identity and remain
separate. Conflicting volumes remain separate.

Episodes reconcile only inside confirmed-equal TV media, using the same
standard integer episode number and compatible known narrative season. Airing
season is never treated as narrative season. Movies, OVA, ONA, music, specials,
fractional/unknown numbering, and conflicting narrative seasons remain
separate for review.

## 8. Conflict handling

Conflicts are typed and returned in deterministic processing order: title,
provenance, installment ambiguity, library status, and progress differences.
The target title is primary; source sourced values remain alternates. Library
booleans use logical OR, and the newer library status/progress record wins the
active target projection. Both original source and target facts remain in the
recovery snapshot/historical rows. Duplicate provider media bindings reject
the merge rather than overwrite either binding.

## 9. Merge transaction behavior

The complete merge—metadata, installment/media binding movement, library and
progress projection, preference, alias, audit, and fingerprint—is a single
Drift transaction. Any exception rolls it all back. Ingestion and normal reads
resolve against only committed state.

## 10. Split/recovery guarantees

Each merge audit stores the target pre-merge state plus every binding move and
an aggregate post-merge fingerprint. `undoMerge(auditId)` restores target state,
source media/installment bindings, page resumes, preferences, and the old active
identity, then removes the alias. Undo is exact for the tested immediate merge
scenarios and survives database reopen.

Undo deliberately refuses if the merged aggregate changed after the merge.
This prevents silently discarding later ingestion or user changes. Arbitrary
partial split, choosing individual bindings from a long-edited merge, and
rewriting a later chain of merges are not claimed; those need an M4 reviewed
recovery workflow.

## 11. Source availability aggregation

`SourceAvailabilityRepository` returns media availability with all provider
bindings and chapter/episode availability with every binding attached to that
canonical installment. It resolves historical media IDs before querying. No UI
or application caller needs provider DTOs to display coverage gaps.

## 12. Preferred source selection

Selection checks an available per-media provider first, then a configured
preference for the media kind, then an explicit fallback order, and finally a
stable provider-ID ordering. A preference that is unavailable is skipped. The
same policy selects media, chapter, or episode bindings and never fetches a
payload or discovers another domain.

## 13. Manga page-resume semantics

Canonical manga progress identifies media, canonical chapter, and the legacy
page position used by M1. Cross-provider continuity is guaranteed at chapter
identity only. `MangaSourcePageResume` separately keys the precise page index by
media, chapter, provider, and provider chapter external ID. Saving it validates
that exact binding. It moves with that binding during merge/split and is never
copied to another scan as page equivalence.

## 14. Anime playback-position semantics

Canonical anime progress follows the reconciled episode. Its playback position
and duration are retained through merge/split. A future player may offer the
position when switching providers, but different encodes can have different
cuts, timing, or duration, so portability is approximate and must be confirmed
by the user/player. M3 extracts no streams.

## 15. Concurrency strategy

First ingestion is serialized in-process by stable `providerId/externalId` key
across service instances. The binding lookup, canonical/installment ID
allocation, and complete import also run in one database transaction. Database
unique constraints remain the final invariant. Tests launch two concurrent
imports of one unseen binding and require one canonical entity and one creator.

This protects the current single-process Flutter application. Multi-process or
cloud writers will require database-specific upsert/retry coordination.

## 16. Risks for M4

- Matching lacks broadly available authors, studios, release windows, and
  trusted third-party canonical IDs; reviewed false positives remain possible.
- Volume labels and special installment naming vary too much for automatic
  reconciliation; a manual installment mapping workflow is still needed.
- Immediate fingerprint-protected undo is safe but not a general historical
  split editor after later writes or merge chains.
- Provider-specific episode edits and alternate-order schemes need richer
  narrative identity before reconciliation can expand beyond standard TV.
- Page and playback portability require reader/player UX and must never imply
  scan/encode equivalence.
- In-process ingestion serialization is not sufficient for multiple processes,
  sync replicas, or remote writers.

### Developer validation data

The harness action **Seed synthetic M3 scenarios** transactionally and
idempotently creates the documented A/B manga and anime coverage without HTTP.
These records are visibly labeled synthetic, use synthetic provider IDs, and
exist only to make reviewed merge, alias inspection, availability, and undo
physically testable when production providers do not overlap by media kind.
