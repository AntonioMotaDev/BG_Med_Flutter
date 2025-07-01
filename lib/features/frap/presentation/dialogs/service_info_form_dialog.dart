import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceInfoFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const ServiceInfoFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<ServiceInfoFormDialog> createState() => _ServiceInfoFormDialogState();
}

class _ServiceInfoFormDialogState extends State<ServiceInfoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores de texto para campos que no son de hora
  final _tiempoEsperaArriboController = TextEditingController();
  final _tiempoEsperaLlegadaController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _tipoServicioEspecifiqueController = TextEditingController();

  // Variables para los horarios (usando TimeOfDay)
  TimeOfDay? _horaLlamada;
  TimeOfDay? _horaArribo;
  TimeOfDay? _horaLlegada;
  TimeOfDay? _horaTermino;

  // Variables para checkboxes y selecciones
  String _tipoServicioSeleccionado = '';
  String _lugarOcurrenciaSeleccionado = '';

  final List<String> _tiposServicio = [
    'Traslado',
    'Urgencia',
    'Estudio',
    'Cuidados Intensivos',
    'Otro'
  ];

  final List<String> _lugaresOcurrencia = [
    'Hogar',
    'Escuela',
    'Trabajo',
    'Recreativo',
    'Vía pública'
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      // Inicializar horarios desde strings
      _horaLlamada = _parseTimeString(data['horaLlamada']);
      _horaArribo = _parseTimeString(data['horaArribo']);
      _horaLlegada = _parseTimeString(data['horaLlegada']);
      _horaTermino = _parseTimeString(data['horaTermino']);
      
      // Inicializar otros campos
      _tiempoEsperaArriboController.text = data['tiempoEsperaArribo'] ?? '';
      _tiempoEsperaLlegadaController.text = data['tiempoEsperaLlegada'] ?? '';
      _ubicacionController.text = data['ubicacion'] ?? '';
      _tipoServicioSeleccionado = data['tipoServicio'] ?? '';
      _tipoServicioEspecifiqueController.text = data['tipoServicioEspecifique'] ?? '';
      _lugarOcurrenciaSeleccionado = data['lugarOcurrencia'] ?? '';
    }
  }

  // Función para parsear string de hora a TimeOfDay
  TimeOfDay? _parseTimeString(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Si no se puede parsear, devolver null
    }
    return null;
  }

  // Función para convertir TimeOfDay a string
  String _timeToString(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tiempoEsperaArriboController.dispose();
    _tiempoEsperaLlegadaController.dispose();
    _ubicacionController.dispose();
    _tipoServicioEspecifiqueController.dispose();
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
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'INFORMACIÓN DEL SERVICIO',
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
                      // Fila de tiempos
                      _buildTimeRow(),
                      const SizedBox(height: 20),

                      // Ubicación
                      _buildUbicacionField(),
                      const SizedBox(height: 20),

                      // Tipo de Servicio
                      _buildTipoServicioSection(),
                      const SizedBox(height: 20),

                      // Lugar de ocurrencia
                      _buildLugarOcurrenciaSection(),
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

  Widget _buildTimeRow() {
    return Column(
      children: [
        // Primera fila de tiempos
        Row(
          children: [
            Expanded(
              child: _buildTimePickerField(
                'Hora de llamada',
                _horaLlamada,
                (time) => setState(() => _horaLlamada = time),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimePickerField(
                'Hora de arribo',
                _horaArribo,
                (time) => setState(() => _horaArribo = time),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeField(
                'Tiempo de espera',
                _tiempoEsperaArriboController,
                'Minutos',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Segunda fila de tiempos
        Row(
          children: [
            Expanded(
              child: _buildTimePickerField(
                'Hora de llegada',
                _horaLlegada,
                (time) => setState(() => _horaLlegada = time),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimePickerField(
                'Hora de término',
                _horaTermino,
                (time) => setState(() => _horaTermino = time),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeField(
                'Tiempo de espera',
                _tiempoEsperaLlegadaController,
                'Minutos',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePickerField(String label, TimeOfDay? selectedTime, Function(TimeOfDay?) onTimeSelected) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryBlue,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: selectedTime != null ? AppTheme.primaryBlue : Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  selectedTime != null ? _timeToString(selectedTime) : 'Seleccionar hora',
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedTime != null ? Colors.black87 : Colors.grey[500],
                    fontWeight: selectedTime != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (selectedTime != null)
                  GestureDetector(
                    onTap: () => onTimeSelected(null),
                    child: Icon(
                      Icons.clear,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: const TextStyle(fontSize: 14),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final minutes = int.tryParse(value);
          if (minutes == null || minutes < 0 || minutes > 999) {
            return 'Minutos inválidos';
          }
        }
        return null;
      },
    );
  }

  Widget _buildUbicacionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ubicacionController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ingrese la ubicación del servicio',
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La ubicación es requerida';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTipoServicioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Servicio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tiposServicio.map((tipo) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 80) / 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CheckboxListTile(
                  title: Text(
                    tipo,
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _tipoServicioSeleccionado == tipo,
                  onChanged: (bool? value) {
                    setState(() {
                      _tipoServicioSeleccionado = value == true ? tipo : '';
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  dense: true,
                ),
              ),
            );
          }).toList(),
        ),
        if (_tipoServicioSeleccionado == 'Otro') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _tipoServicioEspecifiqueController,
            decoration: const InputDecoration(
              labelText: 'Especifique:',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (_tipoServicioSeleccionado == 'Otro' && 
                  (value == null || value.trim().isEmpty)) {
                return 'Especifique el tipo de servicio';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLugarOcurrenciaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lugar de ocurrencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _lugaresOcurrencia.map((lugar) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 80) / 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CheckboxListTile(
                  title: Text(
                    lugar,
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _lugarOcurrenciaSeleccionado == lugar,
                  onChanged: (bool? value) {
                    setState(() {
                      _lugarOcurrenciaSeleccionado = value == true ? lugar : '';
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  dense: true,
                ),
              ),
            );
          }).toList(),
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
        'horaLlamada': _timeToString(_horaLlamada),
        'horaArribo': _timeToString(_horaArribo),
        'tiempoEsperaArribo': _tiempoEsperaArriboController.text.trim(),
        'horaLlegada': _timeToString(_horaLlegada),
        'tiempoEsperaLlegada': _tiempoEsperaLlegadaController.text.trim(),
        'horaTermino': _timeToString(_horaTermino),
        'ubicacion': _ubicacionController.text.trim(),
        'tipoServicio': _tipoServicioSeleccionado,
        'tipoServicioEspecifique': _tipoServicioEspecifiqueController.text.trim(),
        'lugarOcurrencia': _lugarOcurrenciaSeleccionado,
      };

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información del servicio guardada'),
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