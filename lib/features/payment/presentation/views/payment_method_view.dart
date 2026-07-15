import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nisab/core/utils/app_colors.dart';
import 'package:nisab/core/services/zakat_api_service.dart';

class PaymentMethodView extends StatefulWidget {
  const PaymentMethodView({super.key});

  @override
  State<PaymentMethodView> createState() => _PaymentMethodViewState();
}

class _PaymentMethodViewState extends State<PaymentMethodView> {
  int? selectedMethod;
  bool isSubmitting = false;

  Future<void> _confirmPayment() async {
    final selection = selectedMethod;
    if (selection == null) return;
    setState(() => isSubmitting = true);
    try {
      await ZakatApiService.instance.pay(
        selection == 0 ? 'zakaty' : 'self',
      );
      if (mounted) context.go('/payment-success');
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'إتمام الدفع',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'كيف تودين إخراج زكاتك؟',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'اختار الطريقة المناسبة لإتمام زكاتك.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 30),

              _paymentOption(
                index: 0,
                title: 'الدفع عبر زكاتي',
                subtitle: 'إتمام الدفع من خلال منصة زكاتي.',
                child: Image.asset(
                  'assets/images/Screenshot 2026-07-12 190559.png',
                  width: 85,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 15),

              _paymentOption(
                index: 1,
                title: 'سأدفع بنفسي',
                subtitle: 'سأقوم بإخراج مبلغ الزكاة بالطريقة التي أختارها.',
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_rounded, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'معلوماتك وبياناتك المالية محفوظة وآمنة.',
                        style: TextStyle(color: Colors.white70),
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
                  onPressed: selectedMethod == null || isSubmitting
                      ? null
                      : _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.card,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'تأكيد إتمام الدفع',
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
      ),
    );
  }

  Widget _paymentOption({
    required int index,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final isSelected = selectedMethod == index;

    return InkWell(
      onTap: () => setState(() => selectedMethod = index),
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF104864) : AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: child,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}
