from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.ai_service import ask_ai
from app.database import get_db
from app.price_service import get_gold_price, get_silver_price
from app.services import build_zakat_summary


router = APIRouter()


@router.post("/assistant")
def ai_assistant(
    question: str,
    user_id: str,
    db: Session = Depends(get_db),
):
    question = question.strip()
    if not question:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="السؤال مطلوب.",
        )

    if "سعر الذهب" in question:
        gold24 = get_gold_price()
        return {
            "answer": (
                f"سعر الذهب عيار 24 هو {round(gold24, 2)} ريال/جرام، "
                f"وعيار 22 هو {round(gold24 * 22 / 24, 2)} ريال/جرام، "
                f"وعيار 21 هو {round(gold24 * 21 / 24, 2)} ريال/جرام، "
                f"وعيار 18 هو {round(gold24 * 18 / 24, 2)} ريال/جرام."
            )
        }

    if "سعر الفضة" in question:
        silver = get_silver_price()
        return {"answer": f"سعر الفضة اليوم هو {round(silver, 2)} ريال/جرام."}

    summary = build_zakat_summary(db, user_id)
    financial_context = (
        f"إجمالي الأصول الزكوية: {summary['total_assets']} ريال. "
        f"الزكاة المحسوبة: {summary['total_zakat']} ريال. "
        f"بلغ النصاب: {'نعم' if summary['has_reached_nisab'] else 'لا'}."
    )
    try:
        answer = ask_ai(question, financial_context)
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(exc),
        ) from exc
    return {"answer": answer}
