import secrets
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Payment, User
from app.schemas import PaymentRequest
from app.security import get_current_user
from app.services import owned_session

router = APIRouter()
def output(row):
    return {"id": row.id, "session_id": row.session_id, "amount": row.amount, "method": row.method, "status": row.status, "transaction_id": row.transaction_id, "payment_date": row.payment_date, "currency": "SAR", "simulation": True, "notice": "سجل محاكاة داخلية ولا يثبت تحويلاً مالياً حقيقياً"}

@router.post("/pay")
def pay(data: PaymentRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    session = owned_session(db, data.session_id, user.id)
    if session.total_zakat <= 0: raise HTTPException(422, detail={"code": "NOTHING_DUE", "message": "لا يوجد مبلغ زكاة مستحق"})
    row = Payment(session_id=session.id, user_id=user.id, amount=session.total_zakat, method=data.method, status="paid", transaction_id=f"SIM-{datetime.now(timezone.utc):%Y%m%d}-{secrets.token_hex(4).upper()}")
    session.status = "paid"; db.add(row); db.commit(); db.refresh(row)
    return output(row)

@router.get("/completed")
def completed(session_id: int | None = None, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    query = db.query(Payment).filter(Payment.user_id == user.id)
    if session_id is not None: query = query.filter(Payment.session_id == session_id)
    row = query.order_by(Payment.id.desc()).first()
    if not row: raise HTTPException(404, detail={"code": "PAYMENT_NOT_FOUND", "message": "لا يوجد سجل دفع"})
    return output(row)
