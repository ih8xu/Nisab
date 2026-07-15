from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import engine
from app.models import Base

from app.routes import ai
from app.routes import analysis
from app.routes import assets
from app.routes import customer_data
from app.routes import hawl
from app.routes import payment
from app.routes import prices
from app.routes import terms
from app.routes import zakat

# إنشاء جداول قاعدة البيانات
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="منصة الزكاة الرقمية",
    description="واجهة الباك إند الخاصة بمنصة حساب وإدارة الزكاة الذكية",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# أسعار الذهب والفضة
app.include_router(
    prices.router,
    prefix="/api/prices",
    tags=["أسعار الذهب والفضة"]
)

# البيانات المالية الوسيطة التي يعبئها النظام البنكي أو Postman
app.include_router(
    customer_data.router,
    prefix="/api/customer-data",
    tags=["البيانات المالية الوسيطة"]
)

# الأصول الزكوية الإضافية
app.include_router(
    assets.router,
    prefix="/api/assets",
    tags=["الأصول الزكوية"]
)

# الزكاة
app.include_router(
    zakat.router,
    prefix="/api/zakat",
    tags=["حساب الزكاة"]
)

# الحول
app.include_router(
    hawl.router,
    prefix="/api/hawl",
    tags=["حساب الحول"]
)

# الشروط والأحكام
app.include_router(
    terms.router,
    prefix="/api/terms",
    tags=["الشروط والأحكام"]
)

# الدفع
app.include_router(
    payment.router,
    prefix="/api/payment",
    tags=["الدفع"]
)

# المساعد الذكي
app.include_router(
    ai.router,
    prefix="/api/ai",
    tags=["المساعد الذكي"]
)

# تحليل البيانات
app.include_router(
    analysis.router,
    prefix="/api/analysis",
    tags=["تحليل البيانات"]
)

# الصفحة الرئيسية
@app.get("/", tags=["الرئيسية"])
def read_root():
    return {
        "الحالة": "نجاح",
        "الرسالة": "مرحبًا بك في الباك إند الخاص بمنصة الزكاة"
    }

from fastapi.middleware.cors import CORSMiddleware
