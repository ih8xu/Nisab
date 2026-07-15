from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import CustomerFinancialData, HawlStatus


router = APIRouter()
HAWL_DAYS = 354


@router.get("/details")
def hawl_details(user_id: str, db: Session = Depends(get_db)):
    hawl = db.query(HawlStatus).filter(HawlStatus.user_id == user_id).first()
    financial_data = (
        db.query(CustomerFinancialData)
        .filter(CustomerFinancialData.user_id == user_id)
        .first()
    )
    if hawl is None or financial_data is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="بيانات الحول أو البيانات المالية غير موجودة لهذا المستخدم.",
        )

    today = datetime.today()
    end_date = hawl.start_date + timedelta(days=HAWL_DAYS)
    remaining_days = max((end_date.date() - today.date()).days, 0)
    is_completed = remaining_days == 0
    zakatable_balance = (
        financial_data.cash_amount
        + financial_data.stocks_amount
        + financial_data.trade_offers_amount
    )

    return {
        "user_id": user_id,
        "start_date": hawl.start_date.date().isoformat(),
        "today": today.date().isoformat(),
        "completion_date": end_date.date().isoformat(),
        "remaining_days": remaining_days,
        "is_completed": is_completed,
        "hawl_status": "completed" if is_completed else "in_progress",
        "has_reached_nisab": financial_data.has_reached_nisab,
        "zakatable_balance": round(zakatable_balance, 2),
        "currency": "SAR",
    }
