// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse(
    'https://www.six-group.com/dam/download/financial-information/data-center/iso-4217/list_one.xml',
  );
  print('Downloading ISO 4217 data from $url ...');

  try {
    final request = await HttpClient().getUrl(url);
    final response = await request.close();
    final contents = await response.transform(utf8.decoder).join();

    // We parse only CcyNtry nodes to get valid current ISO 4217 currencies
    final ccyRegex = RegExp(
      r'<CcyNtry>.*?<CcyNm>(.*?)</CcyNm>.*?<Ccy>(.*?)</Ccy>.*?<CcyNbr>(.*?)</CcyNbr>.*?<CcyMnrUnts>(.*?)</CcyMnrUnts>.*?</CcyNtry>',
      dotAll: true,
    );

    final matches = ccyRegex.allMatches(contents);
    final Set<String> codes = {};

    final out = File('lib/domain/currency_data.dart');
    final sink = out.openWrite();

    sink.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    sink.writeln(
      '// Source: ISO 4217 (https://www.six-group.com/dam/download/financial-information/data-center/iso-4217/list_one.xml)',
    );
    sink.writeln('// Generated via: dart run tool/generate_currencies.dart');
    sink.writeln('');
    sink.writeln('import \'currency.dart\';');
    sink.writeln('');
    sink.writeln('const Map<String, CurrencyMetadata> iso4217Currencies = {');

    for (final match in matches) {
      final name = match.group(1)!.trim().replaceAll("'", "\\'");
      final code = match.group(2)!.trim();
      final numStr = match.group(3)!.trim();
      final minorStr = match.group(4)!.trim();

      // Filter out historic, fund, and non-minor unit currencies
      if (code.isEmpty ||
          numStr.isEmpty ||
          minorStr == 'N.A.' ||
          codes.contains(code)) {
        continue;
      }

      codes.add(code);
      int numCode = int.parse(numStr);
      int minor = int.parse(minorStr);

      sink.writeln("  '$code': CurrencyMetadata(");
      sink.writeln("    alpha3Code: '$code',");
      sink.writeln("    numericCode: $numCode,");
      sink.writeln("    name: '$name',");
      sink.writeln("    minorUnitExponent: $minor,");
      sink.writeln("  ),");
    }

    sink.writeln('};');
    await sink.close();

    print(
      'Successfully generated lib/domain/currency_data.dart with ${codes.length} currencies.',
    );
  } catch (e) {
    print('Failed to generate currencies: $e');
    exit(1);
  }
}
