import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/patient_firestore.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/core/models/medication.dart';
import 'package:bg_med/core/models/insumo.dart';
import 'package:bg_med/core/models/personal_medico.dart';
import 'package:bg_med/core/models/escalas_obstetricas.dart';
import 'package:bg_med/core/services/duplicate_detection_service.dart';
import 'package:bg_med/core/services/data_cleanup_service.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/services/validation_service.dart';
import 'package:bg_med/core/services/search_service.dart';
import 'package:bg_med/core/services/notification_service.dart';
import 'package:bg_med/core/services/frap_unified_service.dart';
import 'package:bg_med/features/auth/presentation/providers/auth_provider.dart';
import 'package:bg_med/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:bg_med/features/auth/presentation/screens/login_screen.dart';
import 'package:bg_med/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bg_med/core/widgets/hive_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inicializar Firebase con mejor manejo de errores
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado correctamente');
  } catch (e) {
    print('Error inicializando Firebase: $e');
    // Continuar con la app incluso si Firebase falla
  }
  
  try {
    // Inicializar Hive
    await Hive.initFlutter();
    
    // Registrar adaptadores de Hive
    Hive.registerAdapter(PatientAdapter());
    Hive.registerAdapter(ClinicalHistoryAdapter());
    Hive.registerAdapter(PhysicalExamAdapter());
    Hive.registerAdapter(FrapAdapter());
    Hive.registerAdapter(MedicationAdapter());
    Hive.registerAdapter(InsumoAdapter());
    Hive.registerAdapter(PersonalMedicoAdapter());
    Hive.registerAdapter(EscalasObstetricasAdapter());
    
    // Abrir las cajas de Hive con manejo de errores
    try {
      await Hive.openBox<Frap>('fraps');
      print('Caja de FRAP abierta correctamente');
    } catch (e) {
      print('Error abriendo caja de FRAP: $e');
      // Intentar eliminar la caja corrupta y crear una nueva
      try {
        await Hive.deleteBoxFromDisk('fraps');
        await Hive.openBox<Frap>('fraps');
        print('Caja de FRAP recreada correctamente');
      } catch (e2) {
        print('Error recreando caja de FRAP: $e2');
      }
    }
    
    print('Hive inicializado correctamente');
  } catch (e) {
    print('Error inicializando Hive: $e');
  }
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HiveWrapper(
      child: MaterialApp(
        title: 'BG Med',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
        routes: {
          '/dashboard': (context) => DashboardScreen(),
        },
      ),
    );
  }
}

// Providers para servicios
final duplicateDetectionServiceProvider = Provider<DuplicateDetectionService>((ref) {
  return DuplicateDetectionService();
});

final dataCleanupServiceProvider = Provider<DataCleanupService>((ref) {
  final localService = ref.watch(frapLocalServiceProvider);
  final cloudService = ref.watch(frapFirestoreServiceProvider);
  
  return DataCleanupService(
    localService: localService,
    cloudService: cloudService,
  );
});

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

final validationServiceProvider = Provider<ValidationService>((ref) {
  return ValidationService();
});

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
}); 