from fastapi import APIRouter

router = APIRouter()


@router.get("/analyze")
def analyze_data():

    return {
        "الحالة": "جاري التحليل",
        "الرسالة": "يتم الآن تحليل بيانات العميل وحساب الأموال الخاضعة للزكاة.",
        "نسبة الإنجاز": "100%"
    }