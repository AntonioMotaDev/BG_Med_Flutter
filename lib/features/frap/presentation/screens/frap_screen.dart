import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';
import 'package:bg_med/features/frap/presentation/dialogs/patient_info_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/service_info_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/registry_info_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/management_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/gyneco_obstetric_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/pathological_history_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/clinical_history_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/medications_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FrapScreen extends ConsumerStatefulWidget {
  const FrapScreen({super.key});

  @override
  ConsumerState<FrapScreen> createState() => _FrapScreenState();
}

class _FrapScreenState extends ConsumerState<FrapScreen> {
  @override
  Widget build(BuildContext context) {
    final frapData = ref.watch(frapDataProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Registro de Atención Prehospitalaria',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAllData,
            tooltip: 'Guardar registro',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Grid de tarjetas en dos columnas
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3,
              children: [
                // Información del Servicio
                _buildSectionCard(
                  title: 'INFORMACIÓN DEL SERVICIO',
                  icon: Icons.local_hospital,
                  filledFields: frapData.getFilledFieldsCount('service_info'),
                  totalFields: 8,
                  onTap: () => _openServiceInfoDialog(),
                ),
                
                // Información del Registro
                _buildSectionCard(
                  title: 'INFORMACIÓN DEL REGISTRO',
                  icon: Icons.assignment,
                  filledFields: frapData.getFilledFieldsCount('registry_info'),
                  totalFields: 5,
                  onTap: () => _openRegistryInfoDialog(),
                ),
                
                // Información del Paciente
                _buildSectionCard(
                  title: 'INFORMACIÓN DEL PACIENTE',
                  icon: Icons.person,
                  filledFields: frapData.getFilledFieldsCount('patient_info'),
                  totalFields: 14,
                  onTap: () => _openPatientInfoDialog(),
                ),
                
                // Manejo
                _buildSectionCard(
                  title: 'MANEJO',
                  icon: Icons.medical_services,
                  filledFields: frapData.getFilledFieldsCount('management'),
                  totalFields: 12,
                  onTap: () => _openManagementDialog(),
                ),
                
                // Antecedentes Patológicos
                _buildSectionCard(
                  title: 'ANTECEDENTES PATOLÓGICOS',
                  icon: Icons.history,
                  filledFields: frapData.getFilledFieldsCount('pathological_history'),
                  totalFields: 8,
                  onTap: () => _openPathologicalHistoryDialog(),
                ),
                
                // Medicamentos
                _buildSectionCard(
                  title: 'MEDICAMENTOS',
                  icon: Icons.medication,
                  filledFields: frapData.getFilledFieldsCount('medications'),
                  totalFields: 1,
                  onTap: () => _openMedicationsDialog(),
                ),
                
                // Historia Clínica
                _buildSectionCard(
                  title: 'ANTECEDENTES CLÍNICOS',
                  icon: Icons.description,
                  filledFields: frapData.getFilledFieldsCount('clinical_history'),
                  totalFields: 14,
                  onTap: () => _openClinicalHistoryDialog(),
                ),
                
                // Gineco-Obstétrico
                _buildSectionCard(
                  title: 'URGENCIAS GINECO-OBSTÉTRICAS',
                  icon: Icons.pregnant_woman,
                  filledFields: frapData.getFilledFieldsCount('gyneco_obstetric'),
                  totalFields: 10,
                  onTap: () => _openGynecoObstetricDialog(),
                ),
                
                // Examen Físico
                _buildSectionCard(
                  title: 'EXPLORACIÓN FÍSICA',
                  icon: Icons.health_and_safety,
                  filledFields: frapData.getFilledFieldsCount('physical_exam'),
                  totalFields: 12,
                  onTap: () => _openPhysicalExamDialog(),
                ),
                
                // Negativa de Atención
                _buildSectionCard(
                  title: 'NEGATIVA DE ATENCIÓN',
                  icon: Icons.cancel,
                  filledFields: frapData.getFilledFieldsCount('attention_negative'),
                  totalFields: 4,
                  onTap: () => _openAttentionNegativeDialog(),
                ),
                
                // Justificación de Prioridad
                _buildSectionCard(
                  title: 'JUSTIFICACIÓN DE PRIORIDAD',
                  icon: Icons.priority_high,
                  filledFields: frapData.getFilledFieldsCount('priority_justification'),
                  totalFields: 5,
                  onTap: () => _openPriorityJustificationDialog(),
                ),
                
                // Unidad Receptora
                _buildSectionCard(
                  title: 'UNIDAD MEDICA RECEPTORA',
                  icon: Icons.local_hospital,
                  filledFields: frapData.getFilledFieldsCount('receiving_unit'),
                  totalFields: 8,
                  onTap: () => _openReceivingUnitDialog(),
                ),
                
                // Localización de Lesiones
                _buildSectionCard(
                  title: 'LOCALIZACIÓN DE LESIONES',
                  icon: Icons.my_location,
                  filledFields: frapData.getFilledFieldsCount('injury_location'),
                  totalFields: 6,
                  onTap: () => _openInjuryLocationDialog(),
                ),
                
                // Recepción del Paciente
                _buildSectionCard(
                  title: 'RECEPCIÓN DEL PACIENTE',
                  icon: Icons.how_to_reg,
                  filledFields: frapData.getFilledFieldsCount('patient_reception'),
                  totalFields: 6,
                  onTap: () => _openPatientReceptionDialog(),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Botón de guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveAllData,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR REGISTRO COMPLETO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required int filledFields,
    required int totalFields,
    required VoidCallback onTap,
  }) {
    final completionPercentage = totalFields > 0 ? (filledFields / totalFields) : 0.0;
    final isComplete = filledFields == totalFields;
    final isEmpty = filledFields == 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isComplete
              ? Colors.green
              : isEmpty
                  ? Colors.grey[300]!
                  : AppTheme.primaryBlue,
          width: isComplete ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? Colors.green.withOpacity(0.1)
                          : isEmpty
                              ? Colors.grey.withOpacity(0.1)
                              : AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: isComplete
                          ? Colors.green
                          : isEmpty
                              ? Colors.grey[600]
                              : AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isComplete
                                ? Colors.green[700]
                                : isEmpty
                                    ? Colors.grey[600]
                                    : AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$filledFields de $totalFields campos completados',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isComplete
                        ? Icons.check_circle
                        : isEmpty
                            ? Icons.radio_button_unchecked
                            : Icons.edit,
                    color: isComplete
                        ? Colors.green
                        : isEmpty
                            ? Colors.grey[400]
                            : AppTheme.primaryBlue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: completionPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete
                      ? Colors.green
                      : isEmpty
                          ? Colors.grey[400]!
                          : AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openServiceInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ServiceInfoFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('service_info', data);
        },
        initialData: ref.read(frapDataProvider).serviceInfo,
      ),
    );
  }

  void _openRegistryInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RegistryInfoFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('registry_info', data);
        },
        initialData: ref.read(frapDataProvider).registryInfo,
      ),
    );
  }

  void _openPatientInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PatientInfoFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('patient_info', data);
        },
        initialData: ref.read(frapDataProvider).patientInfo,
      ),
    );
  }

  void _openManagementDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ManagementFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('management', data);
        },
        initialData: ref.read(frapDataProvider).management,
      ),
    );
  }

  void _openMedicationsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MedicationsFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('medications', data);
        },
        initialData: ref.read(frapDataProvider).medications,
      ),
    );
  }

  void _openGynecoObstetricDialog() {
    final frapData = ref.read(frapDataProvider);
    final patientSex = frapData.patientInfo['sexSelected'] as String?;
    
    // Verificar si el paciente es de sexo femenino
    if (patientSex == null || patientSex.isEmpty) {
      _showInfoDialog(
        'Información requerida',
        'Primero debe completar la información del paciente para acceder a esta sección.',
      );
      return;
    }
    
    if (patientSex != 'Femenino') {
      _showInfoDialog(
        'Sección no disponible',
        'Esta sección solo está disponible para pacientes de sexo femenino.',
      );
      return;
    }
    
    // Si es femenino, mostrar el formulario
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GynecoObstetricFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('gyneco_obstetric', data);
        },
        initialData: ref.read(frapDataProvider).gynecoObstetric,
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _openAttentionNegativeDialog() {
    _showComingSoonDialog('Negativa de Atención');
  }

  void _openPathologicalHistoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PathologicalHistoryFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('pathological_history', data);
        },
        initialData: ref.read(frapDataProvider).pathologicalHistory,
      ),
    );
  }

  void _openClinicalHistoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClinicalHistoryFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('clinical_history', data);
        },
        initialData: ref.read(frapDataProvider).clinicalHistory,
      ),
    );
  }

  void _openPhysicalExamDialog() {
    _showComingSoonDialog('Examen Físico');
  }

  void _openPriorityJustificationDialog() {
    _showComingSoonDialog('Justificación de Prioridad');
  }

  void _openInjuryLocationDialog() {
    _showComingSoonDialog('Localización de Lesiones');
  }

  void _openReceivingUnitDialog() {
    _showComingSoonDialog('Unidad Receptora');
  }

  void _openPatientReceptionDialog() {
    _showComingSoonDialog('Recepción del Paciente');
  }

  void _showComingSoonDialog(String sectionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sectionName),
        content: const Text('Esta sección estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _saveAllData() {
    final frapData = ref.read(frapDataProvider);
    
    // Aquí implementarías la lógica para guardar todos los datos
    // Por ejemplo, convertir a un modelo Frap y guardar en Hive
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registro FRAP guardado exitosamente'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    
    // Limpiar datos después de guardar
    ref.read(frapDataProvider.notifier).clearAllData();
    
    Navigator.of(context).pop();
  }
} 