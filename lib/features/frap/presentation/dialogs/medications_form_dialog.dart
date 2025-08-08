import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MedicationsFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const MedicationsFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<MedicationsFormDialog> createState() => _MedicationsFormDialogState();
}

class _MedicationsFormDialogState extends State<MedicationsFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Lista de medicamentos
  List<MedicationRow> _medications = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;

      // Si hay medicamentos guardados en formato de tabla
      if (data['medicationsList'] != null && data['medicationsList'] is List) {
        final List<dynamic> medicationsList = data['medicationsList'];
        _medications =
            medicationsList.map((med) {
              return MedicationRow(
                medicamento: med['medicamento'] ?? '',
                dosis: med['dosis'] ?? '',
                viaAdministracion: med['viaAdministracion'] ?? '',
                hora: med['hora'] ?? '',
                medicoIndico: med['medicoIndico'] ?? '',
                medicoOtro: med['medicoOtro'] ?? '',
              );
            }).toList();
      } else if (data['medications'] != null &&
          data['medications'].toString().isNotEmpty) {
        // Migrar de formato texto libre a tabla
        final String medicationsText = data['medications'];
        _medications = _parseTextToMedications(medicationsText);
      }
    }

    // Si no hay medicamentos, agregar una fila vacía
    if (_medications.isEmpty) {
      _addMedicationRow();
    }
  }

  List<MedicationRow> _parseTextToMedications(String text) {
    final List<MedicationRow> medications = [];
    final lines = text.split('\n');

    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        // Intentar parsear líneas con formato común
        final parts = line.split(' - ');
        if (parts.length >= 3) {
          medications.add(
            MedicationRow(
              medicamento: parts[0].trim(),
              dosis: parts.length > 1 ? parts[1].trim() : '',
              viaAdministracion: parts.length > 2 ? parts[2].trim() : '',
              hora: parts.length > 3 ? parts[3].trim() : '',
              medicoIndico: parts.length > 4 ? parts[4].trim() : '',
            ),
          );
        } else {
          // Si no se puede parsear, agregar como medicamento general
          medications.add(
            MedicationRow(
              medicamento: line.trim(),
              dosis: '',
              viaAdministracion: '',
              hora: '',
              medicoIndico: '',
            ),
          );
        }
      }
    }

    return medications;
  }

  void _addMedicationRow() {
    setState(() {
      _medications.add(MedicationRow());
    });
  }

  void _removeMedicationRow(int index) {
    setState(() {
      _medications.removeAt(index);
      // Asegurar que siempre haya al menos una fila
      if (_medications.isEmpty) {
        _addMedicationRow();
      }
    });
  }

  void _updateMedicationRow(int index, MedicationRow medication) {
    setState(() {
      _medications[index] = medication;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medication, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'MEDICAMENTOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y descripción
                      const Text(
                        'Registro de Medicamentos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registre todos los medicamentos administrados al paciente durante la atención prehospitalaria.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tabla de medicamentos
                      _buildMedicationsTable(),

                      const SizedBox(height: 16),

                      // Botón para agregar medicamento
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _addMedicationRow,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Medicamento'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Guía de formato
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Información importante:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Complete todos los campos obligatorios\n'
                              '• La hora debe estar en formato HH:MM (ej: 14:30, 9:30)\n'
                              '• Escriba el nombre completo del médico que indicó el medicamento\n'
                              '• Puede agregar o eliminar medicamentos según sea necesario',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[800],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveForm,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.save),
                    label: Text(
                      _isLoading ? 'Guardando...' : 'Guardar Sección',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la tabla
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Medicamento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Dosis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Vía',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Hora',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Médico',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 40), // Espacio para botón eliminar
            ],
          ),
        ),

        // Filas de medicamentos
        ...List.generate(_medications.length, (index) {
          return _buildMedicationRow(index);
        }),
      ],
    );
  }

  Widget _buildMedicationRow(int index) {
    final medication = _medications[index];
    final isLastRow = index == _medications.length - 1;

    return Container(
      margin: EdgeInsets.only(bottom: isLastRow ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Medicamento
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: medication.medicamento,
                decoration: const InputDecoration(
                  hintText: 'Ej: Paracetamol',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(fontSize: 12),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
                onChanged: (value) {
                  _updateMedicationRow(
                    index,
                    medication.copyWith(medicamento: value),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Dosis
            Expanded(
              child: TextFormField(
                initialValue: medication.dosis,
                decoration: const InputDecoration(
                  hintText: '500mg',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(fontSize: 12),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
                onChanged: (value) {
                  _updateMedicationRow(
                    index,
                    medication.copyWith(dosis: value),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Vía de administración
            Expanded(
              child: TextFormField(
                initialValue: medication.viaAdministracion,
                decoration: const InputDecoration(
                  hintText: 'Oral',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(fontSize: 12),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
                onChanged: (value) {
                  _updateMedicationRow(
                    index,
                    medication.copyWith(viaAdministracion: value),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Hora mejorada
            Expanded(child: _buildTimeField(index, medication)),
            const SizedBox(width: 8),

            // Médico que indicó
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: medication.medicoIndico,
                decoration: const InputDecoration(
                  hintText: 'Ej: Dr. García',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(fontSize: 12),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requerido';
                  }
                  return null;
                },
                onChanged: (value) {
                  _updateMedicationRow(
                    index,
                    medication.copyWith(
                      medicoIndico: value,
                      medicoOtro: '', // Limpiar campo otro ya que no se usa
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),

            // Botón eliminar
            if (_medications.length > 1)
              IconButton(
                onPressed: () => _removeMedicationRow(index),
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              )
            else
              const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(int index, MedicationRow medication) {
    return TextFormField(
      initialValue: medication.hora,
      decoration: const InputDecoration(
        hintText: 'HH:MM',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      style: const TextStyle(fontSize: 12),
      keyboardType: TextInputType.text,
    );
  }

  // Método para normalizar formato de hora
  String _normalizeTimeFormat(String time) {
    if (time.isEmpty) return time;

    final parts = time.split(':');
    if (parts.length != 2) return time;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return time;

    // Normalizar a formato HH:MM
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que al menos un medicamento tenga datos
    bool hasValidMedication = false;
    for (final medication in _medications) {
      if (medication.medicamento.isNotEmpty ||
          medication.dosis.isNotEmpty ||
          medication.viaAdministracion.isNotEmpty) {
        hasValidMedication = true;
        break;
      }
    }

    if (!hasValidMedication) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe registrar al menos un medicamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Filtrar medicamentos con datos
      final validMedications =
          _medications
              .where(
                (med) =>
                    med.medicamento.isNotEmpty ||
                    med.dosis.isNotEmpty ||
                    med.viaAdministracion.isNotEmpty,
              )
              .toList();

      final formData = {
        'medicationsList':
            validMedications
                .map(
                  (med) => {
                    'medicamento': med.medicamento,
                    'dosis': med.dosis,
                    'viaAdministracion': med.viaAdministracion,
                    'hora': _normalizeTimeFormat(med.hora),
                    'medicoIndico': med.medicoIndico,
                    'medicoOtro': med.medicoOtro,
                  },
                )
                .toList(),
        'medications': validMedications
            .map(
              (med) =>
                  '${med.medicamento} - ${med.dosis} - ${med.viaAdministracion} - ${_normalizeTimeFormat(med.hora)} - ${med.medicoIndico == 'Otro' ? med.medicoOtro : med.medicoIndico}',
            )
            .join('\n'),
        'totalMedications': validMedications.length,
        'timestamp': DateTime.now().toIso8601String(),
      };

      widget.onSave(formData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${validMedications.length} medicamento(s) guardado(s) correctamente',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('Error al guardar: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Clase para representar una fila de medicamento
class MedicationRow {
  final String medicamento;
  final String dosis;
  final String viaAdministracion;
  final String hora;
  final String medicoIndico;
  final String medicoOtro;

  const MedicationRow({
    this.medicamento = '',
    this.dosis = '',
    this.viaAdministracion = '',
    this.hora = '',
    this.medicoIndico = '',
    this.medicoOtro = '',
  });

  MedicationRow copyWith({
    String? medicamento,
    String? dosis,
    String? viaAdministracion,
    String? hora,
    String? medicoIndico,
    String? medicoOtro,
  }) {
    return MedicationRow(
      medicamento: medicamento ?? this.medicamento,
      dosis: dosis ?? this.dosis,
      viaAdministracion: viaAdministracion ?? this.viaAdministracion,
      hora: hora ?? this.hora,
      medicoIndico: medicoIndico ?? this.medicoIndico,
      medicoOtro: medicoOtro ?? this.medicoOtro,
    );
  }
}
