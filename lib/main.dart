import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bg_med/firebase_options.dart';
import 'package:bg_med/core/widgets/hive_wrapper.dart';
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
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/services/frap_unified_service.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_local_provider.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_unified_provider.dart';
import 'package:bg_med/features/patients/presentation/providers/patients_provider.dart';

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

    // Abrir cajas de Hive
    try {
      await Hive.openBox<Frap>('fraps');
    } catch (e) {
      // Si hay error, limpiar la caja y reintentar
      try {
        await Hive.deleteBoxFromDisk('fraps');
        await Hive.openBox<Frap>('fraps');
      } catch (e2) {
        print('Error inicializando base de datos local: $e2');
      }
    }

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BG Med',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
} 