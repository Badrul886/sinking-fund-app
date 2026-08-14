import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_state_provider.dart';

// Placeholder screen to prove routing without building the real UI (Phase 5C)
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<bool>>(onboardingStateProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final onboardingState = ref.read(onboardingStateProvider);
      
      // While we are loading the onboarding status from the DB, we shouldn't force a redirect yet.
      if (onboardingState.isLoading) {
        return null; // Could optionally redirect to a /splash route here
      }
      
      final isComplete = onboardingState.value ?? false;
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!isComplete && !isGoingToOnboarding) {
        return '/onboarding';
      }
      
      if (isComplete && isGoingToOnboarding) {
        return '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PlaceholderScreen(title: 'Dashboard'),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const PlaceholderScreen(title: 'Onboarding'),
      ),
      GoRoute(
        path: '/fund/create',
        builder: (context, state) => const PlaceholderScreen(title: 'Create Fund'),
      ),
      GoRoute(
        path: '/fund/:id',
        builder: (context, state) => const PlaceholderScreen(title: 'Fund Detail'),
      ),
    ],
  );
});
