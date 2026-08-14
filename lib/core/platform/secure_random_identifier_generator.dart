import 'dart:math';
import '../../application/ports/identifier_generator.dart';

class SecureRandomIdentifierGenerator implements IdentifierGenerator {
  final Random _random;

  SecureRandomIdentifierGenerator() : _random = Random.secure();

  // For testing deterministic generation
  SecureRandomIdentifierGenerator.withRandom(this._random);

  @override
  String generate() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    // Set version 4
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set variant to RFC 4122
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}
