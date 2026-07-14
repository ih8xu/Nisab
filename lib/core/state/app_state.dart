import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../network/api_client.dart';

class AppData {
  const AppData({
    this.authenticated = false,
    this.sessionId,
    this.summary,
    this.prices,
  });
  final bool authenticated;
  final int? sessionId;
  final SummaryModel? summary;
  final PriceModel? prices;
  AppData copyWith({
    bool? authenticated,
    int? sessionId,
    SummaryModel? summary,
    PriceModel? prices,
  }) => AppData(
    authenticated: authenticated ?? this.authenticated,
    sessionId: sessionId ?? this.sessionId,
    summary: summary ?? this.summary,
    prices: prices ?? this.prices,
  );
}

class AppController extends ChangeNotifier {
  AppController({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage() {
    api = ApiClient(this.storage);
  }
  final FlutterSecureStorage storage;
  late final ApiClient api;
  AppData data = const AppData();
  bool initialized = false;
  bool loading = false;
  String? error;

  Future<void> initialize() async {
    final token = await storage.read(key: 'refresh_token');
    if (token != null) {
      try {
        await api.refresh();
        await api.request('GET', '/auth/me');
        final saved = await storage.read(key: 'session_id');
        data = AppData(
          authenticated: true,
          sessionId: int.tryParse(saved ?? ''),
        );
      } catch (_) {
        await storage.deleteAll();
      }
    }
    initialized = true;
    notifyListeners();
  }

  Future<void> authenticate({
    required bool register,
    required String email,
    required String password,
    String name = '',
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await api.request(
        'POST',
        register ? '/auth/register' : '/auth/login',
        data: register
            ? {'name': name, 'email': email, 'password': password}
            : {'email': email, 'password': password},
      );
      await api.saveTokens(result);
      data = const AppData(authenticated: true);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final refresh = await storage.read(key: 'refresh_token');
    if (refresh != null) {
      try {
        await api.request(
          'POST',
          '/auth/logout',
          data: {'refresh_token': refresh},
        );
      } catch (_) {}
    }
    await storage.deleteAll();
    data = const AppData();
    notifyListeners();
  }

  Future<void> acceptAndCreateSession() async {
    await api.request('POST', '/terms/accept', data: {'terms_version': '1.0'});
    if (data.sessionId != null) return;
    final row = await api.request(
      'POST',
      '/zakat-sessions',
      data: {'cash_amount': 0},
    );
    final id = row['id'] as int;
    await storage.write(key: 'session_id', value: '$id');
    data = data.copyWith(sessionId: id);
    notifyListeners();
  }

  Future<void> saveHawl(DateTime start) async {
    await api.request(
      'POST',
      '/zakat-sessions/${data.sessionId}/hawl',
      data: {'start_date': start.toIso8601String().split('T').first},
    );
    await loadSummary();
  }

  Future<void> loadFinancials() async {
    final results = await Future.wait([
      api.request('GET', '/prices/live'),
      api.request('GET', '/zakat-sessions/${data.sessionId}/summary'),
    ]);
    data = data.copyWith(
      prices: PriceModel.fromJson(results[0]),
      summary: SummaryModel.fromJson(results[1]),
    );
    notifyListeners();
  }

  Future<void> loadSummary() async {
    final result = await api.request(
      'GET',
      '/zakat-sessions/${data.sessionId}/summary',
    );
    data = data.copyWith(summary: SummaryModel.fromJson(result));
    notifyListeners();
  }

  Future<void> addAsset(Map<String, dynamic> value) async {
    await api.request(
      'POST',
      '/zakat-sessions/${data.sessionId}/assets',
      data: value,
    );
    await loadFinancials();
  }

  Future<void> updateAsset(int id, Map<String, dynamic> value) async {
    await api.request(
      'PUT',
      '/zakat-sessions/${data.sessionId}/assets/$id',
      data: value,
    );
    await loadFinancials();
  }

  Future<void> deleteAsset(int id) async {
    await api.request('DELETE', '/zakat-sessions/${data.sessionId}/assets/$id');
    await loadFinancials();
  }

  Future<Map<String, dynamic>> pay(String method) => api.request(
    'POST',
    '/payment/pay',
    data: {'session_id': data.sessionId, 'method': method},
  );
  Future<Map<String, dynamic>> lastPayment() => api.request(
    'GET',
    '/payment/completed',
    query: {'session_id': data.sessionId},
  );
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);
  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  static AppController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
