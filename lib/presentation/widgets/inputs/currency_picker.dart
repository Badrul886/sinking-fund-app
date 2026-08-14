import 'package:flutter/material.dart';
import '../../../domain/currency.dart';
import '../../../domain/currency_data.dart';

class CurrencyPicker extends StatefulWidget {
  final Currency selectedCurrency;
  final ValueChanged<Currency> onCurrencySelected;

  const CurrencyPicker({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Currency',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.selectedCurrency.code} - ${iso4217Currencies[widget.selectedCurrency.code]?.name ?? ''}'),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _CurrencyPickerSheet(
          onCurrencySelected: (currency) {
            widget.onCurrencySelected(currency);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  final ValueChanged<Currency> onCurrencySelected;

  const _CurrencyPickerSheet({required this.onCurrencySelected});

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _searchQuery = '';
  late List<CurrencyMetadata> _allCurrencies;

  @override
  void initState() {
    super.initState();
    _allCurrencies = iso4217Currencies.values.toList()
      ..sort((a, b) => a.alpha3Code.compareTo(b.alpha3Code));
  }

  @override
  Widget build(BuildContext context) {
    final filteredCurrencies = _allCurrencies.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.alpha3Code.toLowerCase().contains(query) ||
             c.name.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select Currency', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                final c = filteredCurrencies[index];
                return ListTile(
                  title: Text(c.alpha3Code),
                  subtitle: Text(c.name),
                  onTap: () => widget.onCurrencySelected(Currency(c.alpha3Code)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
