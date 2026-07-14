import hashlib
import os
import secrets
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pwdlib import PasswordHash
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import RefreshToken, User

password_hash = PasswordHash.recommended()
bearer = HTTPBearer(auto_error=False)

def normalize_email(email: str) -> str:
    return email.strip().lower()

def validate_password(value: str):
    if len(value) < 10 or not any(c.isupper() for c in value) or not any(c.islower() for c in value) or not any(c.isdigit() for c in value):
        raise HTTPException(422, detail={"code": "WEAK_PASSWORD", "message": "كلمة المرور يجب أن تكون 10 أحرف على الأقل وتحتوي حرفاً كبيراً وصغيراً ورقماً"})

def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()

def create_access_token(user_id: int) -> str:
    secret = os.getenv("JWT_SECRET_KEY")
    if not secret:
        raise RuntimeError("JWT_SECRET_KEY is required")
    now = datetime.now(timezone.utc)
    return jwt.encode({"sub": str(user_id), "type": "access", "iat": now, "exp": now + timedelta(minutes=int(os.getenv("ACCESS_TOKEN_MINUTES", "15")))}, secret, algorithm="HS256")

def create_refresh_token(db: Session, user_id: int) -> str:
    token = secrets.token_urlsafe(48)
    expires = datetime.now(timezone.utc) + timedelta(days=int(os.getenv("REFRESH_TOKEN_DAYS", "30")))
    db.add(RefreshToken(user_id=user_id, token_hash=hash_token(token), expires_at=expires))
    db.commit()
    return token

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(bearer), db: Session = Depends(get_db)) -> User:
    unauthorized = HTTPException(status.HTTP_401_UNAUTHORIZED, detail={"code": "UNAUTHORIZED", "message": "يلزم تسجيل الدخول"})
    if not credentials:
        raise unauthorized
    try:
        payload = jwt.decode(credentials.credentials, os.getenv("JWT_SECRET_KEY", ""), algorithms=["HS256"])
        if payload.get("type") != "access":
            raise unauthorized
        user_id = int(payload["sub"])
    except (jwt.PyJWTError, KeyError, ValueError):
        raise unauthorized
    user = db.get(User, user_id)
    if not user or not user.is_active:
        raise unauthorized
    return user
