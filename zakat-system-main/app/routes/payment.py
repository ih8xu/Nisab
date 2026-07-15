from datetime import datetime
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Payment
from app.schemas import PaymentCreate
from app.services import build_zakat_summary


router = APIRouter()


def _payment_response(payment: Payment) -> dict:
    return {
        "status": payment.status,
        "user_id": payment.user_id,
        "zakatable_amount": round(payment.zakatable_amount, 2),
        "amount": round(payment.amount, 2),
        "method": payment.method,
        "transaction_id": payment.transaction_id,
        "payment_date": payment.payment_date.isoformat(),
        "currency": "SAR",
    }


@router.post("/{user_id}/pay", status_code=status.HTTP_201_CREATED)
def pay_zakat(
    user_id: str,
    payload: PaymentCreate,
    db: Session = Depends(get_db),
):
    summary = build_zakat_summary(db, user_id)
    if summary["total_zakat"] <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="إجمالي مبلغ الزكاة يجب أن يكون أكبر من الصفر.",
        )

    transaction_id = (
        f"ZAKAT-{datetime.today().strftime('%Y%m%d')}-{uuid4().hex[:8].upper()}"
    )
    payment = Payment(
        user_id=user_id,
        zakatable_amount=summary["total_assets"],
        amount=summary["total_zakat"],
        method=payload.method,
        status="completed",
        transaction_id=transaction_id,
    )
    db.add(payment)
    db.commit()
    db.refresh(payment)
    return _payment_response(payment)


@router.get("/{user_id}/completed")
def completed(user_id: str, db: Session = Depends(get_db)):
    payment = (
        db.query(Payment)
        .filter(Payment.user_id == user_id, Payment.status == "completed")
        .order_by(Payment.id.desc())
        .first()
    )
    if payment is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="لا توجد عملية دفع مكتملة لهذا المستخدم.",
        )
    return _payment_response(payment)
