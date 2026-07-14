import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/utils/app_colors.dart';

class PaymentMethodView extends StatefulWidget {
  const PaymentMethodView({super.key});
  @override
  State<PaymentMethodView> createState() => _PaymentMethodViewState();
}

class _PaymentMethodViewState extends State<PaymentMethodView> {
  String? method, error;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إتمام الدفع'),
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'اختر طريقة إخراج الزكاة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _option('zakati', 'الدفع عبر زكاتي'),
            _option('self', 'سأدفع بنفسي'),
            const SizedBox(height: 18),
            const Text(
              'هذه العملية محاكاة داخلية لتسجيل اختيارك فقط ولا تنفذ تحويلاً مالياً حقيقياً.',
              style: TextStyle(color: Colors.orange, height: 1.5),
            ),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: method == null || loading ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('تسجيل إتمام الدفع'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await AppScope.read(context).pay(method!);
      if (mounted) context.go('/payment-success');
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _option(String value, String title) => Card(
    color: AppColors.card,
    child: ListTile(
      onTap: () => setState(() => method = value),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Icon(
        method == value ? Icons.radio_button_checked : Icons.radio_button_off,
        color: method == value ? AppColors.primary : Colors.white54,
      ),
    ),
  );
}
