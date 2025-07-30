import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bg_med/core/models/frap.dart';

class HiveWrapper extends StatefulWidget {
  final Widget child;
  
  const HiveWrapper({
    super.key,
    required this.child,
  });

  @override
  State<HiveWrapper> createState() => _HiveWrapperState();
}

class _HiveWrapperState extends State<HiveWrapper> {
  bool _isHiveReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      // Verificar si la caja está abierta
      if (!Hive.isBoxOpen('fraps')) {
        await Hive.openBox<Frap>('fraps');
      }
      
      setState(() {
        _isHiveReady = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      print('Error inicializando Hive en wrapper: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al inicializar la base de datos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $_error',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _initializeHive();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isHiveReady) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Inicializando...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
} 