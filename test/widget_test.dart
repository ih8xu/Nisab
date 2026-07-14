import 'package:flutter_test/flutter_test.dart';
import 'package:nisab/core/models/models.dart';

void main() {
  test('parses backend summary and typed assets', () {
    final summary = SummaryModel.fromJson({
      'total_assets': 41000,
      'nisab_value': 34000.5,
      'reached_nisab': true,
      'hawl_completed': true,
      'total_zakat': 1025,
      'assets': [
        {
          'id': 1,
          'asset_type': 'gold',
          'name': null,
          'weight': 100,
          'karat': 24,
          'purity': null,
          'units': null,
          'unit_price': null,
          'total_value': 40000,
          'zakat_amount': 1000,
        },
      ],
    });
    expect(summary.totalZakat, 1025);
    expect(summary.assets.single.type, 'gold');
    expect(summary.assets.single.weight, 100);
  });

  test('parses fallback price marker', () {
    final price = PriceModel.fromJson({
      'gold_24k': 432,
      'silver_999': 5,
      'is_fallback': true,
    });
    expect(price.isFallback, isTrue);
    expect(price.gold, 432);
  });
}
