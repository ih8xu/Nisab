from datetime import date
from typing import Literal

from pydantic import BaseModel, Field


class CustomerDataUpsert(BaseModel):
    cash_amount: float = Field(ge=0)
    stocks_amount: float = Field(ge=0)
    trade_offers_amount: float = Field(ge=0)
    hawl_start_date: date
    has_reached_nisab: bool


class GoldAssetUpsert(BaseModel):
    weight: float = Field(gt=0)
    karat: Literal[12, 14, 18, 21, 22, 24]


class SilverAssetUpsert(BaseModel):
    weight: float = Field(gt=0)
    purity: Literal[999, 925, 800] = 999


class InvestmentFundCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    units: float = Field(gt=0)
    unit_price: float = Field(gt=0)


class PaymentCreate(BaseModel):
    method: Literal["zakaty", "self"]
