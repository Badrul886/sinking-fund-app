import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/fund.dart';
import '../../../domain/schedule.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/money.dart';
import '../../state/fund_detail_notifier.dart';
import '../../utils/money_parser.dart';
import '../../widgets/buttons/primary_action_button.dart';
import '../../../application/errors/application_error.dart';

class EditFundScreen extends ConsumerWidget {
  final String fundId;

  const EditFundScreen({super.key, required this.fundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fundDetailProvider(fundId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Fund')),
      body: state.when(
        data: (detail) =>
            SafeArea(child: _EditFundForm(fund: detail.fundState.fund)),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _EditFundForm extends ConsumerStatefulWidget {
  final Fund fund;

  const _EditFundForm({required this.fund});

  @override
  ConsumerState<_EditFundForm> createState() => _EditFundFormState();
}

class _EditFundFormState extends ConsumerState<_EditFundForm> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late CalendarDate _targetDate;
  late ContributionFrequency _frequency;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fund.name);
    _amountController = TextEditingController(
      text: _formatMoney(widget.fund.targetAmount),
    );
    _targetDate = widget.fund.targetDate;
    _frequency = widget.fund.contributionFrequency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatMoney(Money money) {
    final exp = money.currency.metadata.minorUnitExponent;
    if (exp == 0) return money.minorUnits.toString();
    final str = money.minorUnits.toString().padLeft(exp + 1, '0');
    final whole = str.substring(0, str.length - exp);
    final frac = str.substring(str.length - exp);
    return '$whole.$frac'
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      if (name.isEmpty) throw const FormatException('Name cannot be empty');

      final targetAmount = MoneyParser.parse(
        _amountController.text,
        widget.fund.targetAmount.currency,
      );

      final notifier = ref.read(fundDetailProvider(widget.fund.id).notifier);
      await notifier.updateFund(
        name: name,
        targetAmount: targetAmount,
        targetDate: _targetDate,
        contributionFrequency: _frequency,
      );

      if (mounted) {
        context.pop();
      }
    } on FormatException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorSnackBar(e.message);
    } on ApplicationError catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
      _showErrorSnackBar(e.message);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextField(
            key: const Key('name_input'),
            controller: _nameController,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'Fund Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('amount_input'),
            controller: _amountController,
            enabled: !_isLoading,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Target Amount',
              border: const OutlineInputBorder(),
              prefixText: '${widget.fund.targetAmount.currency.code} ',
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Target Date Picker',
            button: true,
            child: InkWell(
              key: const Key('date_picker'),
              onTap: _isLoading
                  ? null
                  : () async {
                      final now = DateTime.now();
                      final initialDate = DateTime(
                        _targetDate.year,
                        _targetDate.month,
                        _targetDate.day,
                      );
                      // Start date determines the first possible target date
                      final firstDate = DateTime(
                        widget.fund.startDate.year,
                        widget.fund.startDate.month,
                        widget.fund.startDate.day,
                      );
                      final date = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: firstDate,
                        lastDate: now.add(const Duration(days: 365 * 100)),
                      );
                      if (date != null) {
                        setState(() {
                          _targetDate = CalendarDate(
                            date.year,
                            date.month,
                            date.day,
                          );
                        });
                      }
                    },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Target Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(_targetDate.toString()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ContributionFrequency>(
            key: const Key('frequency_dropdown'),
            initialValue: _frequency,
            decoration: const InputDecoration(
              labelText: 'Contribution Frequency',
              border: OutlineInputBorder(),
            ),
            items: ContributionFrequency.values.map((f) {
              return DropdownMenuItem(
                value: f,
                child: Text(f.name.toUpperCase()),
              );
            }).toList(),
            onChanged: _isLoading
                ? null
                : (val) {
                    if (val != null) {
                      setState(() => _frequency = val);
                    }
                  },
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            PrimaryActionButton(
              key: const Key('save_button'),
              label: 'Save Changes',
              onPressed: _submit,
            ),
        ],
      ),
    );
  }
}
