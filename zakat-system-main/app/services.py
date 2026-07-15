from sqlalchemy.orm import Session

from app.models import CustomerFinancialData, InvestmentFund, ZakatAsset
from app.price_service import get_gold_price, get_silver_price


ZAKAT_RATE = 0.025


def _round(value: float) -> float:
    return round(float(value), 2)


def refresh_metal_values(db: Session, user_id: str) -> tuple[float, float]:
    gold_value = 0.0
    silver_value = 0.0

    gold = (
        db.query(ZakatAsset)
        .filter(ZakatAsset.user_id == user_id, ZakatAsset.asset_type == "gold")
        .first()
    )
    if gold is not None:
        gold.price_per_gram = get_gold_price()
        gold.value = gold.weight * gold.price_per_gram * (
            gold.karat_or_purity / 24
        )
        gold.zakat_result = gold.value * ZAKAT_RATE
        gold_value = gold.value

    silver = (
        db.query(ZakatAsset)
        .filter(ZakatAsset.user_id == user_id, ZakatAsset.asset_type == "silver")
        .first()
    )
    if silver is not None:
        silver.price_per_gram = get_silver_price()
        silver.value = silver.weight * silver.price_per_gram * (
            silver.karat_or_purity / 1000
        )
        silver.zakat_result = silver.value * ZAKAT_RATE
        silver_value = silver.value

    if gold is not None or silver is not None:
        db.commit()

    return gold_value, silver_value


def build_zakat_summary(db: Session, user_id: str) -> dict:
    financial_data = (
        db.query(CustomerFinancialData)
        .filter(CustomerFinancialData.user_id == user_id)
        .first()
    )

    cash = financial_data.cash_amount if financial_data else 0.0
    stocks = financial_data.stocks_amount if financial_data else 0.0
    trade_offers = financial_data.trade_offers_amount if financial_data else 0.0
    has_reached_nisab = (
        financial_data.has_reached_nisab if financial_data else False
    )

    gold, silver = refresh_metal_values(db, user_id)
    funds = (
        db.query(InvestmentFund)
        .filter(InvestmentFund.user_id == user_id)
        .all()
    )
    funds_value = sum(fund.units * fund.unit_price for fund in funds)

    total_assets = cash + stocks + trade_offers + gold + silver + funds_value
    total_zakat = total_assets * ZAKAT_RATE

    return {
        "user_id": user_id,
        "cash_amount": _round(cash),
        "gold_amount": _round(gold),
        "silver_amount": _round(silver),
        "stocks_amount": _round(stocks),
        "trade_offers_amount": _round(trade_offers),
        "funds_amount": _round(funds_value),
        "total_assets": _round(total_assets),
        "total_zakat": _round(total_zakat),
        "has_reached_nisab": has_reached_nisab,
        "currency": "SAR",
    }
