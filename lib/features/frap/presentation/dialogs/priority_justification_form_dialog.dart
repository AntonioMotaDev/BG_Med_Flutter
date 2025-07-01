import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PriorityJustificationFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const PriorityJustificationFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<PriorityJustificationFormDialog> createState() => _PriorityJustificationFormDialogState();
}

class _PriorityJustificationFormDialogState extends State<PriorityJustificationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _especifiqueController = TextEditingController();
  bool _isLoading = false;

  // Variables para las selecciones
  String? _selectedPriority;
  String? _selectedPupils;
  String? _selectedSkinColor;
  String? _selectedSkin;
  String? _selectedTemperature;
  String? _selectedInfluence;

  // Opciones de prioridad con colores
  final List<Map<String, dynamic>> _priorityOptions = [
    {'value': 'rojo', 'label': 'Rojo', 'color': Colors.red},
    {'value': 'amarillo', 'label': 'Amarillo', 'color': Colors.amber},
    {'value': 'verde', 'label': 'Verde', 'color': Colors.green},
    {'value': 'negro', 'label': 'Negro', 'color': Colors.black87},
  ];

  // Opciones para cada categoría
  final List<String> _pupilsOptions = ['Iguales', 'Midriasis', 'Miosis', 'Anisocoria', 'Arreflexia'];
  final List<String> _skinColorOptions = ['Normal', 'Cianosis', 'Marmórea', 'Pálida'];
  final List<String> _skinOptions = ['Seca', 'Húmeda'];
  final List<String> _temperatureOptions = ['Normal', 'Caliente', 'Fría'];
  final List<String> _influenceOptions = ['Alcohol', 'Otras drogas', 'Otro'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _selectedPriority = data['priority'];
      _selectedPupils = data['pupils'];
      _selectedSkinColor = data['skinColor'];
      _selectedSkin = data['skin'];
      _selectedTemperature = data['temperature'];
      _selectedInfluence = data['influence'];
      _especifiqueController.text = data['especifique'] ?? '';
    }
  }

  @override
  void dispose() {
    _especifiqueController.dispose();
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
                    Icons.priority_high,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'JUSTIFICACIÓN DE PRIORIDAD',
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
                      // Selección de Prioridad por Color
                      _buildSectionTitle('Nivel de Prioridad', Icons.flag),
                      const SizedBox(height: 16),
                      _buildPrioritySelector(),
                      
                      const SizedBox(height: 24),

                      // Evaluaciones Clínicas
                      _buildSectionTitle('Evaluación Clínica', Icons.medical_services),
                      const SizedBox(height: 16),

                      // Pupilas
                      _buildClinicalSection(
                        title: 'Pupilas:',
                        options: _pupilsOptions,
                        selectedValue: _selectedPupils,
                        onChanged: (value) => setState(() => _selectedPupils = value),
                        icon: Icons.visibility,
                        color: Colors.purple,
                      ),

                      const SizedBox(height: 16),

                      // Color de Piel
                      _buildClinicalSection(
                        title: 'Color Piel:',
                        options: _skinColorOptions,
                        selectedValue: _selectedSkinColor,
                        onChanged: (value) => setState(() => _selectedSkinColor = value),
                        icon: Icons.palette,
                        color: Colors.orange,
                      ),

                      const SizedBox(height: 16),

                      // Piel
                      _buildClinicalSection(
                        title: 'Piel:',
                        options: _skinOptions,
                        selectedValue: _selectedSkin,
                        onChanged: (value) => setState(() => _selectedSkin = value),
                        icon: Icons.touch_app,
                        color: Colors.teal,
                      ),

                      const SizedBox(height: 16),

                      // Temperatura
                      _buildClinicalSection(
                        title: 'Temperatura:',
                        options: _temperatureOptions,
                        selectedValue: _selectedTemperature,
                        onChanged: (value) => setState(() => _selectedTemperature = value),
                        icon: Icons.thermostat,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 16),

                      // Influenciado por
                      _buildClinicalSection(
                        title: 'Influenciado por:',
                        options: _influenceOptions,
                        selectedValue: _selectedInfluence,
                        onChanged: (value) => setState(() => _selectedInfluence = value),
                        icon: Icons.psychology,
                        color: Colors.indigo,
                      ),

                      const SizedBox(height: 20),

                      // Campo Especifique
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          color: Colors.grey[50],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.edit_note, color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Especifique:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                controller: _especifiqueController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: 'Describa información adicional relevante para la evaluación...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(12),
                                ),
                                style: const TextStyle(fontSize: 14),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.emergency, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Seleccione el nivel de prioridad:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _priorityOptions.map((option) {
                final isSelected = _selectedPriority == option['value'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = option['value']),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? option['color'] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: option['color'],
                          width: 2,
                        ),
                      ),
                      child: Text(
                        option['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : option['color'],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalSection({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selectedValue == option;
                return GestureDetector(
                  onTap: () => onChanged(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final formData = {
        'priority': _selectedPriority,
        'pupils': _selectedPupils,
        'skinColor': _selectedSkinColor,
        'skin': _selectedSkin,
        'temperature': _selectedTemperature,
        'influence': _selectedInfluence,
        'especifique': _especifiqueController.text.trim(),
      };

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Justificación de prioridad guardada'),
              ],
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