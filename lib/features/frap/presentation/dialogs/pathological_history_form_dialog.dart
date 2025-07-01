import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PathologicalHistoryFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const PathologicalHistoryFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<PathologicalHistoryFormDialog> createState() => _PathologicalHistoryFormDialogState();
}

class _PathologicalHistoryFormDialogState extends State<PathologicalHistoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controlador para el campo "Otro"
  final _otherController = TextEditingController();

  // Variables para los checkboxes
  bool _respiratoria = false;
  bool _emocional = false;
  bool _traumatica = false;
  bool _cardiovascular = false;
  bool _neurologica = false;
  bool _alergico = false;
  bool _metabolica = false;
  bool _otro = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      _respiratoria = data['respiratoria'] ?? false;
      _emocional = data['emocional'] ?? false;
      _traumatica = data['traumatica'] ?? false;
      _cardiovascular = data['cardiovascular'] ?? false;
      _neurologica = data['neurologica'] ?? false;
      _alergico = data['alergico'] ?? false;
      _metabolica = data['metabolica'] ?? false;
      _otro = data['otro'] ?? false;
      _otherController.text = data['otherDescription'] ?? '';
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
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
                  const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'ANTECEDENTES PATOLÓGICOS',
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
                      const Text(
                        'Seleccione los antecedentes patológicos que apliquen:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Lista de antecedentes patológicos
                      _buildCheckboxOption(
                        value: _respiratoria,
                        title: 'Respiratoria',
                        onChanged: (value) {
                          setState(() {
                            _respiratoria = value ?? false;
                          });
                        },
                      ),
                      
                      _buildCheckboxOption(
                        value: _emocional,
                        title: 'Emocional',
                        onChanged: (value) {
                          setState(() {
                            _emocional = value ?? false;
                          });
                        },
                      ),
                      
                      _buildCheckboxOption(
                        value: _traumatica,
                        title: 'Traumática',
                        onChanged: (value) {
                          setState(() {
                            _traumatica = value ?? false;
                          });
                        },
                      ),
                      
                      _buildCheckboxOption(
                        value: _cardiovascular,
                        title: 'Cardiovascular',
                        onChanged: (value) {
                          setState(() {
                            _cardiovascular = value ?? false;
                          });
                        },
                      ),
                      
                      _buildCheckboxOption(
                        value: _neurologica,
                        title: 'Neurológica',
                        onChanged: (value) {
                          setState(() {
                            _neurologica = value ?? false;
                          });
                        },
                      ),
                      
                      _buildCheckboxOption(
                        value: _alergico,
                        title: 'Alérgico',
                        onChanged: (value) {
                          setState(() {
                            _alergico = value ?? false;
                          });
                        },
                      ),
                      
                      _buildCheckboxOption(
                        value: _metabolica,
                        title: 'Metabólica',
                        onChanged: (value) {
                          setState(() {
                            _metabolica = value ?? false;
                          });
                        },
                      ),

                      // Opción "Otro" con campo de texto
                      Row(
                        children: [
                          Checkbox(
                            value: _otro,
                            onChanged: (value) {
                              setState(() {
                                _otro = value ?? false;
                                if (!_otro) {
                                  _otherController.clear();
                                }
                              });
                            },
                            activeColor: AppTheme.primaryBlue,
                          ),
                          const Text(
                            'Otro:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _otherController,
                              enabled: _otro,
                              decoration: const InputDecoration(
                                hintText: 'Especifique...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              style: const TextStyle(fontSize: 14),
                              validator: (value) {
                                if (_otro && (value == null || value.trim().isEmpty)) {
                                  return 'Especifique el antecedente';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                if (value.isNotEmpty && !_otro) {
                                  setState(() {
                                    _otro = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Información adicional
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Seleccione todos los antecedentes patológicos que apliquen al paciente. Esta información es importante para el tratamiento.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
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
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Guardando...' : 'Guardar Sección'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
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

  Widget _buildCheckboxOption({
    required bool value,
    required String title,
    required Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = {
        'respiratoria': _respiratoria,
        'emocional': _emocional,
        'traumatica': _traumatica,
        'cardiovascular': _cardiovascular,
        'neurologica': _neurologica,
        'alergico': _alergico,
        'metabolica': _metabolica,
        'otro': _otro,
        'otherDescription': _otherController.text.trim(),
      };

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Antecedentes patológicos guardados'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
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