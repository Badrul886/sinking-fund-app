import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/currency.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/schedule.dart';
import '../../../domain/money.dart';
import '../../../application/models/fund_preview.dart';
import '../providers/dependencies.dart';
import '../utils/money_parser.dart';

class OnboardingDraftState {
  final int currentStep;
  final String name;
  final String targetAmountText;
  final Currency currency;
  final CalendarDate? targetDate;
  final ContributionFrequency frequency;
  final String initialSavingsText;
  final FundPreview? preview;
  final bool isSubmitting;
  final String? errorMessage;

  OnboardingDraftState({
    this.currentStep = 0,
    this.name = '',
    this.targetAmountText = '',
    this.currency = const Currency('USD'),
    this.targetDate,
    this.frequency = ContributionFrequency.monthly,
    this.initialSavingsText = '',
    this.preview,
    this.isSubmitting = false,
    this.errorMessage,
  });

  OnboardingDraftState copyWith({
    int? currentStep,
    String? name,
    String? targetAmountText,
    Currency? currency,
    CalendarDate? targetDate,
    ContributionFrequency? frequency,
    String? initialSavingsText,
    FundPreview? preview,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingDraftState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      targetAmountText: targetAmountText ?? this.targetAmountText,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      frequency: frequency ?? this.frequency,
      initialSavingsText: initialSavingsText ?? this.initialSavingsText,
      preview: preview ?? this.preview,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OnboardingDraftNotifier extends Notifier<OnboardingDraftState> {
  @override
  OnboardingDraftState build() {
    return OnboardingDraftState();
  }

  void updateName(String name) =>
      state = state.copyWith(name: name, errorMessage: null);
  void updateTargetAmountText(String text) =>
      state = state.copyWith(targetAmountText: text, errorMessage: null);
  void updateCurrency(Currency currency) =>
      state = state.copyWith(currency: currency, errorMessage: null);
  void updateTargetDate(CalendarDate date) =>
      state = state.copyWith(targetDate: date, errorMessage: null);
  void updateFrequency(ContributionFrequency frequency) =>
      state = state.copyWith(frequency: frequency, errorMessage: null);
  void updateInitialSavingsText(String text) =>
      state = state.copyWith(initialSavingsText: text, errorMessage: null);

  void nextStep() async {
    if (state.currentStep == 1) {
      // Transitioning to Preview step. We must calculate the preview intentionally.
      try {
        if (state.name.trim().isEmpty) {
          throw const FormatException('Name cannot be empty');
        }
        if (state.targetDate == null) {
          throw const FormatException('Target date is required');
        }

        final targetAmount = MoneyParser.parse(
          state.targetAmountText,
          state.currency,
        );
        if (targetAmount.minorUnits <= 0) {
          throw const FormatException(
            'Target amount must be greater than zero',
          );
        }

        Money initialSavings;
        if (state.initialSavingsText.trim().isEmpty) {
          initialSavings = Money(minorUnits: 0, currency: state.currency);
        } else {
          initialSavings = MoneyParser.parse(
            state.initialSavingsText,
            state.currency,
          );
        }

        final calculatePreview = ref.read(calculateFundPreviewUseCaseProvider);
        final clock = ref.read(clockProvider);
        final today = clock.today();

        final preview = calculatePreview.execute(
          targetAmount: targetAmount,
          startDate: today,
          targetDate: state.targetDate!,
          contributionFrequency: state.frequency,
          initialSavings: initialSavings,
          currentDate: today,
        );

        state = state.copyWith(preview: preview, errorMessage: null);
      } catch (e) {
        state = state.copyWith(errorMessage: e.toString());
        return;
      }
    }

    if (state.currentStep < 3) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        errorMessage: null,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0 && !state.isSubmitting) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        errorMessage: null,
      );
    }
  }

  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final completeOnboarding = ref.read(
        completeInitialOnboardingUseCaseProvider,
      );

      final targetAmount = MoneyParser.parse(
        state.targetAmountText,
        state.currency,
      );
      final initialSavings = state.initialSavingsText.trim().isEmpty
          ? Money(minorUnits: 0, currency: state.currency)
          : MoneyParser.parse(state.initialSavingsText, state.currency);

      await completeOnboarding.execute(
        name: state.name.trim(),
        targetAmount: targetAmount,
        targetDate: state.targetDate!,
        frequency: state.frequency,
        initialSavings: initialSavings,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

final onboardingDraftNotifierProvider =
    NotifierProvider<OnboardingDraftNotifier, OnboardingDraftState>(
      OnboardingDraftNotifier.new,
    );
