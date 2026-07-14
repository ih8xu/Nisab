from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime
from datetime import datetime
from app.database import Base


# حفظ موافقة الشروط والأحكام
class TermsAcceptance(Base):
    __tablename__ = "terms_acceptance"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String)
    accepted = Column(Boolean)
    terms_version = Column(String)
    accepted_at = Column(DateTime, default=datetime.utcnow)


# بيانات الحول والنصاب
class HawlStatus(Base):
    __tablename__ = "hawl_status"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String)
    start_date = Column(DateTime)
    is_completed = Column(Boolean)
    created_at = Column(DateTime, default=datetime.utcnow)


# حسابات الزكاة
class ZakatCalculation(Base):
    __tablename__ = "zakat_calculations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String)
    zakat_type = Column(String)
    amount = Column(Float)
    zakat_result = Column(Float)
    created_at = Column(DateTime, default=datetime.utcnow)


# الأصول الإضافية (ذهب وفضة)
class ZakatAssets(Base):
    __tablename__ = "zakat_assets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String)
    asset_type = Column(String)
    weight = Column(Float)
    value = Column(Float)
    zakat_result = Column(Float)


# عمليات الدفع
class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String)
    amount = Column(Float)
    status = Column(String)
    transaction_id = Column(String)
    payment_date = Column(DateTime, default=datetime.utcnow)