from datetime import datetime, timedelta

from fastapi import APIRouter, HTTPException, status

router = APIRouter()


@router.post("/status")
def save_hawl_status(
    start_date: str,
    is_completed: bool
):
    """
    حفظ حالة الحول بشكل مبدئي.
    صيغة التاريخ المطلوبة: يوم.شهر.سنة
    مثال: 10.07.2026
    """

    try:
        parsed_date = datetime.strptime(start_date, "%d.%m.%Y")
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="صيغة التاريخ غير صحيحة. استخدمي الصيغة: يوم.شهر.سنة، مثل 10.07.2026.",
        )

    return {
        "الحالة": "نجاح",
        "تاريخ بداية الحول": parsed_date.strftime("%d.%m.%Y"),
        "هل اكتمل الحول": is_completed,
        "الرسالة": "تم حفظ حالة الحول بنجاح.",
    }


@router.get("/details")
def hawl_details(start_date: str):
    """
    حساب تفاصيل الحول:
    - تاريخ البداية
    - تاريخ اليوم
    - تاريخ اكتمال الحول
    - الأيام المتبقية
    - حالة الحول
    """

    try:
        start = datetime.strptime(start_date, "%d.%m.%Y")
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="صيغة التاريخ غير صحيحة. استخدمي الصيغة: يوم.شهر.سنة، مثل 10.07.2026.",
        )

    today = datetime.today()
    end_date = start + timedelta(days=354)
    remaining_days = (end_date.date() - today.date()).days

    if remaining_days <= 0:
        hawl_status = "مكتمل"
        remaining_days = 0
        is_completed = True
    else:
        hawl_status = "قيد الاكتمال"
        is_completed = False

    return {
        "الحالة": "نجاح",
        "تاريخ بداية الحول": start.strftime("%d.%m.%Y"),
        "تاريخ اليوم": today.strftime("%d.%m.%Y"),
        "تاريخ اكتمال الحول": end_date.strftime("%d.%m.%Y"),
        "الأيام المتبقية": remaining_days,
        "هل اكتمل الحول": is_completed,
        "حالة الحول": hawl_status,
        "الرسالة": "تم حساب حالة الحول بنجاح.",
    }