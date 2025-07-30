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

class _PathologicalHistoryFormDialogState extends State<PathologicalHistoryFormDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Variables para checkboxes
  bool _diabetes = false;
  bool _hipertension = false;
  bool _cardiopatias = false;
  bool _enfermedadesRenales = false;
  bool _enfermedadesHepaticas = false;
  bool _enfermedadesRespiratorias = false;
  bool _enfermedadesNeurologicas = false;
  bool _cancer = false;
  bool _vih = false;
  bool _otras = false;

  // Controladores para especificaciones
  final _diabetesEspecifiqueController = TextEditingController();
  final _hipertensionEspecifiqueController = TextEditingController();
  final _cardiopatiasEspecifiqueController = TextEditingController();
  final _enfermedadesRenalesEspecifiqueController = TextEditingController();
  final _enfermedadesHepaticasEspecifiqueController = TextEditingController();
  final _enfermedadesRespiratoriasEspecifiqueController = TextEditingController();
  final _enfermedadesNeurologicasEspecifiqueController = TextEditingController();
  final _cancerEspecifiqueController = TextEditingController();
  final _vihEspecifiqueController = TextEditingController();
  final _otrasEspecifiqueController = TextEditingController();

  // Animación para el diálogo
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      _diabetes = data['diabetes'] ?? false;
      _hipertension = data['hipertension'] ?? false;
      _cardiopatias = data['cardiopatias'] ?? false;
      _enfermedadesRenales = data['enfermedadesRenales'] ?? false;
      _enfermedadesHepaticas = data['enfermedadesHepaticas'] ?? false;
      _enfermedadesRespiratorias = data['enfermedadesRespiratorias'] ?? false;
      _enfermedadesNeurologicas = data['enfermedadesNeurologicas'] ?? false;
      _cancer = data['cancer'] ?? false;
      _vih = data['vih'] ?? false;
      _otras = data['otras'] ?? false;

      // Especificaciones
      _diabetesEspecifiqueController.text = data['diabetesEspecifique'] ?? '';
      _hipertensionEspecifiqueController.text = data['hipertensionEspecifique'] ?? '';
      _cardiopatiasEspecifiqueController.text = data['cardiopatiasEspecifique'] ?? '';
      _enfermedadesRenalesEspecifiqueController.text = data['enfermedadesRenalesEspecifique'] ?? '';
      _enfermedadesHepaticasEspecifiqueController.text = data['enfermedadesHepaticasEspecifique'] ?? '';
      _enfermedadesRespiratoriasEspecifiqueController.text = data['enfermedadesRespiratoriasEspecifique'] ?? '';
      _enfermedadesNeurologicasEspecifiqueController.text = data['enfermedadesNeurologicasEspecifique'] ?? '';
      _cancerEspecifiqueController.text = data['cancerEspecifique'] ?? '';
      _vihEspecifiqueController.text = data['vihEspecifique'] ?? '';
      _otrasEspecifiqueController.text = data['otrasEspecifique'] ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _diabetesEspecifiqueController.dispose();
    _hipertensionEspecifiqueController.dispose();
    _cardiopatiasEspecifiqueController.dispose();
    _enfermedadesRenalesEspecifiqueController.dispose();
    _enfermedadesHepaticasEspecifiqueController.dispose();
    _enfermedadesRespiratoriasEspecifiqueController.dispose();
    _enfermedadesNeurologicasEspecifiqueController.dispose();
    _cancerEspecifiqueController.dispose();
    _vihEspecifiqueController.dispose();
    _otrasEspecifiqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header mejorado
                    _buildHeader(),
                    
                    // Content mejorado
                    Expanded(
                      child: _buildContent(),
                    ),

                    // Footer mejorado
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_information,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Antecedentes Patológicos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Historial médico del paciente',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.checklist,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Seleccione los antecedentes patológicos del paciente',
                      style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid de opciones mejorado
            _buildDiseaseGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseGrid() {
    final diseases = [
      {
        'label': 'Diabetes',
        'icon': Icons.monitor_heart,
        'value': _diabetes,
        'controller': _diabetesEspecifiqueController,
        'onChanged': (value) => setState(() => _diabetes = value ?? false),
      },
      {
        'label': 'Hipertensión',
        'icon': Icons.favorite,
        'value': _hipertension,
        'controller': _hipertensionEspecifiqueController,
        'onChanged': (value) => setState(() => _hipertension = value ?? false),
      },
      {
        'label': 'Cardiopatías',
        'icon': Icons.favorite_border,
        'value': _cardiopatias,
        'controller': _cardiopatiasEspecifiqueController,
        'onChanged': (value) => setState(() => _cardiopatias = value ?? false),
      },
      {
        'label': 'Enfermedades Renales',
        'icon': Icons.water_drop,
        'value': _enfermedadesRenales,
        'controller': _enfermedadesRenalesEspecifiqueController,
        'onChanged': (value) => setState(() => _enfermedadesRenales = value ?? false),
      },
      {
        'label': 'Enfermedades Hepáticas',
        'icon': Icons.local_hospital,
        'value': _enfermedadesHepaticas,
        'controller': _enfermedadesHepaticasEspecifiqueController,
        'onChanged': (value) => setState(() => _enfermedadesHepaticas = value ?? false),
      },
      {
        'label': 'Enfermedades Respiratorias',
        'icon': Icons.air,
        'value': _enfermedadesRespiratorias,
        'controller': _enfermedadesRespiratoriasEspecifiqueController,
        'onChanged': (value) => setState(() => _enfermedadesRespiratorias = value ?? false),
      },
      {
        'label': 'Enfermedades Neurológicas',
        'icon': Icons.psychology,
        'value': _enfermedadesNeurologicas,
        'controller': _enfermedadesNeurologicasEspecifiqueController,
        'onChanged': (value) => setState(() => _enfermedadesNeurologicas = value ?? false),
      },
      {
        'label': 'Cáncer',
        'icon': Icons.warning,
        'value': _cancer,
        'controller': _cancerEspecifiqueController,
        'onChanged': (value) => setState(() => _cancer = value ?? false),
      },
      {
        'label': 'VIH',
        'icon': Icons.error,
        'value': _vih,
        'controller': _vihEspecifiqueController,
        'onChanged': (value) => setState(() => _vih = value ?? false),
      },
      {
        'label': 'Otras',
        'icon': Icons.more_horiz,
        'value': _otras,
        'controller': _otrasEspecifiqueController,
        'onChanged': (value) => setState(() => _otras = value ?? false),
      },
    ];

    return Column(
      children: diseases.map((disease) {
        return _buildDiseaseListItem(
          label: disease['label'] as String,
          icon: disease['icon'] as IconData,
          value: disease['value'] as bool,
          controller: disease['controller'] as TextEditingController,
          onChanged: disease['onChanged'] as Function(bool?),
        );
      }).toList(),
    );
  }

  Widget _buildDiseaseListItem({
    required String label,
    required IconData icon,
    required bool value,
    required TextEditingController controller,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? AppTheme.primaryBlue.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? AppTheme.primaryBlue.withOpacity(0.3) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
                        children: [
          // Checkbox y label
                          Expanded(
            flex: 2,
            child: CheckboxListTile(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: value ? AppTheme.primaryBlue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      color: value ? Colors.white : Colors.grey[600],
                      size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                        color: value ? AppTheme.primaryBlue : Colors.black87,
                      ),
                            ),
                          ),
                        ],
                      ),
              value: value,
              onChanged: onChanged,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppTheme.primaryBlue,
            ),
          ),
          
          // Campo de especificación (solo si está seleccionado)
          if (value)
                          Expanded(
              flex: 3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Especifique',
                    hintText: 'Detalles...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: AppTheme.primaryBlue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    labelStyle: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 12,
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
          Expanded(
            child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
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
              label: Text(_isLoading ? 'Guardando...' : 'Guardar Antecedentes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
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
        'diabetes': _diabetes,
        'hipertension': _hipertension,
        'cardiopatias': _cardiopatias,
        'enfermedadesRenales': _enfermedadesRenales,
        'enfermedadesHepaticas': _enfermedadesHepaticas,
        'enfermedadesRespiratorias': _enfermedadesRespiratorias,
        'enfermedadesNeurologicas': _enfermedadesNeurologicas,
        'cancer': _cancer,
        'vih': _vih,
        'otras': _otras,
        // Especificaciones
        'diabetesEspecifique': _diabetesEspecifiqueController.text.trim(),
        'hipertensionEspecifique': _hipertensionEspecifiqueController.text.trim(),
        'cardiopatiasEspecifique': _cardiopatiasEspecifiqueController.text.trim(),
        'enfermedadesRenalesEspecifique': _enfermedadesRenalesEspecifiqueController.text.trim(),
        'enfermedadesHepaticasEspecifique': _enfermedadesHepaticasEspecifiqueController.text.trim(),
        'enfermedadesRespiratoriasEspecifique': _enfermedadesRespiratoriasEspecifiqueController.text.trim(),
        'enfermedadesNeurologicasEspecifique': _enfermedadesNeurologicasEspecifiqueController.text.trim(),
        'cancerEspecifique': _cancerEspecifiqueController.text.trim(),
        'vihEspecifique': _vihEspecifiqueController.text.trim(),
        'otrasEspecifique': _otrasEspecifiqueController.text.trim(),
      };

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Antecedentes patológicos guardados exitosamente'),
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