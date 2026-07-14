import requests

USD_TO_SAR = 3.75


def get_gold_price():
    try:
        response = requests.get(
            "https://api.gold-api.com/price/XAU",
            timeout=10
        )

        response.raise_for_status()

        data = response.json()

        # سعر أونصة الذهب بالدولار
        ounce_price = data["price"]

        # تحويل إلى سعر الجرام بالريال السعودي
        gram_price = (ounce_price / 31.1035) * USD_TO_SAR

        return round(gram_price, 2)

    except Exception as e:
        print("Gold Error:", e)
        return 432


def get_silver_price():
    try:
        response = requests.get(
            "https://api.gold-api.com/price/XAG",
            timeout=10
        )

        response.raise_for_status()

        data = response.json()

        # سعر أونصة الفضة بالدولار
        ounce_price = data["price"]

        # تحويل إلى سعر الجرام بالريال السعودي
        gram_price = (ounce_price / 31.1035) * USD_TO_SAR

        return round(gram_price, 2)

    except Exception as e:
        print("Silver Error:", e)
        return 5
    