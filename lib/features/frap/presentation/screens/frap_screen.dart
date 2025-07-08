import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';
import 'package:bg_med/features/frap/presentation/providers/auto_sync_provider.dart';
import 'package:bg_med/core/services/auto_sync_service.dart';
import 'package:bg_med/features/frap/presentation/dialogs/patient_info_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/service_info_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/registry_info_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/management_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/gyneco_obstetric_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/pathological_history_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/clinical_history_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/medications_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/priority_justification_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/receiving_unit_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/physical_exam_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/attention_negative_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/patient_reception_form_dialog.dart';
import 'package:bg_med/features/frap/presentation/dialogs/injury_location_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FrapScreen extends ConsumerStatefulWidget {
  const FrapScreen({super.key});

  @override
  ConsumerState<FrapScreen> createState() => _FrapScreenState();
}

class _FrapScreenState extends ConsumerState<FrapScreen> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializar el servicio de sincronización automática
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(autoSyncProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final frapData = ref.watch(frapDataProvider);
    final autoSyncState = ref.watch(autoSyncProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Atención Prehospitalaria'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Indicador de conectividad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: autoSyncState.isOnline ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  autoSyncState.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  autoSyncState.isOnline ? 'En línea' : 'Sin conexión',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Botón de sincronización manual
          if (autoSyncState.isOnline)
            IconButton(
              icon: autoSyncState.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Icon(Icons.sync),
              onPressed: autoSyncState.isSyncing
                  ? null
                  : () {
                      ref.read(autoSyncProvider.notifier).forceSyncNow();
                    },
              tooltip: 'Sincronizar ahora',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de estado de sincronización
            if (autoSyncState.lastSyncMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: autoSyncState.isOnline 
                      ? Colors.green.shade50 
                      : Colors.orange.shade50,
                  border: Border.all(
                    color: autoSyncState.isOnline 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      autoSyncState.isOnline 
                          ? Icons.info_outline 
                          : Icons.warning_outlined,
                      color: autoSyncState.isOnline 
                          ? Colors.green 
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        autoSyncState.lastSyncMessage!,
                        style: TextStyle(
                          color: autoSyncState.isOnline 
                              ? Colors.green.shade700 
                              : Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
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
                  totalFields: 15,
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
                  isDisabled: !_isGynecoObstetricEnabled(frapData),
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
                  totalFields: 7,
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
                  totalFields: 2,
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
            
            // Indicador de conectividad
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: autoSyncState.isOnline 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: autoSyncState.isOnline 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      autoSyncState.isOnline ? Icons.wifi : Icons.wifi_off,
                      color: autoSyncState.isOnline ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      autoSyncState.isOnline 
                          ? 'Conectado - Se guardará en la nube'
                          : 'Sin conexión - Se guardará localmente',
                      style: TextStyle(
                        color: autoSyncState.isOnline ? Colors.green[700] : Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botón de guardado único
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving || autoSyncState.isSyncing ? null : _saveRecord,
                icon: _isSaving || autoSyncState.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(autoSyncState.isOnline ? Icons.cloud_upload : Icons.save),
                label: Text(
                  _isSaving || autoSyncState.isSyncing
                      ? 'Guardando...'
                      : 'Guardar Registro',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: autoSyncState.isOnline 
                      ? AppTheme.primaryBlue 
                      : AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botones de navegación a registros
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/frap-records');
                    },
                    icon: const Icon(Icons.folder),
                    label: const Text('Ver Registros Locales'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/frap-cloud-records');
                    },
                    icon: const Icon(Icons.cloud),
                    label: const Text('Ver Registros en la Nube'),
                  ),
                ),
              ],
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
    bool isDisabled = false,
  }) {
    final completionPercentage = totalFields > 0 ? (filledFields / totalFields) : 0.0;
    final isComplete = filledFields == totalFields;
    final isEmpty = filledFields == 0;

    // Determinar colores basado en el estado
    Color borderColor;
    Color iconBackgroundColor;
    Color iconColor;
    Color titleColor;
    Color progressColor;

    if (isDisabled) {
      borderColor = Colors.grey[300]!;
      iconBackgroundColor = Colors.grey.withOpacity(0.1);
      iconColor = Colors.grey[400]!;
      titleColor = Colors.grey[400]!;
      progressColor = Colors.grey[300]!;
    } else if (isComplete) {
      borderColor = Colors.green;
      iconBackgroundColor = Colors.green.withOpacity(0.1);
      iconColor = Colors.green;
      titleColor = Colors.green[700]!;
      progressColor = Colors.green;
    } else if (isEmpty) {
      borderColor = Colors.grey[300]!;
      iconBackgroundColor = Colors.grey.withOpacity(0.1);
      iconColor = Colors.grey[600]!;
      titleColor = Colors.grey[600]!;
      progressColor = Colors.grey[400]!;
    } else {
      borderColor = AppTheme.primaryBlue;
      iconBackgroundColor = AppTheme.primaryBlue.withOpacity(0.1);
      iconColor = AppTheme.primaryBlue;
      titleColor = AppTheme.primaryBlue;
      progressColor = AppTheme.primaryBlue;
    }

    return Card(
      elevation: isDisabled ? 0.5 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: isComplete ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
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
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
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
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDisabled 
                              ? 'Requiere sexo femenino'
                              : '$filledFields de $totalFields campos completados',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDisabled ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isDisabled
                        ? Icons.lock
                        : isComplete
                            ? Icons.check_circle
                            : isEmpty
                                ? Icons.radio_button_unchecked
                                : Icons.edit,
                    color: isDisabled
                        ? Colors.grey[400]
                        : isComplete
                            ? Colors.green
                            : isEmpty
                                ? Colors.grey[400]
                                : AppTheme.primaryBlue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: isDisabled ? 0.0 : completionPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
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
    final patientSex = frapData.patientInfo['sex'] as String?;
    
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AttentionNegativeFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('attention_negative', data);
        },
        initialData: ref.read(frapDataProvider).attentionNegative,
      ),
    );
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PhysicalExamFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('physical_exam', data);
        },
        initialData: ref.read(frapDataProvider).physicalExam,
      ),
    );
  }

  void _openPriorityJustificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PriorityJustificationFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('priority_justification', data);
        },
        initialData: ref.read(frapDataProvider).priorityJustification,
      ),
    );
  }

  void _openInjuryLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InjuryLocationFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('injury_location', data);
        },
        initialData: ref.read(frapDataProvider).injuryLocation,
      ),
    );
  }

  void _openReceivingUnitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReceivingUnitFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('receiving_unit', data);
        },
        initialData: ref.read(frapDataProvider).receivingUnit,
      ),
    );
  }

  void _openPatientReceptionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PatientReceptionFormDialog(
        onSave: (data) {
          ref.read(frapDataProvider.notifier).updateSectionData('patient_reception', data);
        },
        initialData: ref.read(frapDataProvider).patientReception,
      ),
    );
  }

  void _saveRecord() async {
    if (_isSaving) return;
    
    if (!mounted) return;
    setState(() {
      _isSaving = true;
    });

    try {
    final frapData = ref.read(frapDataProvider);
    
      // Validar que se hayan completado los campos mínimos requeridos
      if (frapData.patientInfo.isEmpty) {
        if (mounted) {
          _showErrorDialog('Error de validación', 'Debe completar al menos la información del paciente para guardar el registro.');
        }
        return;
      }

      // Usar el servicio de sincronización automática
      final result = await ref.read(autoSyncProvider.notifier).saveRecord(frapData);
      
      if (!mounted) return;
      
      if (result.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
            content: Text(result.message),
            backgroundColor: result.savedToCloud ? AppTheme.primaryBlue : AppTheme.primaryGreen,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                if (mounted) {
                  // Navegar a la vista correspondiente
                  Navigator.pushNamed(
                    context, 
                    result.savedToCloud ? '/frap-cloud-records' : '/frap-records'
                  );
                }
              },
            ),
          ),
        );
        
        // Mostrar diálogo de confirmación para limpiar el formulario
        if (mounted) {
          _showSuccessDialog(result);
        }
      } else {
        if (mounted) {
          _showErrorDialog('Error al guardar', result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al guardar', 'Error inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSuccessDialog(SaveResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: result.savedToCloud ? AppTheme.primaryBlue : AppTheme.primaryGreen,
      ),
            const SizedBox(width: 8),
            const Text('Registro Guardado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 16),
            const Text('¿Qué desea hacer a continuación?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Limpiar datos del formulario
              ref.read(frapDataProvider.notifier).clearAllData();
            },
            child: const Text('Nuevo Registro'),
          ),
          TextButton(
            onPressed: () {
    Navigator.of(context).pop();
              // Navegar a la vista correspondiente
              Navigator.pushNamed(
                context, 
                result.savedToCloud ? '/frap-cloud-records' : '/frap-records'
              );
            },
            child: const Text('Ver Registros'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Salir del formulario
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: result.savedToCloud ? AppTheme.primaryBlue : AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
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

  bool _isGynecoObstetricEnabled(FrapData frapData) {
    final patientSex = frapData.patientInfo['sex'] as String?;
    return patientSex != null && (patientSex.toLowerCase() == 'femenino' || patientSex.toLowerCase() == 'mujer');
  }
} 