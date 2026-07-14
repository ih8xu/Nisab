import 'package:go_router/go_router.dart';
import '../state/app_state.dart';
import '../../features/auth/presentation/auth_view.dart';
import '../../features/introduction/presentation/views/intro_view.dart';
import '../../features/analysis/presentation/views/analysis_view.dart';
import '../../features/analysis/presentation/views/hawl_view.dart';
import '../../features/other_assets/presentation/views/other_assets.dart';
import '../../features/analysis/presentation/views/zakat_summary_view.dart';
import '../../features/payment/presentation/views/payment_method_view.dart';
import '../../features/success/presentation/views/payment_success_view.dart';
import '../../features/ai_assistant/presentation/views/chat_view.dart';

GoRouter createRouter(AppController controller) => GoRouter(
  initialLocation: '/auth',
  refreshListenable: controller,
  redirect: (_, state) {
    if (!controller.initialized) {
      return null;
    }
    if (!controller.data.authenticated && state.matchedLocation != '/auth') {
      return '/auth';
    }
    if (controller.data.authenticated && state.matchedLocation == '/auth') {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/auth', builder: (context, state) => const AuthView()),
    GoRoute(path: '/', builder: (context, state) => const IntroView()),
    GoRoute(path: '/process', builder: (context, state) => const ProcessView()),
    GoRoute(path: '/hawl', builder: (context, state) => const HawlView()),
    GoRoute(
      path: '/other-assets',
      builder: (context, state) => const OtherAssetsView(),
    ),
    GoRoute(
      path: '/zakat-summary',
      builder: (context, state) => const ZakatSummaryView(),
    ),
    GoRoute(
      path: '/payment-method',
      builder: (context, state) => const PaymentMethodView(),
    ),
    GoRoute(
      path: '/payment-success',
      builder: (context, state) => const PaymentSuccessView(),
    ),
    GoRoute(path: '/assistant', builder: (context, state) => const ChatView()),
  ],
);
