from datetime import datetime
import random

from fastapi import APIRouter, HTTPException, status

from app.database import SessionLocal
from app.models import Payment

router = APIRouter()


@router.post("/pay")
def pay_zakat(
    cash: float = 0,
    gold: float = 0,
    silver: float = 0
):
    if cash < 0 or gold < 0 or silver < 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="مبالغ الزكاة لا يمكن أن تكون سالبة."
        )

    total = cash + gold + silver

    if total <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="إجمالي مبلغ الزكاة يجب أن يكون أكبر من الصفر."
        )

    رقم_العملية = (
        f"ZAKAT-"
        f"{datetime.today().strftime('%Y%m%d')}-"
        f"{random.randint(1000,9999)}"
    )

    db = SessionLocal()

    try:
        new_payment = Payment(
            user_id="demo_user",
            amount=total,
            status="نجاح",
            transaction_id=رقم_العملية
        )

        db.add(new_payment)
        db.commit()
        db.refresh(new_payment)

    finally:
        db.close()

    return {
        "الحالة": "نجاح",
        "حالة الدفع": "تم الدفع بنجاح",
        "المبلغ": round(total, 2),
        "رقم العملية": رقم_العملية,
        "تاريخ الدفع": datetime.today().strftime("%d.%m.%Y"),
        "العملة": "ريال سعودي",
        "الرسالة": "تم سداد الزكاة بنجاح."
    }


@router.get("/completed")
def completed():

    db = SessionLocal()

    try:
        last_payment = (
            db.query(Payment)
            .order_by(Payment.id.desc())
            .first()
        )

        if last_payment is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="لا توجد عملية دفع حتى الآن."
            )

        return {
            "الحالة": "مكتملة",
            "رقم العملية": last_payment.transaction_id,
            "المبلغ": round(last_payment.amount, 2),
            "العملة": "ريال سعودي",
            "الرسالة": "تمت عملية دفع الزكاة بنجاح."
        }

    finally:
        db.close()