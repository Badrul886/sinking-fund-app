import 'currency_data.dart';

class CurrencyMetadata {
  final String alpha3Code;
  final int numericCode;
  final String name;
  final int minorUnitExponent;

  const CurrencyMetadata({
    required this.alpha3Code,
    required this.numericCode,
    required this.name,
    required this.minorUnitExponent,
  });
}

class Currency {
  final String code;
  const Currency(this.code);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Currency && code == other.code;

  @override
  int get hashCode => code.hashCode;

  CurrencyMetadata get metadata => CurrencyRegistry.get(code);
}

class CurrencyRegistry {
  static CurrencyMetadata get(String code) {
    final meta = iso4217Currencies[code];
    if (meta == null) {
      throw StateError('Currency $code not found in registry');
    }
    return meta;
  }
}
