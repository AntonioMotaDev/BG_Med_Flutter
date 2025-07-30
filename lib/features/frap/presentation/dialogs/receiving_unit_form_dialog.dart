import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ReceivingUnitFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const ReceivingUnitFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<ReceivingUnitFormDialog> createState() => _ReceivingUnitFormDialogState();
}

class _ReceivingUnitFormDialogState extends State<ReceivingUnitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ambulanciaNumeroController = TextEditingController();
  final _ambulanciaPlacasController = TextEditingController();
  final _doctorController = TextEditingController();
  final _otroLugarController = TextEditingController();
  
  bool _isLoading = false;

  // Variables para dropdowns
  String? _selectedLugarOrigen;
  String? _selectedLugarDestino;
  String? _selectedLugarConsulta;
  String? _selectedPersonal;

  // Lista de opciones para los dropdowns
  final List<String> _lugaresOptions = [
    'Domicilio',
    'Hospital Regional',
    'Hospital PEMEX Salamanca',
    'Hospital PEMEX Cd. Madero',
    'Hospital PEMEX Cd. México',
    'Hospital Angeles',
    'Hospital HEMS',
    'Otro',
  ];

  final List<String> _personalOptions = [
    'Médico',
    'Enfermero/a',
    'Paramédico',
    'Técnico',
    'Otro',
  ];

  // Lista dinámica para personal médico
  List<Map<String, String>> _personalMedicoList = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _selectedLugarOrigen = data['lugarOrigen'];
      _selectedLugarDestino = data['lugarDestino'];
      _selectedLugarConsulta = data['lugarConsulta'];
      _selectedPersonal = data['personal'];
      _ambulanciaNumeroController.text = data['ambulanciaNumero'] ?? '';
      _ambulanciaPlacasController.text = data['ambulanciaPlacas'] ?? '';
      _doctorController.text = data['doctor'] ?? '';
      _otroLugarController.text = data['otroLugar'] ?? '';
      
      // Personal médico
      if (data['personalMedico'] != null) {
        _personalMedicoList = List<Map<String, String>>.from(data['personalMedico']);
      }
    }
  }

  @override
  void dispose() {
    _ambulanciaNumeroController.dispose();
    _ambulanciaPlacasController.dispose();
    _doctorController.dispose();
    _otroLugarController.dispose();
    super.dispose();
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
                  const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'UNIDAD MÉDICA QUE RECIBE',
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lugar de origen
                      _buildDropdownField(
                        label: 'Lugar de Origen',
                        value: _selectedLugarOrigen,
                        items: _lugaresOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedLugarOrigen = value;
                          });
                        },
                      ),
                      
                      // Campo "Otro" para lugar de origen
                      if (_selectedLugarOrigen == 'Otro')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildTextField(
                            controller: _otroLugarController,
                            label: 'Especifique lugar de origen',
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Lugar de destino
                      _buildDropdownField(
                        label: 'Lugar de Destino',
                        value: _selectedLugarDestino,
                        items: _lugaresOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedLugarDestino = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Lugar de consulta (solo si no es domicilio)
                      if (_selectedLugarDestino != null && _selectedLugarDestino != 'Domicilio')
                        Column(
                          children: [
                            _buildDropdownField(
                              label: 'Lugar de Consulta',
                              value: _selectedLugarConsulta,
                              items: _lugaresOptions.where((item) => item != 'Domicilio').toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLugarConsulta = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Información de ambulancia
                      const Text(
                        'Información de Ambulancia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _ambulanciaNumeroController,
                              label: 'Número de Ambulancia',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _ambulanciaPlacasController,
                              label: 'Placas',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Personal médico
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Personal',
                              value: _selectedPersonal,
                              items: _personalOptions,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPersonal = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _doctorController,
                              label: 'Doctor',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Personal médico dinámico
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Personal Médico',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addPersonalMedico,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Añadir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Lista de personal médico
                      if (_personalMedicoList.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _personalMedicoList.length,
                            itemBuilder: (context, index) {
                              return _buildPersonalMedicoItem(index);
                            },
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label es requerido';
        }
        return null;
      },
    );
  }

  Widget _buildPersonalMedicoItem(int index) {
    final personal = _personalMedicoList[index];
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: personal['nombre'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (value) {
                    _personalMedicoList[index]['nombre'] = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: personal['especialidad'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Especialidad',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (value) {
                    _personalMedicoList[index]['especialidad'] = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: personal['cedula'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Cédula',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (value) {
                    _personalMedicoList[index]['cedula'] = value;
                  },
                ),
              ),
              IconButton(
                onPressed: () => _removePersonalMedico(index),
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addPersonalMedico() {
    setState(() {
      _personalMedicoList.add({
        'nombre': '',
        'especialidad': '',
        'cedula': '',
      });
    });
  }

  void _removePersonalMedico(int index) {
    setState(() {
      _personalMedicoList.removeAt(index);
    });
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
        'lugarOrigen': _selectedLugarOrigen,
        'lugarDestino': _selectedLugarDestino,
        'lugarConsulta': _selectedLugarDestino == 'Domicilio' ? null : _selectedLugarConsulta,
        'ambulanciaNumero': _ambulanciaNumeroController.text.trim(),
        'ambulanciaPlacas': _ambulanciaPlacasController.text.trim(),
        'personal': _selectedPersonal,
        'doctor': _doctorController.text.trim(),
        'otroLugar': _otroLugarController.text.trim(),
        'personalMedico': _personalMedicoList,
      };

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información de unidad receptora guardada'),
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