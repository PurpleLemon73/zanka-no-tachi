import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release retains only the reflected WorkDatabase constructor', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final rules = File('android/app/proguard-rules.pro')
        .readAsLinesSync()
        .where((line) => !line.trimLeft().startsWith('#'))
        .join('\n')
        .trim();
    expect(gradle, contains('proguardFiles("proguard-rules.pro")'));
    expect(
      rules,
      '-keep class androidx.work.impl.WorkDatabase_Impl {\n'
      '    public <init>();\n'
      '}',
    );
    final releaseTool = File(
      'tool/build_release_candidate.sh',
    ).readAsStringSync();
    final guard = releaseTool.indexOf('tool/verify_release_startup.sh');
    expect(guard, greaterThan(releaseTool.indexOf('flutter build apk')));
    expect(guard, lessThan(releaseTool.indexOf(r'cp "$source_apk"')));
  });

  late Directory directory;
  late File analyzer;
  late File apk;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('zanka-startup-guard-');
    analyzer = File('${directory.path}/cmdline-tools/latest/bin/apkanalyzer');
    await analyzer.parent.create(recursive: true);
    apk = await File(
      '${directory.path}/candidate.apk',
    ).writeAsString('fixture');
  });
  tearDown(() => directory.delete(recursive: true));

  Future<ProcessResult> check(String analyzerBody) async {
    await analyzer.writeAsString('#!/usr/bin/env bash\n$analyzerBody\n');
    final chmod = await Process.run('chmod', ['+x', analyzer.path]);
    expect(chmod.exitCode, 0);
    return Process.run(
      'bash',
      ['tool/verify_release_startup.sh', apk.path],
      environment: {'ANDROID_SDK_ROOT': directory.path},
    );
  }

  test(
    'artifact guard rejects a retained class with a stripped constructor',
    () async {
      final result = await check(
        "printf '%s\\n' '.class public final Landroidx/work/impl/WorkDatabase_Impl;' "
        "'.method public final c()V'",
      );
      expect(result.exitCode, 1);
      expect(
        result.stderr,
        contains('public no-argument constructor is missing'),
      );
    },
  );

  test('artifact guard accepts the public no-argument constructor', () async {
    final result = await check(
      "printf '%s\\n' '.class public final Landroidx/work/impl/WorkDatabase_Impl;' "
      "'.method public constructor <init>()V'",
    );
    expect(result.exitCode, 0, reason: result.stderr.toString());
    expect(
      result.stdout,
      contains('actual device launch smoke test is still required'),
    );
  });

  test('artifact inspection failure cannot silently pass', () async {
    final result = await check('exit 1');
    expect(result.exitCode, 1);
    expect(result.stderr, contains('could not be inspected'));
  });
}
