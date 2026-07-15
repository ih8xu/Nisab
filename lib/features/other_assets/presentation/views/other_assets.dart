import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nisab/core/utils/app_assets.dart';
import 'package:nisab/core/utils/app_colors.dart';
import 'package:nisab/core/utils/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:nisab/core/models/zakat_models.dart';
import 'package:nisab/core/services/zakat_api_service.dart';

class OtherAssetsView extends StatefulWidget {
  const OtherAssetsView({super.key});

  @override
  State<OtherAssetsView> createState() => _OtherAssetsViewState();
}

class _OtherAssetsViewState extends State<OtherAssetsView> {
  double goldGramPrice24 = 0;
  double silverGramPrice = 0;

  int selectedCarat = 21;
  double goldWeight = 0;
  double silverWeight = 0;

  final List<FundAsset> funds = [];

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final data = await ZakatApiService.instance.getAssets();
      if (!mounted) return;
      setState(() {
        goldGramPrice24 = data.goldPrice24;
        silverGramPrice = data.silverPrice999;
        final gold = data.gold;
        if (gold != null) {
          selectedCarat = gold.karat ?? selectedCarat;
          goldWeight = gold.weight;
        }
        final silver = data.silver;
        if (silver != null) silverWeight = silver.weight;
        funds
          ..clear()
          ..addAll(data.funds);
      });
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }

  double get netGoldWeight => goldWeight * selectedCarat / 24;

  double get goldValue => netGoldWeight * goldGramPrice24;

  double get silverValue => silverWeight * silverGramPrice;

  double get fundsValue =>
      funds.fold(0, (total, fund) => total + fund.totalValue);

  double get totalAssets => goldValue + silverValue + fundsValue;

  double get zakatDue => totalAssets * 0.025;

  String amount(double value) => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              children: [
                SizedBox(
                  width: 180,
                  height: 90,
                  child: Image.asset(Assets.alinmalogo, fit: BoxFit.contain),
                ),
                const SizedBox(height: 10),
                const Text(
                  AppStrings.otherAssetsTitle,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.otherAssetsSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                _AssetCard(
                  icon: Icons.workspace_premium_rounded,
                  title: AppStrings.goldTitle,
                  subtitle: goldWeight == 0
                      ? AppStrings.goldHint
                      : 'عيار $selectedCarat • ${amount(goldWeight)} جم',
                  value: goldWeight == 0
                      ? AppStrings.add
                      : '${amount(goldValue)} ريال',
                  onTap: _showGoldForm,
                ),
                const SizedBox(height: 12),

                _AssetCard(
                  icon: Icons.brightness_2_rounded,
                  title: AppStrings.silverTitle,
                  subtitle: silverWeight == 0
                      ? AppStrings.silverHint
                      : '${amount(silverWeight)} جم من الفضة',
                  value: silverWeight == 0
                      ? AppStrings.add
                      : '${amount(silverValue)} ريال',
                  onTap: _showSilverForm,
                ),
                const SizedBox(height: 12),

                _AssetCard(
                  icon: Icons.account_balance_rounded,
                  title: AppStrings.fundsTitle,
                  subtitle: funds.isEmpty
                      ? AppStrings.fundsHint
                      : '${funds.length} صندوق مضاف',
                  value: funds.isEmpty
                      ? AppStrings.add
                      : '${amount(fundsValue)} ريال',
                  onTap: _showFundForm,
                ),

                if (funds.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...funds.map(
                    (fund) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card.withValues(alpha: .6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.show_chart_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              fund.name,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${amount(fund.totalValue)} ريال',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: AppStrings.totalAssets,
                        value: '${amount(totalAssets)} ريال',
                        color: AppColors.white,
                      ),
                      const Divider(color: Colors.white24, height: 26),
                      _SummaryRow(
                        label: AppStrings.zakatDue,
                        value: '${amount(zakatDue)} ريال',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/zakat-summary');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.card,
                      foregroundColor: AppColors.background,
                      disabledForegroundColor: Colors.white54,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      AppStrings.completePayment,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showGoldForm() async {
    final weightController = TextEditingController(
      text: goldWeight == 0 ? '' : goldWeight.toString(),
    );

    int temporaryCarat = selectedCarat;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final enteredWeight =
                double.tryParse(weightController.text.replaceAll(',', '.')) ??
                0;

            final calculatedNetWeight = enteredWeight * temporaryCarat / 24;
            final calculatedGoldValue = calculatedNetWeight * goldGramPrice24;
            final calculatedZakat = calculatedGoldValue * 0.025;
            final isBelowNisab = calculatedNetWeight < 85;

            return _FormSheet(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'زكاة الذهب',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'النصاب: 85 جم من الذهب عيار 24',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 22),

                  const Text(
                    'اختاري العيار',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.85,
                    children: [12, 14, 18, 21, 22, 24].map((carat) {
                      final selected = temporaryCarat == carat;

                      return InkWell(
                        onTap: () {
                          setSheetState(() {
                            temporaryCarat = carat;
                          });
                        },
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : const Color(0xFF19314F),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            '$carat',
                            style: TextStyle(
                              color: selected
                                  ? AppColors.background
                                  : AppColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  _InputBox(
                    controller: weightController,
                    label: AppStrings.goldWeight,
                    suffix: 'جم',
                    onChanged: (_) => setSheetState(() {}),
                  ),

                  const SizedBox(height: 16),

                  _AutomaticBox(
                    label: AppStrings.goldGramPrice,
                    value: '${amount(goldGramPrice24)} ريال',
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'يتم تحديث السعر تلقائيًا من مصدر الأسعار.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),

                  const SizedBox(height: 16),

                  _AutomaticBox(
                    label: AppStrings.netGoldWeight,
                    value: '${amount(calculatedNetWeight)} جم',
                  ),

                  const SizedBox(height: 10),

                  _AutomaticBox(
                    label: 'الزكاة المستحقة على الذهب',
                    value: '${amount(calculatedZakat)} ريال',
                    primaryValue: true,
                  ),

                  const SizedBox(height: 14),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isBelowNisab
                            ? Colors.white10
                            : AppColors.success.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isBelowNisab ? 'دون النصاب' : 'بلغ النصاب',
                        style: TextStyle(
                          color: isBelowNisab
                              ? Colors.white54
                              : AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _SaveButton(
                    text: 'حفظ الذهب',
                    onPressed: enteredWeight <= 0
                        ? null
                        : () async {
                            try {
                              final saved = await ZakatApiService.instance
                                  .saveGold(
                                    weight: enteredWeight,
                                    karat: temporaryCarat,
                                  );
                              if (!mounted) return;
                              setState(() {
                                selectedCarat = saved.karat ?? temporaryCarat;
                                goldWeight = saved.weight;
                                goldGramPrice24 = saved.pricePerGram;
                              });
                              if (context.mounted) Navigator.pop(context);
                            } catch (error) {
                              _showError(error);
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    weightController.dispose();
  }

  Future<void> _showSilverForm() async {
    final weightController = TextEditingController(
      text: silverWeight == 0 ? '' : silverWeight.toString(),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final enteredWeight =
                double.tryParse(weightController.text.replaceAll(',', '.')) ??
                0;

            final value = enteredWeight * silverGramPrice;
            final zakat = value * 0.025;

            return _FormSheet(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'زكاة الفضة',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 22),

                  _InputBox(
                    controller: weightController,
                    label: AppStrings.silverWeight,
                    suffix: 'جم',
                    onChanged: (_) => setSheetState(() {}),
                  ),

                  const SizedBox(height: 16),

                  _AutomaticBox(
                    label: AppStrings.silverGramPrice,
                    value: '${amount(silverGramPrice)} ريال',
                  ),

                  const SizedBox(height: 10),

                  _AutomaticBox(
                    label: 'الزكاة المستحقة على الفضة',
                    value: '${amount(zakat)} ريال',
                    primaryValue: true,
                  ),

                  const SizedBox(height: 22),

                  _SaveButton(
                    text: 'حفظ الفضة',
                    onPressed: enteredWeight <= 0
                        ? null
                        : () async {
                            try {
                              final saved = await ZakatApiService.instance
                                  .saveSilver(weight: enteredWeight);
                              if (!mounted) return;
                              setState(() {
                                silverWeight = saved.weight;
                                silverGramPrice = saved.pricePerGram;
                              });
                              if (context.mounted) Navigator.pop(context);
                            } catch (error) {
                              _showError(error);
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    weightController.dispose();
  }

  Future<void> _showFundForm() async {
    final nameController = TextEditingController();
    final unitsController = TextEditingController();
    final priceController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final units =
                double.tryParse(unitsController.text.replaceAll(',', '.')) ?? 0;

            final unitPrice =
                double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0;

            final value = units * unitPrice;

            return _FormSheet(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إضافة صندوق استثماري',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 22),

                  _InputBox(
                    controller: nameController,
                    label: AppStrings.fundShortName,
                    onChanged: (_) => setSheetState(() {}),
                    isNumber: false,
                  ),

                  const SizedBox(height: 12),

                  _InputBox(
                    controller: unitsController,
                    label: AppStrings.fundUnits,
                    onChanged: (_) => setSheetState(() {}),
                  ),

                  const SizedBox(height: 12),

                  _InputBox(
                    controller: priceController,
                    label: AppStrings.fundUnitPrice,
                    suffix: 'ريال',
                    onChanged: (_) => setSheetState(() {}),
                  ),

                  const SizedBox(height: 16),

                  _AutomaticBox(
                    label: 'قيمة الصندوق',
                    value: '${amount(value)} ريال',
                  ),

                  const SizedBox(height: 22),

                  _SaveButton(
                    text: 'حفظ الصندوق',
                    onPressed: nameController.text.trim().isEmpty ||
                            units <= 0 ||
                            unitPrice <= 0
                        ? null
                        : () async {
                            try {
                              final saved = await ZakatApiService.instance
                                  .addFund(
                                    name: nameController.text.trim(),
                                    units: units,
                                    unitPrice: unitPrice,
                                  );
                              if (!mounted) return;
                              setState(() => funds.add(saved));
                              if (context.mounted) Navigator.pop(context);
                            } catch (error) {
                              _showError(error);
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    unitsController.dispose();
    priceController.dispose();
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Icon(Icons.chevron_left_rounded, color: Colors.white54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSheet extends StatelessWidget {
  const _FormSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.suffix,
    this.isNumber = true,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final bool isNumber;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF132844),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            inputFormatters: isNumber
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
                : null,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: isNumber ? '0' : '',
              hintStyle: const TextStyle(color: Colors.white54),
              suffixText: suffix,
              suffixStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _AutomaticBox extends StatelessWidget {
  const _AutomaticBox({
    required this.label,
    required this.value,
    this.primaryValue = false,
  });

  final String label;
  final String value;
  final bool primaryValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10243E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: primaryValue ? AppColors.primary : AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.card,
          foregroundColor: AppColors.background,
          disabledForegroundColor: Colors.white54,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
