import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/routes/app_router.dart';
import 'core/state/app_state.dart';
import 'core/utils/app_colors.dart';

void main() => runApp(const Nisab());

class Nisab extends StatefulWidget {
  const Nisab({super.key});
  @override
  State<Nisab> createState() => _NisabState();
}

class _NisabState extends State<Nisab> {
  late final AppController controller;
  late final GoRouter router;
  @override
  void initState() {
    super.initState();
    controller = AppController();
    router = createRouter(controller);
    controller.initialize();
  }

  @override
  void dispose() {
    router.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    controller: controller,
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
    ),
  );
}
