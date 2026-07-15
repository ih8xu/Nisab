from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import CustomerFinancialData, HawlStatus


router = APIRouter()


@router.get("/analyze")
def analyze_data(user_id: str, db: Session = Depends(get_db)):
    data = (
        db.query(CustomerFinancialData)
        .filter(CustomerFinancialData.user_id == user_id)
        .first()
    )
    hawl = db.query(HawlStatus).filter(HawlStatus.user_id == user_id).first()
    if data is None or hawl is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="بيانات العميل الوسيطة غير مكتملة. أضفها عبر /api/customer-data/{user_id}.",
        )

    zakatable_balance = (
        data.cash_amount + data.stocks_amount + data.trade_offers_amount
    )
    return {
        "status": "completed",
        "progress": 100,
        "user_id": user_id,
        "zakatable_balance": round(zakatable_balance, 2),
        "has_reached_nisab": data.has_reached_nisab,
        "hawl_start_date": hawl.start_date.date().isoformat(),
        "currency": "SAR",
    }
