import 'package:flutter/material.dart';
import 'package:nisab/core/utils/app_colors.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      'text':
          'مرحباً، أنا مساعد نِصاب.\nأستطيع مساعدتك في فهم طريقة احتساب زكاتك.',
      'isUser': false,
    },
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void sendMessage([String? text]) {
    final message = (text ?? controller.text).trim();
    if (message.isEmpty) return;

    setState(() {
      messages.add({'text': message, 'isUser': true});
      controller.clear();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        messages.add({
          'text':
              'تم احتساب الزكاة بنسبة 2.5٪ من المبلغ الزكوي بعد تحقق بلوغ النصاب وحولان الحول. إذا كان المبلغ الزكوي 57,250 ريالاً، فإن الزكاة المستحقة هي 1,431.25 ريالاً.',
          'isUser': false,
        });
      });
    });
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
          elevation: 0,
          centerTitle: true,
          title: const Column(
            children: [
              Text(
                'مساعد نِصاب',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'لفهم تفاصيل احتساب الزكاة',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _suggestion('كيف تم احتساب زكاتي؟'),
                  _suggestion('ما هو النصاب؟'),
                  _suggestion('لماذا الزكاة 2.5٪؟'),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final item = messages[index];

                  return Align(
                    alignment: item['isUser']
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: item['isUser']
                            ? AppColors.primary
                            : AppColors.card,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(
                            item['isUser'] ? 20 : 5,
                          ),
                          bottomRight: Radius.circular(
                            item['isUser'] ? 5 : 20,
                          ),
                        ),
                      ),
                      child: Text(
                        item['text'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onSubmitted: (_) => sendMessage(),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'اكتبي سؤالك هنا...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestion(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ActionChip(
        label: Text(text),
        backgroundColor: AppColors.card,
        labelStyle: const TextStyle(color: Colors.white),
        side: BorderSide.none,
        onPressed: () => sendMessage(text),
      ),
    );
  }
}
