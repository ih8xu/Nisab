import os

os.environ["DATABASE_URL"] = "sqlite:///./test_zakat.db"
os.environ["JWT_SECRET_KEY"] = "test-secret-key-that-is-long-enough-for-tests"
os.environ["GROQ_API_KEY"] = "test-key-not-used-by-tests"

import pytest
from fastapi.testclient import TestClient
from app.database import Base, engine
from main import app

@pytest.fixture(autouse=True)
def database():
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    yield
    Base.metadata.drop_all(engine)

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def auth(client):
    response = client.post("/api/auth/register", json={"name": "مستخدم", "email": "user@example.com", "password": "StrongPass1"})
    assert response.status_code == 201
    return response.json()

@pytest.fixture
def headers(auth):
    return {"Authorization": f"Bearer {auth['access_token']}"}
