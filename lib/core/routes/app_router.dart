import 'package:go_router/go_router.dart';
import 'package:nisab/features/introduction/presentation/views/intro_view.dart';
import 'package:nisab/features/analysis/presentation/views/analysis_view.dart';
import 'package:nisab/features/analysis/presentation/views/hawl_view.dart';
import 'package:nisab/features/other_assets/presentation/views/other_assets.dart';
import 'package:nisab/features/analysis/presentation/views/zakat_summary_view.dart';
import 'package:nisab/features/payment/presentation/views/payment_method_view.dart';
import 'package:nisab/features/success/presentation/views/payment_success_view.dart';
import 'package:nisab/features/ai_assistant/presentation/views/chat_view.dart';


final GoRouter appRouter = GoRouter(
  routes: [
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
