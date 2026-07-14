from datetime import date, timedelta
import os

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import HawlStatus, User, ZakatAsset, ZakatSession
from app.schemas import AssetOut, AssetRequest, HawlOut, HawlRequest, SessionCreate, SessionOut
from app.security import get_current_user
from app.services import calculate_asset, owned_session, recalculate

router = APIRouter()

@router.post("", response_model=SessionOut, status_code=201)
def create_session(data: SessionCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = ZakatSession(user_id=user.id, cash_amount=data.cash_amount)
    db.add(row); db.commit(); db.refresh(row)
    return row

@router.get("/{session_id}", response_model=SessionOut)
def get_session(session_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return owned_session(db, session_id, user.id)

@router.post("/{session_id}/assets", response_model=AssetOut, status_code=201)
def add_asset(session_id: int, data: AssetRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    session = owned_session(db, session_id, user.id)
    value, zakat, market = calculate_asset(data)
    row = ZakatAsset(session_id=session.id, user_id=user.id, asset_type=data.asset_type, name=data.name, weight=data.weight, karat=data.karat, purity=data.purity, units=data.units, unit_price=data.unit_price, market_price=market, total_value=value, zakat_amount=zakat)
    db.add(row); db.commit(); db.refresh(row); recalculate(db, session)
    return row

@router.get("/{session_id}/assets", response_model=list[AssetOut])
def list_assets(session_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    owned_session(db, session_id, user.id)
    return db.query(ZakatAsset).filter_by(session_id=session_id, user_id=user.id).order_by(ZakatAsset.id).all()

@router.put("/{session_id}/assets/{asset_id}", response_model=AssetOut)
def update_asset(session_id: int, asset_id: int, data: AssetRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    session = owned_session(db, session_id, user.id)
    row = db.query(ZakatAsset).filter_by(id=asset_id, session_id=session_id, user_id=user.id).first()
    if not row: raise HTTPException(404, detail={"code": "ASSET_NOT_FOUND", "message": "الأصل غير موجود"})
    value, zakat, market = calculate_asset(data)
    for key in ("asset_type", "name", "weight", "karat", "purity", "units", "unit_price"):
        setattr(row, key, getattr(data, key))
    row.market_price = market; row.total_value = value; row.zakat_amount = zakat
    db.commit(); db.refresh(row); recalculate(db, session)
    return row

@router.delete("/{session_id}/assets/{asset_id}", status_code=204)
def delete_asset(session_id: int, asset_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    session = owned_session(db, session_id, user.id)
    row = db.query(ZakatAsset).filter_by(id=asset_id, session_id=session_id, user_id=user.id).first()
    if not row: raise HTTPException(404, detail={"code": "ASSET_NOT_FOUND", "message": "الأصل غير موجود"})
    db.delete(row); db.commit(); recalculate(db, session)

def hawl_response(row):
    remaining = max((row.completion_date - date.today()).days, 0)
    return HawlOut(start_date=row.start_date, completion_date=row.completion_date, days_remaining=remaining, is_completed=row.is_completed, is_due=row.is_completed)

@router.post("/{session_id}/hawl", response_model=HawlOut)
def save_hawl(session_id: int, data: HawlRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    session = owned_session(db, session_id, user.id)
    completion = data.start_date + timedelta(days=int(os.getenv("HAWL_DAYS", "354")))
    row = db.query(HawlStatus).filter_by(session_id=session_id).first()
    if row:
        row.start_date = data.start_date; row.completion_date = completion; row.is_completed = date.today() >= completion
    else:
        row = HawlStatus(session_id=session_id, user_id=user.id, start_date=data.start_date, completion_date=completion, is_completed=date.today() >= completion); db.add(row)
    db.commit(); db.refresh(row); recalculate(db, session)
    return hawl_response(row)

@router.get("/{session_id}/hawl", response_model=HawlOut)
def get_hawl(session_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    owned_session(db, session_id, user.id)
    row = db.query(HawlStatus).filter_by(session_id=session_id, user_id=user.id).first()
    if not row: raise HTTPException(404, detail={"code": "HAWL_NOT_FOUND", "message": "بيانات الحول غير موجودة"})
    return hawl_response(row)

@router.get("/{session_id}/summary")
def summary(session_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    session = owned_session(db, session_id, user.id)
    result = recalculate(db, session)
    return {"session_id": session.id, "assets": [AssetOut.model_validate(a) for a in session.assets], "total_assets": result["total"], "nisab_value": result["nisab"], "reached_nisab": result["reached"], "hawl_completed": bool(result["hawl"] and result["hawl"].is_completed), "total_zakat": result["zakat"], "currency": "SAR"}
