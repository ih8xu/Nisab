from fastapi import APIRouter
from app.price_service import get_gold_price, get_silver_price

router = APIRouter()


@router.get("/live")
def live_prices():

    gold24 = get_gold_price()
    silver = get_silver_price()

    return {
        "الحالة": "نجاح",
        "الذهب": {
            "عيار 24": round(gold24, 2),
            "عيار 22": round(gold24 * 22 / 24, 2),
            "عيار 21": round(gold24 * 21 / 24, 2),
            "عيار 18": round(gold24 * 18 / 24, 2)
        },
        "الفضة": {
            "عيار 999": round(silver, 2)
        },
        "العملة": "ريال سعودي",
        "الرسالة": "تم جلب أسعار الذهب والفضة بنجاح."
    }