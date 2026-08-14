import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/core/platform/secure_random_identifier_generator.dart';

void main() {
  group('SecureRandomIdentifierGenerator', () {
    test('generates valid RFC 4122 v4 UUID format', () {
      final generator = SecureRandomIdentifierGenerator();
      final id = generator.generate();

      final regex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );

      expect(
        regex.hasMatch(id),
        isTrue,
        reason: 'ID $id does not match RFC 4122 v4 UUID format',
      );
    });

    test('generates unique IDs across a sample', () {
      final generator = SecureRandomIdentifierGenerator();
      final sampleSize = 10000;
      final ids = <String>{};

      for (var i = 0; i < sampleSize; i++) {
        ids.add(generator.generate());
      }

      expect(
        ids.length,
        equals(sampleSize),
        reason: 'Expected $sampleSize unique IDs, got ${ids.length}',
      );
    });

    test('deterministic fake generator produces repeatable output', () {
      // By using a seeded random, the output should be completely deterministic
      final generator1 = SecureRandomIdentifierGenerator.withRandom(
        Random(12345),
      );
      final generator2 = SecureRandomIdentifierGenerator.withRandom(
        Random(12345),
      );

      expect(generator1.generate(), equals(generator2.generate()));
      expect(generator1.generate(), equals(generator2.generate()));
    });
  });
}
