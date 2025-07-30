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

class _ClinicalHistoryFormDialogState extends State<ClinicalHistoryFormDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Variables para checkboxes
  bool _traumaCraneo = false;
  bool _traumaTorax = false;
  bool _traumaAbdomen = false;
  bool _traumaColumna = false;
  bool _traumaExtremidades = false;
  bool _traumaPelvis = false;
  bool _traumaOtros = false;

  // Controladores para especificaciones
  final _traumaCraneoEspecifiqueController = TextEditingController();
  final _traumaToraxEspecifiqueController = TextEditingController();
  final _traumaAbdomenEspecifiqueController = TextEditingController();
  final _traumaColumnaEspecifiqueController = TextEditingController();
  final _traumaExtremidadesEspecifiqueController = TextEditingController();
  final _traumaPelvisEspecifiqueController = TextEditingController();
  final _traumaOtrosEspecifiqueController = TextEditingController();

  // Animación para el diálogo
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;

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
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );
    _animationController!.forward();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      _traumaCraneo = data['traumaCraneo'] ?? false;
      _traumaTorax = data['traumaTorax'] ?? false;
      _traumaAbdomen = data['traumaAbdomen'] ?? false;
      _traumaColumna = data['traumaColumna'] ?? false;
      _traumaExtremidades = data['traumaExtremidades'] ?? false;
      _traumaPelvis = data['traumaPelvis'] ?? false;
      _traumaOtros = data['traumaOtros'] ?? false;

      // Especificaciones
      _traumaCraneoEspecifiqueController.text = data['traumaCraneoEspecifique'] ?? '';
      _traumaToraxEspecifiqueController.text = data['traumaToraxEspecifique'] ?? '';
      _traumaAbdomenEspecifiqueController.text = data['traumaAbdomenEspecifique'] ?? '';
      _traumaColumnaEspecifiqueController.text = data['traumaColumnaEspecifique'] ?? '';
      _traumaExtremidadesEspecifiqueController.text = data['traumaExtremidadesEspecifique'] ?? '';
      _traumaPelvisEspecifiqueController.text = data['traumaPelvisEspecifique'] ?? '';
      _traumaOtrosEspecifiqueController.text = data['traumaOtrosEspecifique'] ?? '';
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _traumaCraneoEspecifiqueController.dispose();
    _traumaToraxEspecifiqueController.dispose();
    _traumaAbdomenEspecifiqueController.dispose();
    _traumaColumnaEspecifiqueController.dispose();
    _traumaExtremidadesEspecifiqueController.dispose();
    _traumaPelvisEspecifiqueController.dispose();
    _traumaOtrosEspecifiqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si las animaciones no están inicializadas, mostrar diálogo sin animación
    if (_animationController == null || _scaleAnimation == null || _fadeAnimation == null) {
      return _buildDialogContent();
    }

    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation!,
          child: ScaleTransition(
            scale: _scaleAnimation!,
            child: _buildDialogContent(),
          ),
        );
      },
    );
  }

  Widget _buildDialogContent() {
    return Dialog(
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
              Icons.medical_services,
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
                  'Antecedentes Clínicos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Historial de traumas del paciente',
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
                    Icons.emergency,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Seleccione los antecedentes clínicos del paciente',
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
            _buildTraumaGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildTraumaGrid() {
    final traumaOptions = [
      {
        'label': 'Trauma Cráneo',
        'icon': Icons.psychology,
        'value': _traumaCraneo,
        'controller': _traumaCraneoEspecifiqueController,
        'onChanged': (value) => setState(() => _traumaCraneo = value ?? false),
      },
      {
        'label': 'Trauma Tórax',
        'icon': Icons.favorite,
        'value': _traumaTorax,
        'controller': _traumaToraxEspecifiqueController,
        'onChanged': (value) => setState(() => _traumaTorax = value ?? false),
      },
      {
        'label': 'Trauma Abdomen',
        'icon': Icons.airline_seat_individual_suite,
        'value': _traumaAbdomen,
        'controller': _traumaAbdomenEspecifiqueController,
        'onChanged': (value) => setState(() => _traumaAbdomen = value ?? false),
      },
      {
        'label': 'Trauma Columna',
        'icon': Icons.straighten,
        'value': _traumaColumna,
        'controller': _traumaColumnaEspecifiqueController,
        'onChanged': (value) => setState(() => _traumaColumna = value ?? false),
      },
      {
        'label': 'Trauma Extremidades',
        'icon': Icons.accessibility,
        'value': _traumaExtremidades,
        'controller': _traumaExtremidadesEspecifiqueController,
        'onChanged': (value) => setState(() => _traumaExtremidades = value ?? false),
      },
      {
        'label': 'Trauma Pelvis',
        'icon': Icons.person,
        'value': _traumaPelvis,
        'controller': _traumaPelvisEspecifiqueController,
        'onChanged': (value) => setState(() => _traumaPelvis = value ?? false),
      },
      {
        'label': 'Otros',
        'icon': Icons.more_horiz,
        'value': _traumaOtros,
        'controller': _traumaOtrosEspecifiqueController,
        'onChanged': (value) => setState(() => _traumaOtros = value ?? false),
      },
    ];

    return Column(
      children: traumaOptions.map((trauma) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTraumaListItem(
            label: trauma['label'] as String,
            icon: trauma['icon'] as IconData,
            value: trauma['value'] as bool,
            controller: trauma['controller'] as TextEditingController,
            onChanged: trauma['onChanged'] as Function(bool?),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTraumaListItem({
    required String label,
    required IconData icon,
    required bool value,
    required TextEditingController controller,
    required Function(bool?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppTheme.primaryBlue : Colors.grey[300]!,
          width: value ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox y label (flex: 2)
          Expanded(
            flex: 2,
            child: CheckboxListTile(
              title: Row(
                children: [
                  Icon(
                    icon,
                    color: value ? AppTheme.primaryBlue : Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
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
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              dense: true,
              activeColor: AppTheme.primaryBlue,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          // Campo de especificación (flex: 3)
          Expanded(
            flex: 3,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: value ? 60 : 0,
              child: value
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Especifique',
                          hintText: 'Detalles adicionales...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.primaryBlue),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          labelStyle: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                      ),
                    )
                  : const SizedBox.shrink(),
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
        'traumaCraneo': _traumaCraneo,
        'traumaTorax': _traumaTorax,
        'traumaAbdomen': _traumaAbdomen,
        'traumaColumna': _traumaColumna,
        'traumaExtremidades': _traumaExtremidades,
        'traumaPelvis': _traumaPelvis,
        'traumaOtros': _traumaOtros,
        // Especificaciones
        'traumaCraneoEspecifique': _traumaCraneoEspecifiqueController.text.trim(),
        'traumaToraxEspecifique': _traumaToraxEspecifiqueController.text.trim(),
        'traumaAbdomenEspecifique': _traumaAbdomenEspecifiqueController.text.trim(),
        'traumaColumnaEspecifique': _traumaColumnaEspecifiqueController.text.trim(),
        'traumaExtremidadesEspecifique': _traumaExtremidadesEspecifiqueController.text.trim(),
        'traumaPelvisEspecifique': _traumaPelvisEspecifiqueController.text.trim(),
        'traumaOtrosEspecifique': _traumaOtrosEspecifiqueController.text.trim(),
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
                const Text('Antecedentes clínicos guardados exitosamente'),
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