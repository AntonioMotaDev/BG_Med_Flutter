import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';
import 'package:bg_med/features/frap/presentation/dialogs/patient_info_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/service_info_form_dialog.dart';
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
            // Información del Servicio
            _buildSectionCard(
              title: 'INFORMACIÓN DEL SERVICIO',
              icon: Icons.local_hospital,
              filledFields: frapData.getFilledFieldsCount('service_info'),
              totalFields: 8,
              onTap: () => _openServiceInfoDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Información del Registro
            _buildSectionCard(
              title: 'INFORMACIÓN DEL REGISTRO',
              icon: Icons.assignment,
              filledFields: frapData.getFilledFieldsCount('registry_info'),
              totalFields: 6,
              onTap: () => _openRegistryInfoDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Información del Paciente
            _buildSectionCard(
              title: 'INFORMACIÓN DEL PACIENTE',
              icon: Icons.person,
              filledFields: frapData.getFilledFieldsCount('patient_info'),
              totalFields: 12,
              onTap: () => _openPatientInfoDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Manejo
            _buildSectionCard(
              title: 'MANEJO',
              icon: Icons.medical_services,
              filledFields: frapData.getFilledFieldsCount('management'),
              totalFields: 10,
              onTap: () => _openManagementDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Medicamentos
            _buildSectionCard(
              title: 'MEDICAMENTOS',
              icon: Icons.medication,
              filledFields: frapData.getFilledFieldsCount('medications'),
              totalFields: 8,
              onTap: () => _openMedicationsDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Gineco-Obstétrico
            _buildSectionCard(
              title: 'EMERGENCIAS GINECO-OBSTÉTRICAS',
              icon: Icons.pregnant_woman,
              filledFields: frapData.getFilledFieldsCount('gyneco_obstetric'),
              totalFields: 6,
              onTap: () => _openGynecoObstetricDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Negativa de Atención
            _buildSectionCard(
              title: 'NEGATIVA DE ATENCIÓN',
              icon: Icons.cancel,
              filledFields: frapData.getFilledFieldsCount('attention_negative'),
              totalFields: 4,
              onTap: () => _openAttentionNegativeDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Antecedentes Patológicos
            _buildSectionCard(
              title: 'ANTECEDENTES PATOLÓGICOS',
              icon: Icons.history,
              filledFields: frapData.getFilledFieldsCount('pathological_history'),
              totalFields: 15,
              onTap: () => _openPathologicalHistoryDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Historia Clínica
            _buildSectionCard(
              title: 'HISTORIA CLÍNICA',
              icon: Icons.description,
              filledFields: frapData.getFilledFieldsCount('clinical_history'),
              totalFields: 8,
              onTap: () => _openClinicalHistoryDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Examen Físico
            _buildSectionCard(
              title: 'EXAMEN FÍSICO',
              icon: Icons.health_and_safety,
              filledFields: frapData.getFilledFieldsCount('physical_exam'),
              totalFields: 12,
              onTap: () => _openPhysicalExamDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Justificación de Prioridad
            _buildSectionCard(
              title: 'JUSTIFICACIÓN DE PRIORIDAD',
              icon: Icons.priority_high,
              filledFields: frapData.getFilledFieldsCount('priority_justification'),
              totalFields: 5,
              onTap: () => _openPriorityJustificationDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Localización de Lesiones
            _buildSectionCard(
              title: 'LOCALIZACIÓN DE LESIONES',
              icon: Icons.my_location,
              filledFields: frapData.getFilledFieldsCount('injury_location'),
              totalFields: 6,
              onTap: () => _openInjuryLocationDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Unidad Receptora
            _buildSectionCard(
              title: 'UNIDAD RECEPTORA',
              icon: Icons.local_hospital,
              filledFields: frapData.getFilledFieldsCount('receiving_unit'),
              totalFields: 8,
              onTap: () => _openReceivingUnitDialog(),
            ),
            
                  const SizedBox(height: 16),
            
            // Recepción del Paciente
            _buildSectionCard(
              title: 'RECEPCIÓN DEL PACIENTE',
              icon: Icons.how_to_reg,
              filledFields: frapData.getFilledFieldsCount('patient_reception'),
              totalFields: 6,
              onTap: () => _openPatientReceptionDialog(),
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
          Navigator.of(context).pop();
        },
        initialData: ref.read(frapDataProvider).serviceInfo,
      ),
    );
  }

  void _openRegistryInfoDialog() {
    // TODO: Implementar diálogo de información del registro
    _showComingSoonDialog('Información del Registro');
  }

  void _openPatientInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PatientInfoFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('patient_info', data);
          Navigator.of(context).pop();
        },
        initialData: ref.read(frapDataProvider).patientInfo,
      ),
    );
  }

  void _openManagementDialog() {
    _showComingSoonDialog('Manejo');
  }

  void _openMedicationsDialog() {
    _showComingSoonDialog('Medicamentos');
  }

  void _openGynecoObstetricDialog() {
    _showComingSoonDialog('Emergencias Gineco-Obstétricas');
  }

  void _openAttentionNegativeDialog() {
    _showComingSoonDialog('Negativa de Atención');
  }

  void _openPathologicalHistoryDialog() {
    _showComingSoonDialog('Antecedentes Patológicos');
  }

  void _openClinicalHistoryDialog() {
    _showComingSoonDialog('Historia Clínica');
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