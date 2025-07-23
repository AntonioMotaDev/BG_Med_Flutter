import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/providers/connectivity_provider.dart';
import 'package:bg_med/core/theme/app_theme.dart';

class ConnectivityIndicator extends ConsumerWidget {
  final int? pendingSyncCount;
  final VoidCallback? onSyncPressed;

  const ConnectivityIndicator({
    super.key,
    this.pendingSyncCount,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(connectivityState, isOffline),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor(connectivityState, isOffline),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de conectividad
          Icon(
            _getConnectivityIcon(connectivityState, isOffline),
            size: 16,
            color: _getIconColor(connectivityState, isOffline),
          ),
          const SizedBox(width: 6),
          
          // Texto de estado
          Text(
            _getConnectivityText(connectivityState, isOffline),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getTextColor(connectivityState, isOffline),
            ),
          ),
          
          // Contador de registros pendientes
          if (pendingSyncCount != null && pendingSyncCount! > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$pendingSyncCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          
          // Botón de sincronización manual
          if (onSyncPressed != null && !isOffline && (pendingSyncCount ?? 0) > 0) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSyncPressed,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sync,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(ConnectivityState state, bool isOffline) {
    if (isOffline) {
      return AppTheme.accentRed.withOpacity(0.1);
    }
    
    switch (state) {
      case ConnectivityState.connected:
        return AppTheme.primaryGreen.withOpacity(0.1);
      case ConnectivityState.connecting:
        return AppTheme.accentOrange.withOpacity(0.1);
      case ConnectivityState.disconnected:
        return AppTheme.accentRed.withOpacity(0.1);
      case ConnectivityState.unknown:
        return AppTheme.neutralGray.withOpacity(0.1);
    }
  }

  Color _getBorderColor(ConnectivityState state, bool isOffline) {
    if (isOffline) {
      return AppTheme.accentRed;
    }
    
    switch (state) {
      case ConnectivityState.connected:
        return AppTheme.primaryGreen;
      case ConnectivityState.connecting:
        return AppTheme.accentOrange;
      case ConnectivityState.disconnected:
        return AppTheme.accentRed;
      case ConnectivityState.unknown:
        return AppTheme.neutralGray;
    }
  }

  Color _getIconColor(ConnectivityState state, bool isOffline) {
    if (isOffline) {
      return AppTheme.accentRed;
    }
    
    switch (state) {
      case ConnectivityState.connected:
        return AppTheme.primaryGreen;
      case ConnectivityState.connecting:
        return AppTheme.accentOrange;
      case ConnectivityState.disconnected:
        return AppTheme.accentRed;
      case ConnectivityState.unknown:
        return AppTheme.neutralGray;
    }
  }

  Color _getTextColor(ConnectivityState state, bool isOffline) {
    if (isOffline) {
      return AppTheme.accentRed;
    }
    
    switch (state) {
      case ConnectivityState.connected:
        return AppTheme.primaryGreen;
      case ConnectivityState.connecting:
        return AppTheme.accentOrange;
      case ConnectivityState.disconnected:
        return AppTheme.accentRed;
      case ConnectivityState.unknown:
        return AppTheme.neutralGray;
    }
  }

  IconData _getConnectivityIcon(ConnectivityState state, bool isOffline) {
    if (isOffline) {
      return Icons.wifi_off;
    }
    
    switch (state) {
      case ConnectivityState.connected:
        return Icons.wifi;
      case ConnectivityState.connecting:
        return Icons.wifi_find;
      case ConnectivityState.disconnected:
        return Icons.wifi_off;
      case ConnectivityState.unknown:
        return Icons.help_outline;
    }
  }

  String _getConnectivityText(ConnectivityState state, bool isOffline) {
    if (isOffline) {
      return 'Sin conexión';
    }
    
    switch (state) {
      case ConnectivityState.connected:
        return 'Conectado';
      case ConnectivityState.connecting:
        return 'Conectando...';
      case ConnectivityState.disconnected:
        return 'Sin conexión';
      case ConnectivityState.unknown:
        return 'Desconocido';
    }
  }
}

// Widget para mostrar en AppBar
class AppBarConnectivityIndicator extends ConsumerWidget {
  final int? pendingSyncCount;
  final VoidCallback? onSyncPressed;

  const AppBarConnectivityIndicator({
    super.key,
    this.pendingSyncCount,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    final isOffline = ref.watch(isOfflineProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono simple
        Icon(
          _getConnectivityIcon(connectivityState, isOffline),
          size: 18,
          color: _getIconColor(connectivityState, isOffline),
        ),
        
        // Contador de pendientes
        if (pendingSyncCount != null && pendingSyncCount! > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pendingSyncCount',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
        
        // Botón de sincronización
        if (onSyncPressed != null && !isOffline && (pendingSyncCount ?? 0) > 0) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSyncPressed,
            icon: const Icon(Icons.sync),
            iconSize: 20,
            color: AppTheme.primaryBlue,
          ),
        ],
      ],
    );
  }

  Color _getIconColor(ConnectivityState state, bool isOffline) {
    if (isOffline) {
      return AppTheme.accentRed;
    }
    
    switch (state) {
      case ConnectivityState.connected:
        return AppTheme.primaryGreen;
      case ConnectivityState.connecting:
        return AppTheme.accentOrange;
      case ConnectivityState.disconnected:
        return AppTheme.accentRed;
      case ConnectivityState.unknown:
        return AppTheme.neutralGray;
    }
  }

  IconData _getConnectivityIcon(ConnectivityState state, bool isOffline) {
    if (isOffline) {
      return Icons.wifi_off;
    }
    
    switch (state) {
      case ConnectivityState.connected:
        return Icons.wifi;
      case ConnectivityState.connecting:
        return Icons.wifi_find;
      case ConnectivityState.disconnected:
        return Icons.wifi_off;
      case ConnectivityState.unknown:
        return Icons.help_outline;
    }
  }
} 