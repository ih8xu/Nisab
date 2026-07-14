from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import RefreshToken, User
from app.schemas import LoginRequest, TokenPair, TokenRequest, UserCreate, UserOut
from app.security import create_access_token, create_refresh_token, get_current_user, hash_token, normalize_email, password_hash, validate_password

router = APIRouter()

def pair(db, user):
    return TokenPair(access_token=create_access_token(user.id), refresh_token=create_refresh_token(db, user.id), user=user)

@router.post("/register", response_model=TokenPair, status_code=201)
def register(data: UserCreate, db: Session = Depends(get_db)):
    validate_password(data.password)
    email = normalize_email(data.email)
    if db.query(User).filter(User.email == email).first():
        raise HTTPException(409, detail={"code": "EMAIL_EXISTS", "message": "تعذر إنشاء الحساب بهذه البيانات"})
    user = User(name=data.name.strip(), email=email, password_hash=password_hash.hash(data.password))
    db.add(user); db.commit(); db.refresh(user)
    return pair(db, user)

@router.post("/login", response_model=TokenPair)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == normalize_email(data.email)).first()
    if not user or not password_hash.verify(data.password, user.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail={"code": "INVALID_CREDENTIALS", "message": "بيانات الدخول غير صحيحة"})
    return pair(db, user)

def valid_refresh(data, db):
    record = db.query(RefreshToken).filter(RefreshToken.token_hash == hash_token(data.refresh_token)).first()
    now = datetime.now(timezone.utc)
    if not record or record.revoked_at or record.expires_at.replace(tzinfo=timezone.utc) <= now:
        raise HTTPException(401, detail={"code": "INVALID_REFRESH_TOKEN", "message": "جلسة التجديد غير صالحة"})
    return record

@router.post("/refresh", response_model=TokenPair)
def refresh(data: TokenRequest, db: Session = Depends(get_db)):
    record = valid_refresh(data, db)
    record.revoked_at = datetime.now(timezone.utc); db.commit()
    return pair(db, db.get(User, record.user_id))

@router.post("/logout", status_code=204)
def logout(data: TokenRequest, db: Session = Depends(get_db)):
    record = valid_refresh(data, db)
    record.revoked_at = datetime.now(timezone.utc); db.commit()

@router.get("/me", response_model=UserOut)
def me(user: User = Depends(get_current_user)):
    return user
