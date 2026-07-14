double _number(Object? value) => (value as num?)?.toDouble() ?? 0;

class AssetModel {
  const AssetModel({
    required this.id,
    required this.type,
    required this.name,
    required this.totalValue,
    required this.zakatAmount,
    this.weight,
    this.karat,
    this.purity,
    this.units,
    this.unitPrice,
  });
  factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel(
    id: json['id'] as int,
    type: json['asset_type'] as String,
    name: json['name'] as String? ?? '',
    totalValue: _number(json['total_value']),
    zakatAmount: _number(json['zakat_amount']),
    weight: (json['weight'] as num?)?.toDouble(),
    karat: json['karat'] as int?,
    purity: json['purity'] as int?,
    units: (json['units'] as num?)?.toDouble(),
    unitPrice: (json['unit_price'] as num?)?.toDouble(),
  );
  final int id;
  final String type;
  final String name;
  final double totalValue;
  final double zakatAmount;
  final double? weight, units, unitPrice;
  final int? karat, purity;
}

class SummaryModel {
  const SummaryModel({
    required this.totalAssets,
    required this.nisabValue,
    required this.reachedNisab,
    required this.hawlCompleted,
    required this.totalZakat,
    required this.assets,
  });
  factory SummaryModel.fromJson(Map<String, dynamic> json) => SummaryModel(
    totalAssets: _number(json['total_assets']),
    nisabValue: _number(json['nisab_value']),
    reachedNisab: json['reached_nisab'] as bool,
    hawlCompleted: json['hawl_completed'] as bool,
    totalZakat: _number(json['total_zakat']),
    assets: (json['assets'] as List)
        .map((e) => AssetModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
  final double totalAssets, nisabValue, totalZakat;
  final bool reachedNisab, hawlCompleted;
  final List<AssetModel> assets;
}

class PriceModel {
  const PriceModel({
    required this.gold,
    required this.silver,
    required this.isFallback,
  });
  factory PriceModel.fromJson(Map<String, dynamic> json) => PriceModel(
    gold: _number(json['gold_24k']),
    silver: _number(json['silver_999']),
    isFallback: json['is_fallback'] as bool,
  );
  final double gold, silver;
  final bool isFallback;
}
