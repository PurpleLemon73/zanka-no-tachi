import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';

void main() {
  test('volume labels sort naturally above nine and remain deterministic', () {
    final values = [
      'Volume 11',
      'Special',
      'Volume 2',
      'Volume 10',
      'Volume 1',
      'Volume 9',
      'Volume 2.5',
    ]..sort(compareNaturalVolumeLabels);
    expect(values, [
      'Volume 1',
      'Volume 2',
      'Volume 2.5',
      'Volume 9',
      'Volume 10',
      'Volume 11',
      'Special',
    ]);
    expect(compareNaturalVolumeLabels('Oneshot', null), lessThan(0));
    expect(compareNaturalVolumeLabels(null, null), 0);
  });
}
