from fastapi import APIRouter
from app.price_service import get_price_snapshot
router = APIRouter()
@router.get("/live")
def live_prices():
    value = get_price_snapshot()
    return {**value, "updated_at": value["updated_at"].isoformat()}
