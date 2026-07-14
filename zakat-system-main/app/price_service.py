from datetime import datetime, timedelta, timezone
import os
from threading import Lock

import requests

USD_TO_SAR = 3.75
FALLBACK = {
    "gold_24k": float(os.getenv("FALLBACK_GOLD_SAR", "432")),
    "silver_999": float(os.getenv("FALLBACK_SILVER_SAR", "5")),
}
_cache = None
_lock = Lock()

def _fetch(symbol):
    response = requests.get(f"https://api.gold-api.com/price/{symbol}", timeout=5)
    response.raise_for_status()
    return round((float(response.json()["price"]) / 31.1035) * USD_TO_SAR, 2)

def get_price_snapshot(force=False):
    global _cache
    now = datetime.now(timezone.utc)
    with _lock:
        if not force and _cache and now - _cache["updated_at"] < timedelta(minutes=5):
            return dict(_cache)
        try:
            result = {"gold_24k": _fetch("XAU"), "silver_999": _fetch("XAG"), "currency": "SAR", "source": "gold-api.com", "is_fallback": False, "updated_at": now}
        except (requests.RequestException, KeyError, TypeError, ValueError):
            result = {**FALLBACK, "currency": "SAR", "source": "configured fallback", "is_fallback": True, "updated_at": now}
        _cache = result
        return dict(result)

def get_gold_price():
    return get_price_snapshot()["gold_24k"]

def get_silver_price():
    return get_price_snapshot()["silver_999"]
