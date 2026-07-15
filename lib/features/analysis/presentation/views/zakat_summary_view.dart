import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nisab/core/models/zakat_models.dart';
import 'package:nisab/core/services/zakat_api_service.dart';
import 'package:nisab/core/utils/app_assets.dart';
import 'package:nisab/core/utils/app_colors.dart';

class ZakatSummaryView extends StatefulWidget {
  const ZakatSummaryView({super.key});

  @override
  State<ZakatSummaryView> createState() => _ZakatSummaryViewState();
}

class _ZakatSummaryViewState extends State<ZakatSummaryView> {
  late Future<ZakatSummary> summaryFuture;

  @override
  void initState() {
    super.initState();
    summaryFuture = ZakatApiService.instance.getSummary();
  }

  String amount(double value) => '${value.toStringAsFixed(2)} ريال';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<ZakatSummary>(
          future: summaryFuture,
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

            final summary = snapshot.requireData;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  SizedBox(width: 220, child: Image.asset(Assets.alinmalogo)),
                  const SizedBox(height: 30),
                  const Text(
                    'ملخص الزكاة',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      '✓ شامل لجميع أصولك الزكوية',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'تم احتساب الزكاة بناءً على جميع الأصول التي قمت بإضافتها.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تفاصيل الأصول الزكوية',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _AssetRow(
                          title: 'المال النقدي',
                          amount: amount(summary.cashAmount),
                        ),
                        const Divider(color: Colors.white24, height: 30),
                        _AssetRow(
                          title: 'الذهب',
                          amount: amount(summary.goldAmount),
                        ),
                        const Divider(color: Colors.white24, height: 30),
                        _AssetRow(
                          title: 'الأسهم',
                          amount: amount(summary.stocksAmount),
                        ),
                        const Divider(color: Colors.white24, height: 30),
                        _AssetRow(
                          title: 'عروض التجارة',
                          amount: amount(summary.tradeOffersAmount),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'إجمالي الزكاة المستحقة',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          summary.totalZakat.toStringAsFixed(2),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'ريال',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextButton(
                    onPressed: () => context.push('/assistant'),
                    child: const Text(
                      'لديك سؤال عن النتيجة؟ اسأل مساعد نصاب ←',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => context.push('/payment-method'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'ادفع الزكاة الآن',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.title, required this.amount});

  final String title;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
