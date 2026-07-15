import 'package:nisab/core/config/app_config.dart';
import 'package:nisab/core/models/zakat_models.dart';
import 'package:nisab/core/network/api_client.dart';

class ZakatApiService {
  ZakatApiService._();

  static final ZakatApiService instance = ZakatApiService._();

  final ApiClient _api = ApiClient();
  final String _userId = AppConfig.defaultUserId;

  Future<void> acceptTerms() async {
    await _api.post(
      '/api/terms/accept',
      query: {'user_id': _userId, 'terms_version': '1.0'},
    );
  }

  Future<AnalysisResult> analyze() async {
    final json = await _api.get(
      '/api/analysis/analyze',
      query: {'user_id': _userId},
    );
    return AnalysisResult.fromJson(json);
  }

  Future<HawlDetails> getHawlDetails() async {
    final json = await _api.get(
      '/api/hawl/details',
      query: {'user_id': _userId},
    );
    return HawlDetails.fromJson(json);
  }

  Future<AssetsData> getAssets() async {
    final json = await _api.get('/api/assets/$_userId');
    return AssetsData.fromJson(json);
  }

  Future<MetalAsset> saveGold({
    required double weight,
    required int karat,
  }) async {
    final json = await _api.put(
      '/api/assets/$_userId/gold',
      body: {'weight': weight, 'karat': karat},
    );
    return MetalAsset.fromJson(json);
  }

  Future<MetalAsset> saveSilver({
    required double weight,
    int purity = 999,
  }) async {
    final json = await _api.put(
      '/api/assets/$_userId/silver',
      body: {'weight': weight, 'purity': purity},
    );
    return MetalAsset.fromJson(json);
  }

  Future<FundAsset> addFund({
    required String name,
    required double units,
    required double unitPrice,
  }) async {
    final json = await _api.post(
      '/api/assets/$_userId/funds',
      body: {'name': name, 'units': units, 'unit_price': unitPrice},
    );
    return FundAsset.fromJson(json);
  }

  Future<ZakatSummary> getSummary() async {
    final json = await _api.get('/api/zakat/$_userId/summary');
    return ZakatSummary.fromJson(json);
  }

  Future<PaymentResult> pay(String method) async {
    final json = await _api.post(
      '/api/payment/$_userId/pay',
      body: {'method': method},
    );
    return PaymentResult.fromJson(json);
  }

  Future<PaymentResult> getLastPayment() async {
    final json = await _api.get('/api/payment/$_userId/completed');
    return PaymentResult.fromJson(json);
  }

  Future<String> askAssistant(String question) async {
    final json = await _api.post(
      '/api/ai/assistant',
      query: {'user_id': _userId, 'question': question},
    );
    return json['answer'] as String;
  }
}
