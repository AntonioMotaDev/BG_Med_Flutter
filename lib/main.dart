import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:bg_med/core/providers/theme_provider.dart';
import 'package:bg_med/core/providers/connectivity_provider.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:bg_med/core/services/duplicate_detection_service.dart';
import 'package:bg_med/core/services/data_cleanup_service.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/services/validation_service.dart';
import 'package:bg_med/core/services/search_service.dart';
import 'package:bg_med/core/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado correctamente');
  } catch (e) {
    print('Error al inicializar Firebase: $e');
    // La app puede continuar sin Firebase para desarrollo local
  }
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Registrar adaptadores
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(ClinicalHistoryAdapter());
  Hive.registerAdapter(PhysicalExamAdapter());
  Hive.registerAdapter(FrapAdapter());
  
  // Limpiar base de datos Hive existente para evitar errores de compatibilidad
  try {
    await Hive.deleteBoxFromDisk('fraps');
    print('Base de datos Hive limpiada exitosamente');
  } catch (e) {
    print('No se pudo limpiar la base de datos Hive: $e');
  }
  
  // Abrir cajas de Hive
  await Hive.openBox<Frap>('fraps');
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return MaterialApp(
      title: 'BG Med',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      home: const AuthWrapper(),
    );
  }
}

// Providers para servicios
final duplicateDetectionServiceProvider = Provider<DuplicateDetectionService>((ref) {
  return DuplicateDetectionService();
});

final dataCleanupServiceProvider = Provider<DataCleanupService>((ref) {
  final duplicateDetection = ref.watch(duplicateDetectionServiceProvider);
  final localService = ref.watch(frapLocalServiceProvider);
  final cloudService = ref.watch(frapFirestoreServiceProvider);
  
  return DataCleanupService(
    duplicateDetection: duplicateDetection,
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

final validationServiceProvider = Provider<ValidationService>((ref) {
  return ValidationService();
});

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
}); 