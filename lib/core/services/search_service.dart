import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/patient.dart';

class SearchFilters {
  final DateTimeRange? dateRange;
  final String? patientName;
  final String? emergencyType;
  final String? receivingUnit;
  final bool? isSynced;
  final String? createdBy;
  final int? minAge;
  final int? maxAge;
  final String? gender;
  final List<String>? allergies;
  final String? vitalSigns;
  final bool? hasPathologicalHistory;
  final String? priorityLevel;

  SearchFilters({
    this.dateRange,
    this.patientName,
    this.emergencyType,
    this.receivingUnit,
    this.isSynced,
    this.createdBy,
    this.minAge,
    this.maxAge,
    this.gender,
    this.allergies,
    this.vitalSigns,
    this.hasPathologicalHistory,
    this.priorityLevel,
  });

  SearchFilters copyWith({
    DateTimeRange? dateRange,
    String? patientName,
    String? emergencyType,
    String? receivingUnit,
    bool? isSynced,
    String? createdBy,
    int? minAge,
    int? maxAge,
    String? gender,
    List<String>? allergies,
    String? vitalSigns,
    bool? hasPathologicalHistory,
    String? priorityLevel,
  }) {
    return SearchFilters(
      dateRange: dateRange ?? this.dateRange,
      patientName: patientName ?? this.patientName,
      emergencyType: emergencyType ?? this.emergencyType,
      receivingUnit: receivingUnit ?? this.receivingUnit,
      isSynced: isSynced ?? this.isSynced,
      createdBy: createdBy ?? this.createdBy,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      gender: gender ?? this.gender,
      allergies: allergies ?? this.allergies,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      hasPathologicalHistory: hasPathologicalHistory ?? this.hasPathologicalHistory,
      priorityLevel: priorityLevel ?? this.priorityLevel,
    );
  }

  bool get isEmpty {
    return dateRange == null &&
           patientName == null &&
           emergencyType == null &&
           receivingUnit == null &&
           isSynced == null &&
           createdBy == null &&
           minAge == null &&
           maxAge == null &&
           gender == null &&
           allergies == null &&
           vitalSigns == null &&
           hasPathologicalHistory == null &&
           priorityLevel == null;
  }
}

class SearchResult {
  final Frap record;
  final double relevance;
  final List<String> matchedFields;

  SearchResult({
    required this.record,
    required this.relevance,
    required this.matchedFields,
  });
}

class SearchService {
  // Búsqueda por texto en múltiples campos
  Future<List<SearchResult>> searchFraps(List<Frap> records, String query) async {
    if (query.trim().isEmpty) {
      return records.map((r) => SearchResult(
        record: r,
        relevance: 1.0,
        matchedFields: [],
      )).toList();
    }

    final List<SearchResult> results = [];
    final queryLower = query.toLowerCase().trim();

    for (final record in records) {
      final matchedFields = <String>[];
      double relevance = 0.0;

      // Búsqueda en nombre del paciente (peso alto)
      if (record.patient.name.toLowerCase().contains(queryLower)) {
        matchedFields.add('Nombre del paciente');
        relevance += 0.4;
      }

      // Búsqueda en edad
      if (record.patient.age.toString().contains(queryLower)) {
        matchedFields.add('Edad');
        relevance += 0.1;
      }

      // Búsqueda en género
      if (record.patient.gender.toLowerCase().contains(queryLower)) {
        matchedFields.add('Género');
        relevance += 0.1;
      }

      // Búsqueda en dirección
      if (record.patient.address.toLowerCase().contains(queryLower)) {
        matchedFields.add('Dirección');
        relevance += 0.2;
      }

      // Búsqueda en alergias
      for (final allergy in record.clinicalHistory.allergies) {
        if (allergy.toLowerCase().contains(queryLower)) {
          matchedFields.add('Alergias');
          relevance += 0.3;
          break;
        }
      }

      // Búsqueda en medicamentos
      for (final medication in record.clinicalHistory.medications) {
        if (medication.toLowerCase().contains(queryLower)) {
          matchedFields.add('Medicamentos');
          relevance += 0.3;
          break;
        }
      }

      // Búsqueda en enfermedades previas
      for (final illness in record.clinicalHistory.previousIllnesses) {
        if (illness.toLowerCase().contains(queryLower)) {
          matchedFields.add('Enfermedades previas');
          relevance += 0.2;
          break;
        }
      }

      // Búsqueda en signos vitales
      if (record.physicalExam.vitalSigns.toLowerCase().contains(queryLower)) {
        matchedFields.add('Signos vitales');
        relevance += 0.2;
      }

      // Búsqueda en secciones adicionales
      if (_searchInMap(record.serviceInfo, queryLower)) {
        matchedFields.add('Información del servicio');
        relevance += 0.1;
      }

      if (_searchInMap(record.management, queryLower)) {
        matchedFields.add('Manejo');
        relevance += 0.1;
      }

      if (_searchInMap(record.medications, queryLower)) {
        matchedFields.add('Medicamentos adicionales');
        relevance += 0.2;
      }

      // Solo incluir resultados con relevancia
      if (relevance > 0) {
        results.add(SearchResult(
          record: record,
          relevance: relevance,
          matchedFields: matchedFields.toSet().toList(),
        ));
      }
    }

    // Ordenar por relevancia
    results.sort((a, b) => b.relevance.compareTo(a.relevance));

    return results;
  }

