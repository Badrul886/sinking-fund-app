import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/currency.dart';
import '../../../application/errors/application_error.dart';
import '../../state/fund_detail_notifier.dart';
import '../../utils/money_parser.dart';
import '../../providers/dependencies.dart';

enum TransactionType { contribution, withdrawal }

class TransactionBottomSheet extends ConsumerStatefulWidget {
  final String fundId;
  final Currency currency;
  final TransactionType type;

  const TransactionBottomSheet({
    super.key,
    required this.fundId,
    required this.currency,
    required this.type,
  });

  @override
  ConsumerState<TransactionBottomSheet> createState() =>
      _TransactionBottomSheetState();
}

class _TransactionBottomSheetState
    extends ConsumerState<TransactionBottomSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final amountText = _amountController.text;
    final rawNote = _noteController.text.trim();
    final note = rawNote.isEmpty ? null : rawNote;

    try {
      if (amountText.isEmpty) {
        throw const FormatException('Amount cannot be empty');
      }

      final amount = MoneyParser.parse(amountText, widget.currency);

      if (amount.minorUnits <= 0) {
        throw const FormatException('Amount must be strictly positive');
      }

      final notifier = ref.read(fundDetailProvider(widget.fundId).notifier);
      final clock = ref.read(clockProvider);

      if (widget.type == TransactionType.contribution) {
        await notifier.addContribution(
          amount: amount,
          date: clock.today(),
          note: note,
        );
      } else {
        await notifier.addWithdrawal(
          amount: amount,
          date: clock.today(),
          note: note,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } on ApplicationError catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.type == TransactionType.contribution
        ? 'Add Contribution'
        : 'Withdraw Funds';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge,
                semanticsLabel: title,
              ),
              const SizedBox(height: 24),
              Semantics(
                label: 'Amount Input',
                child: TextField(
                  key: const Key('amount_input'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${widget.currency.code} ',
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Optional Note Input',
                child: TextField(
                  key: const Key('note_input'),
                  controller: _noteController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Note (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(title),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
