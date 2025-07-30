import 'package:flutter/material.dart';

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
  final _observacionesController = TextEditingController();
  final _frecuenciaCardiacaFetalController = TextEditingController();
  final _contraccionesController = TextEditingController();

  // Variables para checkboxes
  bool _isParto = false;
  bool _isAborto = false;
  bool _isHxVaginal = false;
  bool _ruidosFetalesPerceptibles = false;

  // Variables para escalas
  Map<String, int> _silvermanAnderson = {
    'minuto': 0,
    '3min': 0,
    '5min': 0,
    '10min': 0,
  };

  Map<String, int> _apgar = {
    'minuto': 0,
    '3min': 0,
    '5min': 0,
    '10min': 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      // Campos de texto
      _fumController.text = data['fum'] ?? '';
      _semanasGestacionController.text = data['semanasGestacion'] ?? '';
      _observacionesController.text = data['observaciones'] ?? '';
      _frecuenciaCardiacaFetalController.text = data['frecuenciaCardiacaFetal'] ?? '';
      _contraccionesController.text = data['contracciones'] ?? '';
      
      // Checkboxes
      _isParto = data['isParto'] ?? false;
      _isAborto = data['isAborto'] ?? false;
      _isHxVaginal = data['isHxVaginal'] ?? false;
      _ruidosFetalesPerceptibles = data['ruidosFetalesPerceptibles'] ?? false;
      
      // Escalas
      if (data['silvermanAnderson'] != null) {
        final silvermanData = Map<String, dynamic>.from(data['silvermanAnderson']);
        _silvermanAnderson = {
          'minuto': silvermanData['minuto'] ?? 0,
          '3min': silvermanData['3min'] ?? 0,
          '5min': silvermanData['5min'] ?? 0,
          '10min': silvermanData['10min'] ?? 0,
        };
      }
      
      if (data['apgar'] != null) {
        final apgarData = Map<String, dynamic>.from(data['apgar']);
        _apgar = {
          'minuto': apgarData['minuto'] ?? 0,
          '3min': apgarData['3min'] ?? 0,
          '5min': apgarData['5min'] ?? 0,
          '10min': apgarData['10min'] ?? 0,
        };
      }
    }
  }

  @override
  void dispose() {
    _fumController.dispose();
    _semanasGestacionController.dispose();
    _observacionesController.dispose();
    _frecuenciaCardiacaFetalController.dispose();
    _contraccionesController.dispose();
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
                color: Colors.pink[600],
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
                      // Tipo de Urgencia
                      _buildSectionTitle('TIPO DE URGENCIA'),
                      const SizedBox(height: 16),
                      
                      _buildCheckboxOption(
                        title: 'Parto',
                        value: _isParto,
                        onChanged: (value) {
                          setState(() {
                            _isParto = value ?? false;
                          });
                        },
                      ),
                      
                      _buildCheckboxOption(
                        title: 'Aborto',
                        value: _isAborto,
                        onChanged: (value) {
                          setState(() {
                            _isAborto = value ?? false;
                          });
                        },
                      ),
                      
                      _buildCheckboxOption(
                        title: 'Hx Vaginal',
                        value: _isHxVaginal,
                        onChanged: (value) {
                          setState(() {
                            _isHxVaginal = value ?? false;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),

                      // Información General
                      _buildSectionTitle('INFORMACIÓN GENERAL'),
                      const SizedBox(height: 16),
                      
                      // F.U.M. y Semanas de Gestación
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _fumController,
                              decoration: const InputDecoration(
                                labelText: 'F.U.M.',
                                border: OutlineInputBorder(),
                                hintText: 'dd/mm/yyyy',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _semanasGestacionController,
                              decoration: const InputDecoration(
                                labelText: 'Semanas de Gestación',
                                border: OutlineInputBorder(),
                                suffixText: 'semanas',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // Ruidos Fetales
                      _buildSectionTitle('RUIDOS FETALES'),
                      const SizedBox(height: 16),
                      
                      _buildCheckboxOption(
                        title: 'Ruidos fetales perceptibles',
                        value: _ruidosFetalesPerceptibles,
                        onChanged: (value) {
                          setState(() {
                            _ruidosFetalesPerceptibles = value ?? false;
                          });
                        },
                      ),
                      
                      if (_ruidosFetalesPerceptibles) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _frecuenciaCardiacaFetalController,
                          decoration: const InputDecoration(
                            labelText: 'Frecuencia Cardíaca Fetal',
                            border: OutlineInputBorder(),
                            suffixText: 'lpm',
                            hintText: 'Ej: 140',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      
                      const SizedBox(height: 24),

                      // Contracciones
                      _buildSectionTitle('CONTRACCIONES'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _contraccionesController,
                        decoration: const InputDecoration(
                          labelText: 'Contracciones',
                          border: OutlineInputBorder(),
                          hintText: 'Ej: 2/10, 1/5, contracción/minuto',
                        ),
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 24),

                      // Escalas (solo si es parto)
                      if (_isParto) ...[
                        _buildSectionTitle('ESCALAS OBSTÉTRICAS'),
                        const SizedBox(height: 16),
                        
                        // Silverman Anderson
                        _buildScaleSection(
                          title: 'Silverman Anderson',
                          scale: _silvermanAnderson,
                          onScaleChanged: (newScale) {
                            setState(() {
                              _silvermanAnderson = newScale;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Apgar
                        _buildScaleSection(
                          title: 'Apgar',
                          scale: _apgar,
                          onScaleChanged: (newScale) {
                            setState(() {
                              _apgar = newScale;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 24),
                      ],

                      // Observaciones
                      _buildSectionTitle('OBSERVACIONES GENERALES'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _observacionesController,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones',
                          border: OutlineInputBorder(),
                          hintText: 'Observaciones adicionales...',
                        ),
                        maxLines: 4,
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
                      backgroundColor: Colors.pink[600],
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

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.medical_services, color: Colors.pink[700], size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.pink[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.pink[600],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildScaleSection({
    required String title,
    required Map<String, int> scale,
    required Function(Map<String, int>) onScaleChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Escala del 1-10',
            style: TextStyle(
              fontSize: 12,
              color: Colors.purple[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          
          // Grid de inputs para los tiempos
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: scale.entries.map((entry) {
              return _buildScaleInput(
                label: entry.key == 'minuto' ? 'Minuto' : '${entry.key}',
                value: entry.value,
                onChanged: (newValue) {
                  final newScale = Map<String, int>.from(scale);
                  newScale[entry.key] = newValue;
                  onScaleChanged(newScale);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleInput({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<int>(
            value: value > 0 ? value : null,
            decoration: const InputDecoration(
              hintText: 'Seleccionar',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: List.generate(10, (index) => index + 1).map((score) {
              return DropdownMenuItem(
                value: score,
                child: Text('$score'),
              );
            }).toList(),
            onChanged: (newValue) {
              onChanged(newValue ?? 0);
            },
          ),
        ),
      ],
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
        'isParto': _isParto,
        'isAborto': _isAborto,
        'isHxVaginal': _isHxVaginal,
        'fum': _fumController.text.trim(),
        'semanasGestacion': _semanasGestacionController.text.trim(),
        'ruidosFetalesPerceptibles': _ruidosFetalesPerceptibles,
        'frecuenciaCardiacaFetal': _frecuenciaCardiacaFetalController.text.trim(),
        'contracciones': _contraccionesController.text.trim(),
        'silvermanAnderson': _silvermanAnderson,
        'apgar': _apgar,
        'observaciones': _observacionesController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Información gineco-obstétrica guardada exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
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
              borderRadius: BorderRadius.all(Radius.circular(8)),
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