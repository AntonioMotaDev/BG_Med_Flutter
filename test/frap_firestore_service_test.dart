import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  User,
])
import 'frap_firestore_service_test.mocks.dart';

void main() {
  group('FrapFirestoreService Tests', () {
    late FrapFirestoreService service;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockCollectionReference mockCollection;
    late MockUser mockUser;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockUser = MockUser();
      
      // Mock user authentication
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-user-id');
      
      // Mock collection reference
      when(mockFirestore.collection('preHospitalRecords')).thenReturn(mockCollection);
      
      service = FrapFirestoreService();
    });

    test('should create FRAP record successfully', () async {
      // Arrange
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      final frapData = FrapData();
      
      when(mockCollection.add(any)).thenAnswer((_) async => mockDocRef);
      when(mockDocRef.id).thenReturn('test-record-id');
      
      // Act
      final result = await service.createFrapRecord(frapData: frapData);
      
      // Assert
      expect(result, 'test-record-id');
      verify(mockCollection.add(any)).called(1);
    });

    test('should throw exception when user is not authenticated', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);
      final frapData = FrapData();
      
      // Act & Assert
      expect(
        () => service.createFrapRecord(frapData: frapData),
        throwsA(isA<Exception>()),
      );
    });

    test('should fetch FRAP records for authenticated user', () async {
      // Arrange
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
      when(mockQuery.orderBy('createdAt', descending: true)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      
      // Mock document data
      when(mockDocSnapshot.id).thenReturn('test-record-id');
      when(mockDocSnapshot.data()).thenReturn({
        'userId': 'test-user-id',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'serviceInfo': {},
        'registryInfo': {},
        'patientInfo': {'firstName': 'Juan', 'paternalLastName': 'Pérez', 'age': 30},
        'management': {},
        'medications': {},
        'gynecoObstetric': {},
        'attentionNegative': {},
        'pathologicalHistory': {},
        'clinicalHistory': {},
        'physicalExam': {},
        'priorityJustification': {},
        'injuryLocation': {},
        'receivingUnit': {},
        'patientReception': {},
      });
      
      // Act
      final result = await service.getAllFrapRecords();
      
      // Assert
      expect(result, isA<List<FrapFirestore>>());
      expect(result.length, 1);
      expect(result.first.patientName, 'Juan Pérez');
    });

    test('should return empty list when no records exist', () async {
      // Arrange
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      
      when(mockCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
      when(mockQuery.orderBy('createdAt', descending: true)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);
      
      // Act
      final result = await service.getAllFrapRecords();
      
      // Assert
      expect(result, isA<List<FrapFirestore>>());
      expect(result.isEmpty, true);
    });

    test('should search records by patient name', () async {
      // Arrange
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
      when(mockQuery.orderBy('createdAt', descending: true)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      
      // Mock document data
      when(mockDocSnapshot.id).thenReturn('test-record-id');
      when(mockDocSnapshot.data()).thenReturn({
        'userId': 'test-user-id',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'serviceInfo': {},
        'registryInfo': {},
        'patientInfo': {'firstName': 'Juan', 'paternalLastName': 'Pérez', 'age': 30},
        'management': {},
        'medications': {},
        'gynecoObstetric': {},
        'attentionNegative': {},
        'pathologicalHistory': {},
        'clinicalHistory': {},
        'physicalExam': {},
        'priorityJustification': {},
        'injuryLocation': {},
        'receivingUnit': {},
        'patientReception': {},
      });
      
      // Act
      final result = await service.searchFrapRecordsByPatientName(patientName: 'Juan');
      
      // Assert
      expect(result, isA<List<FrapFirestore>>());
      expect(result.length, 1);
      expect(result.first.patientName.toLowerCase(), contains('juan'));
    });
  });

  group('FrapFirestore Model Tests', () {
    test('should create FrapFirestore with correct patient name', () {
      // Arrange
      final frapRecord = FrapFirestore.create(
        userId: 'test-user-id',
        patientInfo: {
          'firstName': 'María',
          'paternalLastName': 'González',
          'maternalLastName': 'López',
          'age': 25,
        },
      );
      
      // Assert
      expect(frapRecord.patientName, 'María González López');
      expect(frapRecord.patientAge, 25);
    });

    test('should handle empty patient info', () {
      // Arrange
      final frapRecord = FrapFirestore.create(
        userId: 'test-user-id',
        patientInfo: {},
      );
      
      // Assert
      expect(frapRecord.patientName, 'Sin nombre');
      expect(frapRecord.patientAge, 0);
    });

    test('should calculate completion percentage correctly', () {
      // Arrange
      final frapRecord = FrapFirestore.create(
        userId: 'test-user-id',
        serviceInfo: {'field1': 'value1'},
        registryInfo: {'field2': 'value2'},
        patientInfo: {'field3': 'value3'},
        management: {'field4': 'value4'},
      );
      
      // Assert
      expect(frapRecord.completionPercentage, closeTo(28.57, 0.01)); // 4/14 * 100
    });
  });
}

// Mock classes for Query
class MockQuery<T> extends Mock implements Query<T> {} 