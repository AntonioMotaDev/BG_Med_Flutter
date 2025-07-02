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
  final _lugarOrigenController = TextEditingController();
  final _lugarConsultaController = TextEditingController();
  final _lugarDestinoController = TextEditingController();
  final _ambulanciaNumeroController = TextEditingController();
  final _ambulanciaPlacasController = TextEditingController();
  final _personalController = TextEditingController();
  final _doctorController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _lugarOrigenController.text = data['lugarOrigen'] ?? '';
      _lugarConsultaController.text = data['lugarConsulta'] ?? '';
      _lugarDestinoController.text = data['lugarDestino'] ?? '';
      _ambulanciaNumeroController.text = data['ambulanciaNumero'] ?? '';
      _ambulanciaPlacasController.text = data['ambulanciaPlacas'] ?? '';
      _personalController.text = data['personal'] ?? '';
      _doctorController.text = data['doctor'] ?? '';
    }
  }

  @override
  void dispose() {
    _lugarOrigenController.dispose();
    _lugarConsultaController.dispose();
    _lugarDestinoController.dispose();
    _ambulanciaNumeroController.dispose();
    _ambulanciaPlacasController.dispose();
    _personalController.dispose();
    _doctorController.dispose();
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

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lugares
                      _buildSectionTitle('Ubicaciones', Icons.location_on),
                      const SizedBox(height: 16),
                      
                      _buildLocationField(
                        controller: _lugarOrigenController,
                        label: 'Lugar de origen',
                        icon: Icons.place,
                        color: Colors.green,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildLocationField(
                        controller: _lugarConsultaController,
                        label: 'Lugar de consulta',
                        icon: Icons.medical_services,
                        color: Colors.blue,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildLocationField(
                        controller: _lugarDestinoController,
                        label: 'Lugar de destino',
                        icon: Icons.flag,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 24),

                      // Ambulancia
                      _buildSectionTitle('Información de Ambulancia', Icons.local_shipping),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildAmbulanceField(
                              controller: _ambulanciaNumeroController,
                              label: 'No.',
                              hint: 'Ej: 02',
                              icon: Icons.numbers,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _buildAmbulanceField(
                              controller: _ambulanciaPlacasController,
                              label: 'Placas',
                              hint: 'Ej: ABC-123',
                              icon: Icons.credit_card,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Personal
                      _buildSectionTitle('Personal Médico', Icons.people),
                      const SizedBox(height: 16),
                      
                      _buildPersonalField(
                        controller: _personalController,
                        label: 'Personal',
                        hint: 'Nombres del personal que atiende',
                        icon: Icons.person,
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildPersonalField(
                        controller: _doctorController,
                        label: 'Dr.',
                        hint: 'Nombre del doctor responsable',
                        icon: Icons.medical_information,
                        maxLines: 1,
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

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
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
                  label,
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
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ingrese $label',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
                prefixIcon: Icon(icon, color: color),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbulanceField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
              color: Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required int maxLines,
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
              color: Colors.purple.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.purple[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.purple[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
                prefixIcon: Icon(icon, color: Colors.purple[700]),
              ),
              style: const TextStyle(fontSize: 14),
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
        'lugarOrigen': _lugarOrigenController.text.trim(),
        'lugarConsulta': _lugarConsultaController.text.trim(),
        'lugarDestino': _lugarDestinoController.text.trim(),
        'ambulanciaNumero': _ambulanciaNumeroController.text.trim(),
        'ambulanciaPlacas': _ambulanciaPlacasController.text.trim(),
        'personal': _personalController.text.trim(),
        'doctor': _doctorController.text.trim(),
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
                Text('Información de unidad receptora guardada'),
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