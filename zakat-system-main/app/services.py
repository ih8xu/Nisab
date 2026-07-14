from datetime import date, timedelta
import os

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models import HawlStatus, ZakatAsset, ZakatCalculation, ZakatSession
from app.price_service import get_price_snapshot

ALLOWED_KARATS = {18, 21, 22, 24}
ALLOWED_PURITY = {800, 925, 999}

def owned_session(db: Session, session_id: int, user_id: int):
    row = db.query(ZakatSession).filter_by(id=session_id, user_id=user_id).first()
    if not row:
        raise HTTPException(404, detail={"code": "SESSION_NOT_FOUND", "message": "جلسة الحساب غير موجودة"})
    return row

def calculate_asset(data, prices=None):
    prices = prices or get_price_snapshot()
    if data.asset_type == "gold":
        if data.karat not in ALLOWED_KARATS or not data.weight:
            raise HTTPException(422, detail={"code": "INVALID_GOLD", "message": "يلزم وزن موجب وعيار ذهب مسموح"})
        market = prices["gold_24k"] * data.karat / 24
        value = data.weight * market
    elif data.asset_type == "silver":
        if data.purity not in ALLOWED_PURITY or not data.weight:
            raise HTTPException(422, detail={"code": "INVALID_SILVER", "message": "يلزم وزن موجب ونقاء فضة مسموح"})
        market = prices["silver_999"] * data.purity / 1000
        value = data.weight * market
    elif data.asset_type == "fund":
        if not data.name or not data.units or not data.unit_price:
            raise HTTPException(422, detail={"code": "INVALID_FUND", "message": "يلزم اسم الصندوق وعدد الوحدات وسعر الوحدة"})
        market = data.unit_price; value = data.units * data.unit_price
    else:
        if not data.amount:
            raise HTTPException(422, detail={"code": "INVALID_CASH", "message": "يلزم مبلغ نقدي موجب"})
        market = None; value = data.amount
    return round(value, 2), round(value * .025, 2), market

def recalculate(db, session):
    asset_total = round(sum(a.total_value for a in session.assets), 2)
    total = round(session.cash_amount + asset_total, 2)
    nisab = round(get_price_snapshot()["gold_24k"] * float(os.getenv("NISAB_GOLD_GRAMS", "85")), 2)
    hawl = db.query(HawlStatus).filter_by(session_id=session.id).first()
    reached = total >= nisab
    due = bool(hawl and hawl.is_completed and reached)
    zakat = round(total * .025, 2) if due else 0.0
    session.total_assets = total; session.total_zakat = zakat; session.status = "calculated"
    db.add(ZakatCalculation(session_id=session.id, total_assets=total, nisab_value=nisab, reached_nisab=reached, total_zakat=zakat))
    db.commit(); db.refresh(session)
    return {"total": total, "nisab": nisab, "reached": reached, "hawl": hawl, "zakat": zakat}
