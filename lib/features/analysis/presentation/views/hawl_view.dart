import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nisab/core/models/zakat_models.dart';
import 'package:nisab/core/services/zakat_api_service.dart';
import 'package:nisab/core/utils/app_assets.dart';
import 'package:nisab/core/utils/app_colors.dart';

class HawlView extends StatefulWidget {
  const HawlView({super.key});

  @override
  State<HawlView> createState() => _HawlViewState();
}

class _HawlViewState extends State<HawlView> {
  late Future<HawlDetails> detailsFuture;

  @override
  void initState() {
    super.initState();
    detailsFuture = ZakatApiService.instance.getHawlDetails();
  }

  String amount(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final formatted = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return value.truncateToDouble() == value
        ? formatted
        : '$formatted.${parts.last}';
  }

  String date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year} م';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<HawlDetails>(
          future: detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            final details = snapshot.requireData;
            final reachedText = details.hasReachedNisab
                ? 'تم بلوغ النصاب'
                : 'لم يتم بلوغ النصاب';
            final dueText = details.isCompleted && details.hasReachedNisab
                ? '${amount(details.zakatableBalance * 0.025)} ريال'
                : 'غير مستحقة حالياً';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  SizedBox(width: 220, child: Image.asset(Assets.alinmalogo)),
                  const SizedBox(height: 30),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: AppColors.successBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 55,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    reachedText,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'الرصيد الزكوي: ${amount(details.zakatableBalance)} ريال',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تفاصيل الزكاة',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _BuildInfoRow(
                          icon: Icons.calendar_month_rounded,
                          title: 'بدء احتساب الحول',
                          value: date(details.startDate),
                        ),
                        const Divider(color: Colors.white24, height: 35),
                        _BuildInfoRow(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'الرصيد الزكوي',
                          value: '${amount(details.zakatableBalance)} ريال',
                        ),
                        const Divider(color: Colors.white24, height: 35),
                        _BuildInfoRow(
                          icon: Icons.volunteer_activism_outlined,
                          title: 'الزكاة المستحقة',
                          value: dueText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => context.go('/other-assets'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'إضافة أصول زكوية أخرى',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 180,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () => context.go('/zakat-summary'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'ادفع الآن',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BuildInfoRow extends StatelessWidget {
  const _BuildInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
