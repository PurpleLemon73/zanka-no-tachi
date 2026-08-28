import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/media.dart';
import '../canonical/domain/user_state.dart';
import '../canonical/persistence/canonical_database.dart';
import 'local_playback_source.dart';

const sampleAnimeId = CanonicalMediaId('local-sample-anime');
const sampleEpisodeOneId = CanonicalEpisodeId('local-sample-episode-1');
const sampleEpisodeTwoId = CanonicalEpisodeId('local-sample-episode-2');

class SampleAnimeInstaller {
  SampleAnimeInstaller(this.database, {Directory? root}) : _root = root;
  final CanonicalDatabase database;
  final Directory? _root;

  Future<CanonicalMediaId> install() async {
    final root =
        _root ??
        Directory(
          '${(await getApplicationSupportDirectory()).path}/sample-anime',
        );
    await root.create(recursive: true);
    final primary = await _copyAsset(root, 'episode-1-primary.mp4');
    final alternate = await _copyAsset(root, 'episode-1-alternate.mp4');
    final episodeTwo = await _copyAsset(root, 'episode-2.mp4');
    final poster = await _copyShowcaseAsset(
      root,
      'assets/showcase/nova_pulse/poster.png',
      'nova-pulse-poster.png',
    );
    const provenance = FieldProvenance(providerId: localVideoProviderId);
    await database.transaction(() async {
      await database.saveMedia(
        CanonicalAnime(
          id: sampleAnimeId,
          title: SourcedValue(value: 'Nova Pulse', provenance: provenance),
          description: SourcedValue(
            value:
                'A response team races across a neon megacity to understand an energy pulse that predicts disasters moments before they happen.',
            provenance: provenance,
          ),
          status: CanonicalMediaStatus.completed,
          format: AnimeFormat.tv,
          knownEpisodeTotal: 2,
          coverLocator: poster.path,
        ),
      );
      for (final episode in const [
        CanonicalEpisode(
          id: sampleEpisodeOneId,
          mediaId: sampleAnimeId,
          label: EpisodeLabel(rawLabel: 'Episode 1', number: 1),
          title: 'Signal at Zero Hour',
        ),
        CanonicalEpisode(
          id: sampleEpisodeTwoId,
          mediaId: sampleAnimeId,
          label: EpisodeLabel(rawLabel: 'Episode 2', number: 2),
          title: 'The City Between Pulses',
        ),
      ]) {
        await database.saveEpisode(episode);
      }
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: sampleAnimeId,
          providerId: localVideoProviderId,
          externalId: 'zanka-sample-video',
        ),
      );
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: sampleAnimeId,
          providerId: localVideoAlternateProviderId,
          externalId: 'zanka-sample-video-alternate',
        ),
      );
      await database.saveEpisodeBinding(
        EpisodeSourceBinding(
          canonicalId: sampleEpisodeOneId,
          providerId: localVideoProviderId,
          externalId: 'sample-video-episode-1-primary',
          relativeLocator: primary.path,
        ),
      );
      await database.saveEpisodeBinding(
        EpisodeSourceBinding(
          canonicalId: sampleEpisodeOneId,
          providerId: localVideoAlternateProviderId,
          externalId: 'sample-video-episode-1-alternate',
          relativeLocator: alternate.path,
        ),
      );
      await database.saveEpisodeBinding(
        EpisodeSourceBinding(
          canonicalId: sampleEpisodeTwoId,
          providerId: localVideoProviderId,
          externalId: 'sample-video-episode-2',
          relativeLocator: episodeTwo.path,
        ),
      );
      final now = DateTime.now().toUtc();
      final current = await database.libraryEntry(sampleAnimeId);
      await database.saveLibraryEntry(
        CanonicalLibraryEntry(
          mediaId: sampleAnimeId,
          isSaved: true,
          isFavorite: false,
          status: CanonicalLibraryStatus.inProgress,
          createdAt: current?.createdAt ?? now,
          updatedAt: now,
        ),
      );
    });
    return sampleAnimeId;
  }

  Future<File> _copyAsset(Directory root, String name) async {
    final data = await rootBundle.load('assets/sample_anime/$name');
    final file = File('${root.path}/$name');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file;
  }

  Future<File> _copyShowcaseAsset(
    Directory root,
    String assetPath,
    String name,
  ) async {
    final data = await rootBundle.load(assetPath);
    final file = File('${root.path}/$name');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file;
  }
}
