from datetime import date, datetime
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field

class UserCreate(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    email: EmailStr
    password: str

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenRequest(BaseModel):
    refresh_token: str

class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    email: str
    is_active: bool

class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserOut

class SessionCreate(BaseModel):
    cash_amount: float = Field(default=0, ge=0)

class SessionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    status: str
    cash_amount: float
    total_assets: float
    total_zakat: float
    created_at: datetime

class AssetRequest(BaseModel):
    asset_type: Literal["cash", "gold", "silver", "fund"]
    name: Optional[str] = Field(default=None, max_length=120)
    weight: Optional[float] = Field(default=None, gt=0)
    karat: Optional[int] = None
    purity: Optional[int] = None
    units: Optional[float] = Field(default=None, gt=0)
    unit_price: Optional[float] = Field(default=None, gt=0)
    amount: Optional[float] = Field(default=None, gt=0)

class AssetOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    asset_type: str
    name: Optional[str]
    weight: Optional[float]
    karat: Optional[int]
    purity: Optional[int]
    units: Optional[float]
    unit_price: Optional[float]
    market_price: Optional[float]
    total_value: float
    zakat_amount: float

class HawlRequest(BaseModel):
    start_date: date

class HawlOut(BaseModel):
    start_date: date
    completion_date: date
    days_remaining: int
    is_completed: bool
    is_due: bool

class PaymentRequest(BaseModel):
    session_id: int
    method: str = Field(min_length=2, max_length=64)

class TermsRequest(BaseModel):
    terms_version: str = Field(default="1.0", min_length=1, max_length=32)
