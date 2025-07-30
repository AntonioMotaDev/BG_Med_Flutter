import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/providers/connectivity_provider.dart';

class ConnectivityIndicator extends ConsumerWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    final connectivityNotifier = ref.read(connectivityProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(connectivityState),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(connectivityState),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(connectivityState),
            size: 16,
            color: _getIconColor(connectivityState),
          ),
          const SizedBox(width: 4),
          Text(
            connectivityNotifier.statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getTextColor(connectivityState),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
        return Icons.wifi;
      case ConnectivityState.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Icons.signal_wifi_off;
      case ConnectivityState.connecting:
        return Icons.sync;
      case ConnectivityState.unknown:
        return Icons.help_outline;
    }
  }

  Color _getBackgroundColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
      case ConnectivityState.mobile:
        return Colors.green.withValues(alpha: 0.1);
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Colors.red.withValues(alpha: 0.1);
      case ConnectivityState.connecting:
        return Colors.orange.withValues(alpha: 0.1);
      case ConnectivityState.unknown:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
      case ConnectivityState.mobile:
        return Colors.green.withValues(alpha: 0.3);
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Colors.red.withValues(alpha: 0.3);
      case ConnectivityState.connecting:
        return Colors.orange.withValues(alpha: 0.3);
      case ConnectivityState.unknown:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }

  Color _getIconColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
      case ConnectivityState.mobile:
        return Colors.green;
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Colors.red;
      case ConnectivityState.connecting:
        return Colors.orange;
      case ConnectivityState.unknown:
        return Colors.grey;
    }
  }

  Color _getTextColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
      case ConnectivityState.mobile:
        return Colors.green;
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Colors.red;
      case ConnectivityState.connecting:
        return Colors.orange;
      case ConnectivityState.unknown:
        return Colors.grey;
    }
  }
}

class AppBarConnectivityIndicator extends ConsumerWidget {
  const AppBarConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    final connectivityNotifier = ref.read(connectivityProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(connectivityState),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(connectivityState),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(connectivityState),
            size: 14,
            color: _getIconColor(connectivityState),
          ),
          const SizedBox(width: 4),
          Text(
            connectivityNotifier.statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _getTextColor(connectivityState),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
        return Icons.wifi;
      case ConnectivityState.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Icons.signal_wifi_off;
      case ConnectivityState.connecting:
        return Icons.sync;
      case ConnectivityState.unknown:
        return Icons.help_outline;
    }
  }

  Color _getBackgroundColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
      case ConnectivityState.mobile:
        return Colors.green.withValues(alpha: 0.1);
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Colors.red.withValues(alpha: 0.1);
      case ConnectivityState.connecting:
        return Colors.orange.withValues(alpha: 0.1);
      case ConnectivityState.unknown:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
      case ConnectivityState.mobile:
        return Colors.green.withValues(alpha: 0.3);
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Colors.red.withValues(alpha: 0.3);
      case ConnectivityState.connecting:
        return Colors.orange.withValues(alpha: 0.3);
      case ConnectivityState.unknown:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }

  Color _getIconColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
      case ConnectivityState.mobile:
        return Colors.green;
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Colors.red;
      case ConnectivityState.connecting:
        return Colors.orange;
      case ConnectivityState.unknown:
        return Colors.grey;
    }
  }

  Color _getTextColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.connected:
      case ConnectivityState.wifi:
      case ConnectivityState.mobile:
        return Colors.green;
      case ConnectivityState.disconnected:
      case ConnectivityState.offline:
        return Colors.red;
      case ConnectivityState.connecting:
        return Colors.orange;
      case ConnectivityState.unknown:
        return Colors.grey;
    }
  }
}

class ConnectivityStatusBar extends ConsumerWidget {
  final String? customMessage;
  final VoidCallback? onTap;

  const ConnectivityStatusBar({
    super.key,
    this.customMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    
    if (connectivityState == ConnectivityState.connected || 
        connectivityState == ConnectivityState.wifi || 
        connectivityState == ConnectivityState.mobile) {
      return const SizedBox.shrink(); // No mostrar si está conectado
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          border: Border(
            top: BorderSide(
              color: Colors.orange.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customMessage ?? 'Sin conexión a internet. Los datos se guardarán localmente.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class ConnectivityBanner extends ConsumerWidget {
  final String? title;
  final String? message;
  final List<Widget>? actions;

  const ConnectivityBanner({
    super.key,
    this.title,
    this.message,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    
    if (connectivityState == ConnectivityState.connected || 
        connectivityState == ConnectivityState.wifi || 
        connectivityState == ConnectivityState.mobile) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title ?? 'Sin conexión',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: TextStyle(
                color: Colors.orange[600],
                fontSize: 14,
              ),
            ),
          ],
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
} 