from typing import Optional

from fastapi import APIRouter, HTTPException, status, Query

from app.zakat import (
    calculate_cash_zakat,
    calculate_gold_zakat,
    calculate_silver_zakat,
)

router = APIRouter()

ALLOWED_GOLD_KARATS = [24, 22, 21, 18]
ALLOWED_SILVER_PURITY = [999, 925, 800]


@router.get("/calculate-cash")
def calculate_cash(amount: float):
    """حساب زكاة الأموال النقدية."""

    if amount <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="يجب أن يكون المبلغ أكبر من الصفر.",
        )

    zakat = calculate_cash_zakat(amount)

    return {
        "الحالة": "نجاح",
        "المبلغ": round(amount, 2),
        "مبلغ الزكاة": round(zakat, 2),
        "العملة": "ريال سعودي",
        "الرسالة": "تم حساب زكاة الأموال النقدية بنجاح.",
    }


@router.post("/calculate-zakat")
def calculate_zakat(
    zakat_type: str = Query(..., alias="نوع الزكاة", description="نقد أو ذهب أو فضة"),
    amount: Optional[float] = Query(None, alias="المبلغ", description="المبلغ النقدي"),
    weight: Optional[float] = Query(None, alias="الوزن", description="الوزن بالجرام"),
    karat: Optional[int] = Query(None, alias="عيار الذهب", description="24 أو 22 أو 21 أو 18"),
    purity: Optional[int] = Query(None, alias="نقاء الفضة", description="999 أو 925 أو 800"),
):
    """حساب الزكاة بحسب النوع."""

    normalized_type = zakat_type.strip().lower()

    if normalized_type in ["cash", "نقد", "أموال", "اموال"]:
        if amount is None or amount <= 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="يجب إدخال مبلغ أكبر من الصفر لحساب زكاة النقد.",
            )

        result = calculate_cash_zakat(amount)
        arabic_type = "النقد"

    elif normalized_type in ["gold", "ذهب"]:
        if weight is None or weight <= 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="يجب إدخال وزن الذهب.",
            )

        if karat not in ALLOWED_GOLD_KARATS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="العيارات المتاحة: 24، 22، 21، 18.",
            )

        result = calculate_gold_zakat(weight, karat)
        arabic_type = "الذهب"

    elif normalized_type in ["silver", "فضة"]:
        if weight is None or weight <= 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="يجب إدخال وزن الفضة.",
            )

        if purity not in ALLOWED_SILVER_PURITY:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="النقاء المتاح: 999، 925، 800.",
            )

        result = calculate_silver_zakat(weight, purity)
        arabic_type = "الفضة"

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="نوع الزكاة غير صحيح.",
        )

    return {
        "الحالة": "نجاح",
        "نوع الزكاة": arabic_type,
        "مبلغ الزكاة": round(result, 2),
        "العملة": "ريال سعودي",
        "الرسالة": "تم حساب الزكاة بنجاح."
    }


@router.post("/assets-zakat")
def assets_zakat(
    asset_type: str = Query(..., alias="نوع الأصل", description="ذهب أو فضة"),
    weight: float = Query(..., alias="الوزن", description="الوزن بالجرام"),
    karat: Optional[int] = Query(None, alias="عيار الذهب", description="24 أو 22 أو 21 أو 18"),
    purity: Optional[int] = Query(None, alias="نقاء الفضة", description="999 أو 925 أو 800"),
):
    """حساب زكاة الذهب أو الفضة."""

    if weight <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="يجب أن يكون الوزن أكبر من الصفر."
        )

    normalized_type = asset_type.strip().lower()

    if normalized_type in ["gold", "ذهب"]:

        if karat not in ALLOWED_GOLD_KARATS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="العيارات المتاحة: 24، 22، 21، 18."
            )

        result = calculate_gold_zakat(weight, karat)
        arabic_type = "الذهب"

    elif normalized_type in ["silver", "فضة"]:

        if purity not in ALLOWED_SILVER_PURITY:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="النقاء المتاح: 999، 925، 800."
            )

        result = calculate_silver_zakat(weight, purity)
        arabic_type = "الفضة"

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="نوع الأصل غير صحيح."
        )

    return {
        "الحالة": "نجاح",
        "نوع الأصل": arabic_type,
        "الوزن": round(weight, 2),
        "مبلغ الزكاة": round(result, 2),
        "العملة": "ريال سعودي",
        "الرسالة": "تم حساب زكاة الأصل بنجاح."
    }


@router.get("/final-result")
def final_result(
    cash: float = Query(0, alias="زكاة النقد"),
    gold: float = Query(0, alias="زكاة الذهب"),
    silver: float = Query(0, alias="زكاة الفضة"),
):

    if cash < 0 or gold < 0 or silver < 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="قيم الزكاة لا يمكن أن تكون سالبة."
        )

    total = cash + gold + silver

    return {
        "الحالة": "نجاح",
        "زكاة النقد": round(cash, 2),
        "زكاة الذهب": round(gold, 2),
        "زكاة الفضة": round(silver, 2),
        "إجمالي الزكاة": round(total, 2),
        "العملة": "ريال سعودي",
        "الرسالة": "تم حساب إجمالي الزكاة بنجاح."
    }