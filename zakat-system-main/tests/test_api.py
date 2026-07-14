from datetime import date, timedelta
import requests

from app.database import SessionLocal
from app.models import RefreshToken, User
from app.price_service import get_price_snapshot

def test_auth_hash_duplicate_rotation_logout(client):
    payload = {"name": "Ali", "email": "ALI@Example.com", "password": "StrongPass1"}
    registered = client.post("/api/auth/register", json=payload)
    assert registered.status_code == 201
    with SessionLocal() as db:
        user = db.query(User).one()
        assert user.email == "ali@example.com"
        assert user.password_hash.startswith("$argon2")
        assert "StrongPass1" not in user.password_hash
        stored_refresh = db.query(RefreshToken).one()
        assert stored_refresh.token_hash != registered.json()["refresh_token"]
        assert len(stored_refresh.token_hash) == 64
    assert client.post("/api/auth/register", json=payload).status_code == 409
    assert client.post("/api/auth/login", json={**payload, "password": "wrong"}).json()["detail"]["code"] == "INVALID_CREDENTIALS"
    refresh = registered.json()["refresh_token"]
    rotated = client.post("/api/auth/refresh", json={"refresh_token": refresh})
    assert rotated.status_code == 200
    assert client.post("/api/auth/refresh", json={"refresh_token": refresh}).status_code == 401
    newer = rotated.json()["refresh_token"]
    assert client.post("/api/auth/logout", json={"refresh_token": newer}).status_code == 204
    assert client.post("/api/auth/refresh", json={"refresh_token": newer}).status_code == 401

def test_protected_crud_hawl_summary_and_ownership(client, headers, monkeypatch):
    monkeypatch.setattr("app.services.get_price_snapshot", lambda: {"gold_24k": 400.0, "silver_999": 5.0})
    session = client.post("/api/zakat-sessions", json={"cash_amount": 40000}, headers=headers).json()
    sid = session["id"]
    hawl = client.post(f"/api/zakat-sessions/{sid}/hawl", json={"start_date": str(date.today() - timedelta(days=400))}, headers=headers)
    assert hawl.status_code == 200 and hawl.json()["is_completed"] is True
    gold = client.post(f"/api/zakat-sessions/{sid}/assets", json={"asset_type": "gold", "weight": 100, "karat": 24}, headers=headers)
    assert gold.status_code == 201 and gold.json()["total_value"] == 40000
    silver = client.post(f"/api/zakat-sessions/{sid}/assets", json={"asset_type": "silver", "weight": 1000, "purity": 999}, headers=headers)
    assert silver.status_code == 201 and silver.json()["total_value"] == 4995
    asset_id = gold.json()["id"]
    updated = client.put(f"/api/zakat-sessions/{sid}/assets/{asset_id}", json={"asset_type": "fund", "name": "صندوق", "units": 10, "unit_price": 100}, headers=headers)
    assert updated.json()["total_value"] == 1000
    summary = client.get(f"/api/zakat-sessions/{sid}/summary", headers=headers).json()
    assert summary["total_assets"] == 45995
    assert summary["reached_nisab"] is True
    assert summary["total_zakat"] == 1149.88
    other = client.post("/api/auth/register", json={"name": "Other", "email": "other@example.com", "password": "StrongPass1"}).json()
    other_headers = {"Authorization": f"Bearer {other['access_token']}"}
    assert client.get(f"/api/zakat-sessions/{sid}", headers=other_headers).status_code == 404
    assert client.delete(f"/api/zakat-sessions/{sid}/assets/{asset_id}", headers=headers).status_code == 204

def test_terms_payment_simulation_and_validation(client, headers, monkeypatch):
    monkeypatch.setattr("app.services.get_price_snapshot", lambda: {"gold_24k": 400.0, "silver_999": 5.0})
    assert client.post("/api/terms/accept", json={"terms_version": "1.0"}, headers=headers).status_code == 200
    session = client.post("/api/zakat-sessions", json={"cash_amount": 50000}, headers=headers).json()
    sid = session["id"]
    client.post(f"/api/zakat-sessions/{sid}/hawl", json={"start_date": str(date.today() - timedelta(days=400))}, headers=headers)
    paid = client.post("/api/payment/pay", json={"session_id": sid, "method": "self"}, headers=headers)
    assert paid.status_code == 200 and paid.json()["simulation"] is True
    assert client.get(f"/api/payment/completed?session_id={sid}", headers=headers).json()["amount"] == 1250
    bad = client.post(f"/api/zakat-sessions/{sid}/assets", json={"asset_type": "gold", "weight": -1, "karat": 20}, headers=headers)
    assert bad.status_code == 422

def test_price_fallback_is_explicit(monkeypatch):
    def fail(*args, **kwargs):
        raise requests.ConnectionError("offline")
    monkeypatch.setattr("app.price_service.requests.get", fail)
    result = get_price_snapshot(force=True)
    assert result["is_fallback"] is True
    assert result["source"] == "configured fallback"