  // Búsqueda por filtros específicos
  Future<List<Frap>> filterFraps(List<Frap> records, SearchFilters filters) async {
    if (filters.isEmpty) {
      return records;
    }

    return records.where((record) {
      // Filtro por rango de fechas
      if (filters.dateRange != null) {
        if (record.createdAt.isBefore(filters.dateRange!.start) ||
            record.createdAt.isAfter(filters.dateRange!.end)) {
          return false;
        }
      }

      // Filtro por nombre del paciente
      if (filters.patientName != null && filters.patientName!.isNotEmpty) {
        if (!record.patient.name.toLowerCase().contains(filters.patientName!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por tipo de emergencia
      if (filters.emergencyType != null && filters.emergencyType!.isNotEmpty) {
        final emergencyType = record.serviceInfo['emergencyType']?.toString() ?? '';
        if (!emergencyType.toLowerCase().contains(filters.emergencyType!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por unidad receptora
      if (filters.receivingUnit != null && filters.receivingUnit!.isNotEmpty) {
        final receivingUnit = record.receivingUnit['unit']?.toString() ?? '';
        if (!receivingUnit.toLowerCase().contains(filters.receivingUnit!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por estado de sincronización
      if (filters.isSynced != null) {
        final isLocal = record.id.startsWith('local_');
        if (filters.isSynced! && isLocal) {
          return false;
        }
        if (!filters.isSynced! && !isLocal) {
          return false;
        }
      }

      // Filtro por creador
      if (filters.createdBy != null && filters.createdBy!.isNotEmpty) {
        final createdBy = record.registryInfo['createdBy']?.toString() ?? '';
        if (!createdBy.toLowerCase().contains(filters.createdBy!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por edad mínima
      if (filters.minAge != null && record.patient.age < filters.minAge!) {
        return false;
      }

      // Filtro por edad máxima
      if (filters.maxAge != null && record.patient.age > filters.maxAge!) {
        return false;
      }

      // Filtro por género
      if (filters.gender != null && filters.gender!.isNotEmpty) {
        if (record.patient.gender.toLowerCase() != filters.gender!.toLowerCase()) {
          return false;
        }
      }

      // Filtro por alergias específicas
      if (filters.allergies != null && filters.allergies!.isNotEmpty) {
        bool hasMatchingAllergy = false;
        for (final allergy in filters.allergies!) {
          if (record.clinicalHistory.allergies.any((a) => 
              a.toLowerCase().contains(allergy.toLowerCase()))) {
            hasMatchingAllergy = true;
            break;
          }
        }
        if (!hasMatchingAllergy) {
          return false;
        }
      }

      // Filtro por signos vitales
      if (filters.vitalSigns != null && filters.vitalSigns!.isNotEmpty) {
        if (!record.physicalExam.vitalSigns.toLowerCase().contains(filters.vitalSigns!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por antecedentes patológicos
      if (filters.hasPathologicalHistory != null) {
        final hasHistory = record.pathologicalHistory.isNotEmpty;
        if (filters.hasPathologicalHistory! != hasHistory) {
          return false;
        }
      }

      // Filtro por nivel de prioridad
      if (filters.priorityLevel != null && filters.priorityLevel!.isNotEmpty) {
        final priority = record.priorityJustification['level']?.toString() ?? '';
        if (priority.toLowerCase() != filters.priorityLevel!.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Búsqueda fuzzy para nombres
  Future<List<SearchResult>> fuzzySearch(List<Frap> records, String name) async {
    if (name.trim().isEmpty) {
      return [];
    }

    final List<SearchResult> results = [];
    final queryLower = name.toLowerCase().trim();

    for (final record in records) {
      final patientName = record.patient.name.toLowerCase();
      final similarity = _calculateStringSimilarity(patientName, queryLower);

      if (similarity > 0.6) { // Umbral de similitud
        results.add(SearchResult(
          record: record,
          relevance: similarity,
          matchedFields: ['Nombre del paciente (similitud: ${(similarity * 100).toStringAsFixed(1)}%)'],
        ));
      }
    }

    // Ordenar por similitud
    results.sort((a, b) => b.relevance.compareTo(a.relevance));

    return results;
  }

  // Búsqueda avanzada combinando texto y filtros
  Future<List<SearchResult>> advancedSearch(
    List<Frap> records,
    String query,
    SearchFilters filters,
  ) async {
    List<Frap> filteredRecords = records;

    // Aplicar filtros primero
    if (!filters.isEmpty) {
      filteredRecords = await filterFraps(records, filters);
    }

    // Luego aplicar búsqueda de texto
    if (query.trim().isNotEmpty) {
      return await searchFraps(filteredRecords, query);
    } else {
      return filteredRecords.map((r) => SearchResult(
        record: r,
        relevance: 1.0,
        matchedFields: [],
      )).toList();
    }
  }

  // Obtener sugerencias de búsqueda
  List<String> getSearchSuggestions(List<Frap> records, String partialQuery) {
    if (partialQuery.trim().isEmpty) {
      return [];
    }

    final suggestions = <String>{};
    final queryLower = partialQuery.toLowerCase().trim();

    for (final record in records) {
      // Sugerencias de nombres
      if (record.patient.name.toLowerCase().contains(queryLower)) {
        suggestions.add(record.patient.name);
      }

      // Sugerencias de alergias
      for (final allergy in record.clinicalHistory.allergies) {
        if (allergy.toLowerCase().contains(queryLower)) {
          suggestions.add(allergy);
        }
      }

      // Sugerencias de medicamentos
      for (final medication in record.clinicalHistory.medications) {
        if (medication.toLowerCase().contains(queryLower)) {
          suggestions.add(medication);
        }
      }

      // Sugerencias de enfermedades
      for (final illness in record.clinicalHistory.previousIllnesses) {
        if (illness.toLowerCase().contains(queryLower)) {
          suggestions.add(illness);
        }
      }
    }

    return suggestions.take(10).toList();
  }

  // Buscar en Map<String, dynamic>
  bool _searchInMap(Map<String, dynamic> map, String query) {
    for (final entry in map.entries) {
      final value = entry.value?.toString().toLowerCase() ?? '';
      if (value.contains(query)) {
        return true;
      }
    }
    return false;
  }

  // Calcular similitud entre strings (algoritmo simple)
  double _calculateStringSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;

    if (longer.length == 0) return 1.0;

    return (longer.length - _editDistance(longer, shorter)) / longer.length;
  }

  // Distancia de edición (Levenshtein)
  int _editDistance(String s1, String s2) {
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = 1 + [
            matrix[i - 1][j],
            matrix[i][j - 1],
            matrix[i - 1][j - 1],
          ].reduce((a, b) => a < b ? a : b);
        }
      }
    }

    return matrix[s1.length][s2.length];
  }
} 