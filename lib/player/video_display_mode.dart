import 'dart:math' as math;

import 'package:flutter/material.dart';

/// How the selected video frame is placed inside the available player area.
///
/// Aspect-ratio selection is deliberately modeled separately. Only [stretch]
/// may distort the selected frame to match its parent.
enum VideoDisplayFit {
  autoOriginal,
  fit,
  fillCrop,
  fitWidth,
  fitHeight,
  stretch,
}

enum VideoAspectPreset {
  original,
  fourThree,
  sixteenNine,
  sixteenTen,
  twentyOneNine,
  square,
  threeTwo,
  fiveFour,
  custom,
}

class VideoDisplayMode {
  const VideoDisplayMode({
    this.fit = VideoDisplayFit.autoOriginal,
    this.aspectPreset = VideoAspectPreset.original,
    this.customAspectRatio,
  });

  final VideoDisplayFit fit;
  final VideoAspectPreset aspectPreset;
  final double? customAspectRatio;

  static const automatic = VideoDisplayMode();

  bool get isAutomatic =>
      fit == VideoDisplayFit.autoOriginal &&
      aspectPreset == VideoAspectPreset.original;

  VideoDisplayMode withFit(VideoDisplayFit value) =>
      value == VideoDisplayFit.autoOriginal
      ? automatic
      : VideoDisplayMode(
          fit: value,
          aspectPreset: aspectPreset,
          customAspectRatio: customAspectRatio,
        );

  VideoDisplayMode withAspect(VideoAspectPreset value, {double? customRatio}) {
    final ratio = value == VideoAspectPreset.custom
        ? validVideoAspectRatio(customRatio)
        : null;
    if (value == VideoAspectPreset.custom && ratio == null) return this;
    return VideoDisplayMode(
      // A forced aspect needs a real fit policy. "Auto / Original" is a
      // strict safe mode that always returns to the intrinsic dimensions.
      fit:
          value != VideoAspectPreset.original &&
              fit == VideoDisplayFit.autoOriginal
          ? VideoDisplayFit.fit
          : fit,
      aspectPreset: value,
      customAspectRatio: ratio,
    );
  }

  double? effectiveAspectRatio(double? intrinsicAspectRatio) {
    final intrinsic = validVideoAspectRatio(intrinsicAspectRatio);
    if (fit == VideoDisplayFit.autoOriginal ||
        aspectPreset == VideoAspectPreset.original) {
      return intrinsic;
    }
    return switch (aspectPreset) {
      VideoAspectPreset.original => intrinsic,
      VideoAspectPreset.fourThree => 4 / 3,
      VideoAspectPreset.sixteenNine => 16 / 9,
      VideoAspectPreset.sixteenTen => 16 / 10,
      VideoAspectPreset.twentyOneNine => 21 / 9,
      VideoAspectPreset.square => 1,
      VideoAspectPreset.threeTwo => 3 / 2,
      VideoAspectPreset.fiveFour => 5 / 4,
      VideoAspectPreset.custom => validVideoAspectRatio(customAspectRatio),
    };
  }

  Map<String, Object?> toJson() => {
    'fit': fit.name,
    'aspectPreset': aspectPreset.name,
    'customAspectRatio': customAspectRatio,
  };

  factory VideoDisplayMode.fromJson(Map<String, dynamic>? json) {
    if (json == null) return automatic;
    final fit =
        _enumByName(VideoDisplayFit.values, json['fit']) ??
        VideoDisplayFit.autoOriginal;
    final preset =
        _enumByName(VideoAspectPreset.values, json['aspectPreset']) ??
        VideoAspectPreset.original;
    final custom = validVideoAspectRatio(
      (json['customAspectRatio'] as num?)?.toDouble(),
    );
    if (preset == VideoAspectPreset.custom && custom == null) {
      return automatic;
    }
    return VideoDisplayMode(
      fit: fit,
      aspectPreset: preset,
      customAspectRatio: custom,
    );
  }
}

