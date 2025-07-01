import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GynecoObstetricFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const GynecoObstetricFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<GynecoObstetricFormDialog> createState() => _GynecoObstetricFormDialogState();
}

class _GynecoObstetricFormDialogState extends State<GynecoObstetricFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores de texto
  final _fumController = TextEditingController();
  final _semanasGestacionController = TextEditingController();
  final _gestaController = TextEditingController();
  final _abortosController = TextEditingController();
  final _partosController = TextEditingController();
  final _metodosAnticonceptivosController = TextEditingController();
  final _horaController = TextEditingController();
  final _cesareasController = TextEditingController();

  // Variables para opciones seleccionables
  String _ruidosCardiacosFetales = '';
  String _expulsionPlacenta = '';

  final List<String> _ruidosOptions = ['Perceptibles', 'No Perceptibles'];
  final List<String> _expulsionOptions = ['Si', 'No'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      _fumController.text = data['fum'] ?? '';
      _semanasGestacionController.text = data['semanasGestacion'] ?? '';
      _gestaController.text = data['gesta'] ?? '';
      _abortosController.text = data['abortos'] ?? '';
      _partosController.text = data['partos'] ?? '';
      _metodosAnticonceptivosController.text = data['metodosAnticonceptivos'] ?? '';
      _horaController.text = data['hora'] ?? '';
      _cesareasController.text = data['cesareas'] ?? '';
      
      _ruidosCardiacosFetales = data['ruidosCardiacosFetales'] ?? '';
      _expulsionPlacenta = data['expulsionPlacenta'] ?? '';
    }
  }

  @override
  void dispose() {
    _fumController.dispose();
    _semanasGestacionController.dispose();
    _gestaController.dispose();
    _abortosController.dispose();
    _partosController.dispose();
    _metodosAnticonceptivosController.dispose();
    _horaController.dispose();
    _cesareasController.dispose();
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
                color: Colors.pink,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pregnant_woman,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'URGENCIAS GINECO-OBSTÉTRICAS',
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
                      // Sección PARTO
                      _buildSectionTitle('PARTO'),
                      const SizedBox(height: 16),
                      
                      // F.U.M. y Semanas de Gestación
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _fumController,
                              label: 'F.U.M.',
                              hintText: 'Fecha de última menstruación',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _semanasGestacionController,
                              label: 'Semanas de Gestación',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Ruidos Cardíacos Fetales
                      _buildDropdownField(
                        label: 'Ruidos Cardíacos Fetales',
                        value: _ruidosCardiacosFetales,
                        options: _ruidosOptions,
                        onChanged: (value) {
                          setState(() {
                            _ruidosCardiacosFetales = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Expulsión de placenta
                      _buildDropdownField(
                        label: 'Expulsión de placenta',
                        value: _expulsionPlacenta,
                        options: _expulsionOptions,
                        onChanged: (value) {
                          setState(() {
                            _expulsionPlacenta = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Gesta y Abortos
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _gestaController,
                              label: 'Gesta',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _abortosController,
                              label: 'Abortos',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sección ABORTO
                      _buildSectionTitle('ABORTO'),
                      const SizedBox(height: 16),

                      // Partos
                      _buildTextField(
                        controller: _partosController,
                        label: 'Partos',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Métodos Anticonceptivos
                      _buildTextField(
                        controller: _metodosAnticonceptivosController,
                        label: 'Métodos Anticonceptivos',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Sección HX. VAGINAL
                      _buildSectionTitle('HX. VAGINAL'),
                      const SizedBox(height: 16),

                      // Hora y Cesáreas
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeField(
                              controller: _horaController,
                              label: 'Hora',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _cesareasController,
                              label: 'Cesáreas',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
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
                      backgroundColor: Colors.pink,
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

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
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
        hintText: hintText,
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
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Seleccione una opción';
        }
        return null;
      },
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: () async {
            final TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) {
              final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              controller.text = formattedTime;
            }
          },
        ),
      ),
      style: const TextStyle(fontSize: 14),
      readOnly: true,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label es requerido';
        }
        return null;
      },
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
        'fum': _fumController.text.trim(),
        'semanasGestacion': _semanasGestacionController.text.trim(),
        'ruidosCardiacosFetales': _ruidosCardiacosFetales,
        'expulsionPlacenta': _expulsionPlacenta,
        'gesta': _gestaController.text.trim(),
        'abortos': _abortosController.text.trim(),
        'partos': _partosController.text.trim(),
        'metodosAnticonceptivos': _metodosAnticonceptivosController.text.trim(),
        'hora': _horaController.text.trim(),
        'cesareas': _cesareasController.text.trim(),
      };

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información gineco-obstétrica guardada'),
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