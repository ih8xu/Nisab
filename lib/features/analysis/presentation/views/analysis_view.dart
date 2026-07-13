import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nisab/core/utils/app_assets.dart';
import 'package:nisab/core/utils/app_colors.dart';
import 'package:nisab/core/utils/app_strings.dart';
import 'package:go_router/go_router.dart';

class ProcessView extends StatefulWidget {
  const ProcessView({super.key});

  @override
  State<ProcessView> createState() => _ProcessViewState();
}

class _ProcessViewState extends State<ProcessView> {
  int currentStep = 0;
  late Timer stepTimer;

  @override
  void initState() {
    super.initState();

    stepTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;

      if (currentStep < AppStrings.processSteps.length - 1) {
        setState(() {
          currentStep++;
        });
      } else {
        timer.cancel();

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/hawl');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    stepTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / AppStrings.processSteps.length;

    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 310,
                      height: 185,
                      child: Image.asset(
                        Assets.alinmalogo,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      AppStrings.processTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      AppStrings.processSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: AppColors.card,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 5,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Text(
                              AppStrings.processSteps[currentStep],
                              key: ValueKey(currentStep),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Text(
                              AppStrings.processStepDetails[currentStep],
                              key: ValueKey('detail$currentStep'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            '${currentStep + 1} من ${AppStrings.processSteps.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const _ProcessInfoRow(
                      icon: Icons.lock_rounded,
                      text: AppStrings.processSecurity,
                    ),
                    const SizedBox(height: 12),

                    const _ProcessInfoRow(
                      icon: Icons.privacy_tip_rounded,
                      text: AppStrings.processPrivacy,
                    ),
                    const SizedBox(height: 12),

                    const _ProcessInfoRow(
                      icon: Icons.verified_rounded,
                      text: AppStrings.processAccuracy,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcessInfoRow extends StatelessWidget {
  const _ProcessInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.successBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.success, size: 20),
        ),
        const SizedBox(width: 11),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }
}
