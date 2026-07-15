# Nisab FastAPI backend

يستخدم الباكند قاعدة SQLite محلية في `zakat-system-main/zakat.db`. المعرّف
المستخدم في النموذج الأولي هو `demo_user`، وهو نفس المعرّف الافتراضي داخل
تطبيق Flutter.

## التشغيل

```powershell
cd zakat-system-main
.\.venv\Scripts\python.exe -m uvicorn main:app --reload
```

تتوفر وثائق الـAPI التفاعلية على:

```text
http://127.0.0.1:8000/docs
```

## تعبئة البيانات الوسيطة من Postman

نفّذ طلب `PUT` إلى:

```text
http://127.0.0.1:8000/api/customer-data/demo_user
```

واستخدم Body من نوع JSON:

```json
{
  "cash_amount": 57250,
  "stocks_amount": 0,
  "trade_offers_amount": 0,
  "hawl_start_date": "2026-07-15",
  "has_reached_nisab": true
}
```

هذا الطلب ينشئ أو يحدّث بيانات العميل المالية وبيانات بداية الحول في SQLite.

## أهم المسارات المرتبطة بالتطبيق

- `GET /api/analysis/analyze?user_id=demo_user`
- `GET /api/hawl/details?user_id=demo_user`
- `GET /api/assets/demo_user`
- `PUT /api/assets/demo_user/gold`
- `PUT /api/assets/demo_user/silver`
- `POST /api/assets/demo_user/funds`
- `GET /api/zakat/demo_user/summary`
- `POST /api/payment/demo_user/pay`
- `GET /api/payment/demo_user/completed`
- `POST /api/ai/assistant?user_id=demo_user&question=...`

## عنوان الباكند في Flutter

القيمة الافتراضية هي `http://127.0.0.1:8000`. ويمكن تغييرها دون تعديل الكود:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

يُستخدم `10.0.2.2` عند تشغيل التطبيق على محاكي Android. على جهاز فعلي استخدم
عنوان IP الخاص بالجهاز الذي يشغّل FastAPI على الشبكة المحلية.

## الاختبارات

```powershell
.\.venv\Scripts\python.exe -m unittest discover -s tests -v
```
