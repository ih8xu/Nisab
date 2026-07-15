from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import CustomerFinancialData, HawlStatus
from app.schemas import CustomerDataUpsert


router = APIRouter()


def _get_customer_data(db: Session, user_id: str) -> CustomerFinancialData:
    item = (
        db.query(CustomerFinancialData)
        .filter(CustomerFinancialData.user_id == user_id)
        .first()
    )
    if item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="لا توجد بيانات مالية لهذا المستخدم. أضفها أولاً عبر API البيانات الوسيطة.",
        )
    return item


@router.put("/{user_id}")
def upsert_customer_data(
    user_id: str,
    payload: CustomerDataUpsert,
    db: Session = Depends(get_db),
):
    item = (
        db.query(CustomerFinancialData)
        .filter(CustomerFinancialData.user_id == user_id)
        .first()
    )
    if item is None:
        item = CustomerFinancialData(user_id=user_id)
        db.add(item)

    item.cash_amount = payload.cash_amount
    item.stocks_amount = payload.stocks_amount
    item.trade_offers_amount = payload.trade_offers_amount
    item.has_reached_nisab = payload.has_reached_nisab

    hawl = db.query(HawlStatus).filter(HawlStatus.user_id == user_id).first()
    if hawl is None:
        hawl = HawlStatus(user_id=user_id, start_date=datetime.combine(
            payload.hawl_start_date,
            datetime.min.time(),
        ))
        db.add(hawl)
    else:
        hawl.start_date = datetime.combine(
            payload.hawl_start_date,
            datetime.min.time(),
        )

    db.commit()
    db.refresh(item)
    db.refresh(hawl)

    return {
        "user_id": user_id,
        "cash_amount": round(item.cash_amount, 2),
        "stocks_amount": round(item.stocks_amount, 2),
        "trade_offers_amount": round(item.trade_offers_amount, 2),
        "hawl_start_date": hawl.start_date.date().isoformat(),
        "has_reached_nisab": item.has_reached_nisab,
    }


@router.get("/{user_id}")
def get_customer_data(user_id: str, db: Session = Depends(get_db)):
    item = _get_customer_data(db, user_id)
    hawl = db.query(HawlStatus).filter(HawlStatus.user_id == user_id).first()
    if hawl is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="لا توجد بيانات حول لهذا المستخدم.",
        )

    return {
        "user_id": user_id,
        "cash_amount": round(item.cash_amount, 2),
        "stocks_amount": round(item.stocks_amount, 2),
        "trade_offers_amount": round(item.trade_offers_amount, 2),
        "zakatable_balance": round(
            item.cash_amount + item.stocks_amount + item.trade_offers_amount,
            2,
        ),
        "hawl_start_date": hawl.start_date.date().isoformat(),
        "has_reached_nisab": item.has_reached_nisab,
    }
