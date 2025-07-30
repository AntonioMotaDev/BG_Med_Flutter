import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityState { connected, disconnected, connecting, unknown, offline, wifi, mobile }

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityNotifier(this._connectivity) : super(ConnectivityState.unknown) {
    _initConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateState(result);
    } catch (e) {
      state = ConnectivityState.unknown;
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateState,
      onError: (error) {
        state = ConnectivityState.unknown;
      },
    );
  }

  void _updateState(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      state = ConnectivityState.offline;
      return;
    }

    // Determinar el estado basado en los resultados
    if (results.contains(ConnectivityResult.wifi)) {
      state = ConnectivityState.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      state = ConnectivityState.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      state = ConnectivityState.connected;
    } else if (results.contains(ConnectivityResult.vpn)) {
      state = ConnectivityState.connected;
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      state = ConnectivityState.connected;
    } else if (results.contains(ConnectivityResult.other)) {
      state = ConnectivityState.connected;
    } else {
      state = ConnectivityState.offline;
    }
  }

  bool get isConnected => state == ConnectivityState.mobile || 
                         state == ConnectivityState.wifi || 
                         state == ConnectivityState.connected;

  bool get isOffline => state == ConnectivityState.offline || 
                       state == ConnectivityState.disconnected;

  String get statusText {
    switch (state) {
      case ConnectivityState.connected:
        return 'Conectado';
      case ConnectivityState.disconnected:
        return 'Desconectado';
      case ConnectivityState.connecting:
        return 'Conectando...';
      case ConnectivityState.unknown:
        return 'Estado desconocido';
      case ConnectivityState.offline:
        return 'Sin conexión';
      case ConnectivityState.wifi:
        return 'WiFi';
      case ConnectivityState.mobile:
        return 'Datos móviles';
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier(Connectivity());
}); 