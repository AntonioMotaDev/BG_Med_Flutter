import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:convert';
import 'dart:typed_data';

class PatientReceptionFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const PatientReceptionFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<PatientReceptionFormDialog> createState() => _PatientReceptionFormDialogState();
}

class _PatientReceptionFormDialogState extends State<PatientReceptionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores de texto
  final _doctorNameController = TextEditingController();

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
      _doctorSignatureData = data['doctorSignature'];
    }
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
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
                  const Icon(
                    Icons.how_to_reg,
                    color: Colors.white,
                    size: 24,
                  ),
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
                          'RECEPCIÓN DEL PACIENTE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Campo del nombre del médico
                      Text(
                        'Médico que recibe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      TextFormField(
                        controller: _doctorNameController,
                        decoration: const InputDecoration(
                          hintText: 'Ingrese el nombre completo del médico',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre del médico es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Sección de firma
                      _buildSignatureSection(
                        title: 'Nombre y firma',
                        controller: _doctorSignatureController,
                        base64Data: _doctorSignatureData,
                        onClear: () {
                          _doctorSignatureController.clear();
                          setState(() {
                            _doctorSignatureData = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nota informativa
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.teal[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'La firma del médico receptor es requerida para completar la recepción del paciente.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal[800],
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
                    label: Text(_isLoading ? 'Guardando...' : 'Guardar Recepción'),
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

  Widget _buildSignatureSection({
    required String title,
    required SignatureController controller,
    String? base64Data,
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
              // Si hay datos base64 guardados, mostrar la imagen
              if (base64Data != null)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: MemoryImage(_getImageBytesFromBase64(base64Data)),
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              else
                // Área de firma normal
                Signature(
                  controller: controller,
                  backgroundColor: Colors.white,
                ),
              
              // Texto de instrucción (solo visible cuando está vacía y no hay datos guardados)
              if (controller.isEmpty && base64Data == null)
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
                    onPressed: () {
                      onClear();
                      // Si hay datos guardados, también los limpiamos
                      if (base64Data != null) {
                        setState(() {
                          _doctorSignatureData = null;
                        });
                      }
                    },
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

  Uint8List _getImageBytesFromBase64(String base64Data) {
    try {
      final base64String = base64Data.split(',').last;
      return base64Decode(base64String);
    } catch (e) {
      return Uint8List(0);
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que la firma esté presente (ya sea nueva o guardada)
    if (_doctorSignatureController.isEmpty && _doctorSignatureData == null) {
      _showErrorDialog('Firma requerida', 'Por favor, complete la firma del médico receptor.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? signatureData = _doctorSignatureData;
      
      // Si no hay datos guardados pero hay una firma nueva, convertirla
      if (_doctorSignatureData == null && _doctorSignatureController.isNotEmpty) {
        final signatureBytes = await _doctorSignatureController.toPngBytes();
        if (signatureBytes != null) {
          signatureData = 'data:image/png;base64,${base64Encode(signatureBytes)}';
        }
      }

      if (signatureData != null) {
        final formData = {
          'doctorName': _doctorNameController.text.trim(),
          'doctorSignature': signatureData,
          'timestamp': DateTime.now().toIso8601String(),
        };

        widget.onSave(formData);
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recepción del paciente guardada exitosamente'),
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