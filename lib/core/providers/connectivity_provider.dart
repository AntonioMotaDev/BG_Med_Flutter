import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityState {
  connected,
  disconnected,
  connecting,
  unknown,
}

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityNotifier(this._connectivity) : super(ConnectivityState.unknown) {
    _initializeConnectivity();
  }

  void _initializeConnectivity() async {
    // Verificar estado inicial
    final initialResult = await _connectivity.checkConnectivity();
    _updateState(initialResult);

    // Suscribirse a cambios de conectividad
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  void _updateState(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        state = ConnectivityState.connected;
        break;
      case ConnectivityResult.none:
        state = ConnectivityState.disconnected;
        break;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        state = ConnectivityState.connecting;
        break;
    }
  }

  // Verificar conectividad actual
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Obtener tipo de conexión
  Future<String> getConnectionType() async {
    final result = await _connectivity.checkConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Móvil';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Otro';
      case ConnectivityResult.none:
        return 'Sin conexión';
    }
  }

  // Verificar si es una conexión estable
  bool get isStableConnection {
    return state == ConnectivityState.connected;
  }

  // Verificar si está en modo offline
  bool get isOffline {
    return state == ConnectivityState.disconnected;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Provider para el estado de conectividad
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier(Connectivity());
});

// Provider para verificar si está conectado
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final connectivity = ref.watch(connectivityProvider.notifier);
  return await connectivity.isConnected();
});

// Provider para el tipo de conexión
final connectionTypeProvider = FutureProvider<String>((ref) async {
  final connectivity = ref.watch(connectivityProvider.notifier);
  return await connectivity.getConnectionType();
});

// Provider para verificar si es conexión estable
final isStableConnectionProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider.notifier);
  return connectivity.isStableConnection;
});

// Provider para verificar si está offline
final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider.notifier);
  return connectivity.isOffline;
}); 