import 'package:flutter/material.dart';
import 'package:nisab/core/utils/app_assets.dart';
import 'package:nisab/core/utils/app_colors.dart';
import 'package:nisab/core/utils/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:nisab/core/services/zakat_api_service.dart';

class IntroView extends StatefulWidget {
  const IntroView({super.key});

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  bool isAccepted = false;
  bool isSubmitting = false;

  Future<void> _start() async {
    setState(() => isSubmitting = true);
    try {
      await ZakatApiService.instance.acceptTerms();
      if (mounted) context.go('/process');
    } catch (error) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 390,
                    height: 700,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 300,
                            height: 145,
                            child: Image.asset(
                              Assets.alinmalogo,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Text(
                            'نِصاب',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'حلّك الذكي لاحتساب الزكاة بسهولة',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 16),

                          const _FeatureCard(
                            title: AppStrings.introCard1Title,
                            description: AppStrings.introCard1Description,
                          ),
                          const SizedBox(height: 9),

                          const _FeatureCard(
                            title: AppStrings.introCard2Title,
                            description: AppStrings.introCard2Description,
                          ),
                          const SizedBox(height: 9),

                          const _FeatureCard(
                            title: AppStrings.introCard3Title,
                            description: AppStrings.introCard3Description,
                          ),

                          const Spacer(),

                          InkWell(
                            onTap: () {
                              setState(() {
                                isAccepted = !isAccepted;
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 29,
                                  height: 29,
                                  decoration: BoxDecoration(
                                    color: isAccepted
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isAccepted
                                          ? AppColors.primary
                                          : Colors.white38,
                                      width: 2,
                                    ),
                                  ),
                                  child: isAccepted
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: AppColors.white,
                                          size: 23,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    AppStrings.accept,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isAccepted && !isSubmitting
                                  ? _start
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.card,
                                foregroundColor: AppColors.background,
                                disabledForegroundColor: Colors.white54,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                AppStrings.introButton,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.successBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
