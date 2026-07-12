import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';

void main() {
  runApp(const Nisab());
}
class Nisab  extends StatelessWidget {
  const Nisab({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp.router(
      debugShowCheckedModeBanner: false,
           routerConfig: appRouter ,

      );
  }
}
