import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:bg_med/core/services/frap_unified_service.dart';
import 'package:intl/intl.dart';

import '../../features/frap/presentation/providers/frap_unified_provider.dart';

class PdfGeneratorService {
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
  ///
  /// The PDF structure mimics the provided image layout, with two columns
  /// and various sections organized as shown in the reference.
  Future<Uint8List> generateFrapPdf(UnifiedFrapRecord record) async {
    final pdf = pw.Document(
      title: 'Registro de Atención Prehospitalaria',
      author: 'BG Med',
    );

    // Define text styles for consistency
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueGrey800,
    );

    final labelStyle = pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey800,
    );

    final valueStyle = pw.TextStyle(
      fontSize: 8,
      color: PdfColors.grey700,
    );

    // Helper to create a section container
    pw.Widget _buildSection(String title, pw.Widget content, {bool isLeftColumn = true}) {
      final backgroundColor = PdfColors.white;
      
      return pw.Container(
        padding: const pw.EdgeInsets.all(4),
        margin: const pw.EdgeInsets.only(bottom: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          borderRadius: pw.BorderRadius.circular(4),
          color: backgroundColor,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('$title', style: sectionTitleStyle),
            pw.SizedBox(height: 3),
            content,
          ],
        ),
      );
    }

    // Helper to build signature display
    pw.Widget _buildSignatureDisplay(String? signatureData, String label) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$label:', style: labelStyle),
          pw.SizedBox(height: 3),
          pw.Container(
            height: 40,
            width: 120,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: _getImageFromBase64(signatureData) != null
                ? pw.Image(_getImageFromBase64(signatureData)!)
                : pw.Center(child: pw.Text('Firma no disponible', style: valueStyle)),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter.copyWith(
          marginTop: 0.2 * PdfPageFormat.inch,
          marginBottom: 0.2 * PdfPageFormat.inch,
          marginLeft: 0.3 * PdfPageFormat.inch,
          marginRight: 0.3 * PdfPageFormat.inch,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title of the document
              pw.Center(
                child: pw.Text(
                  'REGISTRO DE ATENCIÓN PREHOSPITALARIA',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Administrative details at top right
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildAdminDetail('Convenio:', _getRegistryInfo(record, 'convenio')),
                      _buildAdminDetail('Episodio:', _getRegistryInfo(record, 'episodio')),
                      _buildAdminDetail('Solicitado por:', _getRegistryInfo(record, 'solicitadoPor')),
                      _buildAdminDetail('Folio:', _getRegistryInfo(record, 'folio')),
                      _buildAdminDetail('Fecha:', _getRegistryInfo(record, 'fecha')),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              
              // Main content in two columns
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Column
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Location and Service Type
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('UBICACIÓN Y TIPO DE SERVICIO', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('Ubicación: ${_getServiceInfo(record, 'ubicacion')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Tipo de servicio: ${_getServiceInfo(record, 'tipoServicio')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Especifique: ${_getServiceInfo(record, 'tipoServicioEspecifique')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Place of Occurrence
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('LUGAR DE OCURRENCIA', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('Lugar: ${_getServiceInfo(record, 'lugarOcurrencia')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Patient Information
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('INFORMACIÓN DEL PACIENTE', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('Nombre: ${record.patientName}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Edad: ${record.patientAge} años', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Sexo: ${record.patientGender}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Dirección: ${record.patientAddress}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Teléfono: ${_getPatientInfo(record, 'phone')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Seguro: ${_getPatientInfo(record, 'insurance')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Current Condition
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('PADECIMIENTO ACTUAL', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text(_getPatientInfo(record, 'currentCondition'), style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Pathological History
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('ANTECEDENTES PATOLÓGICOS', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('Respiratoria: ${_getPathologicalHistory(record, 'respiratoria')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Cardiovascular: ${_getPathologicalHistory(record, 'cardiovascular')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Neurológica: ${_getPathologicalHistory(record, 'neurologica')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Alérgico: ${_getPathologicalHistory(record, 'alergico')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Clinical History
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('ANTECEDENTES CLÍNICOS', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('Atropellado: ${_getClinicalHistory(record, 'atropellado')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Intoxicación: ${_getClinicalHistory(record, 'intoxicacion')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Choque: ${_getClinicalHistory(record, 'choque')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Agente causal: ${_getClinicalHistory(record, 'agenteCausal')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Physical Examination
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('EXPLORACIÓN FÍSICA', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('T/A: ${_getPhysicalExam(record, 'T/A')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('FC: ${_getPhysicalExam(record, 'FC')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('FR: ${_getPhysicalExam(record, 'FR')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Temp.: ${_getPhysicalExam(record, 'Temp.')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Sat. O2: ${_getPhysicalExam(record, 'Sat. O2')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(width: 8),
                  
                  // Right Column
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Management
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('MANEJO', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('Vía aérea: ${_getManagement(record, 'viaAerea')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Canalización: ${_getManagement(record, 'canalizacion')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Inmovilización: ${_getManagement(record, 'inmovilizacion')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Monitor: ${_getManagement(record, 'monitor')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('RCP básica: ${_getManagement(record, 'rcpBasica')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Oxígeno: ${_getManagement(record, 'oxigeno')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Lt/min: ${_getManagement(record, 'ltMin')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Medications
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('MEDICAMENTOS', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text(_getMedications(record, 'medications'), style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Gynecological-Obstetric Emergencies
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('URGENCIAS GINECO-OBSTÉTRICAS', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('FUM: ${_getGynecoObstetric(record, 'fum')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Semanas gestación: ${_getGynecoObstetric(record, 'semanasGestacion')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Gesta: ${_getGynecoObstetric(record, 'gesta')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Partos: ${_getGynecoObstetric(record, 'partos')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Priority Justification
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('JUSTIFICACIÓN DE PRIORIDAD', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('Prioridad: ${_getPriorityJustification(record, 'priority')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Pupilas: ${_getPriorityJustification(record, 'pupils')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Color piel: ${_getPriorityJustification(record, 'skinColor')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Piel: ${_getPriorityJustification(record, 'skin')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Receiving Medical Unit
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('UNIDAD MÉDICA QUE RECIBE', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('Lugar origen: ${_getReceivingUnit(record, 'originPlace')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Lugar consulta: ${_getReceivingUnit(record, 'consultPlace')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Lugar destino: ${_getReceivingUnit(record, 'destinationPlace')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Ambulancia: ${_getReceivingUnit(record, 'ambulanceNumber')}', style: pw.TextStyle(fontSize: 8)),
                              pw.Text('Personal: ${_getReceivingUnit(record, 'personal')}', style: pw.TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        
                        // Patient Reception
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('RECEPCIÓN DEL PACIENTE', style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              )),
                              pw.SizedBox(height: 5),
                              pw.Text('Médico: ${_getPatientReception(record, 'receivingDoctor') ?? 'N/A'}', style: pw.TextStyle(fontSize: 8)),
                              pw.SizedBox(height: 10),
                              pw.Text('Firma del médico:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                              pw.Container(
                                height: 30,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                                ),
                                child: _getImageFromBase64(_getPatientReception(record, 'doctorSignature')) != null
                                    ? pw.Image(_getImageFromBase64(_getPatientReception(record, 'doctorSignature'))!)
                                    : pw.Container(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Helper methods to extract data from different sections
  String _getServiceInfo(UnifiedFrapRecord record, String key) {
    final serviceInfo = record.getDetailedInfo()['serviceInfo'] as Map<String, dynamic>?;
    return serviceInfo?[key]?.toString() ?? 'N/A';
  }

  String _getPatientInfo(UnifiedFrapRecord record, String key) {
    final patientInfo = record.getDetailedInfo()['patientInfo'] as Map<String, dynamic>?;
    return patientInfo?[key]?.toString() ?? 'N/A';
  }

  String _getRegistryInfo(UnifiedFrapRecord record, String key) {
    final registryInfo = record.getDetailedInfo()['registryInfo'] as Map<String, dynamic>?;
    return registryInfo?[key]?.toString() ?? 'N/A';
  }

  String _getManagement(UnifiedFrapRecord record, String key) {
    final management = record.getDetailedInfo()['management'] as Map<String, dynamic>?;
    final value = management?[key];
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    return value?.toString() ?? 'N/A';
  }

  String _getMedications(UnifiedFrapRecord record, String key) {
    final medications = record.getDetailedInfo()['medications'] as Map<String, dynamic>?;
    return medications?[key]?.toString() ?? 'N/A';
  }

  String _getGynecoObstetric(UnifiedFrapRecord record, String key) {
    final gynecoObstetric = record.getDetailedInfo()['gynecoObstetric'] as Map<String, dynamic>?;
    return gynecoObstetric?[key]?.toString() ?? 'N/A';
  }

  String? _getAttentionNegative(UnifiedFrapRecord record, String key) {
    final attentionNegative = record.getDetailedInfo()['attentionNegative'] as Map<String, dynamic>?;
    return attentionNegative?[key]?.toString();
  }

  String _getPathologicalHistory(UnifiedFrapRecord record, String key) {
    final pathologicalHistory = record.getDetailedInfo()['pathologicalHistory'] as Map<String, dynamic>?;
    final value = pathologicalHistory?[key];
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    return value?.toString() ?? 'N/A';
  }

  String _getClinicalHistory(UnifiedFrapRecord record, String key) {
    final clinicalHistory = record.getDetailedInfo()['clinicalHistory'] as Map<String, dynamic>?;
    final value = clinicalHistory?[key];
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    return value?.toString() ?? 'N/A';
  }

  String _getPhysicalExam(UnifiedFrapRecord record, String key) {
    final physicalExam = record.getDetailedInfo()['physicalExam'] as Map<String, dynamic>?;
    return physicalExam?[key]?.toString() ?? 'N/A';
  }

  String _getPriorityJustification(UnifiedFrapRecord record, String key) {
    final priorityJustification = record.getDetailedInfo()['priorityJustification'] as Map<String, dynamic>?;
    return priorityJustification?[key]?.toString() ?? 'N/A';
  }

  String _getInjuryLocation(UnifiedFrapRecord record, String key) {
    final injuryLocation = record.getDetailedInfo()['injuryLocation'] as Map<String, dynamic>?;
    final value = injuryLocation?[key];
    return value?.toString() ?? 'N/A';
  }

  String _getReceivingUnit(UnifiedFrapRecord record, String key) {
    final receivingUnit = record.getDetailedInfo()['receivingUnit'] as Map<String, dynamic>?;
    return receivingUnit?[key]?.toString() ?? 'N/A';
  }

  String? _getPatientReception(UnifiedFrapRecord record, String key) {
    final patientReception = record.getDetailedInfo()['patientReception'] as Map<String, dynamic>?;
    return patientReception?[key]?.toString();
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
            child: pw.Text('$label:', style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            )),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey700,
            )),
          ),
        ],
      ),
    );
  }

  // Build time tracking grid similar to the image
  pw.Widget _buildTimeTrackingGrid(UnifiedFrapRecord record) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          // Header row
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
            ),
            child: pw.Row(
              children: [
                _buildTimeGridCell('Hora de llamada', true),
                _buildTimeGridCell('Hora de arribo', true),
                _buildTimeGridCell('Tiempo de espera', true),
                _buildTimeGridCell('Hora de llegada', true),
                _buildTimeGridCell('Tiempo de espera', true),
                _buildTimeGridCell('Hora de termino', true),
              ],
            ),
          ),
          // Data row
          pw.Row(
            children: [
              _buildTimeGridCell(_getServiceInfo(record, 'horaLlamada'), false),
              _buildTimeGridCell(_getServiceInfo(record, 'horaArribo'), false),
              _buildTimeGridCell(_getServiceInfo(record, 'tiempoEsperaArribo'), false),
              _buildTimeGridCell(_getServiceInfo(record, 'horaLlegada'), false),
              _buildTimeGridCell(_getServiceInfo(record, 'tiempoEsperaLlegada'), false),
              _buildTimeGridCell(_getServiceInfo(record, 'horaTermino'), false),
            ],
          ),
        ],
      ),
    );
  }

  // Build time grid cell
  pw.Widget _buildTimeGridCell(String text, bool isHeader) {
    return pw.Expanded(
      child: pw.Container(
        height: 25,
        decoration: pw.BoxDecoration(
          border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1)),
          color: isHeader ? PdfColors.grey200 : PdfColors.white,
        ),
        child: pw.Center(
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.black,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Build location and service type section
  pw.Widget _buildLocationAndServiceSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Location field
        pw.Row(
          children: [
            pw.Text('Ubicación:', style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            )),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Container(
                height: 20,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 5, bottom: 2),
                  child: pw.Text(
                    _getServiceInfo(record, 'ubicacion'),
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        
        // Service type section
        pw.Text('Tipo de servicio:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _buildCheckboxOption('Traslado', _getServiceInfo(record, 'tipoServicio') == 'Traslado'),
            _buildCheckboxOption('Urgencia', _getServiceInfo(record, 'tipoServicio') == 'Urgencia'),
            _buildCheckboxOption('Estudio', _getServiceInfo(record, 'tipoServicio') == 'Estudio'),
            _buildCheckboxOption('Cuidados Intensivos', _getServiceInfo(record, 'tipoServicio') == 'Cuidados Intensivos'),
            _buildCheckboxOption('Otro', _getServiceInfo(record, 'tipoServicio') == 'Otro'),
          ],
        ),
        pw.SizedBox(height: 10),
        
        // Specify field
        pw.Row(
          children: [
            pw.Text('Especifique:', style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            )),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Container(
                height: 20,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 5, bottom: 2),
                  child: pw.Text(
                    _getServiceInfo(record, 'tipoServicioEspecifique'),
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build place of occurrence section
  pw.Widget _buildPlaceOfOccurrenceSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Lugar de Ocurrencia:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _buildCheckboxOption('Hogar', _getServiceInfo(record, 'lugarOcurrencia') == 'Hogar'),
            _buildCheckboxOption('Escuela', _getServiceInfo(record, 'lugarOcurrencia') == 'Escuela'),
            _buildCheckboxOption('Trabajo', _getServiceInfo(record, 'lugarOcurrencia') == 'Trabajo'),
            _buildCheckboxOption('Recreativo', _getServiceInfo(record, 'lugarOcurrencia') == 'Recreativo'),
            _buildCheckboxOption('Vía Pública', _getServiceInfo(record, 'lugarOcurrencia') == 'Vía Pública'),
          ],
        ),
      ],
    );
  }

  // Build checkbox option
  pw.Widget _buildCheckboxOption(String label, bool isChecked) {
    return pw.Expanded(
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
              color: isChecked ? PdfColors.black : PdfColors.white,
            ),
            child: isChecked ? pw.Center(
              child: pw.Text('✓', style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              )),
            ) : null,
          ),
          pw.SizedBox(width: 3),
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 8),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  // Build patient information section
  pw.Widget _buildPatientInfoSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('INFORMACIÓN DEL PACIENTE:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Apellido Paterno:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'paternalLastName'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Apellido Materno:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'maternalLastName'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Nombre(s):', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'firstName'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Edad:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text('${record.patientAge}', style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Sexo:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            _buildCheckboxOption('Masculino', record.patientGender.toLowerCase() == 'masculino'),
            _buildCheckboxOption('Femenino', record.patientGender.toLowerCase() == 'femenino'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Calle:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'street'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('No. Ext.:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'exteriorNumber'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Text('Colonia:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'neighborhood'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('No. Int.:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'interiorNumber'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Text('Ciudad:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'city'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Teléfono:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'phone'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Derechohabiencia:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'insurance'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Persona Responsable:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientInfo(record, 'responsiblePerson'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build registry information section
  pw.Widget _buildRegistryInfoSection(UnifiedFrapRecord record) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(5),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
            ),
            child: pw.Text(
              'INFORMACIÓN DEL REGISTRO',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              children: [
                _buildDetailRow('Convenio', _getRegistryInfo(record, 'convenio')),
                _buildDetailRow('Folio', _getRegistryInfo(record, 'folio')),
                _buildDetailRow('Episodio', _getRegistryInfo(record, 'episodio')),
                _buildDetailRow('Fecha', _getRegistryInfo(record, 'fecha')),
                _buildDetailRow('Solicitado por', _getRegistryInfo(record, 'solicitadoPor')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build administrative detail
  pw.Widget _buildAdminDetail(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        '$label $value',
        style: pw.TextStyle(fontSize: 9, color: PdfColors.black),
      ),
    );
  }

  // Build current condition section
  pw.Widget _buildCurrentConditionSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Padecimiento Actual:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
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
              _getPatientInfo(record, 'currentCondition'),
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }

  // Build pathological history section
  pw.Widget _buildPathologicalHistorySection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('ANTECEDENTES PATOLÓGICOS:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _buildCheckboxOption('Respiratoria', _getPathologicalHistory(record, 'respiratoria') == 'Sí'),
            _buildCheckboxOption('Emocional', _getPathologicalHistory(record, 'emocional') == 'Sí'),
            _buildCheckboxOption('Sistémica', false),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('Cardiovascular', _getPathologicalHistory(record, 'cardiovascular') == 'Sí'),
            _buildCheckboxOption('Neurológica', _getPathologicalHistory(record, 'neurologica') == 'Sí'),
            _buildCheckboxOption('Alérgico', _getPathologicalHistory(record, 'alergico') == 'Sí'),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('Metabólica', _getPathologicalHistory(record, 'metabolica') == 'Sí'),
            _buildCheckboxOption('Otra', _getPathologicalHistory(record, 'otro') == 'Sí'),
            pw.Expanded(child: pw.Text('Especifique:', style: pw.TextStyle(fontSize: 8))),
          ],
        ),
      ],
    );
  }

  // Build clinical history section
  pw.Widget _buildClinicalHistorySection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('ANTECEDENTES CLÍNICOS:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Text('A) Tipo:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Row(
          children: [
            _buildCheckboxOption('Atropellado', _getClinicalHistory(record, 'atropellado') == 'Sí'),
            _buildCheckboxOption('Lx. Por caída', _getClinicalHistory(record, 'lxPorCaida') == 'Sí'),
            _buildCheckboxOption('Intoxicación', _getClinicalHistory(record, 'intoxicacion') == 'Sí'),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('Amputación', _getClinicalHistory(record, 'amputacion') == 'Sí'),
            _buildCheckboxOption('Choque', _getClinicalHistory(record, 'choque') == 'Sí'),
            _buildCheckboxOption('Agresión', _getClinicalHistory(record, 'agresion') == 'Sí'),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('H.P.A.B.', _getClinicalHistory(record, 'hpab') == 'Sí'),
            _buildCheckboxOption('H.P.A.F.', _getClinicalHistory(record, 'hpaf') == 'Sí'),
            _buildCheckboxOption('Volcadura', _getClinicalHistory(record, 'volcadura') == 'Sí'),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('Quemadura', _getClinicalHistory(record, 'quemadura') == 'Sí'),
            _buildCheckboxOption('Otro', _getClinicalHistory(record, 'otroTipo') == 'Sí'),
            pw.Expanded(child: pw.Text('Especifique:', style: pw.TextStyle(fontSize: 8))),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text('B) Agente causal:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Container(
          width: double.infinity,
          height: 20,
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
          ),
          child: pw.Text(_getClinicalHistory(record, 'agenteCausal'), style: pw.TextStyle(fontSize: 8)),
        ),
        pw.SizedBox(height: 5),
        pw.Text('Cinemática:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Container(
          width: double.infinity,
          height: 20,
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
          ),
          child: pw.Text(_getClinicalHistory(record, 'cinematica'), style: pw.TextStyle(fontSize: 8)),
        ),
        pw.SizedBox(height: 5),
        pw.Text('Medida de seguridad:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Container(
          width: double.infinity,
          height: 20,
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
          ),
          child: pw.Text(_getClinicalHistory(record, 'medidaSeguridad'), style: pw.TextStyle(fontSize: 8)),
        ),
      ],
    );
  }

  // Build physical examination section
  pw.Widget _buildPhysicalExamSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('EXPLORACIÓN FÍSICA:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          child: pw.Column(
            children: [
              // Header row
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(3),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1)),
                        ),
                        child: pw.Text('', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                    ),
                    _buildTimeGridCell('Hora 1', true),
                    _buildTimeGridCell('Hora 2', true),
                    _buildTimeGridCell('Hora 3', true),
                  ],
                ),
              ),
              // Data rows
              _buildVitalSignRow('T/A', record),
              _buildVitalSignRow('FC', record),
              _buildVitalSignRow('FR', record),
              _buildVitalSignRow('Temp.', record),
              _buildVitalSignRow('Sat. O2', record),
              _buildVitalSignRow('LIC', record),
              _buildVitalSignRow('Glu', record),
              _buildVitalSignRow('Glasgow', record),
            ],
          ),
        ),
      ],
    );
  }

  // Build vital sign row
  pw.Widget _buildVitalSignRow(String vitalSign, UnifiedFrapRecord record) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(3),
              decoration: pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1)),
              ),
              child: pw.Text(vitalSign, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ),
          ),
          _buildTimeGridCell(_getPhysicalExam(record, vitalSign), false),
          _buildTimeGridCell('', false),
          _buildTimeGridCell('', false),
        ],
      ),
    );
  }

  // Build injury location section
  pw.Widget _buildInjuryLocationSection(UnifiedFrapRecord record) {
    final injuryLocation = record.getDetailedInfo()['injuryLocation'] as Map<String, dynamic>?;
    final drawnInjuries = injuryLocation?['drawnInjuries'] as List<dynamic>?;
    final notes = injuryLocation?['notes'] as String?;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('LOCALIZACIÓN DE LESIONES:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        
        // Contenido principal
        if (drawnInjuries != null && drawnInjuries.isNotEmpty) ...[
          // Mapa corporal con lesiones
          pw.Container(
            height: 200,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 1),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Stack(
              children: [
                // Fondo blanco
                pw.Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: PdfColors.white,
                ),
                // Silueta humana (placeholder por ahora)
                pw.Center(
                  child: pw.Container(
                    width: 120,
                    height: 180,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 1),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'Silueta Humana',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ),
                  ),
                ),
                // Lesiones dibujadas
                ...drawnInjuries.asMap().entries.map((entry) {
                  final injury = entry.value as Map<String, dynamic>;
                  final points = injury['points'] as List<dynamic>;
                  final injuryType = injury['injuryType'] as int;
                  
                  return _buildInjuryPath(points.cast<Map<String, dynamic>>(), injuryType, entry.key);
                }).toList(),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          
          // Información de lesiones
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Lesiones registradas:', style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    )),
                    pw.SizedBox(height: 4),
                    ...drawnInjuries.asMap().entries.map((entry) {
                      final injury = entry.value as Map<String, dynamic>;
                      final injuryType = injury['injuryType'] as int;
                      final typeName = _getInjuryTypeName(injuryType);
                      final number = entry.key + 1;
                      
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Text(
                          '$number. $typeName',
                          style: pw.TextStyle(
                            fontSize: 7,
                            color: PdfColors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Leyenda:', style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    )),
                    pw.SizedBox(height: 4),
                    _buildInjuryLegend(),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Sin lesiones registradas
          pw.Container(
            height: 100,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                'No se han registrado lesiones',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ),
        ],
        
        // Notas adicionales
        if (notes != null && notes.trim().isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Notas adicionales:', style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                )),
                pw.SizedBox(height: 2),
                pw.Text(
                  notes,
                  style: pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Construir el path de una lesión
  pw.Widget _buildInjuryPath(List<Map<String, dynamic>> pointsData, int injuryType, int index) {
    if (pointsData.isEmpty) return pw.SizedBox.shrink();
    
    final color = _getInjuryTypeColor(injuryType);
    final number = index + 1;
    
    return pw.Stack(
      children: [
        // Número de la lesión en el primer punto
        if (pointsData.isNotEmpty)
          pw.Positioned(
            left: (pointsData.first['dx'] as num).toDouble() - 6,
            top: (pointsData.first['dy'] as num).toDouble() - 6,
            child: pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                color: color,
                shape: pw.BoxShape.circle,
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Center(
                child: pw.Text(
                  '$number',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 6,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
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
      children: injuryTypes.map((type) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 1),
        child: pw.Text(
          type,
          style: pw.TextStyle(
            fontSize: 6,
            color: PdfColors.black,
          ),
        ),
      )).toList(),
    );
  }

  // Obtener color del tipo de lesión
  PdfColor _getInjuryTypeColor(int injuryType) {
    switch (injuryType) {
      case 0: return PdfColors.red; // Hemorragia
      case 1: return PdfColors.brown; // Herida
      case 2: return PdfColors.purple; // Contusión
      case 3: return PdfColors.orange; // Fractura
      case 4: return PdfColors.yellow; // Luxación
      case 5: return PdfColors.pink; // Objeto extraño
      case 6: return PdfColors.deepOrange; // Quemadura
      case 7: return PdfColors.green; // Picadura
      case 8: return PdfColors.indigo; // Edema
      case 9: return PdfColors.grey; // Otro
      default: return PdfColors.black;
    }
  }

  // Obtener nombre del tipo de lesión
  String _getInjuryTypeName(int injuryType) {
    switch (injuryType) {
      case 0: return 'Hemorragia';
      case 1: return 'Herida';
      case 2: return 'Contusión';
      case 3: return 'Fractura';
      case 4: return 'Luxación/Esguince';
      case 5: return 'Objeto extraño';
      case 6: return 'Quemadura';
      case 7: return 'Picadura/Mordedura';
      case 8: return 'Edema/Hematoma';
      case 9: return 'Otro';
      default: return 'Desconocido';
    }
  }

  // Build management section
  pw.Widget _buildManagementSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('MANEJO:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _buildCheckboxOption('Vía aérea', _getManagement(record, 'viaAerea') == 'Sí'),
            _buildCheckboxOption('Canalización', _getManagement(record, 'canalizacion') == 'Sí'),
            _buildCheckboxOption('Empaquetamiento', _getManagement(record, 'empaquetamiento') == 'Sí'),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('Inmovilización', _getManagement(record, 'inmovilizacion') == 'Sí'),
            _buildCheckboxOption('Monitor', _getManagement(record, 'monitor') == 'Sí'),
            _buildCheckboxOption('RCP Básica', _getManagement(record, 'rcpBasica') == 'Sí'),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('MAST O PNA', _getManagement(record, 'mastPna') == 'Sí'),
            _buildCheckboxOption('Collarín Cervical', _getManagement(record, 'collarinCervical') == 'Sí'),
            _buildCheckboxOption('Desfibrilación', _getManagement(record, 'desfibrilacion') == 'Sí'),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('Apoyo Vent.', _getManagement(record, 'apoyoVent') == 'Sí'),
            _buildCheckboxOption('Oxígeno', _getManagement(record, 'oxigeno') == 'Sí'),
            pw.Expanded(child: pw.Text('Lt/min: ${_getManagement(record, 'ltMin')}', style: pw.TextStyle(fontSize: 8))),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('Otro', false),
            pw.Expanded(child: pw.Text('Especifique:', style: pw.TextStyle(fontSize: 8))),
          ],
        ),
      ],
    );
  }

  // Build medications section
  pw.Widget _buildMedicationsSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('MEDICAMENTOS:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
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
              _getMedications(record, 'medications'),
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }

  // Build gynecological-obstetric section
  pw.Widget _buildGynecoObstetricSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('URGENCIAS GINECO-OBSTÉTRICAS:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _buildCheckboxOption('Parto', false),
            _buildCheckboxOption('Aborto', false),
            _buildCheckboxOption('Hx. Vaginal', false),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('F.U.M.:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getGynecoObstetric(record, 'fum'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Text('Semanas de Gestación:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getGynecoObstetric(record, 'semanasGestacion'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text('Ruidos Cardiacos Fetales:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.Row(
          children: [
            _buildCheckboxOption('Perceptible', false),
            _buildCheckboxOption('No Perceptible', false),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text('Expulsión de Placenta:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.Row(
          children: [
            _buildCheckboxOption('Si', false),
            _buildCheckboxOption('No', false),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Gesta:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getGynecoObstetric(record, 'gesta'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Text('Partos:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getGynecoObstetric(record, 'partos'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Cesareas:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getGynecoObstetric(record, 'cesareas'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Text('Hora:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getGynecoObstetric(record, 'hora'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Abortos:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getGynecoObstetric(record, 'abortos'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Text('Método Anticonceptivo:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getGynecoObstetric(record, 'metodosAnticonceptivos'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build refusal of care section
  pw.Widget _buildRefusalOfCareSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('NEGATIVA DE ATENCIÓN:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
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
                  pw.Text('Firma Paciente:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 3),
                  pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                    ),
                    child: _getImageFromBase64(_getAttentionNegative(record, 'patientSignature')) != null
                        ? pw.Image(_getImageFromBase64(_getAttentionNegative(record, 'patientSignature'))!)
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
                  pw.Text('Testigo:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 3),
                  pw.Container(
                    height: 30,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                    ),
                    child: _getImageFromBase64(_getAttentionNegative(record, 'witnessSignature')) != null
                        ? pw.Image(_getImageFromBase64(_getAttentionNegative(record, 'witnessSignature'))!)
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

  // Build priority justification section
  pw.Widget _buildPriorityJustificationSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('JUSTIFICACIÓN DE PRIORIDAD:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            _buildCheckboxOption('Rojo', _getPriorityJustification(record, 'priority') == 'Rojo'),
            _buildCheckboxOption('Amarillo', _getPriorityJustification(record, 'priority') == 'Amarillo'),
            _buildCheckboxOption('Verde', _getPriorityJustification(record, 'priority') == 'Verde'),
            _buildCheckboxOption('Negro', _getPriorityJustification(record, 'priority') == 'Negro'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text('Pupilas:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.Row(
          children: [
            _buildCheckboxOption('Iguales', _getPriorityJustification(record, 'pupils') == 'Iguales'),
            _buildCheckboxOption('Midriasis', _getPriorityJustification(record, 'pupils') == 'Midriasis'),
            _buildCheckboxOption('Miosis', _getPriorityJustification(record, 'pupils') == 'Miosis'),
          ],
        ),
        pw.Row(
          children: [
            _buildCheckboxOption('Anisocoria', _getPriorityJustification(record, 'pupils') == 'Anisocoria'),
            _buildCheckboxOption('Arreflexia', _getPriorityJustification(record, 'pupils') == 'Arreflexia'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text('Color Piel:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.Row(
          children: [
            _buildCheckboxOption('Normal', _getPriorityJustification(record, 'skinColor') == 'Normal'),
            _buildCheckboxOption('Cianosis', _getPriorityJustification(record, 'skinColor') == 'Cianosis'),
            _buildCheckboxOption('Marmórea', _getPriorityJustification(record, 'skinColor') == 'Marmórea'),
            _buildCheckboxOption('Pálida', _getPriorityJustification(record, 'skinColor') == 'Pálida'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text('Piel:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.Row(
          children: [
            _buildCheckboxOption('Seca', _getPriorityJustification(record, 'skin') == 'Seca'),
            _buildCheckboxOption('Húmeda', _getPriorityJustification(record, 'skin') == 'Húmeda'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text('Temperatura:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.Row(
          children: [
            _buildCheckboxOption('Normal', _getPriorityJustification(record, 'temperature') == 'Normal'),
            _buildCheckboxOption('Caliente', _getPriorityJustification(record, 'temperature') == 'Caliente'),
            _buildCheckboxOption('Fría', _getPriorityJustification(record, 'temperature') == 'Fría'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Text('Influenciado por:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.Row(
          children: [
            _buildCheckboxOption('Alcohol', _getPriorityJustification(record, 'influence') == 'Alcohol'),
            _buildCheckboxOption('Otras drogas', _getPriorityJustification(record, 'influence') == 'Otras drogas'),
            _buildCheckboxOption('Otro', _getPriorityJustification(record, 'influence') == 'Otro'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Especifique:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPriorityJustification(record, 'especifique'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build receiving unit section
  pw.Widget _buildReceivingUnitSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('UNIDAD MÉDICA QUE RECIBE:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Lugar de origen:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getReceivingUnit(record, 'originPlace'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Lugar de consulta:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getReceivingUnit(record, 'consultPlace'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Lugar de destino:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getReceivingUnit(record, 'destinationPlace'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build ambulance section
  pw.Widget _buildAmbulanceSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('AMBULANCIA:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('No.:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getReceivingUnit(record, 'ambulanceNumber'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Text('Placas:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getReceivingUnit(record, 'plate'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Personal:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getReceivingUnit(record, 'personal'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Dr.:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getReceivingUnit(record, 'responsibleDoctor'), style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build patient reception section
  pw.Widget _buildPatientReceptionSection(UnifiedFrapRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('RECEPCIÓN DEL PACIENTE:', style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        )),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            pw.Text('Médico que recibe:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Container(
                height: 15,
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                ),
                child: pw.Text(_getPatientReception(record, 'receivingDoctor') ?? '', style: pw.TextStyle(fontSize: 8)),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text('Nombre y firma:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Container(
          height: 30,
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
          ),
          child: _getImageFromBase64(_getPatientReception(record, 'doctorSignature')) != null
              ? pw.Image(_getImageFromBase64(_getPatientReception(record, 'doctorSignature'))!)
              : pw.Container(),
        ),
      ],
    );
  }

  /// Saves the PDF to a file and returns the file path
  Future<String> savePdfToFile(UnifiedFrapRecord record) async {
    final pdfBytes = await generateFrapPdf(record);
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'FRAP_${record.patientName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  /// Shares the PDF file
  Future<void> sharePdf(UnifiedFrapRecord record) async {
    try {
      final filePath = await savePdfToFile(record);
      await Share.shareXFiles([XFile(filePath)], text: 'Registro de Atención Prehospitalaria - ${record.patientName}');
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
}

