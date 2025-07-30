import 'package:bg_med/core/models/user_model.dart';
import 'package:bg_med/features/auth/data/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proveedor del servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Proveedor del stream de autenticación
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Proveedor de los datos del usuario actual
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUserData();
});

// Proveedor para el estado de autenticación
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Estados de autenticación
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.name}, error: $errorMessage)';
  }
}

// Notificador de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState(status: AuthStatus.initial)) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) async {
      print('🔄 AuthNotifier - Cambio en authStateChanges: ${user?.uid}');
      
      if (user == null) {
        print('🔄 AuthNotifier - Usuario es null, estableciendo estado como unauthenticated');
        state = const AuthState(status: AuthStatus.unauthenticated);
      } else {
        print('🔄 AuthNotifier - Usuario detectado, obteniendo datos...');
        try {
          final userData = await _authService.getCurrentUserData();
          if (userData != null) {
            print('🔄 AuthNotifier - Datos del usuario obtenidos: ${userData.name}');
            state = AuthState(
              status: AuthStatus.authenticated,
              user: userData,
            );
          } else {
            print('🔄 AuthNotifier - No se pudieron obtener datos del usuario');
            state = const AuthState(status: AuthStatus.unauthenticated);
          }
        } catch (e) {
          print('🔄 AuthNotifier - Error al obtener datos del usuario: $e');
          state = AuthState(
            status: AuthStatus.error,
            errorMessage: 'Error al cargar datos del usuario',
          );
        }
      }
    });
  }

  // Iniciar sesión
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    print('🔄 AuthNotifier - Iniciando proceso de login...');
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (user != null) {
        print('🔄 AuthNotifier - Login exitoso: ${user.name}');
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        print('🔄 AuthNotifier - Login falló: usuario es null');
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Error al iniciar sesión',
        );
      }
    } catch (e) {
      print('🔄 AuthNotifier - Error en login: $e');
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Registrar usuario
  Future<void> register({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Error al registrar usuario',
        );
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Error al cerrar sesión',
      );
    }
  }

  // Alias para logout (mantiene compatibilidad)
  Future<void> logout() async {
    await signOut();
  }

  // Enviar verificación de email
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Recargar usuario
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      final userData = await _authService.getCurrentUserData();
      if (userData != null) {
        state = state.copyWith(user: userData);
      }
    } catch (e) {
      // Silenciar errores de recarga
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Actualizar perfil
  Future<void> updateProfile({
    String? name,
    String? role,
  }) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    try {
      final updatedUser = await _authService.updateUserProfile(
        userId: currentUser.id,
        name: name,
        role: role,
      );
      
      if (updatedUser != null) {
        state = state.copyWith(user: updatedUser);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Limpiar errores
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(
        status: state.user != null 
            ? AuthStatus.authenticated 
            : AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }
}
