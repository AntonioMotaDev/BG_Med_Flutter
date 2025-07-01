import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ClinicalHistoryFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const ClinicalHistoryFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<ClinicalHistoryFormDialog> createState() => _ClinicalHistoryFormDialogState();
}

class _ClinicalHistoryFormDialogState extends State<ClinicalHistoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para campos de texto
  final _otherTypeController = TextEditingController();
  final _agenteCausalController = TextEditingController();
  final _cinematicaController = TextEditingController();
  final _medidaSeguridadController = TextEditingController();

  // Variables para los checkboxes de tipo
  bool _atropellado = false;
  bool _lxPorCaida = false;
  bool _intoxicacion = false;
  bool _amputacion = false;
  bool _choque = false;
  bool _agresion = false;
  bool _hpaf = false;
  bool _hpab = false;
  bool _volcadura = false;
  bool _quemadura = false;
  bool _otroTipo = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      // Tipos
      _atropellado = data['atropellado'] ?? false;
      _lxPorCaida = data['lxPorCaida'] ?? false;
      _intoxicacion = data['intoxicacion'] ?? false;
      _amputacion = data['amputacion'] ?? false;
      _choque = data['choque'] ?? false;
      _agresion = data['agresion'] ?? false;
      _hpaf = data['hpaf'] ?? false;
      _hpab = data['hpab'] ?? false;
      _volcadura = data['volcadura'] ?? false;
      _quemadura = data['quemadura'] ?? false;
      _otroTipo = data['otroTipo'] ?? false;
      
      // Campos de texto
      _otherTypeController.text = data['otherTypeDescription'] ?? '';
      _agenteCausalController.text = data['agenteCausal'] ?? '';
      _cinematicaController.text = data['cinematica'] ?? '';
      _medidaSeguridadController.text = data['medidaSeguridad'] ?? '';
    }
  }

  @override
  void dispose() {
    _otherTypeController.dispose();
    _agenteCausalController.dispose();
    _cinematicaController.dispose();
    _medidaSeguridadController.dispose();
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
                    Icons.description,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'ANTECEDENTES CLÍNICOS',
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
                      // Sección A) Tipo
                      _buildSectionTitle('A) Tipo:'),
                      const SizedBox(height: 16),
                      
                      // Primera fila de tipos
                      Row(
                        children: [
                          Expanded(child: _buildCheckboxOption(_atropellado, 'Atropellado', (value) => setState(() => _atropellado = value ?? false))),
                          Expanded(child: _buildCheckboxOption(_lxPorCaida, 'Lx. Por caída', (value) => setState(() => _lxPorCaida = value ?? false))),
                          Expanded(child: _buildCheckboxOption(_intoxicacion, 'Intoxicación', (value) => setState(() => _intoxicacion = value ?? false))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildCheckboxOption(_amputacion, 'Amputación', (value) => setState(() => _amputacion = value ?? false))),
                          Expanded(child: _buildCheckboxOption(_choque, 'Choque', (value) => setState(() => _choque = value ?? false))),
                          const Expanded(child: SizedBox()), // Espacio vacío
                        ],
                      ),
                      
                      // Segunda fila de tipos
                      Row(
                        children: [
                          Expanded(child: _buildCheckboxOption(_agresion, 'Agresión', (value) => setState(() => _agresion = value ?? false))),
                          Expanded(child: _buildCheckboxOption(_hpaf, 'H.P.A.F.', (value) => setState(() => _hpaf = value ?? false))),
                          Expanded(child: _buildCheckboxOption(_hpab, 'H.P.A.B.', (value) => setState(() => _hpab = value ?? false))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildCheckboxOption(_volcadura, 'Volcadura', (value) => setState(() => _volcadura = value ?? false))),
                          Expanded(child: _buildCheckboxOption(_quemadura, 'Quemadura', (value) => setState(() => _quemadura = value ?? false))),
                          const Expanded(child: SizedBox()), // Espacio vacío
                        ],
                      ),

                      // Opción "Otro" con campo de texto
                      Row(
                        children: [
                          Checkbox(
                            value: _otroTipo,
                            onChanged: (value) {
                              setState(() {
                                _otroTipo = value ?? false;
                                if (!_otroTipo) {
                                  _otherTypeController.clear();
                                }
                              });
                            },
                            activeColor: AppTheme.primaryBlue,
                          ),
                          const Text('Otro', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _otherTypeController,
                              enabled: _otroTipo,
                              decoration: const InputDecoration(
                                hintText: 'Especifique:',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              style: const TextStyle(fontSize: 14),
                              onChanged: (value) {
                                if (value.isNotEmpty && !_otroTipo) {
                                  setState(() => _otroTipo = true);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // Sección B) Agente causal
                      _buildSectionTitle('B) Agente causal:'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _agenteCausalController,
                        decoration: const InputDecoration(
                          hintText: 'Especifique:',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14),
                      ),
                      
                      const SizedBox(height: 24),

                      // Cinemática
                      _buildSectionTitle('Cinemática:'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cinematicaController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14),
                      ),
                      
                      const SizedBox(height: 24),

                      // Medida de seguridad
                      _buildSectionTitle('Medida de seguridad:'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _medidaSeguridadController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCheckboxOption(bool value, String title, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryBlue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final formData = {
        // Tipos
        'atropellado': _atropellado,
        'lxPorCaida': _lxPorCaida,
        'intoxicacion': _intoxicacion,
        'amputacion': _amputacion,
        'choque': _choque,
        'agresion': _agresion,
        'hpaf': _hpaf,
        'hpab': _hpab,
        'volcadura': _volcadura,
        'quemadura': _quemadura,
        'otroTipo': _otroTipo,
        'otherTypeDescription': _otherTypeController.text.trim(),
        
        // Campos de texto
        'agenteCausal': _agenteCausalController.text.trim(),
        'cinematica': _cinematicaController.text.trim(),
        'medidaSeguridad': _medidaSeguridadController.text.trim(),
      };

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Antecedentes clínicos guardados'),
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