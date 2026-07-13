import 'package:flutter/material.dart';
import 'package:nisab/core/utils/app_assets.dart';
import 'package:nisab/core/utils/app_colors.dart';

class HawlView extends StatelessWidget {
  const HawlView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              SizedBox(width: 220, child: Image.asset(Assets.alinmalogo)),

              const SizedBox(height: 30),

              const Text(
                "تم اكتمال الحول",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: Colors.orange, size: 18),

                  SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      "حددنا لك أول يوم بلغ فيه رصيدك النصاب خلال حولك الحالي.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
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
                      "بداية الحول",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "21 محرم 1448 هـ",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "بدء احتساب الحول من هذا التاريخ.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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
                    _timelineItem(
                      title: "لم يصل رصيدك إلى النصاب بعد",
                      date: "1 محرم 1448 هـ",
                      amount: "30,000 ريال",
                      isDone: false,
                    ),

                    _line(),

                    _timelineItem(
                      title: "لم يصل رصيدك إلى النصاب بعد",
                      date: "10 محرم 1448 هـ",
                      amount: "45,000 ريال",
                      isDone: false,
                    ),

                    _line(),

                    _timelineItem(
                      title: "بلغ رصيدك النصاب وبدأ احتساب الحول",
                      date: "21 محرم 1448 هـ",
                      amount: "57,250 ريال",
                      isDone: true,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "تفاصيل الزكاة",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "الرصيد الزكوي",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "57,250 ريال",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "الزكاة المستحقة",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "1,431.25 ريال",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  onPressed: () {},

                  child: const Text(
                    "التالي",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _timelineItem({
    required String title,
    required String date,
    required String amount,
    required bool isDone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,

          color: isDone ? AppColors.success : Colors.white38,

          size: 24,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(date, style: const TextStyle(color: Colors.white70)),

              Text(amount, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _line() {
    return Container(
      height: 35,
      width: 2,
      margin: const EdgeInsets.only(left: 11),
      color: Colors.white24,
    );
  }
}
