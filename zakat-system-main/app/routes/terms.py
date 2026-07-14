from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import TermsAcceptance, User
from app.schemas import TermsRequest
from app.security import get_current_user

router = APIRouter()
@router.post("/accept")
def accept_terms(data: TermsRequest, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    row = db.query(TermsAcceptance).filter_by(user_id=user.id, terms_version=data.terms_version).first()
    if not row:
        row = TermsAcceptance(user_id=user.id, accepted=True, terms_version=data.terms_version); db.add(row)
    else: row.accepted = True
    db.commit()
    return {"accepted": True, "terms_version": data.terms_version}
