import unittest
from unittest.mock import patch

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.database import Base, engine as app_engine, get_db
from main import app


class ApiFlowTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.engine = create_engine(
            "sqlite://",
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
        cls.session_local = sessionmaker(
            autocommit=False,
            autoflush=False,
            bind=cls.engine,
        )
        Base.metadata.create_all(bind=cls.engine)

        def override_get_db():
            db = cls.session_local()
            try:
                yield db
            finally:
                db.close()

        app.dependency_overrides[get_db] = override_get_db
        cls.client = TestClient(app)

    @classmethod
    def tearDownClass(cls):
        cls.client.close()
        app.dependency_overrides.clear()
        Base.metadata.drop_all(bind=cls.engine)
        cls.engine.dispose()
        app_engine.dispose()

    @patch("app.routes.assets.get_silver_price", return_value=5.0)
    @patch("app.routes.assets.get_gold_price", return_value=400.0)
    @patch("app.services.get_silver_price", return_value=5.0)
    @patch("app.services.get_gold_price", return_value=400.0)
    def test_complete_prototype_flow(self, *_mocks):
        user_id = "demo_user"

        response = self.client.put(
            f"/api/customer-data/{user_id}",
            json={
                "cash_amount": 10000,
                "stocks_amount": 5000,
                "trade_offers_amount": 2000,
                "hawl_start_date": "2025-01-01",
                "has_reached_nisab": True,
            },
        )
        self.assertEqual(response.status_code, 200, response.text)

        response = self.client.post(
            "/api/terms/accept",
            params={"user_id": user_id},
        )
        self.assertEqual(response.status_code, 200, response.text)

        response = self.client.get(
            "/api/analysis/analyze",
            params={"user_id": user_id},
        )
        self.assertEqual(response.status_code, 200, response.text)
        self.assertEqual(response.json()["zakatable_balance"], 17000)

        response = self.client.get(
            "/api/hawl/details",
            params={"user_id": user_id},
        )
        self.assertEqual(response.status_code, 200, response.text)
        self.assertTrue(response.json()["has_reached_nisab"])

        response = self.client.put(
            f"/api/assets/{user_id}/gold",
            json={"weight": 100, "karat": 21},
        )
        self.assertEqual(response.status_code, 200, response.text)
        self.assertEqual(response.json()["value"], 35000)

        response = self.client.put(
            f"/api/assets/{user_id}/silver",
            json={"weight": 600, "purity": 999},
        )
        self.assertEqual(response.status_code, 200, response.text)
        self.assertEqual(response.json()["value"], 2997)

        response = self.client.post(
            f"/api/assets/{user_id}/funds",
            json={"name": "TEST", "units": 20, "unit_price": 100},
        )
        self.assertEqual(response.status_code, 201, response.text)

        response = self.client.get(f"/api/zakat/{user_id}/summary")
        self.assertEqual(response.status_code, 200, response.text)
        summary = response.json()
        self.assertEqual(summary["total_assets"], 56997)
        self.assertEqual(summary["total_zakat"], 1424.93)

        response = self.client.post(
            f"/api/payment/{user_id}/pay",
            json={"method": "self"},
        )
        self.assertEqual(response.status_code, 201, response.text)
        self.assertEqual(response.json()["amount"], 1424.93)

        response = self.client.get(f"/api/payment/{user_id}/completed")
        self.assertEqual(response.status_code, 200, response.text)
        self.assertEqual(response.json()["method"], "self")


if __name__ == "__main__":
    unittest.main()
