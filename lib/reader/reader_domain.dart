import 'dart:typed_data';

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/user_state.dart';

enum ReaderSourceCapability {
  metadataOnly,
  readerCapable,
  temporarilyUnavailable,
  unsupported,
}

enum ReaderMode { vertical, paged }

enum ReaderDirection { leftToRight, rightToLeft }

enum ReaderFit { width, contain }

class ReaderPreferences {
  const ReaderPreferences({
    this.mode = ReaderMode.vertical,
    this.direction = ReaderDirection.leftToRight,
    this.fit = ReaderFit.width,
  });

  final ReaderMode mode;
  final ReaderDirection direction;
  final ReaderFit fit;

  ReaderPreferences copyWith({
    ReaderMode? mode,
    ReaderDirection? direction,
    ReaderFit? fit,
  }) => ReaderPreferences(
    mode: mode ?? this.mode,
    direction: direction ?? this.direction,
    fit: fit ?? this.fit,
  );

  Map<String, String> toJson() => {
    'mode': mode.name,
    'direction': direction.name,
    'fit': fit.name,
  };

  factory ReaderPreferences.fromJson(Map<String, dynamic> json) =>
      ReaderPreferences(
        mode: ReaderMode.values.byName(json['mode'] as String),
        direction: ReaderDirection.values.byName(json['direction'] as String),
        fit: ReaderFit.values.byName(json['fit'] as String),
      );
}

class ReaderSessionRequest {
  const ReaderSessionRequest({
    required this.mediaId,
    required this.chapterId,
    this.binding,
  });

  final CanonicalMediaId mediaId;
  final CanonicalChapterId chapterId;
  final ChapterSourceBinding? binding;
}

class ReaderPage {
  const ReaderPage({
    required this.id,
    required this.index,
    required this.displayLocator,
    required this.loadBytes,
    this.width,
    this.height,
    this.isSpread = false,
  });

  final String id;
  final int index;
  final String displayLocator;
  final Future<Uint8List> Function() loadBytes;
  final int? width;
  final int? height;
  final bool isSpread;
}

class ReaderManifest {
  const ReaderManifest({
    required this.sourceName,
    required this.binding,
    required this.pages,
  });

  final String sourceName;
  final ChapterSourceBinding binding;
  final List<ReaderPage> pages;
}

class ReaderSession {
  const ReaderSession({
    required this.mediaId,
    required this.chapter,
    required this.manifest,
    required this.startPage,
    required this.preferences,
    this.resume,
  });

  final CanonicalMediaId mediaId;
  final CanonicalChapter chapter;
  final ReaderManifest manifest;
  final int startPage;
  final ReaderPreferences preferences;
  final MangaSourcePageResume? resume;
}

enum ReaderErrorKind {
  sourceUnavailable,
  manifestInvalid,
  pageUnavailable,
  unsupportedFormat,
  localFileMissing,
}

class ReaderException implements Exception {
  const ReaderException(this.kind, this.message, [this.cause]);
  final ReaderErrorKind kind;
  final String message;
  final Object? cause;
  @override
  String toString() => message;
}
