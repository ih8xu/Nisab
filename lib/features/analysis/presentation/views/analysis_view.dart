import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';

class ProcessView extends StatelessWidget {
  const ProcessView({super.key});
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_done_rounded,
                color: AppColors.primary,
                size: 90,
              ),
              const SizedBox(height: 20),
              const Text(
                'جاهز لإدخال بياناتك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'لا توجد عملية تحليل بنكية متصلة حالياً. أدخل بيانات الحول والأصول ليحسبها الخادم.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.6),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => context.go('/hawl'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
