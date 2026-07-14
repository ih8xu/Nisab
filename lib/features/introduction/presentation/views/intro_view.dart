import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/utils/app_colors.dart';

class IntroView extends StatefulWidget {
  const IntroView({super.key});
  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  bool accepted = false, loading = false;
  String? error;
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            onPressed: () => AppScope.read(context).logout(),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                const Icon(
                  Icons.balance_rounded,
                  color: AppColors.primary,
                  size: 90,
                ),
                const Text(
                  'نِصاب',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'احتساب أصولك الزكوية وحفظها بأمان',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 30),
                CheckboxListTile(
                  value: accepted,
                  onChanged: (v) => setState(() => accepted = v ?? false),
                  title: const Text(
                    'أقر بأنني اطلعت على آلية الاحتساب وأوافق على استخدامها.',
                    style: TextStyle(color: Colors.white),
                  ),
                  activeColor: AppColors.primary,
                ),
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.redAccent)),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: !accepted || loading
                        ? null
                        : () async {
                            setState(() {
                              loading = true;
                              error = null;
                            });
                            try {
                              await AppScope.read(
                                context,
                              ).acceptAndCreateSession();
                              if (context.mounted) context.go('/process');
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
                        : const Text('ابدأ احتساب الزكاة'),
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
