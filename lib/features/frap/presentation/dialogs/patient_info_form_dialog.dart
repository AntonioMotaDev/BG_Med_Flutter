import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/core/models/patient_firestore.dart';
import 'package:bg_med/features/patients/presentation/providers/patients_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientInfoFormDialog extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const PatientInfoFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  ConsumerState<PatientInfoFormDialog> createState() => _PatientInfoFormDialogState();
}

class _PatientInfoFormDialogState extends ConsumerState<PatientInfoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  PatientFirestore? _selectedPatient;

  // Controladores de texto
  final _firstNameController = TextEditingController();
  final _paternalLastNameController = TextEditingController();
  final _maternalLastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _exteriorNumberController = TextEditingController();
  final _interiorNumberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _searchController = TextEditingController();

  // Variables para dropdowns
  String _sexSelected = '';

  final List<String> _sexOptions = ['Masculino', 'Femenino'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _firstNameController.text = data['firstName'] ?? '';
      _paternalLastNameController.text = data['paternalLastName'] ?? '';
      _maternalLastNameController.text = data['maternalLastName'] ?? '';
      _ageController.text = data['age']?.toString() ?? '';
      _sexSelected = data['sex'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _streetController.text = data['street'] ?? '';
      _exteriorNumberController.text = data['exteriorNumber'] ?? '';
      _interiorNumberController.text = data['interiorNumber'] ?? '';
      _neighborhoodController.text = data['neighborhood'] ?? '';
      _cityController.text = data['city'] ?? '';
      _insuranceController.text = data['insurance'] ?? '';
      
      // Si ya hay datos, probablemente es un paciente seleccionado
      if (data['patientId'] != null) {
        // Buscar el paciente en la lista para establecer _selectedPatient
        final patients = ref.read(patientsNotifierProvider).patients;
        try {
          _selectedPatient = patients.firstWhere(
            (p) => p.id == data['patientId'],
          );
        } catch (e) {
          // Si no se encuentra el paciente, _selectedPatient permanece null
          _selectedPatient = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _paternalLastNameController.dispose();
    _maternalLastNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _exteriorNumberController.dispose();
    _interiorNumberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _insuranceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsState = ref.watch(patientsNotifierProvider);
    
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
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'INFORMACIÓN DEL PACIENTE',
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
                      // Selector de paciente existente
                      _buildPatientSelector(patientsState),
                      const SizedBox(height: 20),

                      // Divisor
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _selectedPatient != null ? 'DATOS DEL PACIENTE SELECCIONADO' : 'DATOS DEL NUEVO PACIENTE',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Formulario de datos del paciente
                      _buildPatientForm(),
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
                  if (_selectedPatient != null) ...[
                    TextButton(
                      onPressed: _clearSelection,
                      child: const Text('Limpiar selección'),
                    ),
                    const SizedBox(width: 12),
                  ],
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

  Widget _buildPatientSelector(PatientsState patientsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.search, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Buscar paciente existente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Buscar por nombre, apellido...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              // Trigger rebuild to filter patients
            });
          },
        ),
        const SizedBox(height: 12),
        
        if (_searchController.text.isNotEmpty && patientsState.patients.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _getFilteredPatients(patientsState.patients).length,
              itemBuilder: (context, index) {
                final patient = _getFilteredPatients(patientsState.patients)[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      patient.firstName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('${patient.firstName} ${patient.paternalLastName} ${patient.maternalLastName}'),
                  subtitle: Text('Edad: ${patient.age} • Teléfono: ${patient.phone}'),
                  onTap: () => _selectPatient(patient),
                  selected: _selectedPatient?.id == patient.id,
                );
              },
            ),
          ),
        ],
        
        if (_selectedPatient != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Paciente seleccionado: ${_selectedPatient!.firstName} ${_selectedPatient!.paternalLastName}',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _clearSelection,
                  icon: Icon(Icons.close, color: AppTheme.primaryBlue),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPatientForm() {
    return Column(
      children: [
        // Nombre completo
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _firstNameController.text.trim().isEmpty,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _paternalLastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido Paterno *',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _paternalLastNameController.text.trim().isEmpty,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El apellido paterno es requerido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _maternalLastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido Materno *',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _maternalLastNameController.text.trim().isEmpty,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El apellido materno es requerido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Edad *',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _ageController.text.trim().isEmpty,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La edad es requerida';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 0 || age > 120) {
                    return 'Edad válida (0-120)';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sexo y teléfono
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sexSelected.isEmpty ? null : _sexSelected,
                decoration: const InputDecoration(
                  labelText: 'Sexo *',
                  border: OutlineInputBorder(),
                ),
                items: _sexOptions.map((sexo) {
                  return DropdownMenuItem(
                    value: sexo,
                    child: Text(sexo),
                  );
                }).toList(),
                onChanged: (_selectedPatient == null || _sexSelected.isEmpty) ? (value) {
                  setState(() {
                    _sexSelected = value ?? '';
                  });
                } : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione el sexo';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono *',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _phoneController.text.trim().isEmpty,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El teléfono es requerido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Dirección - Calle y número exterior
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Calle *',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _streetController.text.trim().isEmpty,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La calle es requerida';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _exteriorNumberController,
                decoration: const InputDecoration(
                  labelText: 'Núm. Ext. *',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _exteriorNumberController.text.trim().isEmpty,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Número requerido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Número interior y colonia
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _interiorNumberController,
                decoration: const InputDecoration(
                  labelText: 'Núm. Int.',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _interiorNumberController.text.trim().isEmpty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _neighborhoodController,
                decoration: const InputDecoration(
                  labelText: 'Colonia *',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _neighborhoodController.text.trim().isEmpty,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La colonia es requerida';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ciudad y seguro médico
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad *',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _cityController.text.trim().isEmpty,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La ciudad es requerida';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _insuranceController,
                decoration: const InputDecoration(
                  labelText: 'Seguro Médico',
                  border: OutlineInputBorder(),
                ),
                enabled: _selectedPatient == null || _insuranceController.text.trim().isEmpty,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<PatientFirestore> _getFilteredPatients(List<PatientFirestore> patients) {
    if (_searchController.text.isEmpty) return [];
    
    final searchTerm = _searchController.text.toLowerCase();
    return patients.where((patient) {
      return patient.firstName.toLowerCase().contains(searchTerm) ||
             patient.paternalLastName.toLowerCase().contains(searchTerm) ||
             patient.maternalLastName.toLowerCase().contains(searchTerm);
    }).toList();
  }

  void _selectPatient(PatientFirestore patient) {
    setState(() {
      _selectedPatient = patient;
      
      // Llenar los campos con los datos del paciente seleccionado
      _firstNameController.text = patient.firstName;
      _paternalLastNameController.text = patient.paternalLastName;
      _maternalLastNameController.text = patient.maternalLastName;
      _ageController.text = patient.age.toString();
      _sexSelected = patient.sex;
      _phoneController.text = patient.phone;
      _streetController.text = patient.street;
      _exteriorNumberController.text = patient.exteriorNumber;
      _interiorNumberController.text = patient.interiorNumber ?? '';
      _neighborhoodController.text = patient.neighborhood;
      _cityController.text = patient.city;
      _insuranceController.text = patient.insurance;
      
      // Limpiar búsqueda
      _searchController.clear();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPatient = null;
      
      // Limpiar todos los campos
      _firstNameController.clear();
      _paternalLastNameController.clear();
      _maternalLastNameController.clear();
      _ageController.clear();
      _sexSelected = '';
      _phoneController.clear();
      _streetController.clear();
      _exteriorNumberController.clear();
      _interiorNumberController.clear();
      _neighborhoodController.clear();
      _cityController.clear();
      _insuranceController.clear();
      _searchController.clear();
    });
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
        'patientId': _selectedPatient?.id,
        'firstName': _firstNameController.text.trim(),
        'paternalLastName': _paternalLastNameController.text.trim(),
        'maternalLastName': _maternalLastNameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'sex': _sexSelected,
        'phone': _phoneController.text.trim(),
        'street': _streetController.text.trim(),
        'exteriorNumber': _exteriorNumberController.text.trim(),
        'interiorNumber': _interiorNumberController.text.trim(),
        'neighborhood': _neighborhoodController.text.trim(),
        'city': _cityController.text.trim(),
        'insurance': _insuranceController.text.trim(),
        'isNewPatient': _selectedPatient == null,
      };

      // Si es un nuevo paciente, preguntar si quiere guardarlo
      if (_selectedPatient == null) {
        final shouldSavePatient = await _showSavePatientDialog();
        if (shouldSavePatient == true) {
          await _saveNewPatient();
        }
      }

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información del paciente guardada'),
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

  Future<bool?> _showSavePatientDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar Nuevo Paciente'),
        content: const Text(
          '¿Deseas guardar este paciente en la base de datos para futuras consultas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No guardar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar paciente'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNewPatient() async {
    try {
      final newPatient = PatientFirestore.create(
        firstName: _firstNameController.text.trim(),
        paternalLastName: _paternalLastNameController.text.trim(),
        maternalLastName: _maternalLastNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        sex: _sexSelected,
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        exteriorNumber: _exteriorNumberController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        city: _cityController.text.trim(),
        insurance: _insuranceController.text.trim(),
      );

      await ref.read(patientsNotifierProvider.notifier).createPatient(newPatient);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nuevo paciente guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar paciente: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 