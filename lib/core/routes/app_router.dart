import 'package:go_router/go_router.dart';
import 'package:nisab/features/introduction/presentation/views/intro_view.dart';
import 'package:nisab/features/analysis/presentation/views/analysis_view.dart';
import 'package:nisab/features/analysis/presentation/views/hawl_view.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const IntroView()),
    GoRoute(path: '/process', builder: (context, state) => const ProcessView()),
    GoRoute(path: '/hawl', builder: (context, state) => const HawlView()),
  ],
);
