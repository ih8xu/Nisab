from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import InvestmentFund, ZakatAsset
from app.price_service import get_gold_price, get_silver_price
from app.schemas import GoldAssetUpsert, InvestmentFundCreate, SilverAssetUpsert
from app.services import ZAKAT_RATE, build_zakat_summary


router = APIRouter()


def _upsert_metal(
    db: Session,
    user_id: str,
    asset_type: str,
    weight: float,
    karat_or_purity: int,
    price_per_gram: float,
    divisor: int,
) -> ZakatAsset:
    item = (
        db.query(ZakatAsset)
        .filter(ZakatAsset.user_id == user_id, ZakatAsset.asset_type == asset_type)
        .first()
    )
    if item is None:
        item = ZakatAsset(user_id=user_id, asset_type=asset_type)
        db.add(item)

    value = weight * price_per_gram * (karat_or_purity / divisor)
    item.weight = weight
    item.karat_or_purity = karat_or_purity
    item.price_per_gram = price_per_gram
    item.value = value
    item.zakat_result = value * ZAKAT_RATE
    db.commit()
    db.refresh(item)
    return item


def _metal_response(item: ZakatAsset) -> dict:
    response = {
        "id": item.id,
        "type": item.asset_type,
        "weight": round(item.weight, 2),
        "price_per_gram": round(item.price_per_gram, 2),
        "value": round(item.value, 2),
        "zakat_due": round(item.zakat_result, 2),
    }
    if item.asset_type == "gold":
        response["karat"] = item.karat_or_purity
        response["net_weight"] = round(
            item.weight * item.karat_or_purity / 24,
            2,
        )
    else:
        response["purity"] = item.karat_or_purity
    return response


@router.put("/{user_id}/gold")
def save_gold(
    user_id: str,
    payload: GoldAssetUpsert,
    db: Session = Depends(get_db),
):
    item = _upsert_metal(
        db,
        user_id,
        "gold",
        payload.weight,
        payload.karat,
        get_gold_price(),
        24,
    )
    return _metal_response(item)


@router.put("/{user_id}/silver")
def save_silver(
    user_id: str,
    payload: SilverAssetUpsert,
    db: Session = Depends(get_db),
):
    item = _upsert_metal(
        db,
        user_id,
        "silver",
        payload.weight,
        payload.purity,
        get_silver_price(),
        1000,
    )
    return _metal_response(item)


@router.post("/{user_id}/funds", status_code=status.HTTP_201_CREATED)
def add_fund(
    user_id: str,
    payload: InvestmentFundCreate,
    db: Session = Depends(get_db),
):
    item = InvestmentFund(
        user_id=user_id,
        name=payload.name.strip(),
        units=payload.units,
        unit_price=payload.unit_price,
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return {
        "id": item.id,
        "name": item.name,
        "units": item.units,
        "unit_price": item.unit_price,
        "total_value": round(item.units * item.unit_price, 2),
    }


@router.delete("/{user_id}/funds/{fund_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_fund(user_id: str, fund_id: int, db: Session = Depends(get_db)):
    item = (
        db.query(InvestmentFund)
        .filter(InvestmentFund.id == fund_id, InvestmentFund.user_id == user_id)
        .first()
    )
    if item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="الصندوق الاستثماري غير موجود.",
        )
    db.delete(item)
    db.commit()


@router.get("/{user_id}")
def get_assets(user_id: str, db: Session = Depends(get_db)):
    summary = build_zakat_summary(db, user_id)
    metals = (
        db.query(ZakatAsset)
        .filter(ZakatAsset.user_id == user_id)
        .order_by(ZakatAsset.id)
        .all()
    )
    funds = (
        db.query(InvestmentFund)
        .filter(InvestmentFund.user_id == user_id)
        .order_by(InvestmentFund.id)
        .all()
    )
    gold = next((item for item in metals if item.asset_type == "gold"), None)
    silver = next((item for item in metals if item.asset_type == "silver"), None)

    return {
        "user_id": user_id,
        "gold_price_24": round(
            gold.price_per_gram if gold is not None else get_gold_price(),
            2,
        ),
        "silver_price_999": round(
            silver.price_per_gram if silver is not None else get_silver_price(),
            2,
        ),
        "metals": [_metal_response(item) for item in metals],
        "funds": [
            {
                "id": item.id,
                "name": item.name,
                "units": item.units,
                "unit_price": item.unit_price,
                "total_value": round(item.units * item.unit_price, 2),
            }
            for item in funds
        ],
        "other_assets_total": round(
            summary["gold_amount"]
            + summary["silver_amount"]
            + summary["funds_amount"],
            2,
        ),
        "other_assets_zakat": round(
            (
                summary["gold_amount"]
                + summary["silver_amount"]
                + summary["funds_amount"]
            )
            * ZAKAT_RATE,
            2,
        ),
        "currency": "SAR",
    }
