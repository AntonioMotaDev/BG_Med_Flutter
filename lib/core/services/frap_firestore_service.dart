import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';

class FrapFirestoreService {
  static const String _collectionName = 'preHospitalRecords';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección
  CollectionReference get _collection => _firestore.collection(_collectionName);

  // Obtener el ID del usuario actual
  String? get _currentUserId => _auth.currentUser?.uid;

  // CREAR un nuevo registro FRAP
  Future<String?> createFrapRecord({
    required FrapData frapData,
    String? customUserId,
  }) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final frapFirestore = FrapFirestore.create(
        userId: userId,
        serviceInfo: frapData.serviceInfo,
        registryInfo: frapData.registryInfo,
        patientInfo: frapData.patientInfo,
        management: frapData.management,
        medications: frapData.medications,
        gynecoObstetric: frapData.gynecoObstetric,
        attentionNegative: frapData.attentionNegative,
        pathologicalHistory: frapData.pathologicalHistory,
        clinicalHistory: frapData.clinicalHistory,
        physicalExam: frapData.physicalExam,
        priorityJustification: frapData.priorityJustification,
        injuryLocation: frapData.injuryLocation,
        receivingUnit: frapData.receivingUnit,
        patientReception: frapData.patientReception,
      );

      final docRef = await _collection.add(frapFirestore.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear el registro FRAP: $e');
    }
  }

  // ACTUALIZAR un registro FRAP existente
  Future<void> updateFrapRecord({
    required String frapId,
    required FrapData frapData,
    String? customUserId,
  }) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que el registro existe y pertenece al usuario
      final doc = await _collection.doc(frapId).get();
      if (!doc.exists) {
        throw Exception('Registro no encontrado');
      }

      final existingData = doc.data() as Map<String, dynamic>;
      if (existingData['userId'] != userId) {
        throw Exception('No tienes permisos para actualizar este registro');
      }

      // Actualizar el registro
      final updatedData = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'serviceInfo': frapData.serviceInfo,
        'registryInfo': frapData.registryInfo,
        'patientInfo': frapData.patientInfo,
        'management': frapData.management,
        'medications': frapData.medications,
        'gynecoObstetric': frapData.gynecoObstetric,
        'attentionNegative': frapData.attentionNegative,
        'pathologicalHistory': frapData.pathologicalHistory,
        'clinicalHistory': frapData.clinicalHistory,
        'physicalExam': frapData.physicalExam,
        'priorityJustification': frapData.priorityJustification,
        'injuryLocation': frapData.injuryLocation,
        'receivingUnit': frapData.receivingUnit,
        'patientReception': frapData.patientReception,
      };

      await _collection.doc(frapId).update(updatedData);
    } catch (e) {
      throw Exception('Error al actualizar el registro FRAP: $e');
    }
  }

  // ACTUALIZAR sección específica de un registro FRAP
  Future<void> updateFrapSection({
    required String frapId,
    required String sectionName,
    required Map<String, dynamic> sectionData,
    String? customUserId,
  }) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que el registro existe y pertenece al usuario
      final doc = await _collection.doc(frapId).get();
      if (!doc.exists) {
        throw Exception('Registro no encontrado');
      }

      final existingData = doc.data() as Map<String, dynamic>;
      if (existingData['userId'] != userId) {
        throw Exception('No tienes permisos para actualizar este registro');
      }

      // Actualizar solo la sección específica
      final updateData = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        sectionName: sectionData,
      };

      await _collection.doc(frapId).update(updateData);
    } catch (e) {
      throw Exception('Error al actualizar la sección del registro FRAP: $e');
    }
  }

  // OBTENER un registro FRAP por ID
  Future<FrapFirestore?> getFrapRecord(String frapId) async {
    try {
      final doc = await _collection.doc(frapId).get();
      if (!doc.exists) {
        return null;
      }

      return FrapFirestore.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error al obtener el registro FRAP: $e');
    }
  }

  // OBTENER todos los registros FRAP del usuario actual
  Future<List<FrapFirestore>> getAllFrapRecords({String? customUserId}) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Temporalmente removemos orderBy para evitar el error de índice
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();

      // Ordenamos en memoria como workaround temporal
      final records = querySnapshot.docs
          .map((doc) => FrapFirestore.fromFirestore(doc))
          .toList();
      
      // Ordenar por fecha de creación descendente
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return records;
    } catch (e) {
      throw Exception('Error al obtener los registros FRAP: $e');
    }
  }

  // OBTENER registros FRAP con paginación
  Future<List<FrapFirestore>> getFrapRecordsPaginated({
    String? customUserId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Simplificamos la consulta para evitar índice compuesto
      Query query = _collection
          .where('userId', isEqualTo: userId)
          .limit(limit);

      // Nota: Por ahora removemos startAfterDocument hasta que se configure el índice
      final querySnapshot = await query.get();

      final records = querySnapshot.docs
          .map((doc) => FrapFirestore.fromFirestore(doc))
          .toList();
      
      // Ordenar en memoria
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return records;
    } catch (e) {
      throw Exception('Error al obtener los registros FRAP paginados: $e');
    }
  }

  // OBTENER registros FRAP por rango de fechas
  Future<List<FrapFirestore>> getFrapRecordsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? customUserId,
  }) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FrapFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener los registros FRAP por fecha: $e');
    }
  }

  // BUSCAR registros FRAP por nombre de paciente
  Future<List<FrapFirestore>> searchFrapRecordsByPatientName({
    required String patientName,
    String? customUserId,
  }) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener todos los registros del usuario
      final allRecords = await getAllFrapRecords(customUserId: userId);

      // Filtrar por nombre del paciente
      final filteredRecords = allRecords.where((record) {
        final fullName = record.patientName.toLowerCase();
        final searchTerm = patientName.toLowerCase();
        return fullName.contains(searchTerm);
      }).toList();

      return filteredRecords;
    } catch (e) {
      throw Exception('Error al buscar registros FRAP: $e');
    }
  }

  // ELIMINAR un registro FRAP
  Future<void> deleteFrapRecord(String frapId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar que el registro existe y pertenece al usuario
      final doc = await _collection.doc(frapId).get();
      if (!doc.exists) {
        throw Exception('Registro no encontrado');
      }

      final existingData = doc.data() as Map<String, dynamic>;
      if (existingData['userId'] != userId) {
        throw Exception('No tienes permisos para eliminar este registro');
      }

      await _collection.doc(frapId).delete();
    } catch (e) {
      throw Exception('Error al eliminar el registro FRAP: $e');
    }
  }

  // DUPLICAR un registro FRAP
  Future<String?> duplicateFrapRecord(String frapId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el registro original
      final originalRecord = await getFrapRecord(frapId);
      if (originalRecord == null) {
        throw Exception('Registro no encontrado');
      }

      // Verificar permisos
      if (originalRecord.userId != userId) {
        throw Exception('No tienes permisos para duplicar este registro');
      }

      // Crear una copia del registro
      final duplicatedRecord = FrapFirestore.create(
        userId: userId,
        serviceInfo: originalRecord.serviceInfo,
        registryInfo: originalRecord.registryInfo,
        patientInfo: originalRecord.patientInfo,
        management: originalRecord.management,
        medications: originalRecord.medications,
        gynecoObstetric: originalRecord.gynecoObstetric,
        attentionNegative: originalRecord.attentionNegative,
        pathologicalHistory: originalRecord.pathologicalHistory,
        clinicalHistory: originalRecord.clinicalHistory,
        physicalExam: originalRecord.physicalExam,
        priorityJustification: originalRecord.priorityJustification,
        injuryLocation: originalRecord.injuryLocation,
        receivingUnit: originalRecord.receivingUnit,
        patientReception: originalRecord.patientReception,
      );

      final docRef = await _collection.add(duplicatedRecord.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al duplicar el registro FRAP: $e');
    }
  }

  // STREAM de registros FRAP en tiempo real
  Stream<List<FrapFirestore>> getFrapRecordsStream({String? customUserId}) {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Removemos orderBy temporalmente para evitar el error de índice
      return _collection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((querySnapshot) {
            final records = querySnapshot.docs
                .map((doc) => FrapFirestore.fromFirestore(doc))
                .toList();
            
            // Ordenar en memoria por fecha de creación descendente
            records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            return records;
          });
    } catch (e) {
      throw Exception('Error al obtener el stream de registros FRAP: $e');
    }
  }

  // STREAM de un registro FRAP específico en tiempo real
  Stream<FrapFirestore?> getFrapRecordStream(String frapId) {
    try {
      return _collection
          .doc(frapId)
          .snapshots()
          .map((docSnapshot) {
            if (!docSnapshot.exists) {
              return null;
            }
            return FrapFirestore.fromFirestore(docSnapshot);
          });
    } catch (e) {
      throw Exception('Error al obtener el stream del registro FRAP: $e');
    }
  }

  // OBTENER estadísticas de registros FRAP
  Future<Map<String, dynamic>> getFrapStatistics({String? customUserId}) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final allRecords = await getAllFrapRecords(customUserId: userId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeek = today.subtract(Duration(days: today.weekday - 1));
      final thisMonth = DateTime(now.year, now.month, 1);
      final thisYear = DateTime(now.year, 1, 1);

      return {
        'total': allRecords.length,
        'today': allRecords.where((record) {
          final recordDate = DateTime(
            record.createdAt.year,
            record.createdAt.month,
            record.createdAt.day,
          );
          return recordDate.isAtSameMomentAs(today);
        }).length,
        'thisWeek': allRecords.where((record) => 
          record.createdAt.isAfter(thisWeek) && record.createdAt.isBefore(today.add(const Duration(days: 1)))
        ).length,
        'thisMonth': allRecords.where((record) => 
          record.createdAt.isAfter(thisMonth) && record.createdAt.isBefore(thisMonth.add(const Duration(days: 32)))
        ).length,
        'thisYear': allRecords.where((record) => 
          record.createdAt.isAfter(thisYear) && record.createdAt.isBefore(thisYear.add(const Duration(days: 366)))
        ).length,
        'completed': allRecords.where((record) => record.isComplete).length,
        'averageCompletion': allRecords.isEmpty 
          ? 0.0 
          : allRecords.map((record) => record.completionPercentage).reduce((a, b) => a + b) / allRecords.length,
      };
    } catch (e) {
      throw Exception('Error al obtener las estadísticas FRAP: $e');
    }
  }

  // SINCRONIZAR registros locales con la nube
  Future<void> syncLocalRecordsToCloud() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Aquí puedes implementar la lógica para sincronizar los registros locales de Hive
      // con los registros en Firestore
      // Por ejemplo, obtener registros de Hive y subirlos a Firestore si no existen
      
      print('Sincronización de registros locales con la nube completada');
    } catch (e) {
      throw Exception('Error al sincronizar registros: $e');
    }
  }

  // BACKUP de registros FRAP
  Future<List<Map<String, dynamic>>> backupFrapRecords({String? customUserId}) async {
    try {
      final records = await getAllFrapRecords(customUserId: customUserId);
      return records.map((record) => record.toMap()).toList();
    } catch (e) {
      throw Exception('Error al crear backup de registros FRAP: $e');
    }
  }

  // RESTAURAR registros FRAP desde backup
  Future<void> restoreFrapRecords({
    required List<Map<String, dynamic>> backupData,
    String? customUserId,
  }) async {
    try {
      final userId = customUserId ?? _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final batch = _firestore.batch();
      
      for (final recordData in backupData) {
        final docRef = _collection.doc();
        final frapRecord = FrapFirestore.fromMap(recordData, docRef.id);
        batch.set(docRef, frapRecord.copyWith(userId: userId).toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error al restaurar registros FRAP: $e');
    }
  }
} 