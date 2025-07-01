import 'package:bg_med/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Obtener datos del usuario desde Firestore
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  // Registrar nuevo usuario
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    try {
      // Crear usuario en Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) return null;

      // Crear documento del usuario en Firestore
      final now = DateTime.now();
      final userData = UserModel(
        id: user.uid,
        name: name,
        email: email,
        role: role,
        emailVerified: user.emailVerified,
        emailVerifiedAt: user.emailVerified ? now : null,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('users').doc(user.uid).set(userData.toFirestore());

      // Enviar verificación de email
      await user.sendEmailVerification();

      return userData;
    } catch (e) {
      print('Error en registro: $e');
      throw _handleAuthException(e);
    }
  }

  // Iniciar sesión
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) return null;

      // Obtener datos del usuario desde Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado en la base de datos');
      }

      final userData = UserModel.fromFirestore(userDoc);

      // Actualizar estado de verificación de email si cambió
      if (userData.emailVerified != user.emailVerified) {
        await _updateEmailVerificationStatus(user.uid, user.emailVerified);
      }

      return userData;
    } catch (e) {
      print('Error en login: $e');
      throw _handleAuthException(e);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      throw Exception('Error al cerrar sesión');
    }
  }

  // Enviar email de verificación
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Error al enviar verificación: $e');
      throw Exception('Error al enviar email de verificación');
    }
  }

  // Recargar usuario para verificar cambios
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      print('Error al recargar usuario: $e');
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error al restablecer contraseña: $e');
      throw _handleAuthException(e);
    }
  }

  // Actualizar perfil del usuario
  Future<UserModel?> updateUserProfile({
    required String userId,
    String? name,
    String? role,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updateData['name'] = name;
      if (role != null) updateData['role'] = role;

      await _firestore.collection('users').doc(userId).update(updateData);

      // Obtener datos actualizados
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      throw Exception('Error al actualizar perfil');
    }
  }

  // Actualizar estado de verificación de email
  Future<void> _updateEmailVerificationStatus(String userId, bool isVerified) async {
    try {
      final updateData = <String, dynamic>{
        'emailVerified': isVerified,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (isVerified) {
        updateData['emailVerifiedAt'] = Timestamp.fromDate(DateTime.now());
      }

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      print('Error al actualizar verificación: $e');
    }
  }

  // Manejar excepciones de Firebase Auth
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No se encontró un usuario con este email';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'invalid-credential':
          return 'Las credenciales proporcionadas son incorrectas';
        case 'invalid-email':
          return 'El formato del email es inválido';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada';
        case 'email-already-in-use':
          return 'Este email ya está registrado';
        case 'weak-password':
          return 'La contraseña es muy débil (mínimo 6 caracteres)';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Intenta más tarde';
        case 'operation-not-allowed':
          return 'Operación no permitida. Contacta al administrador';
        case 'network-request-failed':
          return 'Error de conexión. Verifica tu internet';
        case 'requires-recent-login':
          return 'Necesitas volver a iniciar sesión para realizar esta acción';
        case 'credential-already-in-use':
          return 'Estas credenciales ya están en uso';
        case 'invalid-verification-code':
          return 'Código de verificación inválido';
        case 'invalid-verification-id':
          return 'ID de verificación inválido';
        default:
          return 'Error de autenticación: ${e.message ?? 'Error desconocido'}';
      }
    }
    return 'Error inesperado. Por favor intenta nuevamente';
  }
} 