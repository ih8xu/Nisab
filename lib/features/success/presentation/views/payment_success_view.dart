import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nisab/core/models/zakat_models.dart';
import 'package:nisab/core/services/zakat_api_service.dart';
import 'package:nisab/core/utils/app_assets.dart';
import 'package:nisab/core/utils/app_colors.dart';

class PaymentSuccessView extends StatefulWidget {
  const PaymentSuccessView({super.key});

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
  late Future<PaymentResult> paymentFuture;

  @override
  void initState() {
    super.initState();
    paymentFuture = ZakatApiService.instance.getLastPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: FutureBuilder<PaymentResult>(
            future: paymentFuture,
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

              final payment = snapshot.requireData;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 180,
                        height: 80,
                        child: Image.asset(
                          Assets.alinmalogo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppColors.successBackground,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 82,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'تم إكمال الزكاة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'تقبّل الله منكِ وجعلها بركةً في مالكِ.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            _PaymentRow(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'المبلغ الزكوي',
                              value:
                                  '${payment.zakatableAmount.toStringAsFixed(2)} ريال',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Divider(color: Colors.white24),
                            ),
                            _PaymentRow(
                              icon: Icons.volunteer_activism_rounded,
                              title: 'مبلغ الزكاة المُخرج',
                              value: '${payment.amount.toStringAsFixed(2)} ريال',
                              highlighted: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C433D),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded, color: AppColors.success),
                            SizedBox(width: 10),
                            Text(
                              'تم تسجيل إتمام الدفع بنجاح.',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.go('/'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'العودة للرئيسية',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.icon,
    required this.title,
    required this.value,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: highlighted ? AppColors.primary : Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: highlighted ? AppColors.primary : Colors.white,
            fontSize: highlighted ? 19 : 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
