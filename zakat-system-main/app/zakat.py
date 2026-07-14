from app.price_service import get_gold_price, get_silver_price


# زكاة النقد
def calculate_cash_zakat(amount):
    return amount * 0.025


# زكاة الذهب
def calculate_gold_zakat(weight, karat):
    gold_price = get_gold_price()

    gold_value = weight * gold_price * (karat / 24)

    zakat = gold_value * 0.025

    return zakat


# زكاة الفضة
def calculate_silver_zakat(weight, purity):
    silver_price = get_silver_price()

    silver_value = weight * silver_price * (purity / 1000)

    zakat = silver_value * 0.025

    return zakat
