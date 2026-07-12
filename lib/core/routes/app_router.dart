import 'package:go_router/go_router.dart';
import 'package:nisab/features/introduction/presentation/views/intro_view.dart';

final GoRouter appRouter  = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const Intoview(),
  )
 
]);
  
  