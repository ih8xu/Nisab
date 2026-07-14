import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/models.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/utils/app_colors.dart';

class OtherAssetsView extends StatefulWidget {
  const OtherAssetsView({super.key});
  @override
  State<OtherAssetsView> createState() => _OtherAssetsViewState();
}

class _OtherAssetsViewState extends State<OtherAssetsView> {
  String? error;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppScope.of(context).data.prices == null) Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      await AppScope.read(context).loadFinancials();
      if (mounted) setState(() => error = null);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = AppScope.of(context).data;
    final summary = data.summary;
    final prices = data.prices;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأصول الزكوية'),
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _edit(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (error != null)
                _message(error!, Colors.redAccent, retry: true)
              else if (summary == null || prices == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                if (prices.isFallback)
                  _message(
                    'تعذر جلب السعر المباشر؛ الأسعار المعروضة احتياطية.',
                    Colors.orange,
                  ),
                _message(
                  'ذهب 24: ${prices.gold.toStringAsFixed(2)} ر.س/جرام • فضة: ${prices.silver.toStringAsFixed(2)} ر.س/جرام',
                  Colors.white70,
                ),
                if (summary.assets.isEmpty)
                  _message(
                    'لا توجد أصول بعد. استخدم زر الإضافة.',
                    Colors.white70,
                  ),
                for (final asset in summary.assets)
                  Card(
                    color: AppColors.card,
                    child: ListTile(
                      title: Text(
                        asset.name.isEmpty ? _typeName(asset.type) : asset.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${asset.totalValue.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            onPressed: () => _edit(asset),
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                AppScope.read(context).deleteAsset(asset.id),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                _message(
                  'إجمالي الأصول: ${summary.totalAssets.toStringAsFixed(2)} ر.س',
                  AppColors.primary,
                ),
                ElevatedButton(
                  onPressed: () => context.go('/zakat-summary'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('عرض الملخص'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _message(String text, Color color, {bool retry = false}) => Card(
    color: AppColors.card,
    child: ListTile(
      title: Text(text, style: TextStyle(color: color)),
      trailing: retry
          ? IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh, color: Colors.white),
            )
          : null,
    ),
  );
  String _typeName(String value) =>
      {'gold': 'ذهب', 'silver': 'فضة', 'fund': 'صندوق', 'cash': 'نقد'}[value] ??
      value;
  Future<void> _edit([AssetModel? asset]) async {
    String type = asset?.type ?? 'gold';
    final name = TextEditingController(text: asset?.name);
    final first = TextEditingController(
      text: asset == null
          ? ''
          : (asset.type == 'cash'
                        ? asset.totalValue
                        : (asset.weight ?? asset.units))
                    ?.toString() ??
                '',
    );
    final second = TextEditingController(
      text: asset?.unitPrice?.toString() ?? '',
    );
    int option = asset?.karat ?? asset?.purity ?? 24;
    String? dialogError;
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(
            asset == null ? 'إضافة أصل' : 'تعديل الأصل',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'gold', child: Text('ذهب')),
                    DropdownMenuItem(value: 'silver', child: Text('فضة')),
                    DropdownMenuItem(
                      value: 'fund',
                      child: Text('صندوق استثماري'),
                    ),
                    DropdownMenuItem(value: 'cash', child: Text('نقد')),
                  ],
                  onChanged: asset == null
                      ? (v) => setDialog(() {
                          type = v!;
                          option = type == 'silver' ? 999 : 24;
                        })
                      : null,
                ),
                if (type == 'fund') _input(name, 'اسم الصندوق'),
                _input(
                  first,
                  type == 'fund'
                      ? 'عدد الوحدات'
                      : type == 'cash'
                      ? 'المبلغ'
                      : 'الوزن',
                ),
                if (type == 'fund') _input(second, 'سعر الوحدة'),
                if (type == 'gold')
                  DropdownButton<int>(
                    value: option,
                    dropdownColor: AppColors.card,
                    items: [18, 21, 22, 24]
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(
                              'عيار $v',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialog(() => option = v!),
                  ),
                if (type == 'silver')
                  DropdownButton<int>(
                    value: option,
                    dropdownColor: AppColors.card,
                    items: [800, 925, 999]
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(
                              'نقاء $v',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialog(() => option = v!),
                  ),
                if (dialogError != null)
                  Text(
                    dialogError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(first.text);
                final payload = <String, dynamic>{
                  'asset_type': type,
                  if (type == 'fund') ...{
                    'name': name.text,
                    'units': value,
                    'unit_price': double.tryParse(second.text),
                  },
                  if (type == 'cash') 'amount': value,
                  if (type == 'gold') ...{'weight': value, 'karat': option},
                  if (type == 'silver') ...{'weight': value, 'purity': option},
                };
                try {
                  if (asset == null) {
                    await AppScope.read(context).addAsset(payload);
                  } else {
                    await AppScope.read(context).updateAsset(asset.id, payload);
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (e) {
                  setDialog(() => dialogError = e.toString());
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    first.dispose();
    second.dispose();
  }

  Widget _input(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextField(
      controller: controller,
      keyboardType: label.contains('اسم')
          ? TextInputType.text
          : TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
      ),
    ),
  );
}
