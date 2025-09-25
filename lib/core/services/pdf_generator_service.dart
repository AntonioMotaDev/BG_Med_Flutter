import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:bg_med/core/services/frap_unified_service.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// DTO Classes for unified data representation
class PatientDisplayData {
  final String fullName;
  final String address;
  final String age;
  final String sex;
  final String gender;
  final String phone;
  final String insurance;
  final String responsiblePerson;
  final String emergencyContact;
  final String addressDetails;
  final String tipoEntrega;
  final String currentCondition;

  PatientDisplayData({
    required this.fullName,
    required this.address,
    required this.age,
    required this.sex,
    required this.gender,
    required this.phone,
    required this.insurance,
    required this.responsiblePerson,
    required this.emergencyContact,
    required this.addressDetails,
    required this.tipoEntrega,
    required this.currentCondition,
  });
}

class ServiceDisplayData {
  final String ubicacion;
  final String tipoServicio;
  final String tipoServicioEspecifique;
  final String lugarOcurrencia;
  final String lugarOcurrenciaEspecifique;
  final String horaLlamada;
  final String horaArribo;
  final String horaLlegada;
  final String horaTermino;
  final String tiempoEsperaArribo;
  final String tiempoEsperaLlegada;
  final String tiempoTotal;
  final String currentCondition;

  ServiceDisplayData({
    required this.ubicacion,
    required this.tipoServicio,
    required this.tipoServicioEspecifique,
    required this.lugarOcurrencia,
    required this.lugarOcurrenciaEspecifique,
    required this.horaLlamada,
    required this.horaArribo,
    required this.horaLlegada,
    required this.horaTermino,
    required this.tiempoEsperaArribo,
    required this.tiempoEsperaLlegada,
    required this.tiempoTotal,
    required this.currentCondition,
  });
}

class VitalSignsDisplayData {
  final List<String> timeColumns;
  final Map<String, Map<String, String>> vitalSigns;
  final String eva;
  final String llc;
  final String glucosa;
  final String ta;

  VitalSignsDisplayData({
    required this.timeColumns,
    required this.vitalSigns,
    required this.eva,
    required this.llc,
    required this.glucosa,
    required this.ta,
  });
}

class SampleDisplayData {
  final String alergias;
  final String medicamentos;
  final String enfermedades;
  final String horaAlimento;
  final String eventosPrevios;

  SampleDisplayData({
    required this.alergias,
    required this.medicamentos,
    required this.enfermedades,
    required this.horaAlimento,
    required this.eventosPrevios,
  });
}

class ClinicalDisplayData {
  final String currentCondition;
  final String allergies;
  final String medications;
  final String previousIllnesses;
  final String previousSurgeries;
  final String hospitalizations;
  final String transfusions;
  final Map<String, bool> accidentTypes;
  final String agenteCausal;
  final String cinematica;
  final String medidaSeguridad;

  ClinicalDisplayData({
    required this.currentCondition,
    required this.allergies,
    required this.medications,
    required this.previousIllnesses,
    required this.previousSurgeries,
    required this.hospitalizations,
    required this.transfusions,
    required this.accidentTypes,
    required this.agenteCausal,
    required this.cinematica,
    required this.medidaSeguridad,
  });
}

// Este contiene datos que no son de la seccion de management
class ManagementDisplayData {
  final Map<String, String> procedures;
  final String oxigenoLitros;
  final List<Map<String, dynamic>> insumos;
  final List<Map<String, dynamic>> personalMedico;
  final String medicamentos;

  ManagementDisplayData({
    required this.procedures,
    required this.oxigenoLitros,
    required this.insumos,
    required this.personalMedico,
    required this.medicamentos,
  });
}

// Este contiene datos que no son de la seccion de Ambulance, se deberia llamar ReceptionUnit
class AmbulanceDisplayData {
  final String numeroAmbulancia;
  final String tipoAmbulancia;
  final String personalABordo;
  final String equipamiento;
  final String observaciones;

  AmbulanceDisplayData({
    required this.numeroAmbulancia,
    required this.tipoAmbulancia,
    required this.personalABordo,
    required this.equipamiento,
    required this.observaciones,
  });
}

class GynecoObstetricDisplayData {
  final String urgencia;
  final String fum;
  final String semanasGestacion;
  final String gesta;
  final String partos;
  final String cesareas;
  final String abortos;
  final String hora;
  final String metodosAnticonceptivos;
  final bool ruidosCardiacosFetales;
  final bool expulsionPlacenta;
  final Map<String, dynamic>? escalasObstetricas;

  GynecoObstetricDisplayData({
    required this.urgencia,
    required this.fum,
    required this.semanasGestacion,
    required this.gesta,
    required this.partos,
    required this.cesareas,
    required this.abortos,
    required this.hora,
    required this.metodosAnticonceptivos,
    required this.ruidosCardiacosFetales,
    required this.expulsionPlacenta,
    this.escalasObstetricas,
  });
}

class PriorityDisplayData {
  final String priority;
  final String pupils;
  final String skinColor;
  final String skin;
  final String temperature;
  final String influence;
  final String especifique;

  PriorityDisplayData({
    required this.priority,
    required this.pupils,
    required this.skinColor,
    required this.skin,
    required this.temperature,
    required this.influence,
    required this.especifique,
  });
}

class RegistryDisplayData {
  final String convenio;
  final String episodio;
  final String solicitadoPor;
  final String folio;
  final String fecha;

  RegistryDisplayData({
    required this.convenio,
    required this.episodio,
    required this.solicitadoPor,
    required this.folio,
    required this.fecha,
  });
}

class ReceptionDisplayData {
  final String receivingDoctor;
  final String? doctorSignature;
  final String originPlace;
  final String consultPlace;
  final String destinationPlace;

  ReceptionDisplayData({
    required this.receivingDoctor,
    this.doctorSignature,
    required this.originPlace,
    required this.consultPlace,
    required this.destinationPlace,
  });
}

class InsumosDisplayData {
  final List<Map<String, dynamic>> insumos;

  InsumosDisplayData({required this.insumos});
}

class FrapPdfDisplayData {
  final PatientDisplayData patient;
  final ServiceDisplayData service;
  final VitalSignsDisplayData vitalSigns;
  final SampleDisplayData sample;
  final ClinicalDisplayData clinical;
  final ManagementDisplayData management;
  final AmbulanceDisplayData ambulance;
  final GynecoObstetricDisplayData gynecoObstetric;
  final PriorityDisplayData priority;
  final RegistryDisplayData registry;
  final ReceptionDisplayData reception;
  final String? consentimientoServicio;
  final InsumosDisplayData insumos;
  FrapPdfDisplayData({
    required this.patient,
    required this.service,
    required this.vitalSigns,
    required this.sample,
    required this.clinical,
    required this.management,
    required this.ambulance,
    required this.gynecoObstetric,
    required this.priority,
    required this.registry,
    required this.reception,
    this.consentimientoServicio,
    required this.insumos,
  });
}

class PdfGeneratorService {
  static final PdfGeneratorService _instance = PdfGeneratorService._internal();
  factory PdfGeneratorService() => _instance;
  PdfGeneratorService._internal();

  // Cached fonts
  pw.Font? _robotoRegular;
  pw.Font? _robotoBold;
  pw.Font? _robotoItalic;
  pw.Font? _robotoBoldItalic;
  bool _fontsLoaded = false;

  // Cached styles
  late pw.TextStyle _sectionTitleStyle;
  late pw.TextStyle _labelStyle;
  late pw.TextStyle _valueStyle;
  late pw.TextStyle _headerStyle;

  // Debug logging
  final bool _debugLogs = false;

  void _log(String message) {
    if (!_debugLogs) return;
    // ignore: avoid_print
    print('[PDF] $message');
  }