T? _enumByName<T extends Enum>(Iterable<T> values, Object? raw) {
  if (raw is! String) return null;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return null;
}

double? validVideoAspectRatio(double? value) =>
    value != null && value.isFinite && value > 0 ? value : null;

double? parseVideoAspectRatio(String input) {
  final parts = input.trim().split(':');
  if (parts.length != 2) return null;
  final width = double.tryParse(parts.first.trim());
  final height = double.tryParse(parts.last.trim());
  if (validVideoAspectRatio(width) == null ||
      validVideoAspectRatio(height) == null) {
    return null;
  }
  return validVideoAspectRatio(width! / height!);
}

String videoDisplayFitLabel(VideoDisplayFit value) => switch (value) {
  VideoDisplayFit.autoOriginal => 'Auto / Original',
  VideoDisplayFit.fit => 'Fit',
  VideoDisplayFit.fillCrop => 'Fill / Crop',
  VideoDisplayFit.fitWidth => 'Fit Width',
  VideoDisplayFit.fitHeight => 'Fit Height',
  VideoDisplayFit.stretch => 'Stretch / Fit Parent',
};

String videoAspectPresetLabel(VideoAspectPreset value) => switch (value) {
  VideoAspectPreset.original => 'Original',
  VideoAspectPreset.fourThree => '4:3',
  VideoAspectPreset.sixteenNine => '16:9',
  VideoAspectPreset.sixteenTen => '16:10',
  VideoAspectPreset.twentyOneNine => '21:9',
  VideoAspectPreset.square => '1:1',
  VideoAspectPreset.threeTwo => '3:2',
  VideoAspectPreset.fiveFour => '5:4',
  VideoAspectPreset.custom => 'Custom',
};

/// Returns the frame size used for a selected ratio and fit policy.
///
/// This function is intentionally engine-independent and testable without a
/// decoder. A null ratio means the engine has not reported reliable intrinsic
/// dimensions yet, so no guessed 16:9 geometry is introduced.
Size videoDisplayFrameSize({
  required Size viewport,
  required double? aspectRatio,
  required VideoDisplayFit fit,
}) {
  if (fit == VideoDisplayFit.stretch) {
    return viewport;
  }
  if (validVideoAspectRatio(aspectRatio) == null ||
      viewport.width <= 0 ||
      viewport.height <= 0) {
    return Size.zero;
  }
  final ratio = aspectRatio!;
  final widthForHeight = viewport.height * ratio;
  final heightForWidth = viewport.width / ratio;
  return switch (fit) {
    VideoDisplayFit.autoOriginal || VideoDisplayFit.fit =>
      widthForHeight <= viewport.width
          ? Size(widthForHeight, viewport.height)
          : Size(viewport.width, heightForWidth),
    VideoDisplayFit.fillCrop =>
      widthForHeight >= viewport.width
          ? Size(widthForHeight, viewport.height)
          : Size(viewport.width, heightForWidth),
    VideoDisplayFit.fitWidth => Size(viewport.width, heightForWidth),
    VideoDisplayFit.fitHeight => Size(widthForHeight, viewport.height),
    VideoDisplayFit.stretch => viewport,
  };
}

class VideoDisplaySurface extends StatelessWidget {
  const VideoDisplaySurface({
    super.key,
    required this.mode,
    required this.intrinsicAspectRatio,
    required this.child,
  });

  final VideoDisplayMode mode;
  final double? intrinsicAspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(
          math.max(0, constraints.maxWidth),
          math.max(0, constraints.maxHeight),
        );
        final size = videoDisplayFrameSize(
          viewport: viewport,
          aspectRatio: mode.effectiveAspectRatio(intrinsicAspectRatio),
          fit: mode.fit,
        );
        return OverflowBox(
          alignment: Alignment.center,
          minWidth: 0,
          minHeight: 0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: SizedBox(
            key: const Key('video-content-frame'),
            width: size.width,
            height: size.height,
            child: child,
          ),
        );
      },
    ),
  );
}
