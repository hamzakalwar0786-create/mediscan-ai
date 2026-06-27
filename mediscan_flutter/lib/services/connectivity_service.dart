// Feature: OFFLINE MODE — connectivity monitoring + sync queue
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;
  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  // ── Check if currently online ─────────────────────────────────────────────
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  // ── Stream of connectivity changes ────────────────────────────────────────
  Stream<bool> get onlineStream => _connectivity.onConnectivityChanged
      .map((result) => _isConnected(result));

  bool _isConnected(List<ConnectivityResult> result) {
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }
}
