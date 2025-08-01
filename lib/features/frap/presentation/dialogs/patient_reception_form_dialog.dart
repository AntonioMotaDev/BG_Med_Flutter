import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:convert';
import 'dart:typed_data'; // Added for Uint8List

class PatientReceptionFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const PatientReceptionFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<PatientReceptionFormDialog> createState() =>
      _PatientReceptionFormDialogState();
}

class _PatientReceptionFormDialogState
    extends State<PatientReceptionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores de texto
  final _doctorNameController = TextEditingController();
  final _doctorCedulaController = TextEditingController();

  // Controlador de firma
  late SignatureController _doctorSignatureController;

  // Variable para almacenar la firma
  String? _doctorSignatureData;

  @override
  void initState() {
    super.initState();
    _initializeSignatureController();
    _initializeForm();
  }

  void _initializeSignatureController() {
    _doctorSignatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  void _initializeForm() {
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      final data = widget.initialData!;
      _doctorNameController.text = data['doctorName'] ?? '';
      _doctorCedulaController.text = data['doctorCedula'] ?? '';
      _doctorSignatureData = data['doctorSignature'];
    }
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _doctorCedulaController.dispose();
    _doctorSignatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.75,
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
                color: Colors.teal[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.how_to_reg, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'RECEPCIÓN DEL PACIENTE',
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
                      const Text(
                        'Información del Doctor que Recibe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nombre del doctor
                      _buildTextField(
                        controller: _doctorNameController,
                        label: 'Nombre del Doctor',
                        isRequired: true,
                      ),

                      const SizedBox(height: 16),

                      // Cédula profesional del doctor
                      _buildTextField(
                        controller: _doctorCedulaController,
                        label: 'Cédula Profesional',
                        isRequired: false,
                        hint: 'Opcional',
                      ),

                      const SizedBox(height: 24),

                      // Firma del doctor
                      const Text(
                        'Firma del Doctor',
                        style: TextStyle(
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
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              // Si hay datos base64 guardados, mostrar la imagen
                              if (_doctorSignatureData != null)
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: MemoryImage(
                                        _getImageBytesFromBase64(
                                          _doctorSignatureData!,
                                        ),
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              else
                                // Área de firma normal
                                Signature(
                                  controller: _doctorSignatureController,
                                  backgroundColor: Colors.white,
                                ),

                              // Texto de instrucción (solo visible cuando está vacía y no hay datos guardados)
                              if (_doctorSignatureController.isEmpty &&
                                  _doctorSignatureData == null)
                                const Center(
                                  child: Text(
                                    'Firme aquí',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Botones para la firma
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _doctorSignatureController.clear();
                                setState(() {
                                  _doctorSignatureData = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Limpiar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _captureSignature,
                              icon: const Icon(Icons.save),
                              label: const Text('Capturar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_doctorSignatureData != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Firma capturada',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
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
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.save),
                    label: Text(
                      _isLoading ? 'Guardando...' : 'Guardar Sección',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
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
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
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

  Uint8List _getImageBytesFromBase64(String base64Data) {
    try {
      final base64String = base64Data.split(',').last;
      return base64Decode(base64String);
    } catch (e) {
      return Uint8List(0);
    }
  }

  Future<void> _captureSignature() async {
    if (_doctorSignatureController.isNotEmpty) {
      final signature = await _doctorSignatureController.toPngBytes();
      if (signature != null) {
        setState(() {
          _doctorSignatureData =
              'data:image/png;base64,${base64Encode(signature)}';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firma capturada correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, dibuje una firma antes de capturar'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que la firma esté presente
    if (_doctorSignatureController.isEmpty && _doctorSignatureData == null) {
      _showErrorDialog(
        'Firma requerida',
        'Por favor, complete la firma del doctor antes de guardar.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? signatureData = _doctorSignatureData;

      // Si no hay datos guardados pero hay una firma nueva, convertirla
      if (_doctorSignatureData == null &&
          _doctorSignatureController.isNotEmpty) {
        final signatureBytes = await _doctorSignatureController.toPngBytes();
        if (signatureBytes != null) {
          signatureData =
              'data:image/png;base64,${base64Encode(signatureBytes)}';
        }
      }

      if (signatureData != null) {
        final formData = {
          'doctorName': _doctorNameController.text.trim(),
          'doctorCedula': _doctorCedulaController.text.trim(),
          'doctorSignature': signatureData,
          'timestamp': DateTime.now().toIso8601String(),
        };

        widget.onSave(formData);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Información de recepción guardada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error al procesar la firma');
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
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
