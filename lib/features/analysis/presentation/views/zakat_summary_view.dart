import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/utils/app_colors.dart';

class ZakatSummaryView extends StatefulWidget {
  const ZakatSummaryView({super.key});
  @override
  State<ZakatSummaryView> createState() => _ZakatSummaryViewState();
}

class _ZakatSummaryViewState extends State<ZakatSummaryView> {
  String? error;
  bool requested = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!requested && AppScope.of(context).data.summary == null) {
      requested = true;
      Future.microtask(_load);
    }
  }

  Future<void> _load() async {
    try {
      await AppScope.read(context).loadSummary();
      if (mounted) setState(() => error = null);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = AppScope.of(context).data.summary;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ملخص الزكاة'),
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (error != null)
                _card(error!)
              else if (summary == null)
                const Center(child: CircularProgressIndicator())
              else ...[
                _card(
                  'إجمالي الأصول: ${summary.totalAssets.toStringAsFixed(2)} ر.س',
                ),
                _card(
                  'قيمة النصاب: ${summary.nisabValue.toStringAsFixed(2)} ر.س',
                ),
                _card(
                  summary.reachedNisab
                      ? 'تم بلوغ النصاب'
                      : 'لم يبلغ المال النصاب',
                ),
                _card(summary.hawlCompleted ? 'اكتمل الحول' : 'لم يكتمل الحول'),
                _card(
                  'الزكاة المستحقة: ${summary.totalZakat.toStringAsFixed(2)} ر.س',
                  primary: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: summary.totalZakat > 0
                      ? () => context.go('/payment-method')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('إكمال الدفع'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String text, {bool primary = false}) => Card(
    color: AppColors.card,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Text(
        text,
        style: TextStyle(
          color: primary ? AppColors.primary : Colors.white,
          fontSize: primary ? 21 : 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
