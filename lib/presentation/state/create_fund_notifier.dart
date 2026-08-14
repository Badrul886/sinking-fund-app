import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/currency.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/schedule.dart';
import '../../../domain/money.dart';
import '../../../application/models/fund_preview.dart';
import '../providers/dependencies.dart';
import '../utils/money_parser.dart';

class CreateFundDraftState {
  final String name;
  final String targetAmountText;
  final Currency currency;
  final CalendarDate? targetDate;
  final ContributionFrequency frequency;
  final String initialSavingsText;
  final FundPreview? preview;
  final bool isSubmitting;
  final String? errorMessage;

  CreateFundDraftState({
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

  CreateFundDraftState copyWith({
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
    return CreateFundDraftState(
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

class CreateFundNotifier extends Notifier<CreateFundDraftState> {
  @override
  CreateFundDraftState build() {
    return CreateFundDraftState();
  }

  void updateName(String name) {
    state = state.copyWith(name: name, errorMessage: null);
    _recalculatePreview();
  }

  void updateTargetAmountText(String text) {
    state = state.copyWith(targetAmountText: text, errorMessage: null);
    _recalculatePreview();
  }

  void updateCurrency(Currency currency) {
    state = state.copyWith(currency: currency, errorMessage: null);
    _recalculatePreview();
  }

  void updateTargetDate(CalendarDate date) {
    state = state.copyWith(targetDate: date, errorMessage: null);
    _recalculatePreview();
  }

  void updateFrequency(ContributionFrequency frequency) {
    state = state.copyWith(frequency: frequency, errorMessage: null);
    _recalculatePreview();
  }

  void updateInitialSavingsText(String text) {
    state = state.copyWith(initialSavingsText: text, errorMessage: null);
    _recalculatePreview();
  }

  void _recalculatePreview() {
    try {
      if (state.name.trim().isEmpty ||
          state.targetDate == null ||
          state.targetAmountText.trim().isEmpty) {
        state = state.copyWith(preview: null);
        return;
      }

      final targetAmount = MoneyParser.parse(
        state.targetAmountText,
        state.currency,
      );
      if (targetAmount.minorUnits <= 0) {
        state = state.copyWith(preview: null);
        return;
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
      // If parsing fails, we just don't show preview
      state = state.copyWith(preview: null);
    }
  }

  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      if (state.name.trim().isEmpty) {
        throw const FormatException('Name cannot be empty');
      }
      if (state.targetDate == null) {
        throw const FormatException('Target date is required');
      }

      final createFund = ref.read(createFundUseCaseProvider);
      final clock = ref.read(clockProvider);

      final targetAmount = MoneyParser.parse(
        state.targetAmountText,
        state.currency,
      );
      final initialSavings = state.initialSavingsText.trim().isEmpty
          ? Money(minorUnits: 0, currency: state.currency)
          : MoneyParser.parse(state.initialSavingsText, state.currency);

      await createFund.execute(
        name: state.name.trim(),
        targetAmount: targetAmount,
        startDate: clock.today(),
        targetDate: state.targetDate!,
        contributionFrequency: state.frequency,
        initialSavings: initialSavings,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

final createFundNotifierProvider =
    NotifierProvider.autoDispose<CreateFundNotifier, CreateFundDraftState>(
      CreateFundNotifier.new,
    );
