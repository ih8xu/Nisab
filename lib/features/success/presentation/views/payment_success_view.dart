import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/utils/app_colors.dart';

class PaymentSuccessView extends StatefulWidget {
  const PaymentSuccessView({super.key});
  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
  Map<String, dynamic>? payment;
  String? error;
  bool requested = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!requested) {
      requested = true;
      Future.microtask(_load);
    }
  }

  Future<void> _load() async {
    try {
      final value = await AppScope.read(context).lastPayment();
      if (mounted) setState(() => payment = value);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 110,
                ),
                const Text(
                  'تم تسجيل العملية المحاكية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.redAccent))
                else if (payment == null)
                  const CircularProgressIndicator()
                else
                  Card(
                    color: AppColors.card,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            '${payment!['amount']} ر.س',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${payment!['transaction_id']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'هذا السجل لا يثبت تحويلاً مالياً حقيقياً.',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('العودة للرئيسية'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
