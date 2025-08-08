import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bg_med/firebase_options.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:bg_med/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/medication.dart';
import 'package:bg_med/core/models/insumo.dart';
import 'package:bg_med/core/models/personal_medico.dart';
import 'package:bg_med/core/models/escalas_obstetricas.dart';
import 'package:bg_med/core/models/appointment.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/services/frap_unified_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inicializar Hive
    await Hive.initFlutter();

    // Registrar adaptadores
    Hive.registerAdapter(PatientAdapter());
    Hive.registerAdapter(ClinicalHistoryAdapter());
    Hive.registerAdapter(PhysicalExamAdapter());
    Hive.registerAdapter(FrapAdapter());
    Hive.registerAdapter(MedicationAdapter());
    Hive.registerAdapter(InsumoAdapter());
    Hive.registerAdapter(PersonalMedicoAdapter());
    Hive.registerAdapter(EscalasObstetricasAdapter());
    Hive.registerAdapter(AppointmentAdapter());

    // Abrir cajas de Hive con mejor manejo de errores
    await _initializeHiveBoxes();
  } catch (e) {
    print('Error durante inicialización: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Providers básicos que están en el archivo actual
        frapLocalServiceProvider,
        frapFirestoreServiceProvider,
        frapUnifiedServiceProvider,
      ],
      child: MyApp(),
    ),
  );
}

// Función para inicializar las cajas de Hive
Future<void> _initializeHiveBoxes() async {
  try {
    // Verificar si la caja ya está abierta
    if (!Hive.isBoxOpen('fraps')) {
      await Hive.openBox<Frap>('fraps');
      print('Caja de FRAPs abierta correctamente');
    } else {
      print('Caja de FRAPs ya estaba abierta');
    }
  } catch (e) {
    print('Error abriendo caja de FRAPs: $e');
    try {
      // Si hay error, intentar limpiar y reabrir
      print('Intentando limpiar y reabrir la caja...');
      await Hive.deleteBoxFromDisk('fraps');
      await Future.delayed(Duration(milliseconds: 500)); // Pequeña pausa
      await Hive.openBox<Frap>('fraps');
      print('Caja de FRAPs reabierta correctamente después de limpiar');
    } catch (e2) {
      print('Error crítico inicializando base de datos: $e2');
      // Continuar sin la base de datos local
    }
  }
}

// Providers principales
final frapLocalServiceProvider = Provider<FrapLocalService>((ref) {
  return FrapLocalService();
});

final frapFirestoreServiceProvider = Provider<FrapFirestoreService>((ref) {
  return FrapFirestoreService();
});

final frapUnifiedServiceProvider = Provider<FrapUnifiedService>((ref) {
  final localService = ref.watch(frapLocalServiceProvider);
  final cloudService = ref.watch(frapFirestoreServiceProvider);

  return FrapUnifiedService(
    localService: localService,
    cloudService: cloudService,
  );
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BG Med',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {'/dashboard': (context) => DashboardScreen()},
    );
  }
}
