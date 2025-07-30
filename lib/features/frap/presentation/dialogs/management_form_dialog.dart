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

class _ManagementFormDialogState extends State<ManagementFormDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controlador solo para el campo numérico de Lt/min
  final _ltMinController = TextEditingController();
  
  // Controlador para observaciones generales
  final _observacionesController = TextEditingController();

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

  // Controladores para especificaciones
  final _viaAereaEspecifiqueController = TextEditingController();
  final _canalizacionEspecifiqueController = TextEditingController();
  final _empaquetamientoEspecifiqueController = TextEditingController();
  final _inmovilizacionEspecifiqueController = TextEditingController();
  final _monitorEspecifiqueController = TextEditingController();
  final _rcpBasicaEspecifiqueController = TextEditingController();
  final _mastPnaEspecifiqueController = TextEditingController();
  final _collarinCervicalEspecifiqueController = TextEditingController();
  final _desfibrilacionEspecifiqueController = TextEditingController();
  final _apoyoVentEspecifiqueController = TextEditingController();
  final _oxigenoEspecifiqueController = TextEditingController();

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
      _observacionesController.text = data['observaciones'] ?? '';
      
      // Especificaciones
      _viaAereaEspecifiqueController.text = data['viaAereaEspecifique'] ?? '';
      _canalizacionEspecifiqueController.text = data['canalizacionEspecifique'] ?? '';
      _empaquetamientoEspecifiqueController.text = data['empaquetamientoEspecifique'] ?? '';
      _inmovilizacionEspecifiqueController.text = data['inmovilizacionEspecifique'] ?? '';
      _monitorEspecifiqueController.text = data['monitorEspecifique'] ?? '';
      _rcpBasicaEspecifiqueController.text = data['rcpBasicaEspecifique'] ?? '';
      _mastPnaEspecifiqueController.text = data['mastPnaEspecifique'] ?? '';
      _collarinCervicalEspecifiqueController.text = data['collarinCervicalEspecifique'] ?? '';
      _desfibrilacionEspecifiqueController.text = data['desfibrilacionEspecifique'] ?? '';
      _apoyoVentEspecifiqueController.text = data['apoyoVentEspecifique'] ?? '';
      _oxigenoEspecifiqueController.text = data['oxigenoEspecifique'] ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ltMinController.dispose();
    _observacionesController.dispose();
    _viaAereaEspecifiqueController.dispose();
    _canalizacionEspecifiqueController.dispose();
    _empaquetamientoEspecifiqueController.dispose();
    _inmovilizacionEspecifiqueController.dispose();
    _monitorEspecifiqueController.dispose();
    _rcpBasicaEspecifiqueController.dispose();
    _mastPnaEspecifiqueController.dispose();
    _collarinCervicalEspecifiqueController.dispose();
    _desfibrilacionEspecifiqueController.dispose();
    _apoyoVentEspecifiqueController.dispose();
    _oxigenoEspecifiqueController.dispose();
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
                  'Manejo Médico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Procedimientos aplicados al paciente',
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
                    'Seleccione los tipos de manejo aplicados',
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
            _buildManagementGrid(),
            
            const SizedBox(height: 24),
            
            // Campo de Lt/min
            _buildLtMinField(),
            
            const SizedBox(height: 24),
            
            // Observaciones generales
            _buildObservacionesField(),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementGrid() {
    final managementOptions = [
      {
        'label': 'Vía Aérea',
        'icon': Icons.air,
        'value': _viaAerea,
        'controller': _viaAereaEspecifiqueController,
        'onChanged': (value) => setState(() => _viaAerea = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'Canalización',
        'icon': Icons.medical_services,
        'value': _canalizacion,
        'controller': _canalizacionEspecifiqueController,
        'onChanged': (value) => setState(() => _canalizacion = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'Empaquetamiento',
        'icon': Icons.wrap_text,
        'value': _empaquetamiento,
        'controller': _empaquetamientoEspecifiqueController,
        'onChanged': (value) => setState(() => _empaquetamiento = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'Inmovilización',
        'icon': Icons.block,
        'value': _inmovilizacion,
        'controller': _inmovilizacionEspecifiqueController,
        'onChanged': (value) => setState(() => _inmovilizacion = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'Monitor',
        'icon': Icons.monitor_heart,
        'value': _monitor,
        'controller': _monitorEspecifiqueController,
        'onChanged': (value) => setState(() => _monitor = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'RCP Básica',
        'icon': Icons.favorite,
        'value': _rcpBasica,
        'controller': _rcpBasicaEspecifiqueController,
        'onChanged': (value) => setState(() => _rcpBasica = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'MAST o PNA',
        'icon': Icons.airline_seat_flat,
        'value': _mastPna,
        'controller': _mastPnaEspecifiqueController,
        'onChanged': (value) => setState(() => _mastPna = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'Collarin Cervical',
        'icon': Icons.person,
        'value': _collarinCervical,
        'controller': _collarinCervicalEspecifiqueController,
        'onChanged': (value) => setState(() => _collarinCervical = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'Desfibrilación',
        'icon': Icons.electric_bolt,
        'value': _desfibrilacion,
        'controller': _desfibrilacionEspecifiqueController,
        'onChanged': (value) => setState(() => _desfibrilacion = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'Apoyo Vent.',
        'icon': Icons.air,
        'value': _apoyoVent,
        'controller': _apoyoVentEspecifiqueController,
        'onChanged': (value) => setState(() => _apoyoVent = value ?? false),
        'showSpecification': true,
      },
      {
        'label': 'Oxígeno',
        'icon': Icons.airline_seat_individual_suite,
        'value': _oxigeno,
        'controller': _oxigenoEspecifiqueController,
        'onChanged': (value) => setState(() => _oxigeno = value ?? false),
        'showSpecification': false, // No mostrar especificación para oxígeno
      },
    ];

    return Column(
      children: managementOptions.map((option) {
        return _buildManagementListItem(
          label: option['label'] as String,
          icon: option['icon'] as IconData,
          value: option['value'] as bool,
          controller: option['controller'] as TextEditingController,
          onChanged: option['onChanged'] as Function(bool?),
          showSpecification: option['showSpecification'] as bool,
        );
      }).toList(),
    );
  }

  Widget _buildManagementListItem({
    required String label,
    required IconData icon,
    required bool value,
    required TextEditingController controller,
    required Function(bool?) onChanged,
    required bool showSpecification,
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
          
          // Campo de especificación (solo si está seleccionado y showSpecification es true)
          if (value && showSpecification)
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

  Widget _buildLtMinField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _oxigeno ? null : 0,
      child: _oxigeno
          ? Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Flujo de Oxígeno',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ltMinController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Litros por minuto (Lt/min)',
                      hintText: 'Ej: 2.5',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.primaryBlue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      suffixIcon: const Icon(Icons.air),
                    ),
                    style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildObservacionesField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      Row(
                        children: [
              Icon(
                Icons.note_add,
                color: AppTheme.primaryBlue,
                size: 20,
                          ),
                          const SizedBox(width: 12),
              const Text(
                'Observaciones Generales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                      ),
                    ],
                  ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _observacionesController,
            decoration: InputDecoration(
              labelText: 'Observaciones adicionales',
              hintText: 'Escriba aquí cualquier observación importante...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryBlue),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            style: const TextStyle(fontSize: 14),
            maxLines: 3,
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
              label: Text(_isLoading ? 'Guardando...' : 'Guardar Manejo'),
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
        'observaciones': _observacionesController.text.trim(),
        // Especificaciones
        'viaAereaEspecifique': _viaAereaEspecifiqueController.text.trim(),
        'canalizacionEspecifique': _canalizacionEspecifiqueController.text.trim(),
        'empaquetamientoEspecifique': _empaquetamientoEspecifiqueController.text.trim(),
        'inmovilizacionEspecifique': _inmovilizacionEspecifiqueController.text.trim(),
        'monitorEspecifique': _monitorEspecifiqueController.text.trim(),
        'rcpBasicaEspecifique': _rcpBasicaEspecifiqueController.text.trim(),
        'mastPnaEspecifique': _mastPnaEspecifiqueController.text.trim(),
        'collarinCervicalEspecifique': _collarinCervicalEspecifiqueController.text.trim(),
        'desfibrilacionEspecifique': _desfibrilacionEspecifiqueController.text.trim(),
        'apoyoVentEspecifique': _apoyoVentEspecifiqueController.text.trim(),
        'oxigenoEspecifique': _oxigenoEspecifiqueController.text.trim(),
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
                const Text('Información de manejo guardada exitosamente'),
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