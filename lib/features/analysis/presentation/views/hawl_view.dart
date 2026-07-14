import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/utils/app_colors.dart';

class HawlView extends StatefulWidget {
  const HawlView({super.key});
  @override
  State<HawlView> createState() => _HawlViewState();
}

class _HawlViewState extends State<HawlView> {
  DateTime? start;
  bool loading = false;
  String? error;
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('الحول'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'حدد تاريخ بداية الحول',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () async {
                    final value = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialDate: start ?? DateTime.now(),
                    );
                    if (value != null) setState(() => start = value);
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    start == null
                        ? 'اختيار التاريخ'
                        : '${start!.year}-${start!.month}-${start!.day}',
                  ),
                ),
                const SizedBox(height: 16),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.redAccent)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: start == null || loading
                        ? null
                        : () async {
                            setState(() {
                              loading = true;
                              error = null;
                            });
                            try {
                              await AppScope.read(context).saveHawl(start!);
                              if (context.mounted) context.go('/other-assets');
                            } catch (e) {
                              setState(() => error = e.toString());
                            } finally {
                              if (mounted) setState(() => loading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text('حفظ ومتابعة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
