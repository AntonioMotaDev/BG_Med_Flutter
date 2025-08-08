import 'package:flutter/material.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/core/models/appointment.dart';

class AppointmentFormDialog extends StatefulWidget {
  final Function(Appointment) onSave;
  final Appointment? appointment; // null para crear, Appointment para editar
  final DateTime? initialDate;

  const AppointmentFormDialog({
    super.key,
    required this.onSave,
    this.appointment,
    this.initialDate,
  });

  @override
  State<AppointmentFormDialog> createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<AppointmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _patientAddressController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  String _selectedAppointmentType = 'consulta';
  String _selectedStatus = 'programada';
  bool _isLoading = false;

  final List<String> _appointmentTypes = [
    'consulta',
    'emergencia',
    'seguimiento',
    'revisión',
    'procedimiento',
  ];

  final List<String> _statusOptions = [
    'programada',
    'confirmada',
    'cancelada',
    'completada',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.appointment != null) {
      // Modo edición
      final appointment = widget.appointment!;
      _titleController.text = appointment.title;
      _descriptionController.text = appointment.description;
      _patientNameController.text = appointment.patientName;
      _patientPhoneController.text = appointment.patientPhone;
      _patientAddressController.text = appointment.patientAddress;
      _notesController.text = appointment.notes;
      _selectedDateTime = appointment.dateTime;
      _selectedAppointmentType = appointment.appointmentType;
      _selectedStatus = appointment.status;
    } else {
      // Modo creación
      if (widget.initialDate != null) {
        _selectedDateTime = widget.initialDate!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    _patientAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appointment = Appointment(
        id: widget.appointment?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: _selectedDateTime,
        patientName: _patientNameController.text.trim(),
        patientPhone: _patientPhoneController.text.trim(),
        patientAddress: _patientAddressController.text.trim(),
        appointmentType: _selectedAppointmentType,
        status: _selectedStatus,
        notes: _notesController.text.trim(),
        createdAt: widget.appointment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(appointment);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.appointment != null
                  ? 'Cita actualizada correctamente'
                  : 'Cita creada correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;

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
                color: AppTheme.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'EDITAR CITA' : 'NUEVA CITA',
                      style: const TextStyle(
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
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título de la cita *',
                          hintText: 'Ej: Consulta de seguimiento',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El título es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción *',
                          hintText: 'Detalles de la cita',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descripción es requerida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Fecha y hora
                      InkWell(
                        onTap: _selectDateTime,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Fecha y hora: ${_formatDateTime(_selectedDateTime)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tipo de cita
                      DropdownButtonFormField<String>(
                        value: _selectedAppointmentType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de cita',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _appointmentTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(_capitalize(type)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAppointmentType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Estado (solo en edición)
                      if (isEditing) ...[
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _statusOptions.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(_capitalize(status)),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Información del paciente
                      const Text(
                        'Información del Paciente',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nombre del paciente
                      TextFormField(
                        controller: _patientNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del paciente *',
                          hintText: 'Nombre completo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Teléfono
                      TextFormField(
                        controller: _patientPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          hintText: 'Número de contacto',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Dirección
                      TextFormField(
                        controller: _patientAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          hintText: 'Dirección del paciente',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Notas
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notas adicionales',
                          hintText: 'Información adicional',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
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
                    onPressed: _isLoading ? null : _saveAppointment,
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
                            : Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(
                      _isLoading
                          ? 'Guardando...'
                          : (isEditing ? 'Actualizar' : 'Crear Cita'),
                    ),
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

  String _formatDateTime(DateTime dateTime) {
    final date =
        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
