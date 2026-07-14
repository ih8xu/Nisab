from datetime import datetime, timezone

from sqlalchemy import Boolean, CheckConstraint, Column, Date, DateTime, Float, ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.orm import relationship

from app.database import Base

def utcnow():
    return datetime.now(timezone.utc)

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    name = Column(String(120), nullable=False)
    email = Column(String(320), nullable=False, unique=True, index=True)
    password_hash = Column(String(512), nullable=False)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)
    updated_at = Column(DateTime(timezone=True), nullable=False, default=utcnow, onupdate=utcnow)

class RefreshToken(Base):
    __tablename__ = "refresh_tokens"
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    token_hash = Column(String(64), nullable=False, unique=True, index=True)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    revoked_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

class ZakatSession(Base):
    __tablename__ = "zakat_sessions"
    __table_args__ = (CheckConstraint("status IN ('draft','calculated','payment_pending','paid')"), CheckConstraint("cash_amount >= 0"))
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    status = Column(String(24), nullable=False, default="draft")
    cash_amount = Column(Float, nullable=False, default=0)
    total_assets = Column(Float, nullable=False, default=0)
    total_zakat = Column(Float, nullable=False, default=0)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)
    updated_at = Column(DateTime(timezone=True), nullable=False, default=utcnow, onupdate=utcnow)
    assets = relationship("ZakatAsset", cascade="all, delete-orphan", back_populates="session")

class ZakatAsset(Base):
    __tablename__ = "zakat_assets"
    __table_args__ = (CheckConstraint("asset_type IN ('cash','gold','silver','fund')"), CheckConstraint("total_value >= 0 AND zakat_amount >= 0"), Index("ix_assets_session_user", "session_id", "user_id"))
    id = Column(Integer, primary_key=True)
    session_id = Column(Integer, ForeignKey("zakat_sessions.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    asset_type = Column(String(16), nullable=False)
    name = Column(String(120))
    weight = Column(Float)
    karat = Column(Integer)
    purity = Column(Integer)
    units = Column(Float)
    unit_price = Column(Float)
    market_price = Column(Float)
    total_value = Column(Float, nullable=False)
    zakat_amount = Column(Float, nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)
    updated_at = Column(DateTime(timezone=True), nullable=False, default=utcnow, onupdate=utcnow)
    session = relationship("ZakatSession", back_populates="assets")

class HawlStatus(Base):
    __tablename__ = "hawl_status"
    __table_args__ = (UniqueConstraint("session_id"),)
    id = Column(Integer, primary_key=True)
    session_id = Column(Integer, ForeignKey("zakat_sessions.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    start_date = Column(Date, nullable=False)
    completion_date = Column(Date, nullable=False)
    is_completed = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

class ZakatCalculation(Base):
    __tablename__ = "zakat_calculations"
    id = Column(Integer, primary_key=True)
    session_id = Column(Integer, ForeignKey("zakat_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    total_assets = Column(Float, nullable=False)
    nisab_value = Column(Float, nullable=False)
    reached_nisab = Column(Boolean, nullable=False)
    total_zakat = Column(Float, nullable=False)
    calculation_date = Column(DateTime(timezone=True), nullable=False, default=utcnow)

class TermsAcceptance(Base):
    __tablename__ = "terms_acceptance"
    __table_args__ = (UniqueConstraint("user_id", "terms_version"),)
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    accepted = Column(Boolean, nullable=False)
    terms_version = Column(String(32), nullable=False)
    accepted_at = Column(DateTime(timezone=True), nullable=False, default=utcnow)

class Payment(Base):
    __tablename__ = "payments"
    __table_args__ = (CheckConstraint("status IN ('pending','paid','failed')"),)
    id = Column(Integer, primary_key=True)
    session_id = Column(Integer, ForeignKey("zakat_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    amount = Column(Float, nullable=False)
    method = Column(String(64), nullable=False)
    status = Column(String(16), nullable=False, default="paid")
    transaction_id = Column(String(80), nullable=False, unique=True, index=True)
    payment_date = Column(DateTime(timezone=True), nullable=False, default=utcnow)
