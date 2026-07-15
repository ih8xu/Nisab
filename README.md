# نظام نِصاب

تطبيق Flutter مرتبط بباكند Python باستخدام FastAPI وSQLite. يستخدم النموذج
الأولي المعرّف الافتراضي `demo_user` في جميع العمليات.

## المتطلبات

- Flutter مثبت ومضاف إلى `PATH`.
- Python 3.10 أو أحدث.
- اتصال بالإنترنت لجلب أسعار الذهب والفضة.
- Postman لتعبئة بيانات العميل التجريبية.

## 1. إعداد وتشغيل الباكند

من PowerShell داخل مجلد المشروع:

```powershell
cd E:\Nisab\zakat-system-main
```

عند التشغيل لأول مرة، أنشئ البيئة الافتراضية وثبّت المتطلبات:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

إذا كان أمر `python` يشير إلى إصدار قديم على هذا الجهاز، استخدم Python 3.13
المثبت حاليًا:

```powershell
& "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe" -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

شغّل FastAPI:

```powershell
.\.venv\Scripts\python.exe -m uvicorn main:app --reload
```

بعد التشغيل تتوفر الروابط التالية:

- الباكند: `http://127.0.0.1:8000`
- توثيق Swagger: `http://127.0.0.1:8000/docs`
- ملف OpenAPI: `http://127.0.0.1:8000/openapi.json`

تُنشأ قاعدة SQLite تلقائيًا في:

```text
E:\Nisab\zakat-system-main\zakat.db
```

## 2. تعبئة بيانات العميل باستخدام Postman

يجب تعبئة البيانات الوسيطة قبل بدء التطبيق.

أنشئ طلبًا جديدًا في Postman بالمواصفات التالية:

- Method: `PUT`
- URL: `http://127.0.0.1:8000/api/customer-data/demo_user`
- Body: اختر `raw` ثم `JSON`

```json
{
  "cash_amount": 57250,
  "stocks_amount": 0,
  "trade_offers_amount": 0,
  "hawl_start_date": "2026-07-15",
  "has_reached_nisab": true
}
```

عند نجاح الطلب ستُحفظ البيانات المالية وبداية الحول في SQLite. يمكن إرسال
الطلب نفسه مرة أخرى لتحديث بيانات `demo_user`.

## 3. إعداد المساعد الذكي

هذه الخطوة مطلوبة فقط لتشغيل شاشة المساعد الذكي. أنشئ ملفًا باسم `.env` داخل
`zakat-system-main` وأضف مفتاح Groq:

```env
GROQ_API_KEY=ضع_المفتاح_هنا
```

بقية وظائف التطبيق تعمل دون هذا المفتاح.

## 4. تشغيل Flutter

افتح نافذة PowerShell أخرى، ثم نفّذ:

```powershell
cd E:\Nisab
flutter pub get
```

### Windows

```powershell
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### المتصفح

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

### محاكي Android

يستخدم محاكي Android العنوان `10.0.2.2` للوصول إلى الجهاز المضيف:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### جهاز Android فعلي

شغّل الباكند ليستمع على الشبكة المحلية:

```powershell
cd E:\Nisab\zakat-system-main
.\.venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8000
```

ثم شغّل Flutter باستخدام عنوان IP للجهاز الذي يشغّل الباكند:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000
```

استبدل `192.168.1.100` بعنوان IP الصحيح، وتأكد أن الهاتف والكمبيوتر على الشبكة
نفسها وأن جدار الحماية يسمح بالمنفذ `8000`.

## الاختبارات

اختبارات الباكند:

```powershell
cd E:\Nisab\zakat-system-main
.\.venv\Scripts\python.exe -m unittest discover -s tests -v
```

فحص واختبارات Flutter:

```powershell
cd E:\Nisab
flutter analyze --no-pub
flutter test --no-pub
```

## إيقاف التشغيل

اضغط `Ctrl + C` في نافذة الباكند وفي نافذة Flutter لإيقاف كل عملية.
