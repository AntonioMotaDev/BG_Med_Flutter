import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/services/frap_unified_service.dart';
import 'package:bg_med/features/frap/presentation/screens/pdf_preview_screen.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:bg_med/features/frap/presentation/widgets/injury_location_display_widget.dart';
import 'dart:typed_data'; // Added for Uint8List
import 'package:bg_med/features/frap/presentation/providers/frap_unified_provider.dart';

class FrapRecordDetailsScreen extends ConsumerStatefulWidget {
  final UnifiedFrapRecord record;

  const FrapRecordDetailsScreen({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  ConsumerState<FrapRecordDetailsScreen> createState() => _FrapRecordDetailsScreenState();
}

class _FrapRecordDetailsScreenState extends ConsumerState<FrapRecordDetailsScreen> {
  late Map<String, dynamic> _detailedInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetailedInfo();
  }

  void _loadDetailedInfo() {
    setState(() {
      _isLoading = true;
    });

    // Cargar información detallada del registro
    _detailedInfo = widget.record.getDetailedInfo();
    
    setState(() {
      _isLoading = false;
    });
  }

  // Método auxiliar para decodificar firmas base64 correctamente
  Uint8List _getImageBytesFromBase64(String base64Data) {
    try {
      // Remover el prefijo 'data:image/png;base64,' si existe
      final base64String = base64Data.split(',').last;
      return base64Decode(base64String);
    } catch (e) {
      return Uint8List(0);
    }
  }

  // Método para mostrar firma en tamaño grande
  void _showSignatureFullScreen(String title, String base64Data, {String? doctorName}) {
    try {
      final decodedBytes = _getImageBytesFromBase64(base64Data);
      if (decodedBytes.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            // title,
                            '',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenido de la firma
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InteractiveViewer(
                          child: Image.memory(
                            decodedBytes,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Text(
                                'Error al cargar la firma',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Footer con información
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            doctorName != null ? 'Médico: $doctorName' : 'Medico que recibe el paciente',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al mostrar la firma: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de Atencion Prehospitalaria',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editRecord(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'pdf':
                  _generatePDF();
                  break;
                case 'delete':
                  _deleteRecord();
                  break;
                case 'share':
                  _shareRecord();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Generar PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text('Compartir'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con información básica
                  _buildHeaderCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Información del servicio
                  _buildServiceInfoSection(),
                  
                  // Información del registro
                  _buildRegistryInfoSection(),
                  
                  // Información del paciente
                  _buildPatientInfoSection(),
                  
                  // Manejo
                  _buildManagementSection(),
                  
                  // Medicamentos
                  _buildMedicationsSection(),
                  
                  // Gineco-obstétrica
                  _buildGynecoObstetricSection(),
                  
                  // Atención negativa
                  _buildAttentionNegativeSection(),
                  
                  // Historia patológica
                  _buildPathologicalHistorySection(),
                  
                  // Historia clínica
                  _buildClinicalHistorySection(),
                  
                  // Examen físico
                  _buildPhysicalExamSection(),
                  
                  // Justificación de prioridad
                  _buildPriorityJustificationSection(),
                  
                  // Localización de lesiones
                  _buildInjuryLocationSection(),
                  
                  // Unidad receptora
                  _buildReceivingUnitSection(),
                  
                  // Recepción del paciente
                  _buildPatientReceptionSection(),
                  
                  // Nuevas secciones agregadas
                  _buildInsumosSection(),
                  
                  _buildPersonalMedicoSection(),
                  
                  _buildEscalasObstetricasSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: widget.record.patientGender.toLowerCase() == 'femenino'
                ? [AppTheme.primaryGreen, AppTheme.primaryGreen]
                : [AppTheme.primaryBlue, AppTheme.primaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.record.patientName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.record.patientAge} años • ${widget.record.patientGender}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.record.isLocal ? 'LOCAL' : 'NUBE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información adicional
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Fecha de creación',
                    DateFormat('dd/MM/yyyy HH:mm').format(widget.record.createdAt),
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'Completitud',
                    '${widget.record.completionPercentage.toStringAsFixed(1)}%',
                    Icons.assessment,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Barra de progreso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso de completitud',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: widget.record.completionPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.record.completionPercentage >= 80
                        ? Colors.green[300]!
                        : widget.record.completionPercentage >= 50
                            ? Colors.orange[300]!
                            : Colors.red[300]!,
                  ),
                  minHeight: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfoSection() {
    final serviceInfo = _detailedInfo['serviceInfo'];
    Map<String, dynamic> serviceInfoMap = {};
    if (serviceInfo is Map) {
      serviceInfoMap = Map<String, dynamic>.from(serviceInfo);
    }
    if (serviceInfoMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {'label': 'Hora de llamada', 'value': serviceInfoMap['horaLlamada']},
      {'label': 'Hora de arribo', 'value': serviceInfoMap['horaArribo']},
      {'label': 'Tiempo de espera arribo', 'value': serviceInfoMap['tiempoEsperaArribo']},
      {'label': 'Hora de llegada', 'value': serviceInfoMap['horaLlegada']},
      {'label': 'Tiempo de espera llegada', 'value': serviceInfoMap['tiempoEsperaLlegada']},
      {'label': 'Hora de terminación', 'value': serviceInfoMap['horaTermino']},
      {'label': 'Ubicacion', 'value': serviceInfoMap['ubicacion']},
      {'label': 'Tipo de servicio', 'value': serviceInfoMap['tipoServicio']},
      {'label': 'Especifique', 'value': serviceInfoMap['tipoServicioEspecifique']},
      {'label': 'Lugar de ocurrencia', 'value': serviceInfoMap['lugarOcurrencia']},
    ];

    return _buildSectionCard(
      title: 'Información del Servicio',
      icon: Icons.local_hospital,
      color: Colors.blue,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildRegistryInfoSection() {
    final registryInfo = _detailedInfo['registryInfo'];
    Map<String, dynamic> registryInfoMap = {};
    if (registryInfo is Map) {
      registryInfoMap = Map<String, dynamic>.from(registryInfo);
    }
    if (registryInfoMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {'label': 'Convenio', 'value': registryInfoMap['convenio']},
      {'label': 'Folio', 'value': registryInfoMap['folio']},
      {'label': 'Episodio', 'value': registryInfoMap['episodio']},
      {'label': 'Fecha de registro', 'value': registryInfoMap['fecha']},
      {'label': 'Solicitado por', 'value': registryInfoMap['solicitadoPor']},
    ];

    return _buildSectionCard(
      title: 'Información del Registro',
      icon: Icons.assignment,
      color: Colors.indigo,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildPatientInfoSection() {
    final patientInfo = _detailedInfo['patientInfo'];
    Map<String, dynamic> patientInfoMap = {};
    if (patientInfo is Map) {
      patientInfoMap = Map<String, dynamic>.from(patientInfo);
    }
    
    final details = [
      {'label': 'Nombre completo', 'value': patientInfoMap['name'] ?? widget.record.patientName},
      {'label': 'Edad', 'value': patientInfoMap['age'] != null ? '${patientInfoMap['age']} años' : '${widget.record.patientAge} años'},
      {'label': 'Sexo', 'value': patientInfoMap['sex'] ?? widget.record.patientGender}, // Cambiado de gender a sex
      {'label': 'Dirección', 'value': patientInfoMap['address'] ?? widget.record.patientAddress},
      {'label': 'Teléfono', 'value': patientInfoMap['phone']},
      {'label': 'Seguro médico', 'value': patientInfoMap['insurance']},
      {'label': 'Padecimiento actual', 'value': patientInfoMap['currentCondition']},
      {'label': 'Contacto de emergencia', 'value': patientInfoMap['emergencyContact']},
      {'label': 'Persona responsable', 'value': patientInfoMap['responsiblePerson']},
    ];

    return _buildSectionCard(
      title: 'Información del Paciente',
      icon: Icons.person,
      color: Colors.green,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildManagementSection() {
    final management = _detailedInfo['management'];
    Map<String, dynamic> managementMap = {};
    if (management is Map) {
      managementMap = Map<String, dynamic>.from(management);
    }
    if (managementMap.isEmpty) return const SizedBox.shrink();

    final details = [
      ...[
        if (managementMap['viaAerea'] == true) {'label': 'Vía aérea', 'value': 'Sí'},
        if (managementMap['canalizacion'] == true) {'label': 'Canalización', 'value': 'Sí'},
        if (managementMap['empaquetamiento'] == true) {'label': 'Empaquetamiento', 'value': 'Sí'},
        if (managementMap['inmovilizacion'] == true) {'label': 'Inmovilización', 'value': ''},
        if (managementMap['monitor'] == true) {'label': 'Monitor', 'value': 'Sí'},
        if (managementMap['rcpBasica'] == true) {'label': 'RCP básica', 'value': 'Sí'},
        if (managementMap['mastPna'] == true) {'label': 'MAST/PNA', 'value': 'Sí'},
        if (managementMap['collarinCervical'] == true) {'label': 'Collarín cervical', 'value': 'Sí'},
        if (managementMap['desfibrilacion'] == true) {'label': 'Desfibrilación', 'value': 'Sí'},
        if (managementMap['apoyoVent'] == true) {'label': 'Apoyo ventilatorio', 'value': 'Sí'},
        if (managementMap['oxigeno'] != null)
          {'label': 'Oxígeno', 'value': managementMap['oxigeno'] == true ? 'Sí' : 'No'},
        if (managementMap['oxigeno'] == true && managementMap['ltMin'] != null && managementMap['ltMin'].toString().isNotEmpty)
          {'label': 'Lt/min', 'value': managementMap['ltMin']},
      ],
    ];

    return _buildSectionCard(
      title: 'Manejo',
      icon: Icons.healing,
      color: Colors.purple,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildMedicationsSection() {
    final medications = _detailedInfo['medications'];
    Map<String, dynamic> medicationsMap = {};
    if (medications is Map) {
      medicationsMap = Map<String, dynamic>.from(medications);
    }
    if (medicationsMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {'label': 'Medicamentos', 'value': medicationsMap['medications']},
    ];

    return _buildSectionCard(
      title: 'Medicamentos',
      icon: Icons.medication,
      color: Colors.orange,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildGynecoObstetricSection() {
    final gynecoObstetric = _detailedInfo['gynecoObstetric'];
    Map<String, dynamic> gynecoObstetricMap = {};
    if (gynecoObstetric is Map) {
      gynecoObstetricMap = Map<String, dynamic>.from(gynecoObstetric);
    }
    if (gynecoObstetricMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {'label': 'Última menstruación', 'value': gynecoObstetricMap['fum']},
      {'label': 'Semanas de gestación', 'value': gynecoObstetricMap['semanasGestacion']},
      {'label': 'Gesta', 'value': gynecoObstetricMap['gesta']},
      {'label': 'Abortos', 'value': gynecoObstetricMap['abortos']},
      {'label': 'Partos', 'value': gynecoObstetricMap['partos']},
      {'label': 'Cesáreas', 'value': gynecoObstetricMap['cesareas']},
      {'label': 'Métodos anticonceptivos', 'value': gynecoObstetricMap['metodosAnticonceptivos']},
      {'label': 'Ruidos cardiacos fetales', 'value': gynecoObstetricMap['ruidosCardiacosFetales']},
      {'label': 'Expulsión de placenta', 'value': gynecoObstetricMap['expulsionPlacenta']},
      {'label': 'Hora', 'value': gynecoObstetricMap['hora']},
    ];

    return _buildSectionCard(
      title: 'Urgencias Gineco-Obstétricas',
      icon: Icons.pregnant_woman,
      color: Colors.pink,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildAttentionNegativeSection() {
    final attentionNegative = _detailedInfo['attentionNegative'];
    Map<String, dynamic> attentionNegativeMap = {};
    if (attentionNegative is Map) {
      attentionNegativeMap = Map<String, dynamic>.from(attentionNegative);
    }
    if (attentionNegativeMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {
        'label': 'Firma paciente',
        'value': (() {
          try {
            final signatureData = attentionNegativeMap['patientSignature'];
            if (signatureData != null && signatureData.toString().isNotEmpty) {
              final decodedBytes = _getImageBytesFromBase64(signatureData.toString());
              if (decodedBytes.isNotEmpty) {
                return GestureDetector(
                  onTap: () => _showSignatureFullScreen('Firma del Paciente', signatureData.toString()),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(
                      decodedBytes,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text('Firma no disponible'),
                    ),
                  ),
                );
              }
            }
            return const Text('No registrada');
          } catch (e) {
            // Si hay error decodificando base64, mostrar mensaje de error
            return const Text('Firma corrupta');
          }
        })(),
        'isSignature': true,
      },
      {
        'label': 'Firma Testigo',
        'value': (() {
          try {
            final signatureData = attentionNegativeMap['witnessSignature'];
            if (signatureData != null && signatureData.toString().isNotEmpty) {
              final decodedBytes = _getImageBytesFromBase64(signatureData.toString());
              if (decodedBytes.isNotEmpty) {
                return GestureDetector(
                  onTap: () => _showSignatureFullScreen('Firma del Testigo', signatureData.toString()),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(
                      decodedBytes,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text('Firma no disponible'),
                    ),
                  ),
                );
              }
            }
            return const Text('No registrada');
          } catch (e) {
            // Si hay error decodificando base64, mostrar mensaje de error
            return const Text('Firma corrupta');
          }
        })(),
        'isSignature': true,
      },
    ];

    return _buildSectionCard(
      title: 'Negativa de atención',
      icon: Icons.cancel,
      color: Colors.red,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildPathologicalHistorySection() {
    final pathologicalHistory = _detailedInfo['pathologicalHistory'];
    Map<String, dynamic> pathologicalHistoryMap = {};
    if (pathologicalHistory is Map) {
      pathologicalHistoryMap = Map<String, dynamic>.from(pathologicalHistory);
    }
    if (pathologicalHistoryMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {'label': 'Respiratoria', 'value': pathologicalHistoryMap['respiratoria'] == true ? 'Sí' : 'No'},
      {'label': 'Emocional', 'value': pathologicalHistoryMap['emocional'] == true ? 'Sí' : 'No'},
      {'label': 'Traumática', 'value': pathologicalHistoryMap['traumatica'] == true ? 'Sí' : 'No'},
      {'label': 'Cardiovascular', 'value': pathologicalHistoryMap['cardiovascular'] == true ? 'Sí' : 'No'},
      {'label': 'Neurológica', 'value': pathologicalHistoryMap['neurologica'] == true ? 'Sí' : 'No'},
      {'label': 'Alérgico', 'value': pathologicalHistoryMap['alergico'] == true ? 'Sí' : 'No'},
      {
        'label': 'Otro',
        'value': pathologicalHistoryMap['otro'] == true
            ? (pathologicalHistoryMap['otherDescription'] ?? '')
            : 'No'
      },
      {'label': 'Metabólica', 'value': pathologicalHistoryMap['metabolica'] == true ? 'Sí' : 'No'},
    ];

    return _buildSectionCard(
      title: 'Antecedentes Patológicos',
      icon: Icons.history,
      color: Colors.brown,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildClinicalHistorySection() {
    final clinicalHistory = _detailedInfo['clinicalHistory'];
    Map<String, dynamic> clinicalHistoryMap = {};
    if (clinicalHistory is Map) {
      clinicalHistoryMap = Map<String, dynamic>.from(clinicalHistory);
    }
    if (clinicalHistoryMap.isEmpty) return const SizedBox.shrink();

    final details = [
      ...[
        if (clinicalHistoryMap['atropellado'] == true) {'label': 'Atropellado', 'value': 'Sí'},
        if (clinicalHistoryMap['lxPorCaida'] == true) {'label': 'Lx por caída', 'value': 'Sí'},
        if (clinicalHistoryMap['intoxicacion'] == true) {'label': 'Intoxicación', 'value': 'Sí'},
        if (clinicalHistoryMap['amputacion'] == true) {'label': 'Amputación', 'value': 'Sí'},
        if (clinicalHistoryMap['choque'] == true) {'label': 'Choque', 'value': 'Sí'},
        if (clinicalHistoryMap['agresion'] == true) {'label': 'Agresión', 'value': 'Sí'},
        if (clinicalHistoryMap['hpaf'] == true) {'label': 'HPAF', 'value': 'Sí'},
        if (clinicalHistoryMap['hpab'] == true) {'label': 'HPAB', 'value': 'Sí'},
        if (clinicalHistoryMap['volcadura'] == true) {'label': 'Volcadura', 'value': 'Sí'},
        if (clinicalHistoryMap['quemadura'] == true) {'label': 'Quemadura', 'value': 'Sí'},
      ],
      {
        'label': 'Otro tipo',
        'value': clinicalHistoryMap['otroTipo'] == true
            ? (clinicalHistoryMap['otherTypeDescription'] ?? '')
            : 'No'
      },
      {'label': 'Agente causal', 'value': clinicalHistoryMap['agenteCausal'] ?? ''},
      {'label': 'Cinemática', 'value': clinicalHistoryMap['cinematica'] ?? ''},
      {'label': 'Medida de Seguridad', 'value': clinicalHistoryMap['medidaSeguridad'] ?? ''},
    ];

    return _buildSectionCard(
      title: 'Antecedentes Clínicos',
      icon: Icons.medical_services,
      color: Colors.teal,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildPhysicalExamSection() {
    final physicalExam = _detailedInfo['physicalExam'];
    Map<String, dynamic> physicalExamMap = {};
    if (physicalExam is Map) {
      physicalExamMap = Map<String, dynamic>.from(physicalExam);
    }
    if (physicalExamMap.isEmpty) return const SizedBox.shrink();

    final details = [
      for (final vitalSign in [
        {'label': 'T/A', 'key': 'T/A'},
        {'label': 'FC', 'key': 'FC'},
        {'label': 'FR', 'key': 'FR'},
        {'label': 'Temp.', 'key': 'Temp.'},
        {'label': 'Sat. O2', 'key': 'Sat. O2'},
        {'label': 'LLC', 'key': 'LLC'},
        {'label': 'Glu', 'key': 'Glu'},
        {'label': 'Glasgow', 'key': 'Glasgow'},
      ])
        {
          'label': vitalSign['label'],
          'value': (() {
            // Si hay columnas de tiempo, mostrar los valores por hora
            if (physicalExamMap['timeColumns'] != null && physicalExamMap[vitalSign['key']] != null) {
              final timeColumns = List<String>.from(physicalExamMap['timeColumns']);
              final values = Map<String, dynamic>.from(physicalExamMap[vitalSign['key']]);
              return timeColumns
                  .map((col) => '${col}: ${values[col] ?? ''}')
                  .join('\n');
            }
            // Si no, mostrar el valor directo (por compatibilidad)
            return physicalExamMap[vitalSign['key']];
          })(),
        },
    ];

    return _buildSectionCard(
      title: 'Exploración Física',
      icon: Icons.health_and_safety,
      color: Colors.cyan,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildPriorityJustificationSection() {
    final priorityJustification = _detailedInfo['priorityJustification'];
    Map<String, dynamic> priorityJustificationMap = {};
    if (priorityJustification is Map) {
      priorityJustificationMap = Map<String, dynamic>.from(priorityJustification);
    }
    if (priorityJustificationMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {'label': 'Prioridad', 'value': priorityJustificationMap['priority']},
      {'label': 'Pupilas', 'value': priorityJustificationMap['pupils']},
      {'label': 'Color piel', 'value': priorityJustificationMap['skinColor']},
      {'label': 'Piel', 'value': priorityJustificationMap['skin']},
      {'label': 'Temperatura', 'value': priorityJustificationMap['temperature']},
      {
        'label': 'Influenciado por',
        'value': (priorityJustificationMap['influence'] == 'Otro' &&
                  (priorityJustificationMap['especifique'] != null && priorityJustificationMap['especifique'].toString().trim().isNotEmpty))
            ? priorityJustificationMap['especifique']
            : priorityJustificationMap['influence'],
      },
    ];

    return _buildSectionCard(
      title: 'Justificación de Prioridad',
      icon: Icons.priority_high,
      color: Colors.deepOrange,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildInjuryLocationSection() {
    final injuryLocation = _detailedInfo['injuryLocation'];
    Map<String, dynamic> injuryLocationMap = {};
    if (injuryLocation is Map) {
      injuryLocationMap = Map<String, dynamic>.from(injuryLocation);
    }
    if (injuryLocationMap.isEmpty) return const SizedBox.shrink();

    List<Map<String, dynamic>> details = [];
    List<DrawnInjuryDisplay> drawnInjuries = [];

    // Procesar lesiones dibujadas si existen
    if (injuryLocationMap['drawnInjuries'] != null) {
      final List<dynamic> injuriesData = injuryLocationMap['drawnInjuries'];
      
      if (injuriesData.isNotEmpty) {
        // Convertir datos a objetos DrawnInjuryDisplay
        drawnInjuries = injuriesData.map((injury) {
          final List<dynamic> pointsData = injury['points'];
          final points = pointsData.map((point) => Offset(point['dx'], point['dy'])).toList();
          final injuryType = injury['injuryType'] as int;
          
          return DrawnInjuryDisplay(
            points: points,
            injuryType: injuryType,
          );
        }).toList();
        
        // Agrupar lesiones por tipo para mostrar resumen
        Map<int, int> injuriesByType = {};
        for (var injury in drawnInjuries) {
          injuriesByType[injury.injuryType] = (injuriesByType[injury.injuryType] ?? 0) + 1;
        }
        
        // Crear detalles para cada tipo de lesión
        injuriesByType.forEach((typeIndex, count) {
          final typeName = _getInjuryTypeName(typeIndex);
          details.add({
            'label': typeName,
            'value': '$count ${count == 1 ? 'lesión marcada' : 'lesiones marcadas'}',
          });
        });
        
        // Mostrar total de lesiones
        details.add({
          'label': 'Total de lesiones',
          'value': '${drawnInjuries.length} ${drawnInjuries.length == 1 ? 'lesión' : 'lesiones'} dibujadas',
        });
      }
    }

    // Mostrar notas adicionales
    if (injuryLocationMap['notes'] != null && injuryLocationMap['notes'].toString().trim().isNotEmpty) {
      details.add({
        'label': 'Notas adicionales',
        'value': injuryLocationMap['notes'],
        'isFullWidth': true,
      });
    }

    return _buildSectionCard(
      title: 'Localización de Lesiones',
      icon: Icons.my_location,
      color: Colors.red,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Layout horizontal: Lista de lesiones + Mapa visual
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Panel izquierdo - Lista de lesiones
                  Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lesiones registradas:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Lista de lesiones
                        if (drawnInjuries.isNotEmpty) ...[
                          ...drawnInjuries.asMap().entries.map((entry) {
                            final injury = entry.value;
                            final typeName = _getInjuryTypeName(injury.injuryType);
                            final color = _getInjuryTypeColor(injury.injuryType);
                            final number = injury.injuryType + 1;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: color.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  // Número de la lesión
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$number',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Información de la lesión
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          typeName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: color.withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${injury.points.length} ${injury.points.length == 1 ? 'punto' : 'puntos'} marcados',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          
                          const SizedBox(height: 16),
                          
                          // Resumen
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Total: ${drawnInjuries.length} ${drawnInjuries.length == 1 ? 'lesión' : 'lesiones'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'No se han registrado lesiones',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Panel derecho - Mapa visual del cuerpo humano
                  Expanded(
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InjuryLocationDisplayWidget(
                          drawnInjuries: drawnInjuries,
                          originalImageSize: injuryLocationMap['originalImageSize'] != null
                              ? Size(
                                  injuryLocationMap['originalImageSize']['width']?.toDouble() ?? 400.0,
                                  injuryLocationMap['originalImageSize']['height']?.toDouble() ?? 600.0,
                                )
                              : null, // Para registros antiguos sin esta información
                          originalImageRect: injuryLocationMap['originalImageRect'] != null
                              ? Rect.fromLTWH(
                                  injuryLocationMap['originalImageRect']['left']?.toDouble() ?? 0.0,
                                  injuryLocationMap['originalImageRect']['top']?.toDouble() ?? 0.0,
                                  injuryLocationMap['originalImageRect']['width']?.toDouble() ?? 400.0,
                                  injuryLocationMap['originalImageRect']['height']?.toDouble() ?? 600.0,
                                )
                              : null, // Para registros antiguos sin esta información
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Leyenda de tipos de lesiones (ahora más compacta)
              if (drawnInjuries.isNotEmpty) ...[
                const Text(
                  'Leyenda de tipos:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: _buildInjuryLegend(drawnInjuries),
                ),
                const SizedBox(height: 16),
              ],
              
              // Detalles en texto
              ...details.map((detail) {
                if (detail['isFullWidth'] == true) {
                  return _buildFullWidthDetail(detail['label'], detail['value']);
                }
                return _buildDetailRow(detail['label'], detail['value']);
              }).toList(),
            ],
          ),
    );
  }

  // Método auxiliar para obtener el nombre del tipo de lesión
  String _getInjuryTypeName(int typeIndex) {
    const injuryTypes = [
      'Hemorragia',           // 0
      'Herida',               // 1
      'Contusión',            // 2
      'Fractura',             // 3
      'Luxación/Esguince',    // 4
      'Objeto extraño',       // 5
      'Quemadura',            // 6
      'Picadura/Mordedura',   // 7
      'Edema/Hematoma',       // 8
      'Otro',                 // 9
    ];
    
    if (typeIndex >= 0 && typeIndex < injuryTypes.length) {
      return injuryTypes[typeIndex];
    }
    return 'Tipo desconocido';
  }

  // Método auxiliar para mostrar detalles de ancho completo (como notas)
  Widget _buildFullWidthDetail(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivingUnitSection() {
    final receivingUnit = _detailedInfo['receivingUnit'];
    Map<String, dynamic> receivingUnitMap = {};
    if (receivingUnit is Map) {
      receivingUnitMap = Map<String, dynamic>.from(receivingUnit);
    }
    if (receivingUnitMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {'label': 'Lugar de origen', 'value': receivingUnitMap['originPlace']},
      {'label': 'Lugar de consulta', 'value': receivingUnitMap['consultPlace']},
      {'label': 'Lugar de destino', 'value': receivingUnitMap['destinationPlace']},
      {'label': 'Numero de ambulancia', 'value': receivingUnitMap['ambulanceNumber']},
      {'label': 'Placa', 'value': receivingUnitMap['plate']},
      {'label': 'Personal', 'value': receivingUnitMap['personal']},
      {'label': 'Doctor responsable', 'value': receivingUnitMap['responsibleDoctor']},
    ];

    return _buildSectionCard(
      title: 'Unidad Medica que Recibe',
      icon: Icons.local_hospital,
      color: Colors.indigo,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildPatientReceptionSection() {
    final patientReception = _detailedInfo['patientReception'];
    Map<String, dynamic> patientReceptionMap = {};
    if (patientReception is Map) {
      patientReceptionMap = Map<String, dynamic>.from(patientReception);
    }
    if (patientReceptionMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {'label': 'Medico que recibe', 'value': patientReceptionMap['receivingDoctor']},
      {
        'label': 'Firma del medico',
        'value': (() {
          try {
            final signatureData = patientReceptionMap['doctorSignature'];
            if (signatureData != null && signatureData.toString().isNotEmpty) {
              final decodedBytes = _getImageBytesFromBase64(signatureData.toString());
              if (decodedBytes.isNotEmpty) {
                final doctorName = patientReceptionMap['receivingDoctor'] ?? '';
                return GestureDetector(
                  onTap: () => _showSignatureFullScreen('Firma del Médico', signatureData.toString(), doctorName: doctorName),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(
                      decodedBytes,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text('Firma no disponible'),
                    ),
                  ),
                );
              }
            }
            return const Text('No registrada');
          } catch (e) {
            // Si hay error decodificando base64, mostrar mensaje de error
            return const Text('Firma corrupta');
          }
        })(),
        'isSignature': true,
      },
    ];

    return _buildSectionCard(
      title: 'Recepción del Paciente',
      icon: Icons.how_to_reg,
      color: Colors.green,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildInsumosSection() {
    // Obtener insumos del registro local o de la nube
    List<dynamic> insumosList = [];
    
    if (widget.record.localRecord != null) {
      // Si hay registro local, obtener insumos del modelo local
      insumosList = widget.record.localRecord!.insumos.map((insumo) => {
        'cantidad': insumo.cantidad,
        'articulo': insumo.articulo,
      }).toList();
    } else if (widget.record.cloudRecord != null) {
      // Si es solo de la nube, buscar en las secciones de management o serviceInfo
      final cloudData = widget.record.cloudRecord!;
      insumosList = cloudData.management['insumos'] ?? 
                   cloudData.serviceInfo['insumos'] ?? 
                   [];
    }
    
    if (insumosList.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'Insumos Utilizados',
      icon: Icons.inventory_2,
      color: Colors.deepPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (insumosList.isNotEmpty) ...[
            for (int i = 0; i < insumosList.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insumosList[i]['articulo']?.toString() ?? 'Sin especificar',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cantidad: ${insumosList[i]['cantidad']?.toString() ?? '0'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se registraron insumos',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalMedicoSection() {
    // Obtener personal médico del registro local o de la nube
    List<dynamic> personalList = [];
    
    if (widget.record.localRecord != null) {
      // Si hay registro local, obtener personal médico del modelo local
      personalList = widget.record.localRecord!.personalMedico.map((personal) => {
        'nombre': personal.nombre,
        'especialidad': personal.especialidad,
        'cedula': personal.cedula,
      }).toList();
    } else if (widget.record.cloudRecord != null) {
      // Si es solo de la nube, buscar en las secciones de management o serviceInfo
      final cloudData = widget.record.cloudRecord!;
      personalList = cloudData.management['personalMedico'] ?? 
                    cloudData.serviceInfo['personalMedico'] ?? 
                    [];
    }
    
    if (personalList.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'Personal Médico',
      icon: Icons.medical_services,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (personalList.isNotEmpty) ...[
            for (int i = 0; i < personalList.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            personalList[i]['nombre']?.toString() ?? 'Sin especificar',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (personalList[i]['especialidad']?.toString().isNotEmpty == true)
                            Text(
                              'Especialidad: ${personalList[i]['especialidad']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (personalList[i]['cedula']?.toString().isNotEmpty == true)
                            Text(
                              'Cédula: ${personalList[i]['cedula']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se registró personal médico',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEscalasObstetricasSection() {
    // Obtener escalas obstétricas del registro local o de la nube
    Map<String, dynamic>? escalasData;
    
    if (widget.record.localRecord != null && widget.record.localRecord!.escalasObstetricas != null) {
      // Si hay registro local con escalas obstétricas
      final escalas = widget.record.localRecord!.escalasObstetricas!;
      escalasData = {
        'silvermanAnderson': escalas.silvermanAnderson,
        'apgar': escalas.apgar,
        'frecuenciaCardiacaFetal': escalas.frecuenciaCardiacaFetal,
        'contracciones': escalas.contracciones,
      };
    } else if (widget.record.cloudRecord != null) {
      // Si es solo de la nube, buscar en la sección gynecoObstetric
      final cloudData = widget.record.cloudRecord!;
      escalasData = cloudData.gynecoObstetric['escalasObstetricas'] ?? 
                   cloudData.gynecoObstetric['escalas'];
    }
    
    if (escalasData == null || escalasData.isEmpty) return const SizedBox.shrink();

    List<Map<String, dynamic>> details = [];
    
    // Escala de Silverman-Anderson
    if (escalasData['silvermanAnderson'] != null) {
      final silverman = escalasData['silvermanAnderson'] as Map<String, dynamic>;
      if (silverman.isNotEmpty) {
        details.add({
          'label': 'Escala Silverman-Anderson',
          'value': _buildSilvermanAndersonDisplay(silverman),
          'isFullWidth': true,
        });
      }
    }
    
    // Escala APGAR
    if (escalasData['apgar'] != null) {
      final apgar = escalasData['apgar'] as Map<String, dynamic>;
      if (apgar.isNotEmpty) {
        details.add({
          'label': 'Escala APGAR',
          'value': _buildApgarDisplay(apgar),
          'isFullWidth': true,
        });
      }
    }
    
    // Frecuencia cardíaca fetal
    if (escalasData['frecuenciaCardiacaFetal'] != null) {
      details.add({
        'label': 'Frecuencia cardíaca fetal',
        'value': '${escalasData['frecuenciaCardiacaFetal']} lpm',
      });
    }
    
    // Contracciones
    if (escalasData['contracciones'] != null && escalasData['contracciones'].toString().isNotEmpty) {
      details.add({
        'label': 'Contracciones',
        'value': escalasData['contracciones'].toString(),
      });
    }
    
    if (details.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'Escalas Obstétricas',
      icon: Icons.pregnant_woman,
      color: Colors.pink,
      child: _buildTwoColumnDetails(details),
    );
  }

  Widget _buildSilvermanAndersonDisplay(Map<String, dynamic> silverman) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Puntajes por criterio:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...silverman.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _getSilvermanCriteriaName(entry.key),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Puntaje total:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${silverman.values.fold(0, (sum, value) => sum + (value as int))}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApgarDisplay(Map<String, dynamic> apgar) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Puntajes por criterio:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...apgar.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _getApgarCriteriaName(entry.key),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Puntaje total:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${apgar.values.fold(0, (sum, value) => sum + (value as int))}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSilvermanCriteriaName(String key) {
    switch (key) {
      case 'respirationMoved':
        return 'Movimientos respiratorios';
      case 'retraction':
        return 'Retracción';
      case 'nasal':
        return 'Aleteo nasal';
      case 'moan':
        return 'Quejido';
      case 'circulation':
        return 'Circulación';
      default:
        return key;
    }
  }

  String _getApgarCriteriaName(String key) {
    switch (key) {
      case 'heartRate':
        return 'Frecuencia cardíaca';
      case 'respiratoryEffort':
        return 'Esfuerzo respiratorio';
      case 'muscleTone':
        return 'Tono muscular';
      case 'reflexes':
        return 'Reflejos';
      case 'skinColor':
        return 'Color de la piel';
      default:
        return key;
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header de la sección
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido de la sección
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnDetails(List<Map<String, dynamic>> details) {
    // Filtrar detalles que tienen valor
    final detailsWithData = details.where((detail) => 
      detail['value'] != null && 
      (detail['value'] is Widget || (detail['value'] is String && detail['value'].toString().trim().isNotEmpty))
    ).toList();
    
    // Si no hay datos, mostrar mensaje
    if (detailsWithData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No hay información disponible para esta sección',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    List<Widget> rows = [];
    
    for (int i = 0; i < details.length; i++) {
      final detail = details[i];
      final isFullWidth = detail['isFullWidth'] == true || detail['value'] is Widget;
      
      if (isFullWidth) {
        // Para campos que necesitan ancho completo (como firmas)
        rows.add(_buildDetailRow(detail['label'], detail['value']));
      } else {
        // Para campos normales, intentar poner dos en una fila
        Widget leftColumn = _buildDetailRow(detail['label'], detail['value']);
        Widget? rightColumn;
        
        if (i + 1 < details.length && details[i + 1]['isFullWidth'] != true && details[i + 1]['value'] is! Widget) {
          rightColumn = _buildDetailRow(details[i + 1]['label'], details[i + 1]['value']);
          i++; // Saltar el siguiente elemento ya que lo usamos aquí
        }
        
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftColumn),
              const SizedBox(width: 16),
              Expanded(child: rightColumn ?? const SizedBox()),
            ],
          ),
        );
      }
    }
    
    return Column(children: rows);
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '$label:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'No especificado',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: value is Widget 
                ? value 
                : Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _editRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de edición para ${widget.record.patientName} próximamente disponible'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _generatePDF() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(record: widget.record),
      ),
    );
  }

  Future<void> _deleteRecord() async {
    final context = this.context;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar el registro de ${widget.record.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(unifiedFrapProvider.notifier);
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      
      try {
        final success = await notifier.deleteRecord(widget.record);
        
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(success 
                ? 'Registro eliminado exitosamente' 
                : 'Error al eliminar el registro'
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          
          if (success) {
            navigator.pop(); // Regresar a la lista
          }
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Error al eliminar el registro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _shareRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir próximamente disponible'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Construir leyenda visual de tipos de lesiones
  List<Widget> _buildInjuryLegend(List<DrawnInjuryDisplay> injuries) {
    // Obtener tipos únicos
    Set<int> uniqueTypes = injuries.map((injury) => injury.injuryType).toSet();
    
    return uniqueTypes.map((typeIndex) {
      final typeName = _getInjuryTypeName(typeIndex);
      final color = _getInjuryTypeColor(typeIndex);
      final number = typeIndex + 1; // Los números van de 1-10
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              typeName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Obtener color del tipo de lesión
  Color _getInjuryTypeColor(int typeIndex) {
    const colors = [
      Colors.red,           // Hemorragia
      Color(0xFF8D6E63),   // Herida (brown)
      Colors.purple,        // Contusión
      Colors.orange,        // Fractura
      Colors.yellow,        // Luxación/Esguince
      Colors.pink,          // Objeto extraño
      Colors.deepOrange,    // Quemadura
      Colors.green,         // Picadura/Mordedura
      Colors.indigo,        // Edema/Hematoma
      Colors.grey,          // Otro
    ];
    
    if (typeIndex >= 0 && typeIndex < colors.length) {
      return colors[typeIndex];
    }
    return Colors.grey;
  }
} 