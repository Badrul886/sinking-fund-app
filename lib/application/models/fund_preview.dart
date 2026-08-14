import '../../domain/fund_calculator.dart';
import '../../domain/trajectory.dart';

class FundPreview {
  final FundCalculationResult calculationResult;
  final Trajectory trajectory;

  const FundPreview({
    required this.calculationResult,
    required this.trajectory,
  });
}
