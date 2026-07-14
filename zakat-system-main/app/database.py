from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# مسار قاعدة بيانات SQLite المحلي
DATABASE_URL = "sqlite:///./zakat.db"

# إنشاء محرك قاعدة البيانات مع السماح بالـ Multi-threading لـ FastAPI
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)

# إنشاء الجلسات المحلية للتعامل مع البيانات
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# الفئة الأساسية لإنشاء الـ Models لاحقاً
Base = declarative_base()

# 💡 الإضافة الاحترافية (محقن التبعية لفتح وإغلاق الجلسات تلقائياً)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()