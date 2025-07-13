import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_unified_provider.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Registro de Atencion Prehospitalaria',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: widget.record.isLocal ? AppTheme.primaryBlue : AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editRecord(),
            color: Colors.white,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
            colors: [
              widget.record.isLocal ? AppTheme.primaryBlue : AppTheme.primaryGreen,
              (widget.record.isLocal ? AppTheme.primaryBlue : AppTheme.primaryGreen).withOpacity(0.8),
            ],
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
      {'label': 'Tipo de servicio', 'value': serviceInfoMap['serviceType']},
      {'label': 'Número de ambulancia', 'value': serviceInfoMap['ambulanceNumber']},
      {'label': 'Equipo', 'value': serviceInfoMap['crew']},
      {'label': 'Prioridad', 'value': serviceInfoMap['priority']},
      {'label': 'Fecha del servicio', 'value': serviceInfoMap['date']},
      {'label': 'Hora de inicio', 'value': serviceInfoMap['startTime']},
      {'label': 'Hora de fin', 'value': serviceInfoMap['endTime']},
      {'label': 'Ubicación', 'value': serviceInfoMap['location']},
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
      {'label': 'Folio', 'value': registryInfoMap['folio']},
      {'label': 'Fecha de registro', 'value': registryInfoMap['registrationDate']},
      {'label': 'Hora de registro', 'value': registryInfoMap['registrationTime']},
      {'label': 'Registrado por', 'value': registryInfoMap['registeredBy']},
      {'label': 'Unidad operativa', 'value': registryInfoMap['operativeUnit']},
      {'label': 'Turno', 'value': registryInfoMap['shift']},
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
      {'label': 'Condición actual', 'value': patientInfoMap['currentCondition']},
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
      {'label': 'Procedimientos realizados', 'value': managementMap['procedures']},
      {'label': 'Medicamentos administrados', 'value': managementMap['medications']},
      {'label': 'Respuesta al tratamiento', 'value': managementMap['response']},
      {'label': 'Observaciones', 'value': managementMap['observations']},
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
      {'label': 'Medicamentos actuales', 'value': medicationsMap['current_medications']},
      {'label': 'Dosis', 'value': medicationsMap['dosage']},
      {'label': 'Frecuencia', 'value': medicationsMap['frequency']},
      {'label': 'Vía de administración', 'value': medicationsMap['route']},
      {'label': 'Hora de administración', 'value': medicationsMap['time']},
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
      {'label': 'Embarazo', 'value': gynecoObstetricMap['pregnancy']},
      {'label': 'Semanas de gestación', 'value': gynecoObstetricMap['gestationWeeks']},
      {'label': 'Partos previos', 'value': gynecoObstetricMap['previousDeliveries']},
      {'label': 'Cesáreas', 'value': gynecoObstetricMap['cesareans']},
      {'label': 'Abortos', 'value': gynecoObstetricMap['abortions']},
      {'label': 'Última menstruación', 'value': gynecoObstetricMap['lastMenstruation']},
    ];

    return _buildSectionCard(
      title: 'Gineco-Obstétrica',
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
      {'label': 'Motivo', 'value': attentionNegativeMap['reason']},
      {'label': 'Observaciones', 'value': attentionNegativeMap['observations']},
      {'label': 'Fecha', 'value': attentionNegativeMap['date']},
      {'label': 'Hora', 'value': attentionNegativeMap['time']},
    ];

    return _buildSectionCard(
      title: 'Atención Negativa',
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
      {'label': 'Enfermedades previas', 'value': pathologicalHistoryMap['previous_illnesses']},
      {'label': 'Alergias', 'value': pathologicalHistoryMap['allergies']},
      {'label': 'Cirugías previas', 'value': pathologicalHistoryMap['previousSurgeries']},
      {'label': 'Hospitalizaciones', 'value': pathologicalHistoryMap['hospitalizations']},
      {'label': 'Transfusiones', 'value': pathologicalHistoryMap['transfusions']},
    ];

    return _buildSectionCard(
      title: 'Historia Patológica',
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
      {'label': 'Alergias', 'value': clinicalHistoryMap['allergies']},
      {'label': 'Medicamentos', 'value': clinicalHistoryMap['medications']},
      {'label': 'Enfermedades previas', 'value': clinicalHistoryMap['previousIllnesses']},
      {'label': 'Síntomas actuales', 'value': clinicalHistoryMap['currentSymptoms']},
      {'label': 'Dolor', 'value': clinicalHistoryMap['pain']},
      {'label': 'Escala de dolor', 'value': clinicalHistoryMap['painScale']},
    ];

    return _buildSectionCard(
      title: 'Historia Clínica',
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
      {'label': 'Signos vitales', 'value': physicalExamMap['vitalSigns']},
      {'label': 'Presión arterial', 'value': physicalExamMap['bloodPressure']},
      {'label': 'Frecuencia cardíaca', 'value': physicalExamMap['heartRate']},
      {'label': 'Frecuencia respiratoria', 'value': physicalExamMap['respiratoryRate']},
      {'label': 'Temperatura', 'value': physicalExamMap['temperature']},
      {'label': 'Saturación de oxígeno', 'value': physicalExamMap['oxygenSaturation']},
      {'label': 'Cabeza', 'value': physicalExamMap['head']},
      {'label': 'Cuello', 'value': physicalExamMap['neck']},
      {'label': 'Tórax', 'value': physicalExamMap['thorax']},
      {'label': 'Abdomen', 'value': physicalExamMap['abdomen']},
      {'label': 'Extremidades', 'value': physicalExamMap['extremities']},
      {'label': 'Neurológico', 'value': physicalExamMap['neurological']},
    ];

    return _buildSectionCard(
      title: 'Examen Físico',
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
      {'label': 'Justificación', 'value': priorityJustificationMap['justification']},
      {'label': 'Criterios', 'value': priorityJustificationMap['criteria']},
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

    final details = [
      {'label': 'Ubicación', 'value': injuryLocationMap['location']},
      {'label': 'Tipo de lesión', 'value': injuryLocationMap['injuryType']},
      {'label': 'Gravedad', 'value': injuryLocationMap['severity']},
      {'label': 'Descripción', 'value': injuryLocationMap['description']},
    ];

    return _buildSectionCard(
      title: 'Localización de Lesiones',
      icon: Icons.location_on,
      color: Colors.red,
      child: _buildTwoColumnDetails(details),
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
      {'label': 'Hospital', 'value': receivingUnitMap['hospital']},
      {'label': 'Servicio', 'value': receivingUnitMap['service']},
      {'label': 'Médico receptor', 'value': receivingUnitMap['receivingDoctor']},
      {'label': 'Hora de entrega', 'value': receivingUnitMap['deliveryTime']},
    ];

    return _buildSectionCard(
      title: 'Unidad Receptora',
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
      {'label': 'Estado al ingreso', 'value': patientReceptionMap['admissionStatus']},
      {'label': 'Signos vitales al ingreso', 'value': patientReceptionMap['admissionVitals']},
      {'label': 'Diagnóstico inicial', 'value': patientReceptionMap['initialDiagnosis']},
      {'label': 'Tratamiento inicial', 'value': patientReceptionMap['initialTreatment']},
    ];

    return _buildSectionCard(
      title: 'Recepción del Paciente',
      icon: Icons.how_to_reg,
      color: Colors.green,
      child: _buildTwoColumnDetails(details),
    );
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
      detail['value'].toString().trim().isNotEmpty
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
    
    for (int i = 0; i < details.length; i += 2) {
      Widget leftColumn = _buildDetailRow(details[i]['label'], details[i]['value']);
      Widget? rightColumn;
      
      if (i + 1 < details.length) {
        rightColumn = _buildDetailRow(details[i + 1]['label'], details[i + 1]['value']);
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
    
    return Column(children: rows);
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
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

  void _editRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de edición para ${widget.record.patientName} próximamente disponible'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _generatePDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generando PDF para ${widget.record.patientName}...'),
        backgroundColor: Colors.blue,
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
} 