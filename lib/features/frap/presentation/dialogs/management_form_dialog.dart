import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManagementFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const ManagementFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<ManagementFormDialog> createState() => _ManagementFormDialogState();
}

class _ManagementFormDialogState extends State<ManagementFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controlador solo para el campo numérico de Lt/min
  final _ltMinController = TextEditingController();

  // Variables para checkboxes (opciones seleccionables)
  bool _viaAerea = false;
  bool _canalizacion = false;
  bool _empaquetamiento = false;
  bool _inmovilizacion = false;
  bool _monitor = false;
  bool _rcpBasica = false;
  bool _mastPna = false;
  bool _collarinCervical = false;
  bool _desfibrilacion = false;
  bool _apoyoVent = false;
  bool _oxigeno = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      _viaAerea = data['viaAerea'] ?? false;
      _canalizacion = data['canalizacion'] ?? false;
      _empaquetamiento = data['empaquetamiento'] ?? false;
      _inmovilizacion = data['inmovilizacion'] ?? false;
      _monitor = data['monitor'] ?? false;
      _rcpBasica = data['rcpBasica'] ?? false;
      _mastPna = data['mastPna'] ?? false;
      _collarinCervical = data['collarinCervical'] ?? false;
      _desfibrilacion = data['desfibrilacion'] ?? false;
      _apoyoVent = data['apoyoVent'] ?? false;
      _oxigeno = data['oxigeno'] ?? false;
      _ltMinController.text = data['ltMin'] ?? '';
    }
  }

  @override
  void dispose() {
    _ltMinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.65,
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
                    Icons.medical_services,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'MANEJO',
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
                      // Primera fila: Vía aérea, Canalización, Empaquetamiento
                      Row(
                        children: [
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'Vía aérea',
                              value: _viaAerea,
                              onChanged: (value) {
                                setState(() {
                                  _viaAerea = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'Canalización',
                              value: _canalizacion,
                              onChanged: (value) {
                                setState(() {
                                  _canalizacion = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'Empaquetamiento',
                              value: _empaquetamiento,
                              onChanged: (value) {
                                setState(() {
                                  _empaquetamiento = value ?? false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Segunda fila: Inmovilización, Monitor, RCP Básica
                      Row(
                        children: [
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'Inmovilización',
                              value: _inmovilizacion,
                              onChanged: (value) {
                                setState(() {
                                  _inmovilizacion = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'Monitor',
                              value: _monitor,
                              onChanged: (value) {
                                setState(() {
                                  _monitor = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'RCP Básica',
                              value: _rcpBasica,
                              onChanged: (value) {
                                setState(() {
                                  _rcpBasica = value ?? false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tercera fila: MAST o PNA, Collarin Cervical, Desfibrilación
                      Row(
                        children: [
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'MAST o PNA',
                              value: _mastPna,
                              onChanged: (value) {
                                setState(() {
                                  _mastPna = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'Collarin Cervical',
                              value: _collarinCervical,
                              onChanged: (value) {
                                setState(() {
                                  _collarinCervical = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'Desfibrilación',
                              value: _desfibrilacion,
                              onChanged: (value) {
                                setState(() {
                                  _desfibrilacion = value ?? false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Cuarta fila: Apoyo Vent., Oxígeno con Lt/min
                      Row(
                        children: [
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'Apoyo Vent.',
                              value: _apoyoVent,
                              onChanged: (value) {
                                setState(() {
                                  _apoyoVent = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCheckboxField(
                              label: 'Oxígeno',
                              value: _oxigeno,
                              onChanged: (value) {
                                setState(() {
                                  _oxigeno = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _ltMinController,
                              label: 'Lt/min',
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      style: const TextStyle(fontSize: 14),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label es requerido';
        }
        return null;
      },
    );
  }

  Widget _buildCheckboxField({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CheckboxListTile(
        title: Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
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
        'viaAerea': _viaAerea,
        'canalizacion': _canalizacion,
        'empaquetamiento': _empaquetamiento,
        'inmovilizacion': _inmovilizacion,
        'monitor': _monitor,
        'rcpBasica': _rcpBasica,
        'mastPna': _mastPna,
        'collarinCervical': _collarinCervical,
        'desfibrilacion': _desfibrilacion,
        'apoyoVent': _apoyoVent,
        'oxigeno': _oxigeno,
        'ltMin': _ltMinController.text.trim(),
      };

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información de manejo guardada'),
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