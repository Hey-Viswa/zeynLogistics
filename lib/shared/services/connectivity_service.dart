import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum NetworkStatus { online, offline }

class ConnectivityService extends StateNotifier<NetworkStatus> {
  ConnectivityService() : super(NetworkStatus.online) {
    _init();
  }

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late StreamSubscription<InternetStatus> _internetSubscription;

  void _init() {
    // Listen to strict connectivity changes (WiFi/Mobile)
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.contains(ConnectivityResult.none)) {
        state = NetworkStatus.offline;
      } else {
        // If we have connection, double check actual internet access
        _checkInternet();
      }
    });

    // Listen to actual internet validity (ping check)
    _internetSubscription = InternetConnection().onStatusChange.listen((
      status,
    ) {
      if (status == InternetStatus.connected) {
        state = NetworkStatus.online;
      } else {
        state = NetworkStatus.offline;
      }
    });
  }

  Future<void> _checkInternet() async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    state = hasInternet ? NetworkStatus.online : NetworkStatus.offline;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _internetSubscription.cancel();
    super.dispose();
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityService, NetworkStatus>((ref) {
      return ConnectivityService();
    });
