import 'package:flutter/material.dart';
import 'core/utils/app_assets.dart';

void main() {
  runApp(const Nisab());
}
class Nisab  extends StatelessWidget {
  const Nisab({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
        body: Container (
          child: Image.asset(
            Assets.alinmalogo,
            ),
            ),
        ),
      );

  }
}