double _double(dynamic value) => (value as num?)?.toDouble() ?? 0;

class AnalysisResult {
  const AnalysisResult({
    required this.zakatableBalance,
    required this.hasReachedNisab,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
    zakatableBalance: _double(json['zakatable_balance']),
    hasReachedNisab: json['has_reached_nisab'] == true,
  );

  final double zakatableBalance;
  final bool hasReachedNisab;
}

class HawlDetails {
  const HawlDetails({
    required this.startDate,
    required this.completionDate,
    required this.remainingDays,
    required this.isCompleted,
    required this.hasReachedNisab,
    required this.zakatableBalance,
  });

  factory HawlDetails.fromJson(Map<String, dynamic> json) => HawlDetails(
    startDate: DateTime.parse(json['start_date'] as String),
    completionDate: DateTime.parse(json['completion_date'] as String),
    remainingDays: (json['remaining_days'] as num?)?.toInt() ?? 0,
    isCompleted: json['is_completed'] == true,
    hasReachedNisab: json['has_reached_nisab'] == true,
    zakatableBalance: _double(json['zakatable_balance']),
  );

  final DateTime startDate;
  final DateTime completionDate;
  final int remainingDays;
  final bool isCompleted;
  final bool hasReachedNisab;
  final double zakatableBalance;
}

class MetalAsset {
  const MetalAsset({
    required this.type,
    required this.weight,
    required this.pricePerGram,
    required this.value,
    required this.zakatDue,
    this.karat,
    this.purity,
    this.netWeight,
  });

  factory MetalAsset.fromJson(Map<String, dynamic> json) => MetalAsset(
    type: json['type'] as String,
    weight: _double(json['weight']),
    pricePerGram: _double(json['price_per_gram']),
    value: _double(json['value']),
    zakatDue: _double(json['zakat_due']),
    karat: (json['karat'] as num?)?.toInt(),
    purity: (json['purity'] as num?)?.toInt(),
    netWeight: json['net_weight'] == null
        ? null
        : _double(json['net_weight']),
  );

  final String type;
  final double weight;
  final double pricePerGram;
  final double value;
  final double zakatDue;
  final int? karat;
  final int? purity;
  final double? netWeight;
}

class FundAsset {
  const FundAsset({
    required this.id,
    required this.name,
    required this.units,
    required this.unitPrice,
    required this.totalValue,
  });

  factory FundAsset.fromJson(Map<String, dynamic> json) => FundAsset(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    units: _double(json['units']),
    unitPrice: _double(json['unit_price']),
    totalValue: _double(json['total_value']),
  );

  final int id;
  final String name;
  final double units;
  final double unitPrice;
  final double totalValue;
}

class AssetsData {
  const AssetsData({
    required this.goldPrice24,
    required this.silverPrice999,
    required this.metals,
    required this.funds,
    required this.otherAssetsTotal,
    required this.otherAssetsZakat,
  });

  factory AssetsData.fromJson(Map<String, dynamic> json) => AssetsData(
    goldPrice24: _double(json['gold_price_24']),
    silverPrice999: _double(json['silver_price_999']),
    metals: (json['metals'] as List<dynamic>? ?? const [])
        .map((item) => MetalAsset.fromJson(item as Map<String, dynamic>))
        .toList(),
    funds: (json['funds'] as List<dynamic>? ?? const [])
        .map((item) => FundAsset.fromJson(item as Map<String, dynamic>))
        .toList(),
    otherAssetsTotal: _double(json['other_assets_total']),
    otherAssetsZakat: _double(json['other_assets_zakat']),
  );

  final double goldPrice24;
  final double silverPrice999;
  final List<MetalAsset> metals;
  final List<FundAsset> funds;
  final double otherAssetsTotal;
  final double otherAssetsZakat;

  MetalAsset? get gold => _metal('gold');
  MetalAsset? get silver => _metal('silver');

  MetalAsset? _metal(String type) {
    for (final item in metals) {
      if (item.type == type) return item;
    }
    return null;
  }
}

class ZakatSummary {
  const ZakatSummary({
    required this.cashAmount,
    required this.goldAmount,
    required this.silverAmount,
    required this.stocksAmount,
    required this.tradeOffersAmount,
    required this.fundsAmount,
    required this.totalAssets,
    required this.totalZakat,
  });

  factory ZakatSummary.fromJson(Map<String, dynamic> json) => ZakatSummary(
    cashAmount: _double(json['cash_amount']),
    goldAmount: _double(json['gold_amount']),
    silverAmount: _double(json['silver_amount']),
    stocksAmount: _double(json['stocks_amount']),
    tradeOffersAmount: _double(json['trade_offers_amount']),
    fundsAmount: _double(json['funds_amount']),
    totalAssets: _double(json['total_assets']),
    totalZakat: _double(json['total_zakat']),
  );

  final double cashAmount;
  final double goldAmount;
  final double silverAmount;
  final double stocksAmount;
  final double tradeOffersAmount;
  final double fundsAmount;
  final double totalAssets;
  final double totalZakat;
}

class PaymentResult {
  const PaymentResult({
    required this.zakatableAmount,
    required this.amount,
    required this.method,
    required this.transactionId,
    required this.paymentDate,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) => PaymentResult(
    zakatableAmount: _double(json['zakatable_amount']),
    amount: _double(json['amount']),
    method: json['method'] as String,
    transactionId: json['transaction_id'] as String,
    paymentDate: DateTime.parse(json['payment_date'] as String),
  );

  final double zakatableAmount;
  final double amount;
  final String method;
  final String transactionId;
  final DateTime paymentDate;
}
