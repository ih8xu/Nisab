from fastapi import APIRouter
from app.database import SessionLocal
from app.models import TermsAcceptance

router = APIRouter()


@router.post("/accept")
def accept_terms():

    db = SessionLocal()

    new_acceptance = TermsAcceptance(
        user_id="demo_user",
        accepted=True,
        terms_version="1.0"
    )

    db.add(new_acceptance)
    db.commit()
    db.close()

    return {
        "الحالة": "نجاح",
        "الرسالة": "تمت الموافقة على الشروط والأحكام بنجاح."
    }
