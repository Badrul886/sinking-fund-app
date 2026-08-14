import 'fund_state.dart';
import '../../domain/trajectory.dart';

class FundDetailState {
  final FundState fundState;
  final Trajectory trajectory;

  const FundDetailState({required this.fundState, required this.trajectory});
}
