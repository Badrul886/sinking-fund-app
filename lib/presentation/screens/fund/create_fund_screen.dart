import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/schedule.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/fund.dart';
import '../../state/create_fund_notifier.dart';
import '../../widgets/inputs/currency_picker.dart';
import '../../widgets/buttons/primary_action_button.dart';
import '../../widgets/data_display/amount_display.dart';
import '../../widgets/data_display/progress_visualizer.dart';

class CreateFundScreen extends ConsumerWidget {
  const CreateFundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createFundNotifierProvider);
    final notifier = ref.read(createFundNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Fund')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Fund Name',
                border: OutlineInputBorder(),
              ),
              onChanged: notifier.updateName,
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: state.name,
                  selection: TextSelection.collapsed(offset: state.name.length),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: notifier.updateTargetAmountText,
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: state.targetAmountText,
                  selection: TextSelection.collapsed(
                    offset: state.targetAmountText.length,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CurrencyPicker(
              selectedCurrency: state.currency,
              onCurrencySelected: notifier.updateCurrency,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: now.add(const Duration(days: 30)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365 * 100)),
                );
                if (date != null) {
                  notifier.updateTargetDate(
                    CalendarDate(date.year, date.month, date.day),
                  );
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Target Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(state.targetDate?.toString() ?? 'Select a date'),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ContributionFrequency>(
              decoration: const InputDecoration(
                labelText: 'Contribution Frequency',
                border: OutlineInputBorder(),
              ),
              initialValue: state.frequency,
              items: ContributionFrequency.values.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(f.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) notifier.updateFrequency(val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Initial Savings (Optional)',
                border: const OutlineInputBorder(),
                suffixText: state.currency.code,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: notifier.updateInitialSavingsText,
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: state.initialSavingsText,
                  selection: TextSelection.collapsed(
                    offset: state.initialSavingsText.length,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (state.preview != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Preview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              AmountDisplay(
                amount: state.preview!.calculationResult.currentBalance,
              ),
              const SizedBox(height: 8),
              Text('Target: ${state.currency.code} ${state.targetAmountText}'),
              const SizedBox(height: 16),
              ProgressVisualizer(
                progress: state.preview!.calculationResult.progress,
              ),
              if (state.preview!.calculationResult.status ==
                  FundStatus.overfunded)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'This fund is overfunded!',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              const SizedBox(height: 32),
            ],
            if (state.isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              PrimaryActionButton(
                label: 'Create Fund',
                onPressed: () async {
                  final success = await notifier.submit();
                  if (success && context.mounted) {
                    context.go('/');
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
