import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/player/local_playback_source.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/sample_anime_installer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'offline sample installs two episodes and two distinct episode 1 encodes',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      final root = await Directory.systemTemp.createTemp('zanka-anime-sample');
      addTearDown(() async {
        await database.close();
        await root.delete(recursive: true);
      });

      await SampleAnimeInstaller(database, root: root).install();

      final episodes = await database.episodesFor(sampleAnimeId);
      expect(episodes, hasLength(2));
      final episodeOneBindings = await database.episodeBindingsFor(
        sampleEpisodeOneId,
      );
      expect(episodeOneBindings, hasLength(2));
      expect(episodeOneBindings.map((binding) => binding.providerId).toSet(), {
        localVideoProviderId,
        localVideoAlternateProviderId,
      });
      for (final binding in episodeOneBindings) {
        expect(await File(binding.relativeLocator!).exists(), isTrue);
        final source = LocalVideoPlaybackSource(binding.providerId, 'Local');
        expect(
          source.capability(binding),
          PlaybackSourceCapability.playbackCapable,
        );
      }
      expect((await database.libraryEntry(sampleAnimeId))?.isSaved, isTrue);
    },
  );
}
