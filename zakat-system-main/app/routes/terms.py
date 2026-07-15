from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import TermsAcceptance


router = APIRouter()


@router.post("/accept")
def accept_terms(
    user_id: str,
    terms_version: str = "1.0",
    db: Session = Depends(get_db),
):
    acceptance = TermsAcceptance(
        user_id=user_id,
        accepted=True,
        terms_version=terms_version,
    )
    db.add(acceptance)
    db.commit()
    db.refresh(acceptance)
    return {
        "status": "accepted",
        "user_id": user_id,
        "terms_version": terms_version,
        "accepted_at": acceptance.accepted_at.isoformat(),
    }
