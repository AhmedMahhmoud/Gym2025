import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ConnectivityService {
  ConnectivityService() {
    // Listen to the connectivity changes, which emits a List<ConnectivityResult>
    _subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      inspect(
          results); // Since we get a list, check for ConnectivityResult.none
      bool isConnected =
          results.any((result) => result != ConnectivityResult.none);
      _connectionStatusController.sink.add(isConnected);
    });
  }
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  void dispose() {
    _subscription.cancel();
    _connectionStatusController.close();
  }
}
