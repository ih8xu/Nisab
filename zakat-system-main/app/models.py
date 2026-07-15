from datetime import UTC, datetime

from sqlalchemy import Boolean, Column, DateTime, Float, Integer, String, UniqueConstraint

from app.database import Base


def utc_now() -> datetime:
    return datetime.now(UTC).replace(tzinfo=None)


class TermsAcceptance(Base):
    __tablename__ = "terms_acceptance"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, nullable=False, index=True)
    accepted = Column(Boolean, nullable=False, default=True)
    terms_version = Column(String, nullable=False, default="1.0")
    accepted_at = Column(DateTime, nullable=False, default=utc_now)


class CustomerFinancialData(Base):
    """بيانات وسيطة يعبئها النظام البنكي، أو Postman في النموذج الأولي."""

    __tablename__ = "customer_financial_data"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, nullable=False, unique=True, index=True)
    cash_amount = Column(Float, nullable=False, default=0)
    stocks_amount = Column(Float, nullable=False, default=0)
    trade_offers_amount = Column(Float, nullable=False, default=0)
    has_reached_nisab = Column(Boolean, nullable=False, default=False)
    updated_at = Column(
        DateTime,
        nullable=False,
        default=utc_now,
        onupdate=utc_now,
    )


class HawlStatus(Base):
    __tablename__ = "hawl_status"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, nullable=False, unique=True, index=True)
    start_date = Column(DateTime, nullable=False)
    created_at = Column(DateTime, nullable=False, default=utc_now)
    updated_at = Column(
        DateTime,
        nullable=False,
        default=utc_now,
        onupdate=utc_now,
    )


class ZakatCalculation(Base):
    __tablename__ = "zakat_calculations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, nullable=False, index=True)
    zakat_type = Column(String, nullable=False)
    amount = Column(Float, nullable=False)
    zakat_result = Column(Float, nullable=False)
    created_at = Column(DateTime, nullable=False, default=utc_now)


class ZakatAsset(Base):
    __tablename__ = "zakat_assets"
    __table_args__ = (
        UniqueConstraint("user_id", "asset_type", name="uq_user_asset_type"),
    )

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, nullable=False, index=True)
    asset_type = Column(String, nullable=False)
    weight = Column(Float, nullable=False, default=0)
    karat_or_purity = Column(Integer, nullable=True)
    price_per_gram = Column(Float, nullable=False, default=0)
    value = Column(Float, nullable=False, default=0)
    zakat_result = Column(Float, nullable=False, default=0)
    updated_at = Column(
        DateTime,
        nullable=False,
        default=utc_now,
        onupdate=utc_now,
    )


class InvestmentFund(Base):
    __tablename__ = "investment_funds"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, nullable=False, index=True)
    name = Column(String, nullable=False)
    units = Column(Float, nullable=False)
    unit_price = Column(Float, nullable=False)
    created_at = Column(DateTime, nullable=False, default=utc_now)


class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, nullable=False, index=True)
    zakatable_amount = Column(Float, nullable=False)
    amount = Column(Float, nullable=False)
    method = Column(String, nullable=False)
    status = Column(String, nullable=False)
    transaction_id = Column(String, nullable=False, unique=True, index=True)
    payment_date = Column(DateTime, nullable=False, default=utc_now)
