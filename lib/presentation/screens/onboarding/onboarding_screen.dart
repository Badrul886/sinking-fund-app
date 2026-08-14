import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/schedule.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/fund.dart';
import '../../state/onboarding_draft_notifier.dart';
import '../../widgets/inputs/currency_picker.dart';
import '../../widgets/buttons/primary_action_button.dart';
import '../../widgets/buttons/secondary_action_button.dart';
import '../../widgets/data_display/amount_display.dart';
import '../../widgets/data_display/progress_visualizer.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingDraftNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Started'),
        leading: state.currentStep > 0 && !state.isSubmitting
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(onboardingDraftNotifierProvider.notifier).previousStep();
                },
              )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildStepContent(context, state, ref),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, OnboardingDraftState state, WidgetRef ref) {
    switch (state.currentStep) {
      case 0:
        return _WelcomeStep(key: const ValueKey(0));
      case 1:
        return _InputsStep(key: const ValueKey(1));
      case 2:
        return _PreviewStep(key: const ValueKey(2));
      case 3:
        return _ConfirmationStep(key: const ValueKey(3));
      default:
        return const SizedBox.shrink();
    }
  }
}

class _WelcomeStep extends ConsumerWidget {
  const _WelcomeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mascot Placeholder - 200x200
          const Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text('Mascot\nPlaceholder', textAlign: TextAlign.center)),
              ),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Welcome to Sinking Fund!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Let\'s set up your first savings goal.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          PrimaryActionButton(
            label: 'Start',
            onPressed: () {
              ref.read(onboardingDraftNotifierProvider.notifier).nextStep();
            },
          ),
        ],
      ),
    );
  }
}

class _InputsStep extends ConsumerWidget {
  const _InputsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingDraftNotifierProvider);
    final notifier = ref.read(onboardingDraftNotifierProvider.notifier);

    return SingleChildScrollView(
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
            decoration: const InputDecoration(labelText: 'Fund Name', border: OutlineInputBorder()),
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
            decoration: const InputDecoration(labelText: 'Target Amount', border: OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: notifier.updateTargetAmountText,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: state.targetAmountText,
                selection: TextSelection.collapsed(offset: state.targetAmountText.length),
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
                lastDate: now.add(const Duration(days: 365 * 50)),
              );
              if (date != null) {
                notifier.updateTargetDate(CalendarDate(date.year, date.month, date.day));
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
            decoration: const InputDecoration(labelText: 'Contribution Frequency', border: OutlineInputBorder()),
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: notifier.updateInitialSavingsText,
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: state.initialSavingsText,
                selection: TextSelection.collapsed(offset: state.initialSavingsText.length),
              ),
            ),
          ),
          const SizedBox(height: 32),
          PrimaryActionButton(
            label: 'Preview',
            onPressed: notifier.nextStep,
          ),
        ],
      ),
    );
  }
}

class _PreviewStep extends ConsumerWidget {
  const _PreviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingDraftNotifierProvider);
    final preview = state.preview;

    if (preview == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isSuccess = preview.calculationResult.status == FundStatus.onTrack || 
                      preview.calculationResult.status == FundStatus.ahead ||
                      preview.calculationResult.status == FundStatus.complete ||
                      preview.calculationResult.status == FundStatus.overfunded;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AmountDisplay(amount: preview.calculationResult.currentBalance),
          const SizedBox(height: 8),
          Text(
            'Target: ${state.currency.code} ${state.targetAmountText}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ProgressVisualizer(
            progress: preview.calculationResult.progress,
          ),
          const SizedBox(height: 32),
          if (isSuccess) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Looking good! Your plan is on track.',
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const Icon(Icons.warning, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            const Text(
              'You might need to adjust your target or contribute more often.',
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 48),
          PrimaryActionButton(
            label: 'Looks Good',
            onPressed: () {
              ref.read(onboardingDraftNotifierProvider.notifier).nextStep();
            },
          ),
          const SizedBox(height: 16),
          SecondaryActionButton(
            label: 'Go Back & Edit',
            onPressed: () {
              ref.read(onboardingDraftNotifierProvider.notifier).previousStep();
            },
          ),
        ],
      ),
    );
  }
}

class _ConfirmationStep extends ConsumerWidget {
  const _ConfirmationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingDraftNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ready to start?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          if (state.isSubmitting)
            const Center(child: CircularProgressIndicator())
          else
            PrimaryActionButton(
              label: 'Create Fund',
              onPressed: () async {
                final success = await ref.read(onboardingDraftNotifierProvider.notifier).submit();
                if (success && context.mounted) {
                  context.go('/');
                }
              },
            ),
        ],
      ),
    );
  }
}
