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

// Clase de configuración para secciones
class SectionConfig {
  final String key;
  final String title;
  final IconData icon;
  final Color color;
  final Map<String, String> fieldMappings;
  final Map<String, dynamic> fallbacks;
  final Map<String, Map<String, dynamic>> specialFields;
  final Map<String, String> booleanFields;
  final Map<String, Map<String, dynamic>> conditionalFields;
  final List<String> vitalSigns;

  const SectionConfig({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.fieldMappings,
    this.fallbacks = const {},
    this.specialFields = const {},
    this.booleanFields = const {},
    this.conditionalFields = const {},
    this.vitalSigns = const [],
  });
}

class FrapRecordDetailsScreen extends ConsumerStatefulWidget {
  final UnifiedFrapRecord record;

  const FrapRecordDetailsScreen({super.key, required this.record});

  @override
  ConsumerState<FrapRecordDetailsScreen> createState() =>
      _FrapRecordDetailsScreenState();
}

class _FrapRecordDetailsScreenState
    extends ConsumerState<FrapRecordDetailsScreen> {
  late Map<String, dynamic> _detailedInfo;
  bool _isLoading = true;

  // Configuración centralizada de secciones
  late final List<SectionConfig> _sectionConfigs;

  @override
  void initState() {
    super.initState();
    _initializeSectionConfigs();
    _loadDetailedInfo();
  }

  void _initializeSectionConfigs() {
    _sectionConfigs = [
      SectionConfig(
        key: 'serviceInfo',
        title: 'Información del Servicio',
        icon: Icons.local_hospital,
        color: Colors.blue,
        fieldMappings: {
          'horaLlamada': 'Hora de llamada',
          'horaArribo': 'Hora de arribo',
          'tiempoEsperaArribo': 'Tiempo de espera arribo',
          'horaLlegada': 'Hora de llegada',
          'horaTermino': 'Hora de terminación',
          'tiempoEsperaLlegada': 'Tiempo de espera llegada',
          'ubicacion': 'Ubicación',
          'tipoServicio': 'Tipo de servicio',
          'tipoServicioEspecifique': 'Especifique',
          'lugarOcurrencia': 'Lugar de ocurrencia',
          'lugarOcurrenciaEspecifique': 'Especifique lugar',
          'tipoUrgencia': 'Tipo de urgencia',
          'urgenciaEspecifique': 'Especifique urgencia',
        },
        specialFields: {
          'consentimientoSignature': {
            'label': 'Firma de consentimiento',
            'isSignature': true,
            'signatureTitle': 'Firma de Consentimiento',
          },
        },
      ),
      SectionConfig(
        key: 'registryInfo',
        title: 'Información del Registro',
        icon: Icons.assignment,
        color: Colors.indigo,
        fieldMappings: {
          'convenio': 'Convenio',
          'folio': 'Folio',
          'episodio': 'Episodio',
          'fecha': 'Fecha de registro',
          'solicitadoPor': 'Solicitado por',
        },
      ),
      SectionConfig(
        key: 'patientInfo',
        title: 'Información del Paciente',
        icon: Icons.person,
        color: Colors.green,
        fieldMappings: {
          'name': 'Nombre completo',
          'age': 'Edad',
          'sex': 'Sexo',
          'genero': 'Género',
          'phone': 'Teléfono',
          'emergencyContact': 'Contacto de emergencia',
          'responsiblePerson': 'Persona responsable',
          'entreCalles': 'Entre calles',
          'currentCondition': 'Padecimiento actual',
          'insurance': 'Seguro médico',
          'tipoEntrega': 'Tipo de entrega',
          'tipoEntregaOtro': 'Especifique tipo de entrega',
        },
        fallbacks: {
          'name': widget.record.patientName,
          'age': '${widget.record.patientAge} años',
          'sex': widget.record.patientGender,
        },
        specialFields: {
          'address': {
            'label': 'Dirección',
            'isFullWidth': true,
            'customBuilder': (data) => _buildFullAddress(data),
          },
        },
      ),
      SectionConfig(
        key: 'management',
        title: 'Manejo',
        icon: Icons.healing,
        color: Colors.purple,
        fieldMappings: {'observaciones': 'Observaciones'},
        booleanFields: {
          'viaAerea': 'Vía aérea',
          'canalizacion': 'Canalización',
          'empaquetamiento': 'Empaquetamiento',
          'inmovilizacion': 'Inmovilización',
          'monitor': 'Monitor',
          'rcpBasica': 'RCP básica',
          'mastPna': 'MAST/PNA',
          'collarinCervical': 'Collarín cervical',
          'desfibrilacion': 'Desfibrilación',
          'apoyoVent': 'Apoyo ventilatorio',
        },
        conditionalFields: {
          'oxigeno': {
            'label': 'Oxígeno',
            'condition': (data) => data['oxigeno'] == true,
            'dependentField': 'ltMin',
            'dependentLabel': 'Lt/min',
          },
          'viaAerea': {
            'label': 'Especifique vía aérea',
            'condition': (data) => data['viaAerea'] == true,
            'dependentField': 'viaAereaEspecifique',
            'dependentLabel': 'Especifique',
          },
          'canalizacion': {
            'label': 'Especifique canalización',
            'condition': (data) => data['canalizacion'] == true,
            'dependentField': 'canalizacionEspecifique',
            'dependentLabel': 'Especifique',
          },
          'empaquetamiento': {
            'label': 'Especifique empaquetamiento',
            'condition': (data) => data['empaquetamiento'] == true,
            'dependentField': 'empaquetamientoEspecifique',
            'dependentLabel': 'Especifique',
          },
          'inmovilizacion': {
            'label': 'Especifique inmovilización',
            'condition': (data) => data['inmovilizacion'] == true,
            'dependentField': 'inmovilizacionEspecifique',
            'dependentLabel': 'Especifique',
          },
          'monitor': {
            'label': 'Especifique monitor',
            'condition': (data) => data['monitor'] == true,
            'dependentField': 'monitorEspecifique',
            'dependentLabel': 'Especifique',
          },
          'rcpBasica': {
            'label': 'Especifique RCP básica',
            'condition': (data) => data['rcpBasica'] == true,
            'dependentField': 'rcpBasicaEspecifique',
            'dependentLabel': 'Especifique',
          },
          'mastPna': {
            'label': 'Especifique MAST/PNA',
            'condition': (data) => data['mastPna'] == true,
            'dependentField': 'mastPnaEspecifique',
            'dependentLabel': 'Especifique',
          },
          'collarinCervical': {
            'label': 'Especifique collarín cervical',
            'condition': (data) => data['collarinCervical'] == true,
            'dependentField': 'collarinCervicalEspecifique',
            'dependentLabel': 'Especifique',
          },
          'desfibrilacion': {
            'label': 'Especifique desfibrilación',
            'condition': (data) => data['desfibrilacion'] == true,
            'dependentField': 'desfibrilacionEspecifique',
            'dependentLabel': 'Especifique',
          },
          'apoyoVent': {
            'label': 'Especifique apoyo ventilatorio',
            'condition': (data) => data['apoyoVent'] == true,
            'dependentField': 'apoyoVentEspecifique',
            'dependentLabel': 'Especifique',
          },
          'oxigenoEspecifique': {
            'label': 'Especifique oxígeno',
            'condition': (data) => data['oxigeno'] == true,
            'dependentField': 'oxigenoEspecifique',
            'dependentLabel': 'Especifique',
          },
        },
      ),
      SectionConfig(
        key: 'medications',
        title: 'Medicamentos',
        icon: Icons.medication,
        color: Colors.orange,
        fieldMappings: {
          'medications': 'Medicamentos',
          'observaciones': 'Observaciones',
        },
        specialFields: {
          'medicationsList': {
            'label': 'Lista de medicamentos',
            'isFullWidth': true,
            'customBuilder': (data) => _buildMedicationsList(data),
          },
        },
      ),
      SectionConfig(
        key: 'gynecoObstetric',
        title: 'Urgencias Gineco-Obstétricas',
        icon: Icons.pregnant_woman,
        color: Colors.pink,
        fieldMappings: {
          'fum': 'Última menstruación',
          'semanasGestacion': 'Semanas de gestación',
          'gesta': 'Gesta',
          'abortos': 'Abortos',
          'partos': 'Partos',
          'cesareas': 'Cesáreas',
          'metodosAnticonceptivos': 'Métodos anticonceptivos',
          'ruidosCardiacosFetales': 'Ruidos cardíacos fetales',
          'expulsionPlacenta': 'Expulsión de placenta',
          'hora': 'Hora',
          'observaciones': 'Observaciones',
          'frecuenciaCardiacaFetal': 'Frecuencia cardíaca fetal',
          'contracciones': 'Contracciones',
        },
        booleanFields: {
          'isParto': 'Es parto',
          'isAborto': 'Es aborto',
          'isHxVaginal': 'Hx vaginal',
          'ruidosFetalesPerceptibles': 'Ruidos fetales perceptibles',
        },
        specialFields: {
          'silvermanAnderson': {
            'label': 'Escala Silverman-Anderson',
            'isFullWidth': true,
            'customBuilder':
                (data) => _buildSilvermanAndersonDisplay(
                  data['silvermanAnderson'] ?? {},
                ),
          },
          'apgar': {
            'label': 'Escala APGAR',
            'isFullWidth': true,
            'customBuilder': (data) => _buildApgarDisplay(data['apgar'] ?? {}),
          },
        },
      ),
      SectionConfig(
        key: 'attentionNegative',
        title: 'Negativa de atención',
        icon: Icons.cancel,
        color: Colors.red,
        fieldMappings: {
          'motivoNegativa': 'Motivo de negativa',
          'observaciones': 'Observaciones',
          'declarationText': 'Declaración del paciente',
        },
        specialFields: {
          'patientSignature': {
            'label': 'Firma paciente',
            'isSignature': true,
            'signatureTitle': 'Firma del Paciente',
          },
          'witnessSignature': {
            'label': 'Firma Testigo',
            'isSignature': true,
            'signatureTitle': 'Firma del Testigo',
          },
        },
      ),
      SectionConfig(
        key: 'pathologicalHistory',
        title: 'Antecedentes Patológicos',
        icon: Icons.history,
        color: Colors.brown,
        fieldMappings: {'observaciones': 'Observaciones'},
        booleanFields: {
          'diabetes': 'Diabetes',
          'hipertension': 'Hipertensión',
          'cardiopatias': 'Cardiopatías',
          'enfermedadesRenales': 'Enfermedades renales',
          'enfermedadesHepaticas': 'Enfermedades hepáticas',
          'enfermedadesRespiratorias': 'Enfermedades respiratorias',
          'enfermedadesNeurologicas': 'Enfermedades neurológicas',
          'cancer': 'Cáncer',
          'vih': 'VIH',
          'otras': 'Otras',
        },
        conditionalFields: {
          'diabetes': {
            'label': 'Especifique diabetes',
            'condition': (data) => data['diabetes'] == true,
            'dependentField': 'diabetesEspecifique',
            'dependentLabel': 'Especifique',
          },
          'hipertension': {
            'label': 'Especifique hipertensión',
            'condition': (data) => data['hipertension'] == true,
            'dependentField': 'hipertensionEspecifique',
            'dependentLabel': 'Especifique',
          },
          'cardiopatias': {
            'label': 'Especifique cardiopatías',
            'condition': (data) => data['cardiopatias'] == true,
            'dependentField': 'cardiopatiasEspecifique',
            'dependentLabel': 'Especifique',
          },
          'enfermedadesRenales': {
            'label': 'Especifique enfermedades renales',
            'condition': (data) => data['enfermedadesRenales'] == true,
            'dependentField': 'enfermedadesRenalesEspecifique',
            'dependentLabel': 'Especifique',
          },
          'enfermedadesHepaticas': {
            'label': 'Especifique enfermedades hepáticas',
            'condition': (data) => data['enfermedadesHepaticas'] == true,
            'dependentField': 'enfermedadesHepaticasEspecifique',
            'dependentLabel': 'Especifique',
          },
          'enfermedadesRespiratorias': {
            'label': 'Especifique enfermedades respiratorias',
            'condition': (data) => data['enfermedadesRespiratorias'] == true,
            'dependentField': 'enfermedadesRespiratoriasEspecifique',
            'dependentLabel': 'Especifique',
          },
          'enfermedadesNeurologicas': {
            'label': 'Especifique enfermedades neurológicas',
            'condition': (data) => data['enfermedadesNeurologicas'] == true,
            'dependentField': 'enfermedadesNeurologicasEspecifique',
            'dependentLabel': 'Especifique',
          },
          'cancer': {
            'label': 'Especifique cáncer',
            'condition': (data) => data['cancer'] == true,
            'dependentField': 'cancerEspecifique',
            'dependentLabel': 'Especifique',
          },
          'vih': {
            'label': 'Especifique VIH',
            'condition': (data) => data['vih'] == true,
            'dependentField': 'vihEspecifique',
            'dependentLabel': 'Especifique',
          },
          'otras': {
            'label': 'Especifique otras',
            'condition': (data) => data['otras'] == true,
            'dependentField': 'otrasEspecifique',
            'dependentLabel': 'Especifique',
          },
        },
      ),
      SectionConfig(
        key: 'clinicalHistory',
        title: 'Antecedentes Clínicos',
        icon: Icons.medical_services,
        color: Colors.teal,
        fieldMappings: {
          'agenteCausal': 'Agente causal',
          'cinematica': 'Cinemática',
          'medidaSeguridad': 'Medida de Seguridad',
          'observaciones': 'Observaciones',
        },
        booleanFields: {
          'traumaCraneo': 'Trauma cráneo',
          'traumaTorax': 'Trauma tórax',
          'traumaAbdomen': 'Trauma abdomen',
          'traumaColumna': 'Trauma columna',
          'traumaExtremidades': 'Trauma extremidades',
          'traumaPelvis': 'Trauma pelvis',
          'traumaOtros': 'Trauma otros',
        },
        conditionalFields: {
          'traumaCraneo': {
            'label': 'Especifique trauma cráneo',
            'condition': (data) => data['traumaCraneo'] == true,
            'dependentField': 'traumaCraneoEspecifique',
            'dependentLabel': 'Especifique',
          },
          'traumaTorax': {
            'label': 'Especifique trauma tórax',
            'condition': (data) => data['traumaTorax'] == true,
            'dependentField': 'traumaToraxEspecifique',
            'dependentLabel': 'Especifique',
          },
          'traumaAbdomen': {
            'label': 'Especifique trauma abdomen',
            'condition': (data) => data['traumaAbdomen'] == true,
            'dependentField': 'traumaAbdomenEspecifique',
            'dependentLabel': 'Especifique',
          },
          'traumaColumna': {
            'label': 'Especifique trauma columna',
            'condition': (data) => data['traumaColumna'] == true,
            'dependentField': 'traumaColumnaEspecifique',
            'dependentLabel': 'Especifique',
          },
          'traumaExtremidades': {
            'label': 'Especifique trauma extremidades',
            'condition': (data) => data['traumaExtremidades'] == true,
            'dependentField': 'traumaExtremidadesEspecifique',
            'dependentLabel': 'Especifique',
          },
          'traumaPelvis': {
            'label': 'Especifique trauma pelvis',
            'condition': (data) => data['traumaPelvis'] == true,
            'dependentField': 'traumaPelvisEspecifique',
            'dependentLabel': 'Especifique',
          },
          'traumaOtros': {
            'label': 'Especifique trauma otros',
            'condition': (data) => data['traumaOtros'] == true,
            'dependentField': 'traumaOtrosEspecifique',
            'dependentLabel': 'Especifique',
          },
        },
      ),
      SectionConfig(
        key: 'physicalExam',
        title: 'Exploración Física',
        icon: Icons.health_and_safety,
        color: Colors.cyan,
        fieldMappings: {
          'head': 'Cabeza',
          'neck': 'Cuello',
          'thorax': 'Tórax',
          'abdomen': 'Abdomen',
          'extremities': 'Extremidades',
          'neurological': 'Neurológico',
          'observaciones': 'Observaciones',
          'eva': 'EVA',
          'llc': 'LLC',
          'glucosa': 'Glucosa',
          'ta': 'T/A',
          'sampleAlergias': 'Alergias',
          'sampleMedicamentos': 'Medicamentos',
          'sampleEnfermedades': 'Enfermedades',
          'sampleHoraAlimento': 'Hora último alimento',
          'sampleEventosPrevios': 'Eventos previos',
        },
        vitalSigns: [
          'T/A',
          'FC',
          'FR',
          'Temp.',
          'Sat. O2',
          'LLC',
          'Glu',
          'Glasgow',
        ],
      ),
      SectionConfig(
        key: 'priorityJustification',
        title: 'Justificación de Prioridad',
        icon: Icons.priority_high,
        color: Colors.deepOrange,
        fieldMappings: {
          'priority': 'Prioridad',
          'pupils': 'Pupilas',
          'skinColor': 'Color piel',
          'skin': 'Piel',
          'temperature': 'Temperatura',
        },
        conditionalFields: {
          'influence': {
            'label': 'Influenciado por',
            'condition': (data) => data['influence'] == 'Otro',
            'dependentField': 'especifique',
            'dependentLabel': 'Especifique',
          },
        },
      ),
      SectionConfig(
        key: 'receivingUnit',
        title: 'Unidad Medica que Recibe',
        icon: Icons.local_hospital,
        color: Colors.indigo,
        fieldMappings: {
          'lugarOrigen': 'Lugar de origen',
          'lugarDestino': 'Lugar de destino',
          'lugarConsulta': 'Lugar de consulta',
          'ambulanciaNumero': 'Número de ambulancia',
          'ambulanciaPlacas': 'Placas de ambulancia',
          'personal': 'Personal',
          'doctor': 'Doctor',
          'otroLugar': 'Otro lugar',
          'observaciones': 'Observaciones',
        },
        specialFields: {
          'personalMedico': {
            'label': 'Personal médico',
            'isFullWidth': true,
            'customBuilder': (data) => _buildPersonalMedicoList(data),
          },
        },
      ),
      SectionConfig(
        key: 'patientReception',
        title: 'Recepción del Paciente',
        icon: Icons.how_to_reg,
        color: Colors.green,
        fieldMappings: {
          'receivingDoctor': 'Medico que recibe',
          'doctorName': 'Nombre del doctor',
          'doctorCedula': 'Cédula del doctor',
        },
        specialFields: {
          'doctorSignature': {
            'label': 'Firma del medico',
            'isSignature': true,
            'signatureTitle': 'Firma del Médico',
          },
        },
      ),
    ];
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
      // Validar que el string no esté vacío
      if (base64Data.trim().isEmpty) {
        return Uint8List(0);
      }

      // Remover el prefijo 'data:image/png;base64,' si existe
      final base64String = base64Data.split(',').last;

      // Validar que el string base64 sea válido
      if (base64String.isEmpty) {
        return Uint8List(0);
      }

      return base64Decode(base64String);
    } catch (e) {
      return Uint8List(0);
    }
  }

  // Método para mostrar firma en tamaño grande
  void _showSignatureFullScreen(
    String title,
    String base64Data, {
    String? doctorName,
  }) {
    try {
      final decodedBytes = _getImageBytesFromBase64(base64Data);
      if (decodedBytes.isNotEmpty) {
        showDialog(
          context: context,
          builder:
              (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue[600], size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Contenido de la firma
                      Flexible(
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
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
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
                      if (doctorName != null)
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
                                  'Médico: $doctorName',
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
            itemBuilder:
                (context) => [
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header con información básica
                      _buildHeaderCard(),

                      const SizedBox(height: 16),

                      // Información del servicio
                      _buildSectionFromConfig(_sectionConfigs[0]),

                      // Información del registro
                      _buildSectionFromConfig(_sectionConfigs[1]),

                      // Información del paciente
                      _buildSectionFromConfig(_sectionConfigs[2]),

                      // Manejo
                      _buildSectionFromConfig(_sectionConfigs[3]),

                      // Medicamentos
                      _buildSectionFromConfig(_sectionConfigs[4]),

                      // Gineco-obstétrica
                      _buildSectionFromConfig(_sectionConfigs[5]),

                      // Atención negativa
                      _buildSectionFromConfig(_sectionConfigs[6]),

                      // Historia patológica
                      _buildSectionFromConfig(_sectionConfigs[7]),

                      // Historia clínica
                      _buildSectionFromConfig(_sectionConfigs[8]),

                      // Examen físico
                      _buildSectionFromConfig(_sectionConfigs[9]),

                      // Justificación de prioridad
                      _buildSectionFromConfig(_sectionConfigs[10]),

                      // Localización de lesiones
                      _buildInjuryLocationSection(),

                      // Unidad receptora
                      _buildSectionFromConfig(_sectionConfigs[11]),

                      // Recepción del paciente
                      _buildSectionFromConfig(_sectionConfigs[12]),

                      // Nuevas secciones agregadas
                      _buildInsumosSection(),

                      _buildPersonalMedicoSection(),

                      _buildEscalasObstetricasSection(),

                      const SizedBox(height: 32),
                    ],
                  ),
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
            colors:
                widget.record.patientGender.toLowerCase() == 'femenino'
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
                  child: Icon(Icons.person, size: 32, color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(widget.record.createdAt),
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

  // Información del servicio
  Widget _buildSectionFromConfig(SectionConfig config) {
    final details = _buildDetailsFromConfig(config);

    if (details.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: config.title,
      icon: config.icon,
      color: config.color,
      child: _buildThreeColumnDetails(details),
    );
  }

  // Método auxiliar para construir widgets de firma de manera segura
  Widget _buildSignatureWidget(dynamic signatureData, String signatureTitle) {
    try {
      if (signatureData != null && signatureData.toString().isNotEmpty) {
        final decodedBytes = _getImageBytesFromBase64(signatureData.toString());
        if (decodedBytes.isNotEmpty) {
          return GestureDetector(
            onTap:
                () => _showSignatureFullScreen(
                  signatureTitle,
                  signatureData.toString(),
                ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.memory(
                decodedBytes,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Text('Firma no disponible'),
              ),
            ),
          );
        }
      }
      return const Text('No registrada');
    } catch (e) {
      return const Text('Firma corrupta');
    }
  }

  Widget _buildThreeColumnDetails(List<Map<String, dynamic>> details) {
    // Filtrar detalles que tienen valor
    final detailsWithData =
        details
            .where(
              (detail) =>
                  detail['value'] != null &&
                  (detail['value'] is Widget ||
                      (detail['value'] is String &&
                          detail['value'].toString().trim().isNotEmpty)),
            )
            .toList();

    // Si no hay datos, mostrar mensaje
    if (detailsWithData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay información disponible',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete la información para ver los datos aquí',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Separar campos especiales (firmas y ancho completo) de campos normales
    final normalFields =
        detailsWithData
            .where((d) => d['isSignature'] != true && d['isFullWidth'] != true)
            .toList();
    final specialFields =
        detailsWithData
            .where((d) => d['isSignature'] == true || d['isFullWidth'] == true)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campos normales en 3 columnas
        if (normalFields.isNotEmpty) ...[
          _buildThreeColumnGrid(normalFields),
          if (specialFields.isNotEmpty) const SizedBox(height: 24),
        ],

        // Campos especiales (firmas y ancho completo) en ancho completo
        if (specialFields.isNotEmpty) ...[
          ...specialFields.map((detail) {
            if (detail['isFullWidth'] == true) {
              return _buildFullWidthDetail(detail['label'], detail['value']);
            }
            return _buildServiceDetailCard(
              detail['label'],
              detail['value'],
              isSignature: detail['isSignature'] == true,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildThreeColumnGrid(List<Map<String, dynamic>> details) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return _buildServiceDetailCard(detail['label'], detail['value']);
      },
    );
  }

  Widget _buildServiceDetailCard(
    String label,
    dynamic value, {
    bool isSignature = false,
  }) {
    final hasValue =
        value != null &&
        (value is Widget ||
            (value is String && value.toString().trim().isNotEmpty));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Row(
          children: [
            Icon(
              _getIconForField(label),
              size: 16,
              color: hasValue ? Colors.blue[600] : Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: hasValue ? Colors.blue[700] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Value
        value is Widget
            ? value
            : Text(
              hasValue ? value.toString() : 'No especificado',
              style: TextStyle(
                fontSize: 12,
                fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                color: hasValue ? Colors.black87 : Colors.grey[500],
              ),
              maxLines: isSignature ? 1 : 3,
              overflow: TextOverflow.ellipsis,
            ),
      ],
    );
  }

  IconData _getIconForField(String label) {
    if (label.contains('Hora')) return Icons.access_time;
    if (label.contains('Tiempo')) return Icons.timer;
    if (label.contains('Ubicacion')) return Icons.location_on;
    if (label.contains('Tipo')) return Icons.category;
    if (label.contains('Lugar')) return Icons.place;
    if (label.contains('Urgencia')) return Icons.emergency;
    if (label.contains('Firma')) return Icons.edit;
    if (label.contains('Especifique')) return Icons.edit_note;
    return Icons.info_outline;
  }

  ////////////////////////
  // Información del registro
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

  ////////////////////////
  // Información del paciente
  Widget _buildPatientInfoSection() {
    final patientInfo = _detailedInfo['patientInfo'];
    Map<String, dynamic> patientInfoMap = {};
    if (patientInfo is Map) {
      patientInfoMap = Map<String, dynamic>.from(patientInfo);
    }

    // Debug: Verificar el valor de entreCalles
    final entreCallesValue = _getSafeStringValue(patientInfoMap, 'entreCalles');
    print('DEBUG: entreCalles value: $entreCallesValue');
    print('DEBUG: patientInfoMap keys: ${patientInfoMap.keys.toList()}');

    final details = [
      {
        'label': 'Nombre completo',
        'value':
            _getSafeStringValue(patientInfoMap, 'name') ??
            widget.record.patientName,
      },
      {
        'label': 'Edad',
        'value': _formatAge(
          _getSafeStringValue(patientInfoMap, 'age'),
          widget.record.patientAge,
        ),
      },
      {
        'label': 'Sexo',
        'value':
            _getSafeStringValue(patientInfoMap, 'sex') ??
            widget.record.patientGender,
      },
      {
        'label': 'Género',
        'value': _getSafeStringValue(patientInfoMap, 'genero'),
      },
      {
        'label': 'Teléfono',
        'value': _formatPhone(_getSafeStringValue(patientInfoMap, 'phone')),
      },
      {
        'label': 'Contacto de emergencia',
        'value': _getSafeStringValue(patientInfoMap, 'emergencyContact'),
      },
      {
        'label': 'Persona responsable',
        'value': _getSafeStringValue(patientInfoMap, 'responsiblePerson'),
      },
      {
        'label': 'Dirección',
        'value': _buildFullAddress(patientInfoMap),
        'isFullWidth': true,
      },
      {
        'label': 'Entre calles',
        'value': _getSafeStringValue(patientInfoMap, 'entreCalles'),
      },
      {
        'label': 'Padecimiento actual',
        'value': _getSafeStringValue(patientInfoMap, 'currentCondition'),
        'isFullWidth': true,
      },
      {
        'label': 'Seguro médico',
        'value': _getSafeStringValue(patientInfoMap, 'insurance'),
      },
      {
        'label': 'Tipo de entrega',
        'value': _getSafeStringValue(patientInfoMap, 'tipoEntrega'),
      },
      if (_getSafeStringValue(patientInfoMap, 'tipoEntregaOtro') != null)
        {
          'label': 'Especifique tipo de entrega',
          'value': _getSafeStringValue(patientInfoMap, 'tipoEntregaOtro'),
        },
    ];

    return _buildSectionCard(
      title: 'Información del Paciente',
      icon: Icons.person,
      color: Colors.green,
      child: _buildTwoColumnDetails(details),
    );
  }

  // Método para construir dirección completa
  String _buildFullAddress(Map<String, dynamic> patientInfoMap) {
    final addressParts = <String>[];

    final street = _getSafeStringValue(patientInfoMap, 'street');
    final extNumber = _getSafeStringValue(patientInfoMap, 'exteriorNumber');
    final intNumber = _getSafeStringValue(patientInfoMap, 'interiorNumber');
    final neighborhood = _getSafeStringValue(patientInfoMap, 'neighborhood');
    final city = _getSafeStringValue(patientInfoMap, 'city');

    if (street != null) addressParts.add(street);
    if (extNumber != null) addressParts.add('No. $extNumber');
    if (intNumber != null) addressParts.add('Int. $intNumber');
    if (neighborhood != null) addressParts.add('Col. $neighborhood');
    if (city != null) addressParts.add(city);

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : _getSafeStringValue(patientInfoMap, 'address') ??
            widget.record.patientAddress;
  }

  // Método para formatear edad
  String _formatAge(String? age, int fallbackAge) {
    if (age == null || age.trim().isEmpty) {
      return '$fallbackAge años';
    }

    try {
      final ageNum = int.parse(age);
      if (ageNum < 0 || ageNum > 150) {
        return '$fallbackAge años';
      }
      return '$ageNum años';
    } catch (e) {
      return '$fallbackAge años';
    }
  }

  // Método para formatear teléfono
  String? _formatPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null;
    }

    // Remover caracteres no numéricos
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length == 10) {
      // Formato: (XXX) XXX-XXXX
      return '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 7) {
      // Formato: XXX-XXXX
      return '${cleanPhone.substring(0, 3)}-${cleanPhone.substring(3)}';
    }

    return phone; // Devolver original si no coincide con formatos conocidos
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
        if (managementMap['viaAerea'] == true)
          {'label': 'Vía aérea', 'value': 'Sí'},
        if (managementMap['canalizacion'] == true)
          {'label': 'Canalización', 'value': 'Sí'},
        if (managementMap['empaquetamiento'] == true)
          {'label': 'Empaquetamiento', 'value': 'Sí'},
        if (managementMap['inmovilizacion'] == true)
          {'label': 'Inmovilización', 'value': 'Sí'},
        if (managementMap['monitor'] == true)
          {'label': 'Monitor', 'value': 'Sí'},
        if (managementMap['rcpBasica'] == true)
          {'label': 'RCP básica', 'value': 'Sí'},
        if (managementMap['mastPna'] == true)
          {'label': 'MAST/PNA', 'value': 'Sí'},
        if (managementMap['collarinCervical'] == true)
          {'label': 'Collarín cervical', 'value': 'Sí'},
        if (managementMap['desfibrilacion'] == true)
          {'label': 'Desfibrilación', 'value': 'Sí'},
        if (managementMap['apoyoVent'] == true)
          {'label': 'Apoyo ventilatorio', 'value': 'Sí'},
        if (managementMap['oxigeno'] != null)
          {
            'label': 'Oxígeno',
            'value': managementMap['oxigeno'] == true ? 'Sí' : 'No',
          },
        if (managementMap['oxigeno'] == true &&
            managementMap['ltMin'] != null &&
            managementMap['ltMin'].toString().isNotEmpty)
          {'label': 'Lt/min', 'value': managementMap['ltMin']},
      ],
      // Campos adicionales que pueden estar en el manejo
      if (managementMap['observaciones'] != null &&
          managementMap['observaciones'].toString().isNotEmpty)
        {
          'label': 'Observaciones',
          'value': managementMap['observaciones'],
          'isFullWidth': true,
        },
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
      {'label': 'Observaciones', 'value': medicationsMap['observaciones']},
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
      {
        'label': 'Semanas de gestación',
        'value': gynecoObstetricMap['semanasGestacion'],
      },
      {'label': 'Gesta', 'value': gynecoObstetricMap['gesta']},
      {'label': 'Abortos', 'value': gynecoObstetricMap['abortos']},
      {'label': 'Partos', 'value': gynecoObstetricMap['partos']},
      {'label': 'Cesáreas', 'value': gynecoObstetricMap['cesareas']},
      {
        'label': 'Métodos anticonceptivos',
        'value': gynecoObstetricMap['metodosAnticonceptivos'],
      },
      {
        'label': 'Ruidos cardiacos fetales',
        'value': gynecoObstetricMap['ruidosCardiacosFetales'],
      },
      {
        'label': 'Expulsión de placenta',
        'value': gynecoObstetricMap['expulsionPlacenta'],
      },
      {'label': 'Hora', 'value': gynecoObstetricMap['hora']},
      {'label': 'Observaciones', 'value': gynecoObstetricMap['observaciones']},
      {
        'label': 'Frecuencia cardíaca fetal',
        'value': gynecoObstetricMap['frecuenciaCardiacaFetal'],
      },
      {'label': 'Contracciones', 'value': gynecoObstetricMap['contracciones']},
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
        'value': _buildSignatureWidget(
          attentionNegativeMap['patientSignature'],
          'Firma del Paciente',
        ),
        'isSignature': true,
      },
      {
        'label': 'Firma Testigo',
        'value': _buildSignatureWidget(
          attentionNegativeMap['witnessSignature'],
          'Firma del Testigo',
        ),
        'isSignature': true,
      },
      {
        'label': 'Motivo de negativa',
        'value': attentionNegativeMap['motivoNegativa'],
      },
      {
        'label': 'Observaciones',
        'value': attentionNegativeMap['observaciones'],
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
      {
        'label': 'Respiratoria',
        'value': pathologicalHistoryMap['respiratoria'] == true ? 'Sí' : 'No',
      },
      {
        'label': 'Emocional',
        'value': pathologicalHistoryMap['emocional'] == true ? 'Sí' : 'No',
      },
      {
        'label': 'Traumática',
        'value': pathologicalHistoryMap['traumatica'] == true ? 'Sí' : 'No',
      },
      {
        'label': 'Cardiovascular',
        'value': pathologicalHistoryMap['cardiovascular'] == true ? 'Sí' : 'No',
      },
      {
        'label': 'Neurológica',
        'value': pathologicalHistoryMap['neurologica'] == true ? 'Sí' : 'No',
      },
      {
        'label': 'Alérgico',
        'value': pathologicalHistoryMap['alergico'] == true ? 'Sí' : 'No',
      },
      {
        'label': 'Otro',
        'value':
            pathologicalHistoryMap['otro'] == true
                ? (pathologicalHistoryMap['otherDescription'] ?? '')
                : 'No',
      },
      {
        'label': 'Metabólica',
        'value': pathologicalHistoryMap['metabolica'] == true ? 'Sí' : 'No',
      },
      {
        'label': 'Observaciones',
        'value': pathologicalHistoryMap['observaciones'],
      },
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
        if (clinicalHistoryMap['atropellado'] == true)
          {'label': 'Atropellado', 'value': 'Sí'},
        if (clinicalHistoryMap['lxPorCaida'] == true)
          {'label': 'Lx por caída', 'value': 'Sí'},
        if (clinicalHistoryMap['intoxicacion'] == true)
          {'label': 'Intoxicación', 'value': 'Sí'},
        if (clinicalHistoryMap['amputacion'] == true)
          {'label': 'Amputación', 'value': 'Sí'},
        if (clinicalHistoryMap['choque'] == true)
          {'label': 'Choque', 'value': 'Sí'},
        if (clinicalHistoryMap['agresion'] == true)
          {'label': 'Agresión', 'value': 'Sí'},
        if (clinicalHistoryMap['hpaf'] == true)
          {'label': 'HPAF', 'value': 'Sí'},
        if (clinicalHistoryMap['hpab'] == true)
          {'label': 'HPAB', 'value': 'Sí'},
        if (clinicalHistoryMap['volcadura'] == true)
          {'label': 'Volcadura', 'value': 'Sí'},
        if (clinicalHistoryMap['quemadura'] == true)
          {'label': 'Quemadura', 'value': 'Sí'},
      ],
      {
        'label': 'Otro tipo',
        'value':
            clinicalHistoryMap['otroTipo'] == true
                ? (clinicalHistoryMap['otherTypeDescription'] ?? '')
                : 'No',
      },
      {
        'label': 'Agente causal',
        'value': clinicalHistoryMap['agenteCausal'] ?? '',
      },
      {'label': 'Cinemática', 'value': clinicalHistoryMap['cinematica'] ?? ''},
      {
        'label': 'Medida de Seguridad',
        'value': clinicalHistoryMap['medidaSeguridad'] ?? '',
      },
      {'label': 'Observaciones', 'value': clinicalHistoryMap['observaciones']},
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
          'value':
              (() {
                // Si hay columnas de tiempo, mostrar los valores por hora
                if (physicalExamMap['timeColumns'] != null &&
                    physicalExamMap[vitalSign['key']] != null) {
                  final timeColumns = List<String>.from(
                    physicalExamMap['timeColumns'],
                  );
                  final valuesData = physicalExamMap[vitalSign['key']];

                  // Validar que valuesData sea un Map antes de convertirlo
                  if (valuesData is Map) {
                    final values = Map<String, dynamic>.from(valuesData);
                    return timeColumns
                        .map((col) => '$col: ${values[col] ?? ''}')
                        .join('\n');
                  }
                }
                // Si no, mostrar el valor directo (por compatibilidad)
                return physicalExamMap[vitalSign['key']];
              })(),
        },
      // Campos adicionales del examen físico
      {'label': 'Cabeza', 'value': physicalExamMap['head']},
      {'label': 'Cuello', 'value': physicalExamMap['neck']},
      {'label': 'Tórax', 'value': physicalExamMap['thorax']},
      {'label': 'Abdomen', 'value': physicalExamMap['abdomen']},
      {'label': 'Extremidades', 'value': physicalExamMap['extremities']},
      {'label': 'Neurológico', 'value': physicalExamMap['neurological']},
      {'label': 'Observaciones', 'value': physicalExamMap['observaciones']},
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
      priorityJustificationMap = Map<String, dynamic>.from(
        priorityJustification,
      );
    }
    if (priorityJustificationMap.isEmpty) return const SizedBox.shrink();

    final details = [
      {'label': 'Prioridad', 'value': priorityJustificationMap['priority']},
      {'label': 'Pupilas', 'value': priorityJustificationMap['pupils']},
      {'label': 'Color piel', 'value': priorityJustificationMap['skinColor']},
      {'label': 'Piel', 'value': priorityJustificationMap['skin']},
      {
        'label': 'Temperatura',
        'value': priorityJustificationMap['temperature'],
      },
      {
        'label': 'Influenciado por',
        'value':
            (priorityJustificationMap['influence'] == 'Otro' &&
                    (priorityJustificationMap['especifique'] != null &&
                        priorityJustificationMap['especifique']
                            .toString()
                            .trim()
                            .isNotEmpty))
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
      {
        'label': 'Lugar de destino',
        'value': receivingUnitMap['destinationPlace'],
      },
      {
        'label': 'Numero de ambulancia',
        'value': receivingUnitMap['ambulanceNumber'],
      },
      {'label': 'Placa', 'value': receivingUnitMap['plate']},
      {'label': 'Personal', 'value': receivingUnitMap['personal']},
      {
        'label': 'Doctor responsable',
        'value': receivingUnitMap['responsibleDoctor'],
      },
      {'label': 'Observaciones', 'value': receivingUnitMap['observaciones']},
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
      {
        'label': 'Medico que recibe',
        'value': patientReceptionMap['receivingDoctor'],
      },
      {
        'label': 'Firma del medico',
        'value': _buildSignatureWidget(
          patientReceptionMap['doctorSignature'],
          'Firma del Médico',
        ),
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
    // Obtener insumos desde _detailedInfo
    final insumosData = _detailedInfo['insumos'];
    List<dynamic> insumosList = [];

    if (insumosData != null) {
      if (insumosData is List) {
        insumosList =
            insumosData
                .where((item) => item != null && item is Map<String, dynamic>)
                .toList();
      } else if (insumosData is Map) {
        // Si es un mapa, convertirlo a lista
        insumosList = [insumosData];
      }
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
                            _getSafeStringValue(insumosList[i], 'articulo') ??
                                'Sin especificar',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cantidad: ${_getSafeStringValue(insumosList[i], 'cantidad') ?? '0'}',
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
    // Obtener personal médico desde _detailedInfo
    final personalData = _detailedInfo['personalMedico'];
    List<dynamic> personalList = [];

    if (personalData != null) {
      if (personalData is List) {
        personalList =
            personalData
                .where((item) => item != null && item is Map<String, dynamic>)
                .toList();
      } else if (personalData is Map) {
        // Si es un mapa, convertirlo a lista
        personalList = [personalData];
      }
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
                            _getSafeStringValue(personalList[i], 'nombre') ??
                                'Sin especificar',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_getSafeStringValue(
                                personalList[i],
                                'especialidad',
                              )?.isNotEmpty ==
                              true)
                            Text(
                              'Especialidad: ${_getSafeStringValue(personalList[i], 'especialidad')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (_getSafeStringValue(
                                personalList[i],
                                'cedula',
                              )?.isNotEmpty ==
                              true)
                            Text(
                              'Cédula: ${_getSafeStringValue(personalList[i], 'cedula')}',
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

  // Método auxiliar para obtener valores de string de manera segura
  String? _getSafeStringValue(dynamic data, String key) {
    if (data is Map<String, dynamic> && data.containsKey(key)) {
      final value = data[key];
      if (value != null) {
        return value.toString().trim();
      }
    }
    return null;
  }

  Widget _buildEscalasObstetricasSection() {
    // Obtener escalas obstétricas desde _detailedInfo
    final escalasData = _detailedInfo['escalasObstetricas'];

    if (escalasData == null || escalasData.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Map<String, dynamic>> details = [];

    // Escala de Silverman-Anderson
    if (escalasData['silvermanAnderson'] != null) {
      final silverman = escalasData['silvermanAnderson'];
      if (silverman is Map<String, dynamic> && silverman.isNotEmpty) {
        details.add({
          'label': 'Escala Silverman-Anderson',
          'value': _buildSilvermanAndersonDisplay(silverman),
          'isFullWidth': true,
        });
      }
    }

    // Escala APGAR
    if (escalasData['apgar'] != null) {
      final apgar = escalasData['apgar'];
      if (apgar is Map<String, dynamic> && apgar.isNotEmpty) {
        details.add({
          'label': 'Escala APGAR',
          'value': _buildApgarDisplay(apgar),
          'isFullWidth': true,
        });
      }
    }

    // Frecuencia cardíaca fetal
    if (escalasData['frecuenciaCardiacaFetal'] != null &&
        escalasData['frecuenciaCardiacaFetal'].toString().trim().isNotEmpty) {
      details.add({
        'label': 'Frecuencia cardíaca fetal',
        'value': '${escalasData['frecuenciaCardiacaFetal']} lpm',
      });
    }

    // Contracciones
    if (escalasData['contracciones'] != null &&
        escalasData['contracciones'].toString().trim().isNotEmpty) {
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...silverman.entries.where((entry) => entry.value != null).map((
            entry,
          ) {
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
          }),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Puntaje total:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${silverman.values.where((value) => value != null).fold(0, (sum, value) => sum + (value as int))}',
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...apgar.entries.where((entry) => entry.value != null).map((entry) {
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
          }),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Puntaje total:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${apgar.values.where((value) => value != null).fold(0, (sum, value) => sum + (value as int))}',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header de la sección
          Container(
            width: double.infinity,
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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la sección
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildTwoColumnDetails(List<Map<String, dynamic>> details) {
    // No filtrar campos vacíos para mostrar todos los campos
    final detailsWithData = details;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children:
          detailsWithData
              .map(
                (detail) => _buildDetailRow(detail['label'], detail['value']),
              )
              .toList(),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
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
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                value is Widget
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
        content: Text(
          'Función de edición para ${widget.record.patientName} próximamente disponible',
        ),
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
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Está seguro de eliminar el registro de ${widget.record.patientName}?',
            ),
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
              content: Text(
                success
                    ? 'Registro eliminado exitosamente'
                    : 'Error al eliminar el registro',
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
      Colors.red, // Hemorragia
      Color(0xFF8D6E63), // Herida (brown)
      Colors.purple, // Contusión
      Colors.orange, // Fractura
      Colors.yellow, // Luxación/Esguince
      Colors.pink, // Objeto extraño
      Colors.deepOrange, // Quemadura
      Colors.green, // Picadura/Mordedura
      Colors.indigo, // Edema/Hematoma
      Colors.grey, // Otro
    ];

    if (typeIndex >= 0 && typeIndex < colors.length) {
      return colors[typeIndex];
    }
    return Colors.grey;
  }

  // Métodos automatizados para procesar configuraciones
  Map<String, dynamic> _extractSectionData(String sectionKey) {
    final sectionData = _detailedInfo[sectionKey];
    if (sectionData is Map) {
      return Map<String, dynamic>.from(sectionData);
    }
    return {};
  }

  List<Map<String, dynamic>> _buildDetailsFromConfig(SectionConfig config) {
    final sectionData = _extractSectionData(config.key);
    final details = <Map<String, dynamic>>[];

    // Procesar campos normales
    config.fieldMappings.forEach((fieldKey, label) {
      final value = _getSafeStringValue(sectionData, fieldKey);
      final fallbackValue = config.fallbacks[fieldKey];

      final finalValue = value ?? (fallbackValue?.toString());
      if (finalValue != null && finalValue.trim().isNotEmpty) {
        details.add({'label': label, 'value': finalValue});
      }
    });

    // Procesar campos booleanos
    config.booleanFields.forEach((fieldKey, label) {
      if (sectionData[fieldKey] == true) {
        details.add({'label': label, 'value': 'Sí'});
      }
    });

    // Procesar campos condicionales
    config.conditionalFields.forEach((fieldKey, fieldConfig) {
      final condition =
          fieldConfig['condition'] as Function(Map<String, dynamic>);
      if (condition(sectionData)) {
        final dependentField = fieldConfig['dependentField'] as String;
        final dependentLabel = fieldConfig['dependentLabel'] as String;
        final value = _getSafeStringValue(sectionData, dependentField);
        if (value != null && value.toString().trim().isNotEmpty) {
          details.add({'label': dependentLabel, 'value': value});
        }
      }
    });

    // Procesar campos especiales
    config.specialFields.forEach((fieldKey, fieldConfig) {
      final label = fieldConfig['label'] as String;
      final isSignature = fieldConfig['isSignature'] as bool? ?? false;
      final signatureTitle = fieldConfig['signatureTitle'] as String?;
      final isFullWidth = fieldConfig['isFullWidth'] as bool? ?? false;
      final customBuilder =
          fieldConfig['customBuilder'] as Function(Map<String, dynamic>)?;

      if (isSignature) {
        final signatureData = sectionData[fieldKey];
        final signatureWidget = _buildSignatureWidget(
          signatureData,
          signatureTitle ?? label,
        );
        details.add({
          'label': label,
          'value': signatureWidget,
          'isSignature': true,
          'isFullWidth': isFullWidth,
        });
      } else if (customBuilder != null) {
        final customValue = customBuilder(sectionData);
        details.add({
          'label': label,
          'value': customValue,
          'isFullWidth': isFullWidth,
        });
      } else {
        final value = _getSafeStringValue(sectionData, fieldKey);
        if (value != null && value.toString().trim().isNotEmpty) {
          details.add({
            'label': label,
            'value': value,
            'isFullWidth': isFullWidth,
          });
        }
      }
    });

    // Procesar signos vitales (para examen físico)
    if (config.vitalSigns.isNotEmpty) {
      for (final vitalSign in config.vitalSigns) {
        final value = _buildVitalSignValue(sectionData, vitalSign);
        if (value != null) {
          details.add({'label': vitalSign, 'value': value});
        }
      }
    }

    return details;
  }

  String? _buildVitalSignValue(
    Map<String, dynamic> sectionData,
    String vitalSign,
  ) {
    if (sectionData['timeColumns'] != null && sectionData[vitalSign] != null) {
      final timeColumns = List<String>.from(sectionData['timeColumns']);
      final valuesData = sectionData[vitalSign];

      if (valuesData is Map) {
        final values = Map<String, dynamic>.from(valuesData);
        return timeColumns
            .map((col) => '$col: ${values[col] ?? ''}')
            .join('\n');
      }
    }

    // Manejar el caso donde no hay timeColumns o el valor no es un Map
    final value = sectionData[vitalSign];
    if (value != null) {
      return value.toString();
    }
    return null;
  }

  Widget _buildMedicationsList(Map<String, dynamic> sectionData) {
    final medicationsList = sectionData['medicationsList'];
    if (medicationsList == null || medicationsList.isEmpty) {
      return const Text('No se registraron medicamentos');
    }

    if (medicationsList is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < medicationsList.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.orange,
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
                        child: Text(
                          medicationsList[i]['medicamento'] ??
                              'Sin especificar',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dosis: ${medicationsList[i]['dosis'] ?? 'No especificada'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Vía: ${medicationsList[i]['viaAdministracion'] ?? 'No especificada'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (medicationsList[i]['hora']?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Hora: ${medicationsList[i]['hora']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                  if (medicationsList[i]['medicoIndico']?.isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Médico: ${medicationsList[i]['medicoIndico'] == 'Otro' ? medicationsList[i]['medicoOtro'] : medicationsList[i]['medicoIndico']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
    }

    return const Text('Formato de medicamentos no válido');
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
        drawnInjuries =
            injuriesData.map((injury) {
              final List<dynamic> pointsData = injury['points'];
              final points =
                  pointsData
                      .map((point) => Offset(point['dx'], point['dy']))
                      .toList();
              final injuryType = injury['injuryType'] as int;

              return DrawnInjuryDisplay(points: points, injuryType: injuryType);
            }).toList();

        // Agrupar lesiones por tipo para mostrar resumen
        Map<int, int> injuriesByType = {};
        for (var injury in drawnInjuries) {
          injuriesByType[injury.injuryType] =
              (injuriesByType[injury.injuryType] ?? 0) + 1;
        }

        // Crear detalles para cada tipo de lesión
        injuriesByType.forEach((typeIndex, count) {
          final typeName = _getInjuryTypeName(typeIndex);
          details.add({
            'label': typeName,
            'value':
                '$count ${count == 1 ? 'lesión marcada' : 'lesiones marcadas'}',
          });
        });

        // Mostrar total de lesiones
        details.add({
          'label': 'Total de lesiones',
          'value':
              '${drawnInjuries.length} ${drawnInjuries.length == 1 ? 'lesión' : 'lesiones'} dibujadas',
        });
      }
    }

    // Mostrar notas adicionales
    if (injuryLocationMap['notes'] != null &&
        injuryLocationMap['notes'].toString().trim().isNotEmpty) {
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
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
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
                      }),

                      const SizedBox(height: 16),

                      // Resumen
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
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
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey[600],
                              size: 20,
                            ),
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
                      originalImageSize:
                          injuryLocationMap['originalImageSize'] != null
                              ? Size(
                                injuryLocationMap['originalImageSize']['width']
                                        ?.toDouble() ??
                                    400.0,
                                injuryLocationMap['originalImageSize']['height']
                                        ?.toDouble() ??
                                    600.0,
                              )
                              : null, // Para registros antiguos sin esta información
                      originalImageRect:
                          injuryLocationMap['originalImageRect'] != null
                              ? Rect.fromLTWH(
                                injuryLocationMap['originalImageRect']['left']
                                        ?.toDouble() ??
                                    0.0,
                                injuryLocationMap['originalImageRect']['top']
                                        ?.toDouble() ??
                                    0.0,
                                injuryLocationMap['originalImageRect']['width']
                                        ?.toDouble() ??
                                    400.0,
                                injuryLocationMap['originalImageRect']['height']
                                        ?.toDouble() ??
                                    600.0,
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
          }),
        ],
      ),
    );
  }

  // Método auxiliar para obtener el nombre del tipo de lesión
  String _getInjuryTypeName(int typeIndex) {
    const injuryTypes = [
      'Hemorragia', // 0
      'Herida', // 1
      'Contusión', // 2
      'Fractura', // 3
      'Luxación/Esguince', // 4
      'Objeto extraño', // 5
      'Quemadura', // 6
      'Picadura/Mordedura', // 7
      'Edema/Hematoma', // 8
      'Otro', // 9
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalMedicoList(Map<String, dynamic> sectionData) {
    final personalMedicoList = sectionData['personalMedico'];
    if (personalMedicoList == null || personalMedicoList.isEmpty) {
      return const Text('No se registró personal médico');
    }

    if (personalMedicoList is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < personalMedicoList.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.indigo,
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
                        child: Text(
                          personalMedicoList[i]['nombre'] ?? 'Sin especificar',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Especialidad: ${personalMedicoList[i]['especialidad'] ?? 'No especificada'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Cédula: ${personalMedicoList[i]['cedula'] ?? 'No especificada'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return const Text('Formato de personal médico no válido');
  }
}
