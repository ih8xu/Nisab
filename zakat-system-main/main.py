import os
import time
from collections import defaultdict, deque

from dotenv import load_dotenv
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

load_dotenv()

from app.routes import ai, auth, payment, prices, sessions, terms

app = FastAPI(title="منصة الزكاة الرقمية", version="2.0.0")

_attempts = defaultdict(deque)
@app.middleware("http")
async def rate_limit(request: Request, call_next):
    if request.url.path in {"/api/auth/register", "/api/auth/login", "/api/auth/refresh"}:
        key = f"{request.client.host if request.client else 'unknown'}:{request.url.path}"
        now = time.monotonic(); bucket = _attempts[key]
        while bucket and now - bucket[0] > 60: bucket.popleft()
        if len(bucket) >= 10:
            return JSONResponse(status_code=429, content={"code": "RATE_LIMITED", "message": "محاولات كثيرة؛ حاول لاحقاً"})
        bucket.append(now)
    return await call_next(request)

origins = [value.strip() for value in os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:8080").split(",") if value.strip()]
app.add_middleware(CORSMiddleware, allow_origins=origins, allow_credentials=True, allow_methods=["GET", "POST", "PUT", "DELETE"], allow_headers=["Authorization", "Content-Type"])

@app.exception_handler(RequestValidationError)
async def validation_error(_: Request, exc: RequestValidationError):
    return JSONResponse(status_code=422, content={"code": "VALIDATION_ERROR", "message": "البيانات المدخلة غير صالحة", "errors": exc.errors()})

app.include_router(auth.router, prefix="/api/auth", tags=["المصادقة"])
app.include_router(sessions.router, prefix="/api/zakat-sessions", tags=["جلسات الزكاة"])
app.include_router(prices.router, prefix="/api/prices", tags=["الأسعار"])
app.include_router(terms.router, prefix="/api/terms", tags=["الشروط"])
app.include_router(payment.router, prefix="/api/payment", tags=["الدفع المحاكي"])
app.include_router(ai.router, prefix="/api/ai", tags=["المساعد الذكي"])

@app.get("/")
def root():
    return {"status": "ok", "service": "nisab-api"}
