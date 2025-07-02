import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class AttentionNegativeFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const AttentionNegativeFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<AttentionNegativeFormDialog> createState() => _AttentionNegativeFormDialogState();
}

class _AttentionNegativeFormDialogState extends State<AttentionNegativeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores de firma
  late SignatureController _patientSignatureController;
  late SignatureController _witnessSignatureController;

  // Variables para almacenar las firmas
  String? _patientSignatureData;
  String? _witnessSignatureData;

  @override
  void initState() {
    super.initState();
    _initializeSignatureControllers();
    _initializeForm();
  }

  void _initializeSignatureControllers() {
    _patientSignatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    
    _witnessSignatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _patientSignatureData = data['patientSignature'];
      _witnessSignatureData = data['witnessSignature'];

      // Si hay datos de firma, cargarlos (esto requeriría implementación adicional)
      // Por simplicidad, las firmas se empezarán desde cero cada vez
    }
  }

  @override
  void dispose() {
    _patientSignatureController.dispose();
    _witnessSignatureController.dispose();
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
                color: Colors.red[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'NEGATIVA DE ATENCIÓN',
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
                      // Título del documento
                      Center(
                        child: Text(
                          'NEGATIVA DE ATENCIÓN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Texto predefinido
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'Me he negado a recibir atención médica y a ser trasladado por los paramédicos '
                          'de Ambulancias BgMed, habiéndoseme informado de los riesgos que conlleva '
                          'mi decisión.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Sección de firmas
                      Row(
                        children: [
                          // Firma del Paciente
                          Expanded(
                            child: _buildSignatureSection(
                              title: 'Firma Paciente',
                              controller: _patientSignatureController,
                              onClear: () {
                                _patientSignatureController.clear();
                                setState(() {
                                  _patientSignatureData = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Firma del Testigo
                          Expanded(
                            child: _buildSignatureSection(
                              title: 'Testigo',
                              controller: _witnessSignatureController,
                              onClear: () {
                                _witnessSignatureController.clear();
                                setState(() {
                                  _witnessSignatureData = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nota informativa
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Las firmas son requeridas para completar la negativa de atención.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[800],
                                ),
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
                    label: Text(_isLoading ? 'Guardando...' : 'Guardar Negativa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
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

  Widget _buildSignatureSection({
    required String title,
    required SignatureController controller,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              // Área de firma
              Signature(
                controller: controller,
                backgroundColor: Colors.white,
              ),
              // Texto de instrucción (solo visible cuando está vacía)
              if (controller.isEmpty)
                const Center(
                  child: Text(
                    'Firme aquí',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              // Botón de limpiar
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.clear,
                      size: 16,
                      color: Colors.red,
                    ),
                    onPressed: onClear,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          color: Colors.black,
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveForm() async {
    // Validar que ambas firmas estén presentes
    if (_patientSignatureController.isEmpty) {
      _showErrorDialog('Firma del paciente requerida', 'Por favor, complete la firma del paciente.');
      return;
    }

    if (_witnessSignatureController.isEmpty) {
      _showErrorDialog('Firma del testigo requerida', 'Por favor, complete la firma del testigo.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir las firmas a datos base64
      final patientSignatureBytes = await _patientSignatureController.toPngBytes();
      final witnessSignatureBytes = await _witnessSignatureController.toPngBytes();

      if (patientSignatureBytes != null && witnessSignatureBytes != null) {
        _patientSignatureData = 'data:image/png;base64,${String.fromCharCodes(patientSignatureBytes)}';
        _witnessSignatureData = 'data:image/png;base64,${String.fromCharCodes(witnessSignatureBytes)}';

        final formData = {
          'patientSignature': _patientSignatureData,
          'witnessSignature': _witnessSignatureData,
          'declarationText': 'Me he negado a recibir atención médica y a ser trasladado por los paramédicos '
              'de Ambulancias BgMed, habiéndoseme informado de los riesgos que conlleva mi decisión.',
          'timestamp': DateTime.now().toIso8601String(),
        };

        widget.onSave(formData);
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Negativa de atención guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error al procesar las firmas');
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

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
} 