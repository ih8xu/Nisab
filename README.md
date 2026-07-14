# نِصاب

تطبيق Flutter مع FastAPI وSQLite لحفظ جلسات احتساب الزكاة والأصول والحول والملخص وسجل الدفع المحاكي لكل مستخدم.

## المتطلبات

- Flutter بإصدار يدعم Dart 3.11 أو أحدث.
- Python 3.11 أو أحدث.
- لا تُنسخ `.env` أو قاعدة البيانات إلى Git.

## تشغيل Backend

```powershell
cd zakat-system-main
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
# عيّن JWT_SECRET_KEY إلى قيمة عشوائية طويلة، واضبط GROQ_API_KEY عند استخدام AI.
alembic upgrade head
uvicorn main:app --reload
```

عنوان API المحلي الافتراضي هو `http://127.0.0.1:8000/api`. يجب ضبط `CORS_ORIGINS` صراحةً للإنتاج واستخدام HTTPS.

## تشغيل Flutter

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

`10.0.2.2` خاص بمحاكي Android. استخدم عنوان الخادم المناسب على الجهاز الحقيقي، ولا تستخدم عنواناً محلياً في بناء الإنتاج.

## الاختبارات

```powershell
cd zakat-system-main
pytest -q
cd ..
flutter analyze
flutter test
```

## قرارات التصميم والحدود

- Flutter لا يفتح SQLite؛ جميع البيانات تمر عبر FastAPI.
- access token قصير العمر، وrefresh token عشوائي مخزن في قاعدة البيانات بصيغة SHA-256 وقابل للإلغاء والتدوير. كلمات المرور مجزأة بـArgon2.
- سعر السوق المستخدم يُحفظ مع الأصل. عند تعذر الخدمة الخارجية يعيد API `is_fallback: true` وتعرض الواجهة تحذيراً.
- قيمتا النصاب والحول قابلتان للضبط عبر `NISAB_GOLD_GRAMS` و`HAWL_DAYS` (القيم الابتدائية 85 جراماً و354 يوماً). يلزم اعتماد المرجع الشرعي النهائي قبل النشر التنظيمي.
- لا يوجد مصدر بيانات بنكي معتمد، لذلك أزيلت شاشة التحليل الوهمية ولم يُخترع تكامل بديل.
- الدفع سجل محاكاة داخلي فقط ولا يثبت تحويلاً مالياً حقيقياً. لا توجد بوابة دفع أو Webhook أو SDK خارجي.
- خدمة AI ومسارها ونموذجها وprompt الخاص بها لم تتغير، ولا تُحفظ المحادثات.
