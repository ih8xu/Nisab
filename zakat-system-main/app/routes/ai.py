from fastapi import APIRouter
from app.ai_service import ask_ai
from app.price_service import get_gold_price, get_silver_price

router = APIRouter()


@router.post("/assistant")
def ai_assistant(question: str):

    question = question.strip()

    if "سعر الذهب" in question:

        gold24 = get_gold_price()

        return {
            "الإجابة": {
                "أسعار الذهب اليوم": {
                    "عيار 24": f"{round(gold24, 2)} ريال/جرام",
                    "عيار 22": f"{round(gold24 * 22 / 24, 2)} ريال/جرام",
                    "عيار 21": f"{round(gold24 * 21 / 24, 2)} ريال/جرام",
                    "عيار 18": f"{round(gold24 * 18 / 24, 2)} ريال/جرام"
                }
            }
        }

    elif "سعر الفضة" in question:

        silver = get_silver_price()

        return {
            "الإجابة": f"سعر الفضة اليوم هو {round(silver, 2)} ريال/جرام."
        }

    # أي سؤال آخر يروح للذكاء الاصطناعي
    answer = ask_ai(question)

    return {
        "الإجابة": answer
    }