  // Initialize fonts and styles (singleton pattern)
  Future<void> _initializeFontsAndStyles() async {
    if (_fontsLoaded) return;

    try {
      _robotoRegular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
      );
      _robotoBold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
      );
      _robotoItalic = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Italic.ttf'),
      );
      _robotoBoldItalic = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-BoldItalic.ttf'),
      );
    } catch (e) {
      _log('Error loading Roboto fonts: $e');
      try {
        _robotoRegular = pw.Font.times();
        _robotoBold = pw.Font.timesBold();
        _robotoItalic = pw.Font.timesItalic();
        _robotoBoldItalic = pw.Font.timesBoldItalic();
      } catch (_) {
        _log('Fallback fonts also failed');
      }
    }

    // Initialize styles
    _sectionTitleStyle = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueGrey800,
      font: _robotoBold,
    );

    _labelStyle = pw.TextStyle(
      fontSize: 6,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey800,
      font: _robotoBold,
    );

    _valueStyle = pw.TextStyle(
      fontSize: 6,
      color: PdfColors.black,
      font: _robotoRegular,
    );

    _headerStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue800,
      font: _robotoBold,
    );

    _fontsLoaded = true;
    _log('Fonts and styles initialized successfully');
  }

  // Helper to safely decode base64 image data for PDF
  pw.MemoryImage? _getImageFromBase64(String? base64Data) {
    if (base64Data == null || base64Data.isEmpty) {
      return null;
    }
    try {
      final base64String = base64Data.split(',').last;
      final decodedBytes = base64Decode(base64String);
      return pw.MemoryImage(decodedBytes);
    } catch (e) {
      // Log error or handle gracefully
      return null;
    }
  }

  /// Generates a PDF document for a given UnifiedFrapRecord.
  Future<Uint8List> generateFrapPdf(UnifiedFrapRecord record) async {
    // Initialize fonts and styles
    await _initializeFontsAndStyles();

    // Preload the human silhouette image
    pw.MemoryImage? silhouetteImage;
    try {
      final imageBytes = await rootBundle.load(
        'assets/images/silueta_humana.jpeg',
      );
      silhouetteImage = pw.MemoryImage(imageBytes.buffer.asUint8List());
    } catch (e) {
      _log('Error loading silhouette image: $e');
    }

    // Crear imagen combinada con silueta y lesiones
    pw.MemoryImage? combinedImage;
    final injuryLocation =
        record.getDetailedInfo()['injuryLocation'] as Map<String, dynamic>?;
    final drawnInjuries = injuryLocation?['drawnInjuries'] as List<dynamic>?;
    if (drawnInjuries != null && drawnInjuries.isNotEmpty) {
      try {
        combinedImage = await _createCombinedSilhouetteImage(
          'assets/images/silueta_humana.jpeg',
          drawnInjuries,
          injuryLocationMap: injuryLocation,
        );
      } catch (e) {
        _log('Error creating combined image: $e');
      }
    }

    // Build unified display data
    final displayData = _buildDisplayData(record);
    // print('--------------------------------');
    // print(
    //   'Datos de localizacion de lesiones: ${record.getDetailedInfo()['injuryLocation']}',
    // );
    // print('--------------------------------');
    // _log('Display data built successfully');

    final pdf = pw.Document(
      title: 'Registro de Atención Prehospitalaria',
      author: 'BG Med',
    );

    // Apply theme if fonts are available
    final theme =
        _fontsLoaded
            ? pw.ThemeData.withFont(
              base: _robotoRegular!,
              bold: _robotoBold!,
              italic: _robotoItalic!,
              boldItalic: _robotoBoldItalic!,
            )
            : null;

    // EMPIEZA LA PAGINA GENERADA DEL PDF PREVIEW
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          21.0 * PdfPageFormat.cm,
          29.7 * PdfPageFormat.cm,
          marginTop: 1.0 * PdfPageFormat.cm,
          marginBottom: 1.0 * PdfPageFormat.cm,
          marginLeft: 1.0 * PdfPageFormat.cm,
          marginRight: 1.0 * PdfPageFormat.cm,
        ),
        theme: theme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'REGISTRO DE ATENCIÓN PREHOSPITALARIA',
                    style: _headerStyle,
                  ),
                ],
              ),
              pw.SizedBox(height: 3),

              //COMIENZO DE LAS DOS COLUMNAS
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  /////////////////////////// LEFT COLUMN ///////////////////////////
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildTimeTrackingGrid(displayData.service),
                        pw.SizedBox(height: 3),
                        _buildPatientInfoSection(
                          displayData.patient,
                          displayData.service.currentCondition,
                        ),
                        // _buildConsentimientoSection(
                        //   displayData.consentimientoServicio!,
                        // ),
                        // _buildClinicalHistorySection(displayData.clinical),
                        // pw.SizedBox(height: 3),
                        // _buildPhysicalExamSection(displayData.vitalSigns),
                        // pw.SizedBox(height: 3),
                        //Localizacion de lesiones
                        _buildInjuryLocationSectionSync(
                          record,
                          silhouetteImage,
                          combinedImage,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 3),
                  /////////////////////////// RIGHT COLUMN ///////////////////////////
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildAdminDetailsTable(displayData.registry),
                        pw.SizedBox(height: 3),
                        _buildServiceInfoSection(displayData.service),
                        pw.SizedBox(height: 3),
                        _buildManagementSection(displayData.management),
                        pw.SizedBox(height: 3),
                        _buildMedicationsSection(displayData.management),
                        pw.SizedBox(height: 3),
                        if (displayData.patient.sex.toLowerCase() ==
                            'femenino') ...[
                          _buildGynecoObstetricSection(
                            displayData.gynecoObstetric,
                          ),
                          pw.SizedBox(height: 3),
                        ],
                        _buildEvaSection(displayData.vitalSigns),
                        pw.SizedBox(height: 3),
                        _buildPriorityJustificationSection(
                          displayData.priority,
                        ),
                        pw.SizedBox(height: 3),
                        _buildReceivingUnitSection(displayData.reception),
                        pw.SizedBox(height: 3),
                        _buildAmbulanceSection(displayData.ambulance),
                        pw.SizedBox(height: 3),
                        // _buildRefusalOfCareSection(record),
                        // pw.SizedBox(height: 3),
                        _buildPatientReceptionSection(displayData.reception),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  String _getPatientInfo(UnifiedFrapRecord record, String key) {
    // Acceder a campos específicos del modelo Patient
    if (record.localRecord != null) {
      final patient = record.localRecord!.patient;
      switch (key) {
        case 'firstName':
          return patient.firstName;
        case 'paternalLastName':
          return patient.paternalLastName;
        case 'maternalLastName':
          return patient.maternalLastName;
        case 'phone':
          return patient.phone;
        case 'street':
          return patient.street;
        case 'exteriorNumber':
          return patient.exteriorNumber;
        case 'interiorNumber':
          return patient.interiorNumber ?? '';
        case 'neighborhood':
          return patient.neighborhood;
        case 'city':
          return patient.city;
        case 'insurance':
          return patient.insurance;
        case 'responsiblePerson':
          return patient.responsiblePerson ?? '';
        case 'sex':
          return patient.sex;
        case 'gender':
          return patient.gender;
        case 'age':
          return patient.age.toString();
        case 'addressDetails':
          return patient.addressDetails;
        case 'tipoEntrega':
          return patient.tipoEntrega;
        case 'currentCondition':
          return patient.currentCondition ?? '';
        case 'emergencyContact':
          return patient.emergencyContact ?? '';
        case 'tipoEntregaOtro':
          return patient.tipoEntregaOtro ?? '';
        default:
          // Fallback para campos no mapeados
          final patientInfo =
              record.getDetailedInfo()['patientInfo'] as Map<String, dynamic>?;
          return patientInfo?[key]?.toString() ?? 'N/A';
      }
    } else {
      // Para registros de nube, usar el método genérico
      final patientInfo =
          record.getDetailedInfo()['patientInfo'] as Map<String, dynamic>?;
      return patientInfo?[key]?.toString() ?? 'N/A';
    }
  }

  String _getRegistryInfo(UnifiedFrapRecord record, String key) {
    final registryInfo =
        record.getDetailedInfo()['registryInfo'] as Map<String, dynamic>?;
    return registryInfo?[key]?.toString() ?? 'N/A';
  }

  String _getManagement(UnifiedFrapRecord record, String key) {
    final management =
        record.getDetailedInfo()['management'] as Map<String, dynamic>?;
    final value = management?[key];
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    return value?.toString() ?? 'N/A';
  }

  String _getMedications(UnifiedFrapRecord record, String key) {
    final medications =
        record.getDetailedInfo()['medications'] as Map<String, dynamic>?;
    return medications?[key]?.toString() ?? 'N/A';
  }

  String _getGynecoObstetric(UnifiedFrapRecord record, String key) {
    final gynecoObstetric =
        record.getDetailedInfo()['gynecoObstetric'] as Map<String, dynamic>?;
    return gynecoObstetric?[key]?.toString() ?? 'N/A';
  }

  String? _getAttentionNegative(UnifiedFrapRecord record, String key) {
    final attentionNegative =
        record.getDetailedInfo()['attentionNegative'] as Map<String, dynamic>?;
    return attentionNegative?[key]?.toString();
  }

  String _getPathologicalHistory(UnifiedFrapRecord record, String key) {
    final pathologicalHistory =
        record.getDetailedInfo()['pathologicalHistory']
            as Map<String, dynamic>?;
    final value = pathologicalHistory?[key];
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    return value?.toString() ?? 'N/A';
  }

  String _getClinicalHistory(UnifiedFrapRecord record, String key) {
    // Acceder a campos específicos del modelo ClinicalHistory
    if (record.localRecord != null) {
      final clinicalHistory = record.localRecord!.clinicalHistory;
      switch (key) {
        case 'allergies':
          return clinicalHistory.allergies;
        case 'medications':
          return clinicalHistory.medications;
        case 'previousIllnesses':
          return clinicalHistory.previousIllnesses;
        case 'currentSymptoms':
          return clinicalHistory.currentSymptoms;
        case 'pain':
          return clinicalHistory.pain;
        case 'painScale':
          return clinicalHistory.painScale;
        case 'dosage':
          return clinicalHistory.dosage;
        case 'frequency':
          return clinicalHistory.frequency;
        case 'route':
          return clinicalHistory.route;
        case 'time':
          return clinicalHistory.time;
        case 'previousSurgeries':
          return clinicalHistory.previousSurgeries;
        case 'hospitalizations':
          return clinicalHistory.hospitalizations;
        case 'transfusions':
          return clinicalHistory.transfusions;
        case 'horaUltimoAlimento':
          return clinicalHistory.horaUltimoAlimento;
        case 'eventosPrevios':
          return clinicalHistory.eventosPrevios;
        default:
          // Fallback para campos no mapeados
          final clinicalHistoryMap =
              record.getDetailedInfo()['clinicalHistory']
                  as Map<String, dynamic>?;
          final value = clinicalHistoryMap?[key];
          if (value == true) return 'Sí';
          if (value == false) return 'No';
          return value?.toString() ?? 'N/A';
      }
    } else {
      // Para registros de nube, usar el método genérico
      final clinicalHistoryMap =
          record.getDetailedInfo()['clinicalHistory'] as Map<String, dynamic>?;
      final value = clinicalHistoryMap?[key];
      if (value == true) return 'Sí';
      if (value == false) return 'No';
      return value?.toString() ?? 'N/A';
    }
  }

  String _getPhysicalExam(UnifiedFrapRecord record, String key) {
    // Acceder a campos específicos del modelo PhysicalExam
    if (record.localRecord != null) {
      final physicalExam = record.localRecord!.physicalExam;
      switch (key) {
        case 'eva':
          return physicalExam.eva;
        case 'llc':
          return physicalExam.llc;
        case 'glucosa':
          return physicalExam.glucosa;
        case 'ta':
          return physicalExam.ta;
        case 'sampleAlergias':
          return physicalExam.sampleAlergias;
        case 'sampleMedicamentos':
          return physicalExam.sampleMedicamentos;
        case 'sampleEnfermedades':
          return physicalExam.sampleEnfermedades;
        case 'sampleHoraAlimento':
          return physicalExam.sampleHoraAlimento;
        case 'sampleEventosPrevios':
          return physicalExam.sampleEventosPrevios;
        default:
          // Para signos vitales dinámicos, buscar en vitalSignsData
          if (physicalExam.vitalSignsData.containsKey(key)) {
            final vitalData = physicalExam.vitalSignsData[key];
            if (vitalData != null && vitalData.isNotEmpty) {
              // Retornar el primer valor disponible
              return vitalData.values.first;
            }
          }
          // Fallback para campos obsoletos
          final physicalExamMap =
              record.getDetailedInfo()['physicalExam'] as Map<String, dynamic>?;
          return physicalExamMap?[key]?.toString() ?? 'N/A';
      }
    } else {
      // Para registros de nube, usar el método genérico
      final physicalExamMap =
          record.getDetailedInfo()['physicalExam'] as Map<String, dynamic>?;
      return physicalExamMap?[key]?.toString() ?? 'N/A';
    }
  }

  String _getReceivingUnit(UnifiedFrapRecord record, String key) {
    final receivingUnit =
        record.getDetailedInfo()['receivingUnit'] as Map<String, dynamic>?;
    return receivingUnit?[key]?.toString() ?? 'N/A';
  }

  String? _getPatientReception(UnifiedFrapRecord record, String key) {
    final patientReception =
        record.getDetailedInfo()['patientReception'] as Map<String, dynamic>?;
    return patientReception?[key]?.toString();
  }

  // Métodos para acceder a campos específicos del modelo Frap
  String _getConsentimientoServicio(UnifiedFrapRecord record) {
    if (record.localRecord != null) {
      return record.localRecord!.consentimientoServicio;
    }
    final serviceInfo =
        record.getDetailedInfo()['serviceInfo'] as Map<String, dynamic>?;
    final sig = serviceInfo?['consentimientoSignature']?.toString();
    if (sig != null && sig.trim().isNotEmpty) return sig;
    return serviceInfo?['consentimientoServicio']?.toString() ?? '';
  }

  List<Map<String, dynamic>> _getInsumos(UnifiedFrapRecord record) {
    if (record.localRecord != null) {
      return record.localRecord!.insumos
          .map(
            (insumo) => {
              'cantidad': insumo.cantidad,
              'articulo': insumo.articulo,
            },
          )
          .toList();
    }
    // Fallback cloud
    final details = record.getDetailedInfo();
    final management = details['management'] as Map<String, dynamic>?;
    final list =
        (management?['insumos'] as List?) ?? (details['insumos'] as List?);
    if (list is List) {
      return list
          .where((e) => e != null)
          .map(
            (e) =>
                e is Map
                    ? {
                      'cantidad': e['cantidad']?.toString() ?? '',
                      'articulo': e['articulo']?.toString() ?? '',
                    }
                    : {'cantidad': '', 'articulo': e.toString()},
          )
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> _getPersonalMedico(UnifiedFrapRecord record) {
    if (record.localRecord != null) {
      return record.localRecord!.personalMedico
          .map(
            (p) => {
              'nombre': p.nombre,
              'especialidad': p.especialidad,
              'cedula': p.cedula,
            },
          )
          .toList();
    }
    // Fallback cloud
    final details = record.getDetailedInfo();
    final management = details['management'] as Map<String, dynamic>?;
    final list =
        (management?['personalMedico'] as List?) ??
        (details['personalMedico'] as List?);
    if (list is List) {
      return list
          .where((e) => e != null)
          .map(
            (e) =>
                e is Map
                    ? {
                      'nombre': e['nombre']?.toString() ?? '',
                      'especialidad': e['especialidad']?.toString() ?? '',
                      'cedula': e['cedula']?.toString() ?? '',
                    }
                    : {
                      'nombre': e.toString(),
                      'especialidad': '',
                      'cedula': '',
                    },
          )
          .toList();
    }
    return [];
  }

  Map<String, dynamic>? _getEscalasObstetricas(UnifiedFrapRecord record) {
    if (record.localRecord != null &&
        record.localRecord!.escalasObstetricas != null) {
      final e = record.localRecord!.escalasObstetricas!;
      return {
        'silvermanAnderson': e.silvermanAnderson,
        'apgar': e.apgar,
        'frecuenciaCardiacaFetal': e.frecuenciaCardiacaFetal,
        'contracciones': e.contracciones,
      };
    }
    // Fallback cloud
    final details = record.getDetailedInfo();
    final gyneco = details['gynecoObstetric'] as Map<String, dynamic>?;
    if (gyneco != null) {
      final silver = gyneco['silvermanAnderson'];
      final apgar = gyneco['apgar'];
      final fcf = gyneco['frecuenciaCardiacaFetal'];
      final cont = gyneco['contracciones'];
      if (silver != null || apgar != null || fcf != null || cont != null) {
        return {
          'silvermanAnderson': silver,
          'apgar': apgar,
          'frecuenciaCardiacaFetal': fcf,
          'contracciones': cont,
        };
      }
    }
    final esc = details['escalasObstetricas'] as Map<String, dynamic>?;
    return esc;
  }

  // Helper to build detail rows with label and value
  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );
  }

  // Build time tracking grid
  pw.Widget _buildTimeTrackingGrid(ServiceDisplayData service) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Center(
              child: pw.Text(
                'INFORMACIÓN DEL SERVICIO',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          // Header row
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(child: _buildTimeGridCell('Hora de llamada', true)),
                pw.Expanded(child: _buildTimeGridCell('Hora de arribo', true)),
                pw.Expanded(
                  child: _buildTimeGridCell('Tiempo de espera', true),
                ),
                pw.Expanded(child: _buildTimeGridCell('Hora de llegada', true)),
                pw.Expanded(child: _buildTimeGridCell('Hora de termino', true)),
                pw.Expanded(
                  child: _buildTimeGridCell('Tiempo de espera', true),
                ),
              ],
            ),
          ),
          // Data row
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildTimeGridCell(service.horaLlamada, false),
              ),
              pw.Expanded(child: _buildTimeGridCell(service.horaArribo, false)),
              pw.Expanded(
                child: _buildTimeGridCell(service.tiempoEsperaArribo, false),
              ),
              pw.Expanded(
                child: _buildTimeGridCell(service.horaLlegada, false),
              ),
              pw.Expanded(
                child: _buildTimeGridCell(service.horaTermino, false),
              ),
              pw.Expanded(
                child: _buildTimeGridCell(service.tiempoEsperaLlegada, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build time grid cell
  pw.Widget _buildTimeGridCell(String text, bool isHeader) {
    return pw.Container(
      height: 10,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          right: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
        color: isHeader ? PdfColors.grey200 : PdfColors.white,
      ),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 7, color: PdfColors.black),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  // Build place of occurrence section
  pw.Widget _buildPlaceOfOccurrenceSection(ServiceDisplayData service) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Lugar de Ocurrencia:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _buildCheckboxOption('Hogar', service.lugarOcurrencia == 'Hogar'),
            _buildCheckboxOption(
              'Escuela',
              service.lugarOcurrencia == 'Escuela',
            ),
            _buildCheckboxOption(
              'Trabajo',
              service.lugarOcurrencia == 'Trabajo',
            ),
            _buildCheckboxOption(
              'Recreativo',
              service.lugarOcurrencia == 'Recreativo',
            ),
            _buildCheckboxOption(
              'Vía Pública',
              service.lugarOcurrencia == 'Vía Pública',
            ),
          ],
        ),
      ],
    );
  }

  // Build checkbox option
  pw.Widget _buildCheckboxOption(String label, bool isChecked) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
            color: isChecked ? PdfColors.black : PdfColors.white,
          ),
          child:
              isChecked
                  ? pw.Center(
                    child: pw.Text(
                      'x',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 6,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  )
                  : null,
        ),
        pw.SizedBox(width: 3),
        pw.Text(label, style: pw.TextStyle(fontSize: 6)),
      ],
    );
  }

  // Build patient information section
  pw.Widget _buildPatientInfoSection(
    PatientDisplayData patient,
    String currentCondition,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Center(
              child: pw.Text(
                'INFORMACIÓN DEL PACIENTE',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),

          // Fila: Nombre | Edad | Sexo
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                // Nombre
                pw.Expanded(
                  flex: 4,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Nombre:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          patient.fullName,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Edad
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Edad:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(patient.age, style: pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                ),
                // Sexo
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Sexo:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(patient.sex, style: pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                ),
                // Derechohabiencia
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Derechohabiencia:',
                          style: pw.TextStyle(fontSize: 6),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          patient.insurance,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tercera fila: Dirección | Teléfono | Persona responsable
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                // Dirección
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Dirección:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          patient.address,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Teléfono
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Teléfono:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          patient.phone,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Persona responsable
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Persona responsable:',
                          style: pw.TextStyle(fontSize: 6),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          patient.responsiblePerson,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Séptima fila: Padecimiento actual
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.all(3),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Padecimiento actual:',
                  style: pw.TextStyle(fontSize: 6),
                ),
                pw.SizedBox(height: 2),
                pw.Text(currentCondition, style: pw.TextStyle(fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build current condition section
  pw.Widget _buildCurrentConditionSection(ClinicalDisplayData clinical) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Padecimiento Actual:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(
          width: double.infinity,
          height: 30,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              clinical.currentCondition,
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }

  // Build pathological history section
  pw.Widget _buildPathologicalHistorySection(ClinicalDisplayData clinical) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ANTECEDENTES PATOLÓGICOS:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _buildCheckboxOption(
              'Respiratoria',
              clinical.accidentTypes['respiratoria'] == true,
            ),
            _buildCheckboxOption(
              'Emocional',
              clinical.accidentTypes['emocional'] == true,
            ),
            _buildCheckboxOption('Sistémica', false),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption(
              'Cardiovascular',
              clinical.accidentTypes['cardiovascular'] == true,
            ),
            _buildCheckboxOption(
              'Neurológica',
              clinical.accidentTypes['neurologica'] == true,
            ),
            _buildCheckboxOption(
              'Alérgico',
              clinical.accidentTypes['alergico'] == true,
            ),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption(
              'Metabólica',
              clinical.accidentTypes['metabolica'] == true,
            ),
            _buildCheckboxOption(
              'Otra',
              clinical.accidentTypes['otro'] == true,
            ),
            pw.Expanded(
              child: pw.Text('Especifique:', style: pw.TextStyle(fontSize: 8)),
            ),
          ],
        ),
      ],
    );
  }

  // Build clinical history section
  pw.Widget _buildClinicalHistorySection(ClinicalDisplayData clinical) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          // Header similar to patient info
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Center(
              child: pw.Text(
                'ANTECEDENTES CLÍNICOS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          // Tipo y Agente Causal (nuevo layout)
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Columna "Tipo"
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('A) Tipo:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        if (clinical.accidentTypes['atropellado'] == true)
                          pw.Text(
                            'Atropellado',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        if (clinical.accidentTypes['lxPorCaida'] == true)
                          pw.Text(
                            'Lx. Por caída',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        if (clinical.accidentTypes['intoxicacion'] == true)
                          pw.Text(
                            'Intoxicación',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        if (clinical.accidentTypes['amputacion'] == true)
                          pw.Text(
                            'Amputación',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        if (clinical.accidentTypes['choque'] == true)
                          pw.Text('Choque', style: pw.TextStyle(fontSize: 8)),
                        if (clinical.accidentTypes['agresion'] == true)
                          pw.Text('Agresión', style: pw.TextStyle(fontSize: 8)),
                        if (clinical.accidentTypes['hpab'] == true)
                          pw.Text('H.P.A.B.', style: pw.TextStyle(fontSize: 8)),
                        if (clinical.accidentTypes['hpaf'] == true)
                          pw.Text('H.P.A.F.', style: pw.TextStyle(fontSize: 8)),
                        if (clinical.accidentTypes['volcadura'] == true)
                          pw.Text(
                            'Volcadura',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        if (clinical.accidentTypes['quemadura'] == true)
                          pw.Text(
                            'Quemadura',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        if (clinical.accidentTypes['otroTipo'] == true)
                          pw.Row(
                            children: [
                              pw.Text('Otro', style: pw.TextStyle(fontSize: 8)),
                              pw.SizedBox(width: 4),
                              pw.Text(
                                'Especifique:',
                                style: pw.TextStyle(fontSize: 8),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                // Columna "Agente causal"
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'B) Agente causal:',
                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Container(
                          width: double.infinity,
                          height: 20,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                color: PdfColors.black,
                                width: 1,
                              ),
                            ),
                          ),
                          child: pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              clinical.agenteCausal,
                              style: pw.TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            'Cinemática:',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          pw.Container(
            width: double.infinity,
            height: 20,
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Text(
              clinical.cinematica,
              style: pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Medida de seguridad:',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          pw.Container(
            width: double.infinity,
            height: 20,
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Text(
              clinical.medidaSeguridad,
              style: pw.TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  // Build physical examination section
  pw.Widget _buildPhysicalExamSection(VitalSignsDisplayData vitalSigns) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EXPLORACIÓN FÍSICA:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 5),
        // Usar tabla dinámica basada en timeColumns y vitalSignsData
        _buildDynamicVitalSignsTable(vitalSigns),
      ],
    );
  }

  // Build vital sign row
  pw.Widget _buildVitalSignRow(
    String vitalSign,
    VitalSignsDisplayData vitalSigns,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(3),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              ),
              child: pw.Text(vitalSign, style: _labelStyle),
            ),
          ),
          _buildTimeGridCell(
            'N/A',
            false,
          ), // Obsolete method - replaced by dynamic table
          _buildTimeGridCell('', false),
          _buildTimeGridCell('', false),
        ],
      ),
    );
  }

  // Build injury location section (sync version)
  pw.Widget _buildInjuryLocationSectionSync(
    UnifiedFrapRecord record,
    pw.MemoryImage? silhouetteImage,
    pw.MemoryImage? combinedImage,
  ) {
    final injuryLocation =
        record.getDetailedInfo()['injuryLocation'] as Map<String, dynamic>?;
    final drawnInjuries = injuryLocation?['drawnInjuries'] as List<dynamic>?;
    final notes = injuryLocation?['notes'] as String?;

    // Calcular tamaño de imagen combinada
    double targetHeight = 120.0;
    double originalWidth = 436.0;
    double originalHeight = 845.8;
    if (injuryLocation != null && injuryLocation['originalImageSize'] != null) {
      final size = injuryLocation['originalImageSize'];
      originalWidth = size['width']?.toDouble() ?? originalWidth;
      originalHeight = size['height']?.toDouble() ?? originalHeight;
    }
    double aspectRatio = originalWidth / originalHeight;
    double targetWidth = targetHeight * aspectRatio;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: targetHeight,
          width: targetWidth,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child:
              combinedImage != null
                  ? pw.Image(
                    combinedImage,
                    width: targetWidth,
                    height: targetHeight,
                    fit: pw.BoxFit.contain,
                  )
                  : pw.Text('Sin imagen de lesiones'),
        ),
        if (notes != null && notes.trim().isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text('Notas: $notes', style: _valueStyle),
          ),
      ],
    );
  }

  // Construir imagen combinada con silueta y lesiones
  Future<pw.MemoryImage> _createCombinedSilhouetteImage(
    String silhouettePath,
    List<dynamic> drawnInjuries, {
    Map<String, dynamic>? injuryLocationMap,
  }) async {
    // 1. Obtener tamaño original de la silueta
    double width = 436.0;
    double height = 845.8;
    if (injuryLocationMap != null &&
        injuryLocationMap['originalImageSize'] != null) {
      width =
          (injuryLocationMap['originalImageSize']['width'] as num?)
              ?.toDouble() ??
          436.0;
      height =
          (injuryLocationMap['originalImageSize']['height'] as num?)
              ?.toDouble() ??
          845.8;
    }

    // 2. Cargar imagen de silueta
    final silhouetteBytes = await rootBundle.load(silhouettePath);
    final codec = await ui.instantiateImageCodec(
      silhouetteBytes.buffer.asUint8List(),
    );
    final frame = await codec.getNextFrame();
    final silhouetteImage = frame.image;

    // 3. Crear canvas del tamaño original
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 4. Dibujar silueta como fondo
    final dstRect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawImageRect(
      silhouetteImage,
      Rect.fromLTWH(
        0,
        0,
        silhouetteImage.width.toDouble(),
        silhouetteImage.height.toDouble(),
      ),
      dstRect,
      Paint(),
    );

    // 5. Dibujar los puntos en coordenadas originales
    for (final injury in drawnInjuries) {
      final points = injury['points'] as List<dynamic>? ?? [];
      final injuryType = injury['injuryType'] as int? ?? 0;
      final color = _getInjuryTypeFlutterColor(injuryType);
      for (final point in points) {
        final dx = (point['dx'] as num?)?.toDouble() ?? 0.0;
        final dy = (point['dy'] as num?)?.toDouble() ?? 0.0;
        canvas.drawCircle(Offset(dx, dy), 8, Paint()..color = color);
      }
    }

    // 6. Convertir a imagen
    final picture = recorder.endRecording();
    final combinedImage = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await combinedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return pw.MemoryImage(byteData!.buffer.asUint8List());
  }

  // Obtener color Flutter para tipo de lesión
  Color _getInjuryTypeFlutterColor(int injuryType) {
    switch (injuryType) {
      case 0:
        return Colors.red; // Hemorragia
      case 1:
        return Colors.orange; // Herida
      case 2:
        return Colors.purple; // Contusión
      case 3:
        return Colors.brown; // Fractura
      case 4:
        return Colors.blue; // Luxación/Esguince
      case 5:
        return Colors.yellow; // Objeto extraño
      case 6:
        return Colors.green; // Quemadura
      case 7:
        return Colors.pink; // Amputación
      case 8:
        return Colors.cyan; // Otra
      case 9:
        return Colors.grey; // Sin clasificar
      default:
        return Colors.red;
    }
  }

  // Construir leyenda de tipos de lesiones
  pw.Widget _buildInjuryLegend() {
    final injuryTypes = [
      '1. Hemorragia',
      '2. Herida',
      '3. Contusión',
      '4. Fractura',
      '5. Luxación/Esguince',
      '6. Objeto extraño',
      '7. Quemadura',
      '8. Picadura/Mordedura',
      '9. Edema/Hematoma',
      '10. Otro',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children:
          injuryTypes
              .map(
                (type) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 1),
                  child: pw.Text(
                    type,
                    style: pw.TextStyle(fontSize: 6, color: PdfColors.black),
                  ),
                ),
              )
              .toList(),
    );
  }

  // Obtener nombre del tipo de lesión
  String _getInjuryTypeName(int injuryType) {
    switch (injuryType) {
      case 0:
        return 'Hemorragia';
      case 1:
        return 'Herida';
      case 2:
        return 'Contusión';
      case 3:
        return 'Fractura';
      case 4:
        return 'Luxación/Esguince';
      case 5:
        return 'Objeto extraño';
      case 6:
        return 'Quemadura';
      case 7:
        return 'Picadura/Mordedura';
      case 8:
        return 'Edema/Hematoma';
      case 9:
        return 'Otro';
      default:
        return 'Desconocido';
    }
  }

  // Build management section
  pw.Widget _buildManagementSection(ManagementDisplayData management) {
    // Lista de opciones y sus claves en el mapa
    final options = [
      {'label': 'Vía aérea', 'key': 'viaAerea'},
      {'label': 'Canalización', 'key': 'canalizacion'},
      {'label': 'Empaquetamiento', 'key': 'empaquetamiento'},
      {'label': 'Inmovilización', 'key': 'inmovilizacion'},
      {'label': 'Monitor', 'key': 'monitor'},
      {'label': 'RCP Básica', 'key': 'rcpBasica'},
      {'label': 'MAST O PNA', 'key': 'mastPna'},
      {'label': 'Collarín Cervical', 'key': 'collarinCervical'},
      {'label': 'Desfibrilación', 'key': 'desfibrilacion'},
      {'label': 'Apoyo Vent.', 'key': 'apoyoVent'},
      {'label': 'Oxígeno', 'key': 'oxigeno'},
    ];

    // Filtrar solo las opciones seleccionadas
    final selectedOptions =
        options.where((opt) {
          final key = opt['key']!;
          return management.procedures[key] == 'Sí';
        }).toList();

    // Construir celdas para cada opción seleccionada
    final selectedCells = <pw.Widget>[];
    for (var opt in selectedOptions) {
      if (opt['key'] == 'oxigeno') {
        selectedCells.add(
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600, width: 0.5),
              color: PdfColors.white,
            ),
            child: pw.Row(
              children: [
                _buildCheckboxOption(opt['label']!, true),
                pw.SizedBox(width: 6),
                pw.Text(
                  'Lt/min: ${management.oxigenoLitros}',
                  style: pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          ),
        );
      } else {
        selectedCells.add(
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600, width: 0.5),
              color: PdfColors.white,
            ),
            child: _buildCheckboxOption(opt['label']!, true),
          ),
        );
      }
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Text(
              'MANEJO',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child:
                selectedCells.isNotEmpty
                    ? pw.Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: selectedCells,
                    )
                    : pw.Text(
                      'No se seleccionó ningún procedimiento.',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey700,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  // Build medications section
  pw.Widget _buildMedicationsSection(ManagementDisplayData management) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'MEDICAMENTOS:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: double.infinity,
          height: 30,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              management.medicamentos,
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }

  // Build gynecological-obstetric section with patient info style layout
  pw.Widget _buildGynecoObstetricSection(
    GynecoObstetricDisplayData gynecoObstetric,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            ),
            child: pw.Center(
              child: pw.Text(
                'URGENCIAS GINECO-OBSTÉTRICAS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),

          // Primera fila: Parto | Aborto | Hx. Vaginal
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Row(
                      children: [
                        _buildCheckboxOption('Parto', false),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption('Aborto', false),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption('Hx. Vaginal', false),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Segunda fila: FUM | Semanas de Gestación
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                // FUM
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('F.U.M.:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          gynecoObstetric.fum,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Semanas de Gestación
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Semanas de Gestación:',
                          style: pw.TextStyle(fontSize: 6),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          gynecoObstetric.semanasGestacion,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tercera fila: Ruidos Cardiacos Fetales (checkboxes)
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Row(
                      children: [
                        pw.Text(
                          'Ruidos Cardiacos Fetales:',
                          style: pw.TextStyle(fontSize: 6),
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Perceptible',
                          gynecoObstetric.ruidosCardiacosFetales == true,
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'No Perceptible',
                          gynecoObstetric.ruidosCardiacosFetales == false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cuarta fila: Expulsión de Placenta (checkboxes)
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Row(
                      children: [
                        pw.Text(
                          'Expulsión de Placenta:',
                          style: pw.TextStyle(fontSize: 6),
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Sí',
                          gynecoObstetric.expulsionPlacenta == true,
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'No',
                          gynecoObstetric.expulsionPlacenta == false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quinta fila: Gesta | Partos
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                // Gesta
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Gesta:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          gynecoObstetric.gesta,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Partos
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Partos:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          gynecoObstetric.partos,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sexta fila: Cesáreas | Hora
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
              ),
            ),
            child: pw.Row(
              children: [
                // Cesáreas
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Cesáreas:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          gynecoObstetric.cesareas,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Hora
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Hora:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          gynecoObstetric.hora,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Séptima fila: Abortos | Método Anticonceptivo
          pw.Container(
            child: pw.Row(
              children: [
                // Abortos
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Abortos:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          gynecoObstetric.abortos,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Método Anticonceptivo
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Método Anticonceptivo:',
                          style: pw.TextStyle(fontSize: 6),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          gynecoObstetric.metodosAnticonceptivos,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build refusal of care section
  pw.Widget _buildRefusalOfCareSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'NEGATIVA DE ATENCIÓN:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          child: pw.Text(
            'Me he negado a recibir atención médica y a ser trasladado por los paramédicos de Ambulancias BgMed, habiéndoseme informado de los riesgos que conlleva mi decisión.',
            style: pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.justify,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Firma Paciente:',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                      ),
                    ),
                    child:
                        _getImageFromBase64(
                                  _getAttentionNegative(
                                    record,
                                    'patientSignature',
                                  ),
                                ) !=
                                null
                            ? pw.Image(
                              _getImageFromBase64(
                                _getAttentionNegative(
                                  record,
                                  'patientSignature',
                                ),
                              )!,
                            )
                            : pw.Container(),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Testigo:',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                      ),
                    ),
                    child:
                        _getImageFromBase64(
                                  _getAttentionNegative(
                                    record,
                                    'witnessSignature',
                                  ),
                                ) !=
                                null
                            ? pw.Image(
                              _getImageFromBase64(
                                _getAttentionNegative(
                                  record,
                                  'witnessSignature',
                                ),
                              )!,
                            )
                            : pw.Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build priority justification section with
  pw.Widget _buildPriorityJustificationSection(PriorityDisplayData priority) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('JUSTIFICACIÓN DE PRIORIDAD', style: _sectionTitleStyle),
          pw.SizedBox(height: 5),
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: PdfColors.grey,
                width: 0.5,
              ),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(8),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text('Prioridad:', style: _labelStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        _buildCheckboxOption(
                          'Rojo',
                          priority.priority == 'Rojo',
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Amarillo',
                          priority.priority == 'Amarillo',
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Verde',
                          priority.priority == 'Verde',
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Negro',
                          priority.priority == 'Negro',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text('Pupilas:', style: _labelStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Wrap(
                      spacing: 5,
                      runSpacing: 2,
                      children: [
                        _buildCheckboxOption(
                          'Iguales',
                          priority.pupils == 'Iguales',
                        ),
                        _buildCheckboxOption(
                          'Midriasis',
                          priority.pupils == 'Midriasis',
                        ),
                        _buildCheckboxOption(
                          'Miosis',
                          priority.pupils == 'Miosis',
                        ),
                        _buildCheckboxOption(
                          'Anisocoria',
                          priority.pupils == 'Anisocoria',
                        ),
                        _buildCheckboxOption(
                          'Arreflexia',
                          priority.pupils == 'Arreflexia',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text('Color Piel:', style: _labelStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Wrap(
                      spacing: 5,
                      runSpacing: 2,
                      children: [
                        _buildCheckboxOption(
                          'Normal',
                          priority.skinColor == 'Normal',
                        ),
                        _buildCheckboxOption(
                          'Cianosis',
                          priority.skinColor == 'Cianosis',
                        ),
                        _buildCheckboxOption(
                          'Marmórea',
                          priority.skinColor == 'Marmórea',
                        ),
                        _buildCheckboxOption(
                          'Pálida',
                          priority.skinColor == 'Pálida',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text('Piel:', style: _labelStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        _buildCheckboxOption('Seca', priority.skin == 'Seca'),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Húmeda',
                          priority.skin == 'Húmeda',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text('Temperatura:', style: _labelStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        _buildCheckboxOption(
                          'Normal',
                          priority.temperature == 'Normal',
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Caliente',
                          priority.temperature == 'Caliente',
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Fría',
                          priority.temperature == 'Fría',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text('Influenciado por:', style: _labelStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        _buildCheckboxOption(
                          'Alcohol',
                          priority.influence == 'Alcohol',
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Otras drogas',
                          priority.influence == 'Otras drogas',
                        ),
                        pw.SizedBox(width: 5),
                        _buildCheckboxOption(
                          'Otro',
                          priority.influence == 'Otro',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text('Especifique:', style: _labelStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Container(
                      height: 15,
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: PdfColors.black,
                            width: 1,
                          ),
                        ),
                      ),
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(priority.especifique, style: _valueStyle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build receiving unit section
  pw.Widget _buildReceivingUnitSection(ReceptionDisplayData reception) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('UNIDAD MÉDICA QUE RECIBE', style: _sectionTitleStyle),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('Lugar de origen:', style: _labelStyle),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Container(
                  height: 15,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                    ),
                  ),
                  child: pw.Text(reception.originPlace, style: _valueStyle),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('Lugar de consulta:', style: _labelStyle),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Container(
                  height: 15,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                    ),
                  ),
                  child: pw.Text(reception.consultPlace, style: _valueStyle),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('Lugar de destino:', style: _labelStyle),
              pw.SizedBox(width: 5),
              pw.Expanded(
                child: pw.Container(
                  height: 15,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                    ),
                  ),
                  child: pw.Text(
                    reception.destinationPlace,
                    style: _valueStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build ambulance section
  pw.Widget _buildAmbulanceSection(AmbulanceDisplayData ambulance) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('AMBULANCIA', style: _sectionTitleStyle),
          pw.SizedBox(height: 5),
          pw.Text('Número: ${ambulance.numeroAmbulancia}', style: _valueStyle),
          pw.Text('Tipo: ${ambulance.tipoAmbulancia}', style: _valueStyle),
          pw.Text(
            'Personal a bordo: ${ambulance.personalABordo}',
            style: _valueStyle,
          ),
          pw.Text(
            'Equipamiento: ${ambulance.equipamiento}',
            style: _valueStyle,
          ),
          if (ambulance.observaciones != 'N/A')
            pw.Text(
              'Observaciones: ${ambulance.observaciones}',
              style: _valueStyle,
            ),
        ],
      ),
    );
  }

  // Build patient reception section
  pw.Widget _buildPatientReceptionSection(ReceptionDisplayData reception) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RECEPCIÓN DEL PACIENTE',
                      style: _sectionTitleStyle,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Médico que recibe:', style: _valueStyle),
                    pw.SizedBox(height: 5),
                    pw.Text(reception.receivingDoctor, style: _valueStyle),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Container(
                width: 120,
                height: 40,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child:
                    _getImageFromBase64(reception.doctorSignature) != null
                        ? pw.Image(
                          _getImageFromBase64(reception.doctorSignature)!,
                        )
                        : pw.Center(
                          child: pw.Text(
                            'Firma no disponible',
                            style: _valueStyle,
                          ),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Saves the PDF to a file and returns the file path
  Future<String> savePdfToFile(UnifiedFrapRecord record) async {
    final pdfBytes = await generateFrapPdf(record);
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'FRAP_${record.patientName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  /// Shares the PDF file
  Future<void> sharePdf(UnifiedFrapRecord record) async {
    try {
      final filePath = await savePdfToFile(record);
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Registro de Atención Prehospitalaria - ${record.patientName}');
    } catch (e) {
      throw Exception('Error al compartir el PDF: $e');
    }
  }

  /// Prints the PDF
  Future<void> printPdf(UnifiedFrapRecord record) async {
    try {
      final pdfBytes = await generateFrapPdf(record);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Registro de Atención Prehospitalaria - ${record.patientName}',
      );
    } catch (e) {
      throw Exception('Error al imprimir el PDF: $e');
    }
  }

  // Método para construir tabla de signos vitales dinámicos
  pw.Widget _buildDynamicVitalSignsTable(VitalSignsDisplayData vitalSigns) {
    final timeColumns =
        vitalSigns.timeColumns.take(3).toList(); // Limit to 3 columns
    const vitalSignLabels = [
      'T/A',
      'FC',
      'FR',
      'Temp.',
      'Sat. O2',
      'LLC',
      'Glu',
      'Glasgow',
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Container(
              height: 20,
              child: pw.Center(
                child: pw.Text('Signo Vital', style: _labelStyle),
              ),
            ),
            ...timeColumns.map(
              (time) => pw.Container(
                height: 20,
                child: pw.Center(child: pw.Text(time, style: _labelStyle)),
              ),
            ),
          ],
        ),
        // Data rows
        ...vitalSignLabels.map((vitalSign) {
          final data = vitalSigns.vitalSigns[vitalSign] ?? {};
          return pw.TableRow(
            children: [
              pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(2),
                child: pw.Center(child: pw.Text(vitalSign, style: _valueStyle)),
              ),
              ...timeColumns.map(
                (time) => pw.Container(
                  height: 20,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Center(
                    child: pw.Text(data[time] ?? '', style: _valueStyle),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // Build unified display data from UnifiedFrapRecord
  FrapPdfDisplayData _buildDisplayData(UnifiedFrapRecord record) {
    final detailedInfo = record.getDetailedInfo(); // Cache this expensive call

    return FrapPdfDisplayData(
      patient: _buildPatientDisplayData(record, detailedInfo),
      service: _buildServiceDisplayData(record, detailedInfo),
      vitalSigns: _buildVitalSignsDisplayData(record, detailedInfo),
      sample: _buildSampleDisplayData(record, detailedInfo),
      clinical: _buildClinicalDisplayData(record, detailedInfo),
      management: _buildManagementDisplayData(record, detailedInfo),
      ambulance: _buildAmbulanceDisplayData(record, detailedInfo),
      gynecoObstetric: _buildGynecoObstetricDisplayData(record, detailedInfo),
      priority: _buildPriorityDisplayData(record, detailedInfo),
      registry: _buildRegistryDisplayData(record, detailedInfo),
      reception: _buildReceptionDisplayData(record, detailedInfo),
      consentimientoServicio: _getConsentimientoServicio(record),
      insumos: _buildInsumosDisplayData(record),
    );
  }

  PatientDisplayData _buildPatientDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    _log('Building patient display data...');
    _log('Record has localRecord: ${record.localRecord != null}');
    _log('Patient name: ${record.patientName}');
    _log('Patient age: ${record.patientAge}');
    _log('Patient gender: ${record.patientGender}');

    if (record.localRecord != null) {
      final patient = record.localRecord!.patient;
      _log('Using local patient data');
      _log('Patient firstName: ${patient.firstName}');
      _log('Patient paternalLastName: ${patient.paternalLastName}');
      _log('Patient sex: ${patient.sex}');
      _log('Patient gender: ${patient.gender}');
      _log('Patient address: ${patient.address}');
      return PatientDisplayData(
        fullName:
            '${patient.firstName} ${patient.paternalLastName} ${patient.maternalLastName}',
        address: patient.address,
        age: patient.age.toString(),
        sex: (patient.sex.isNotEmpty ? patient.sex : patient.gender),
        gender: patient.gender,
        phone: patient.phone,
        insurance: patient.insurance,
        responsiblePerson: patient.responsiblePerson ?? 'N/A',
        emergencyContact: 'N/A', // Not available in Patient model
        addressDetails: patient.addressDetails,
        tipoEntrega: patient.tipoEntrega,
        currentCondition: patient.currentCondition ?? 'N/A',
      );
    } else {
      _log('Using cloud patient data');
      final patientInfo =
          detailedInfo['patientInfo'] as Map<String, dynamic>? ?? {};
      _log('Cloud patientInfo keys: ${patientInfo.keys.toList()}');

      return PatientDisplayData(
        fullName: record.patientName,
        address: record.patientAddress,
        age: record.patientAge.toString(),
        sex: patientInfo['sex']?.toString() ?? record.patientGender,
        gender: patientInfo['gender']?.toString() ?? 'N/A',
        phone: patientInfo['phone']?.toString() ?? 'N/A',
        insurance: patientInfo['insurance']?.toString() ?? 'N/A',
        responsiblePerson:
            patientInfo['responsiblePerson']?.toString() ?? 'N/A',
        emergencyContact: patientInfo['emergencyContact']?.toString() ?? 'N/A',
        addressDetails: patientInfo['addressDetails']?.toString() ?? 'N/A',
        tipoEntrega: patientInfo['tipoEntrega']?.toString() ?? 'N/A',
        currentCondition: patientInfo['currentCondition']?.toString() ?? 'N/A',
      );
    }
  }

  ServiceDisplayData _buildServiceDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    final serviceInfo =
        detailedInfo['serviceInfo'] as Map<String, dynamic>? ?? {};
    return ServiceDisplayData(
      ubicacion: serviceInfo['ubicacion']?.toString() ?? 'N/A',
      tipoServicio: serviceInfo['tipoServicio']?.toString() ?? 'N/A',
      tipoServicioEspecifique:
          serviceInfo['tipoServicioEspecifique']?.toString() ?? 'N/A',
      lugarOcurrencia: serviceInfo['lugarOcurrencia']?.toString() ?? 'N/A',
      lugarOcurrenciaEspecifique:
          serviceInfo['lugarOcurrenciaEspecifique']?.toString() ?? 'N/A',
      horaLlamada: serviceInfo['horaLlamada']?.toString() ?? 'N/A',
      horaArribo: serviceInfo['horaArribo']?.toString() ?? 'N/A',
      horaLlegada: serviceInfo['horaLlegada']?.toString() ?? 'N/A',
      horaTermino: serviceInfo['horaTermino']?.toString() ?? 'N/A',
      tiempoEsperaArribo:
          serviceInfo['tiempoEsperaArribo']?.toString() ?? 'N/A',
      tiempoEsperaLlegada:
          serviceInfo['tiempoEsperaLlegada']?.toString() ?? 'N/A',
      tiempoTotal: _calculateTotalTime(serviceInfo),
      currentCondition: serviceInfo['currentCondition']?.toString() ?? 'N/A',
    );
  }

  VitalSignsDisplayData _buildVitalSignsDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    List<String> timeColumns = [];
    Map<String, Map<String, String>> vitalSigns = {};

    if (record.localRecord != null) {
      final physicalExam = record.localRecord!.physicalExam;
      timeColumns = physicalExam.timeColumns;
      vitalSigns = physicalExam.vitalSignsData.map(
        (key, value) => MapEntry(key, value.map((k, v) => MapEntry(k, v))),
      );

      return VitalSignsDisplayData(
        timeColumns: timeColumns,
        vitalSigns: vitalSigns,
        eva: physicalExam.eva,
        llc: physicalExam.llc,
        glucosa: physicalExam.glucosa,
        ta: physicalExam.ta,
      );
    } else {
      final physicalExam =
          detailedInfo['physicalExam'] as Map<String, dynamic>? ?? {};
      final tc = physicalExam['timeColumns'];
      if (tc is List) {
        timeColumns = tc.map((e) => e.toString()).toList();
      }

      // Extract vital signs from cloud data
      const vitalSignKeys = [
        'T/A',
        'FC',
        'FR',
        'Temp.',
        'Sat. O2',
        'LLC',
        'Glu',
        'Glasgow',
      ];
      for (final key in vitalSignKeys) {
        final data = physicalExam[key];
        if (data is Map) {
          vitalSigns[key] = data.map(
            (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
          );
        }
      }

      return VitalSignsDisplayData(
        timeColumns: timeColumns,
        vitalSigns: vitalSigns,
        eva: physicalExam['eva']?.toString() ?? 'N/A',
        llc: physicalExam['llc']?.toString() ?? 'N/A',
        glucosa: physicalExam['glucosa']?.toString() ?? 'N/A',
        ta: physicalExam['ta']?.toString() ?? 'N/A',
      );
    }
  }

  SampleDisplayData _buildSampleDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    if (record.localRecord != null) {
      final physicalExam = record.localRecord!.physicalExam;
      return SampleDisplayData(
        alergias: physicalExam.sampleAlergias,
        medicamentos: physicalExam.sampleMedicamentos,
        enfermedades: physicalExam.sampleEnfermedades,
        horaAlimento: physicalExam.sampleHoraAlimento,
        eventosPrevios: physicalExam.sampleEventosPrevios,
      );
    } else {
      final physicalExam =
          detailedInfo['physicalExam'] as Map<String, dynamic>? ?? {};
      return SampleDisplayData(
        alergias: physicalExam['sampleAlergias']?.toString() ?? 'N/A',
        medicamentos: physicalExam['sampleMedicamentos']?.toString() ?? 'N/A',
        enfermedades: physicalExam['sampleEnfermedades']?.toString() ?? 'N/A',
        horaAlimento: physicalExam['sampleHoraAlimento']?.toString() ?? 'N/A',
        eventosPrevios:
            physicalExam['sampleEventosPrevios']?.toString() ?? 'N/A',
      );
    }
  }

  ClinicalDisplayData _buildClinicalDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    if (record.localRecord != null) {
      final clinicalHistory = record.localRecord!.clinicalHistory;
      return ClinicalDisplayData(
        currentCondition: clinicalHistory.currentSymptoms,
        allergies: clinicalHistory.allergies,
        medications: clinicalHistory.medications,
        previousIllnesses: clinicalHistory.previousIllnesses,
        previousSurgeries: clinicalHistory.previousSurgeries,
        hospitalizations: clinicalHistory.hospitalizations,
        transfusions: clinicalHistory.transfusions,
        accidentTypes: _extractAccidentTypes(detailedInfo),
        agenteCausal: _getFromClinicalHistory(detailedInfo, 'agenteCausal'),
        cinematica: _getFromClinicalHistory(detailedInfo, 'cinematica'),
        medidaSeguridad: _getFromClinicalHistory(
          detailedInfo,
          'medidaSeguridad',
        ),
      );
    } else {
      return ClinicalDisplayData(
        currentCondition: _getFromClinicalHistory(
          detailedInfo,
          'currentSymptoms',
        ),
        allergies: _getFromClinicalHistory(detailedInfo, 'allergies'),
        medications: _getFromClinicalHistory(detailedInfo, 'medications'),
        previousIllnesses: _getFromClinicalHistory(
          detailedInfo,
          'previousIllnesses',
        ),
        previousSurgeries: _getFromClinicalHistory(
          detailedInfo,
          'previousSurgeries',
        ),
        hospitalizations: _getFromClinicalHistory(
          detailedInfo,
          'hospitalizations',
        ),
        transfusions: _getFromClinicalHistory(detailedInfo, 'transfusions'),
        accidentTypes: _extractAccidentTypes(detailedInfo),
        agenteCausal: _getFromClinicalHistory(detailedInfo, 'agenteCausal'),
        cinematica: _getFromClinicalHistory(detailedInfo, 'cinematica'),
        medidaSeguridad: _getFromClinicalHistory(
          detailedInfo,
          'medidaSeguridad',
        ),
      );
    }
  }

  ManagementDisplayData _buildManagementDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    final management =
        detailedInfo['management'] as Map<String, dynamic>? ?? {};
    final insumos = _getInsumos(record);
    final personalMedico = _getPersonalMedico(record);

    return ManagementDisplayData(
      procedures: {
        'viaAerea': _boolToString(management['viaAerea']),
        'canalizacion': _boolToString(management['canalizacion']),
        'inmovilizacion': _boolToString(management['inmovilizacion']),
        'monitor': _boolToString(management['monitor']),
        'rcpBasica': _boolToString(management['rcpBasica']),
        'oxigeno': _boolToString(management['oxigeno']),
      },
      oxigenoLitros: management['ltMin']?.toString() ?? 'N/A',
      insumos: insumos,
      personalMedico: personalMedico,
      medicamentos:
          detailedInfo['medications']?['medications']?.toString() ?? 'N/A',
    );
  }

  AmbulanceDisplayData _buildAmbulanceDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    final ambulance = detailedInfo['ambulance'] as Map<String, dynamic>? ?? {};
    return AmbulanceDisplayData(
      numeroAmbulancia: ambulance['numero']?.toString() ?? 'N/A',
      tipoAmbulancia: ambulance['tipo']?.toString() ?? 'N/A',
      personalABordo: ambulance['personalABordo']?.toString() ?? 'N/A',
      equipamiento: ambulance['equipamiento']?.toString() ?? 'N/A',
      observaciones: ambulance['observaciones']?.toString() ?? 'N/A',
    );
  }

  GynecoObstetricDisplayData _buildGynecoObstetricDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    final gynecoObstetric =
        detailedInfo['gynecoObstetric'] as Map<String, dynamic>? ?? {};
    final escalas = _getEscalasObstetricas(record);

    return GynecoObstetricDisplayData(
      urgencia: gynecoObstetric['urgencia']?.toString() ?? 'N/A',
      fum: gynecoObstetric['fum']?.toString() ?? 'N/A',
      semanasGestacion:
          gynecoObstetric['semanasGestacion']?.toString() ?? 'N/A',
      gesta: gynecoObstetric['gesta']?.toString() ?? 'N/A',
      partos: gynecoObstetric['partos']?.toString() ?? 'N/A',
      cesareas: gynecoObstetric['cesareas']?.toString() ?? 'N/A',
      abortos: gynecoObstetric['abortos']?.toString() ?? 'N/A',
      hora: gynecoObstetric['hora']?.toString() ?? 'N/A',
      metodosAnticonceptivos:
          gynecoObstetric['metodosAnticonceptivos']?.toString() ?? 'N/A',
      ruidosCardiacosFetales: gynecoObstetric['ruidosCardiacosFetales'] == true,
      expulsionPlacenta: gynecoObstetric['expulsionPlacenta'] == true,
      escalasObstetricas: escalas,
    );
  }

  PriorityDisplayData _buildPriorityDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    final priority =
        detailedInfo['priorityJustification'] as Map<String, dynamic>? ?? {};
    return PriorityDisplayData(
      priority: priority['priority']?.toString() ?? 'N/A',
      pupils: priority['pupils']?.toString() ?? 'N/A',
      skinColor: priority['skinColor']?.toString() ?? 'N/A',
      skin: priority['skin']?.toString() ?? 'N/A',
      temperature: priority['temperature']?.toString() ?? 'N/A',
      influence: priority['influence']?.toString() ?? 'N/A',
      especifique: priority['especifique']?.toString() ?? 'N/A',
    );
  }

  RegistryDisplayData _buildRegistryDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    final registryInfo =
        detailedInfo['registryInfo'] as Map<String, dynamic>? ?? {};
    return RegistryDisplayData(
      convenio: registryInfo['convenio']?.toString() ?? 'N/A',
      episodio: registryInfo['episodio']?.toString() ?? 'N/A',
      solicitadoPor: registryInfo['solicitadoPor']?.toString() ?? 'N/A',
      folio: registryInfo['folio']?.toString() ?? 'N/A',
      fecha: (registryInfo['fecha']?.toString()?.split('T')?.first ?? 'N/A'),
    );
  }

  ReceptionDisplayData _buildReceptionDisplayData(
    UnifiedFrapRecord record,
    Map<String, dynamic> detailedInfo,
  ) {
    final reception =
        detailedInfo['patientReception'] as Map<String, dynamic>? ?? {};
    final receivingUnit =
        detailedInfo['receivingUnit'] as Map<String, dynamic>? ?? {};

    return ReceptionDisplayData(
      receivingDoctor: reception['receivingDoctor']?.toString() ?? 'N/A',
      doctorSignature: reception['doctorSignature']?.toString(),
      originPlace: receivingUnit['originPlace']?.toString() ?? 'N/A',
      consultPlace: receivingUnit['consultPlace']?.toString() ?? 'N/A',
      destinationPlace: receivingUnit['destinationPlace']?.toString() ?? 'N/A',
    );
  }

  InsumosDisplayData _buildInsumosDisplayData(UnifiedFrapRecord record) {
    if (record.localRecord != null) {
      return InsumosDisplayData(
        insumos:
            record.localRecord!.insumos
                .map(
                  (insumo) => {
                    'cantidad': insumo.cantidad,
                    'articulo': insumo.articulo,
                  },
                )
                .toList(),
      );
    }
    final insumosData =
        record.getDetailedInfo()['insumos'] as List<dynamic>? ?? [];
    return InsumosDisplayData(
      insumos: insumosData.map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  // Helper methods
  String _calculateTotalTime(Map<String, dynamic> serviceInfo) {
    // Simple calculation - could be enhanced
    final inicio = serviceInfo['horaLlamada']?.toString();
    final fin = serviceInfo['horaTermino']?.toString();
    if (inicio != null && fin != null && inicio != 'N/A' && fin != 'N/A') {
      return 'Calculado'; // Placeholder for actual time calculation
    }
    return 'N/A';
  }

  Map<String, bool> _extractAccidentTypes(Map<String, dynamic> detailedInfo) {
    final clinicalHistory =
        detailedInfo['clinicalHistory'] as Map<String, dynamic>? ?? {};
    return {
      'atropellado':
          clinicalHistory['atropellado'] == true ||
          clinicalHistory['atropellado'] == 'Sí',
      'lxPorCaida':
          clinicalHistory['lxPorCaida'] == true ||
          clinicalHistory['lxPorCaida'] == 'Sí',
      'intoxicacion':
          clinicalHistory['intoxicacion'] == true ||
          clinicalHistory['intoxicacion'] == 'Sí',
      'amputacion':
          clinicalHistory['amputacion'] == true ||
          clinicalHistory['amputacion'] == 'Sí',
      'choque':
          clinicalHistory['choque'] == true ||
          clinicalHistory['choque'] == 'Sí',
      'agresion':
          clinicalHistory['agresion'] == true ||
          clinicalHistory['agresion'] == 'Sí',
      'hpab':
          clinicalHistory['hpab'] == true || clinicalHistory['hpab'] == 'Sí',
      'hpaf':
          clinicalHistory['hpaf'] == true || clinicalHistory['hpaf'] == 'Sí',
      'volcadura':
          clinicalHistory['volcadura'] == true ||
          clinicalHistory['volcadura'] == 'Sí',
      'quemadura':
          clinicalHistory['quemadura'] == true ||
          clinicalHistory['quemadura'] == 'Sí',
      'otroTipo':
          clinicalHistory['otroTipo'] == true ||
          clinicalHistory['otroTipo'] == 'Sí',
    };
  }

  String _getFromClinicalHistory(
    Map<String, dynamic> detailedInfo,
    String key,
  ) {
    final clinicalHistory =
        detailedInfo['clinicalHistory'] as Map<String, dynamic>? ?? {};
    final value = clinicalHistory[key];
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    return value?.toString() ?? 'N/A';
  }

  String _boolToString(dynamic value) {
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    return value?.toString() ?? 'N/A';
  }

  // Missing section builders - adding these new methods
  pw.Widget _buildConsentimientoSection(String signatureData) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CONSENTIMIENTO DE SERVICIO',
                      style: _sectionTitleStyle,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'He recibido atención médica prehospitalaria y autorizo el traslado a la unidad médica correspondiente.',
                      style: _valueStyle,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Container(
                width: 120,
                height: 40,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child:
                    _getImageFromBase64(signatureData) != null
                        ? pw.Image(_getImageFromBase64(signatureData)!)
                        : pw.Center(
                          child: pw.Text(
                            'Firma no disponible',
                            style: _valueStyle,
                          ),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSampleSection(SampleDisplayData sample) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('EVALUACIÓN SAMPLE', style: _sectionTitleStyle),
          pw.SizedBox(height: 5),
          pw.Text(
            'S - Signos y síntomas: ${sample.alergias}',
            style: _valueStyle,
          ),
          pw.Text('A - Alergias: ${sample.alergias}', style: _valueStyle),
          pw.Text(
            'M - Medicamentos: ${sample.medicamentos}',
            style: _valueStyle,
          ),
          pw.Text(
            'P - Historia médica previa: ${sample.enfermedades}',
            style: _valueStyle,
          ),
          pw.Text(
            'L - Última ingesta oral: ${sample.horaAlimento}',
            style: _valueStyle,
          ),
          pw.Text(
            'E - Eventos previos: ${sample.eventosPrevios}',
            style: _valueStyle,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEvaSection(VitalSignsDisplayData vitalSigns) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(3),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ESCALA EVA (DOLOR)', style: _sectionTitleStyle),
          pw.SizedBox(height: 3),
          pw.Text('Nivel de dolor: ${vitalSigns.eva}/10', style: _valueStyle),
          pw.Text('LLC: ${vitalSigns.llc} segundos', style: _valueStyle),
          pw.Text('Glucosa: ${vitalSigns.glucosa} mg/dl', style: _valueStyle),
          pw.Text('T/A: ${vitalSigns.ta} mm/Hg', style: _valueStyle),
        ],
      ),
    );
  }

  pw.Widget _buildEscalasObstetricasSection(Map<String, dynamic> escalas) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ESCALAS OBSTÉTRICAS', style: _sectionTitleStyle),
          pw.SizedBox(height: 5),
          pw.Text(
            'Frecuencia cardíaca fetal: ${escalas['frecuenciaCardiacaFetal'] ?? 'N/A'} lpm',
            style: _valueStyle,
          ),
          pw.Text(
            'Contracciones: ${escalas['contracciones'] ?? 'N/A'}',
            style: _valueStyle,
          ),
          if (escalas['silvermanAnderson'] != null &&
              (escalas['silvermanAnderson'] as Map).isNotEmpty)
            pw.Text(
              'Silverman-Anderson: ${escalas['silvermanAnderson']}',
              style: _valueStyle,
            ),
          if (escalas['apgar'] != null && (escalas['apgar'] as Map).isNotEmpty)
            pw.Text('Apgar: ${escalas['apgar']}', style: _valueStyle),
        ],
      ),
    );
  }

  pw.Widget _buildInsumosSection(List<Map<String, dynamic>> insumos) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('INSUMOS UTILIZADOS', style: _sectionTitleStyle),
          pw.SizedBox(height: 4),
          ...insumos.map(
            (insumo) => pw.Text(
              '• ${insumo['cantidad']} ${insumo['articulo']}',
              style: _valueStyle,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPersonalMedicoSection(List<Map<String, dynamic>> personal) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('PERSONAL MÉDICO', style: _sectionTitleStyle),
          pw.SizedBox(height: 4),
          ...personal.map(
            (p) => pw.Text(
              '• ${p['nombre']} - ${p['especialidad']} (${p['cedula']})',
              style: _valueStyle,
            ),
          ),
        ],
      ),
    );
  }

  // Build basic service info section (added to satisfy call site)
  pw.Widget _buildServiceInfoSection(ServiceDisplayData service) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          // row
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.1),
              ),
            ),
            child: pw.Row(
              children: [
                // Lugar de ocurrencia
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Lugar de ocurrencia:',
                          style: pw.TextStyle(fontSize: 6),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          (service.lugarOcurrencia.isEmpty ||
                                  service.lugarOcurrencia == 'Otro')
                              ? service.lugarOcurrenciaEspecifique
                              : service.lugarOcurrencia,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Ubicación
                pw.Expanded(
                  flex: 4,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Ubicacion:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          service.ubicacion,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tipo de servicio
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Tipo:', style: pw.TextStyle(fontSize: 6)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          service.tipoServicio,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Especifique
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Especifique:',
                          style: pw.TextStyle(fontSize: 6),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          service.tipoServicioEspecifique,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLabeledCell(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(label, style: _labelStyle),
              pw.SizedBox(width: 2),
              pw.Text(value, style: pw.TextStyle(fontSize: 6)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAdminDetailsTable(RegistryDisplayData registry) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1),
      children: [
        pw.TableRow(
          children: [
            _buildLabeledCell('Convenio', ''),
            _buildLabeledCell('Episodio', ''),
            _buildLabeledCell('Solicitado por', ''),
            _buildLabeledCell('Folio', ''),
            _buildLabeledCell('Fecha', ''),
          ],
        ),
        pw.TableRow(
          children: [
            _buildLabeledCell('', registry.convenio),
            _buildLabeledCell('', registry.episodio),
            _buildLabeledCell('', registry.solicitadoPor),
            _buildLabeledCell('', registry.folio),
            _buildLabeledCell('', registry.fecha),
          ],
        ),
      ],
    );
  }
}
