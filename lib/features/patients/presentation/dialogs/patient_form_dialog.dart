import 'package:bg_med/core/models/patient_firestore.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientFormDialog extends StatefulWidget {
  final String title;
  final PatientFirestore? patient;
  final Function(PatientFirestore) onSave;

  const PatientFormDialog({
    super.key,
    required this.title,
    this.patient,
    required this.onSave,
  });

  @override
  State<PatientFormDialog> createState() => _PatientFormDialogState();
}

class _PatientFormDialogState extends State<PatientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

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
  final _responsiblePersonController = TextEditingController();

  // Valores seleccionados
  String _selectedSex = 'Masculino';
  String _selectedInsurance = 'IMSS';

  // Opciones
  final List<String> _sexOptions = ['Masculino', 'Femenino'];
  final List<String> _insuranceOptions = [
    'IMSS',
    'ISSSTE',
    'Seguro Popular',
    'Privado',
    'Sin seguro',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.patient != null) {
      final patient = widget.patient!;
      _firstNameController.text = patient.firstName;
      _paternalLastNameController.text = patient.paternalLastName;
      _maternalLastNameController.text = patient.maternalLastName;
      _ageController.text = patient.age.toString();
      _phoneController.text = patient.phone;
      _streetController.text = patient.street;
      _exteriorNumberController.text = patient.exteriorNumber;
      _interiorNumberController.text = patient.interiorNumber ?? '';
      _neighborhoodController.text = patient.neighborhood;
      _cityController.text = patient.city;
      _responsiblePersonController.text = patient.responsiblePerson ?? '';
      
      // Validar que el sexo del paciente esté en las opciones disponibles
      if (patient.sex.isNotEmpty && _sexOptions.contains(patient.sex)) {
        _selectedSex = patient.sex;
      } else {
        // Si el valor no está en las opciones, usar el valor por defecto
        _selectedSex = _sexOptions.first;
        if (patient.sex.isNotEmpty) {
          print('Advertencia: Sexo "${patient.sex}" no encontrado en opciones, usando "${_selectedSex}"');
        }
      }
      
      // Validar que el seguro del paciente esté en las opciones disponibles
      if (patient.insurance.isNotEmpty && _insuranceOptions.contains(patient.insurance)) {
        _selectedInsurance = patient.insurance;
      } else {
        // Si el valor no está en las opciones, usar el valor por defecto
        _selectedInsurance = _insuranceOptions.first;
        if (patient.insurance.isNotEmpty) {
          print('Advertencia: Seguro "${patient.insurance}" no encontrado en opciones, usando "${_selectedInsurance}"');
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
    _responsiblePersonController.dispose();
    _pageController.dispose();
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
                  Icon(
                    widget.patient == null ? Icons.person_add : Icons.edit,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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

            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _buildProgressStep(0, 'Datos Personales', Icons.person),
                  Expanded(child: _buildProgressLine(0)),
                  _buildProgressStep(1, 'Dirección', Icons.location_on),
                  Expanded(child: _buildProgressLine(1)),
                  _buildProgressStep(2, 'Información Médica', Icons.medical_information),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildPersonalDataPage(),
                    _buildAddressPage(),
                    _buildMedicalInfoPage(),
                  ],
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
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                    ),
                  const Spacer(),
                  if (_currentPage < 2)
                    ElevatedButton.icon(
                      onPressed: _nextPage,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Siguiente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _savePatient,
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
                      label: Text(_isLoading ? 'Guardando...' : 'Guardar'),
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

  Widget _buildProgressStep(int step, String title, IconData icon) {
    final isActive = _currentPage == step;
    final isCompleted = _currentPage > step;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isActive
                    ? AppTheme.primaryBlue
                    : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.primaryBlue : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    final isCompleted = _currentPage > step;
    
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 32),
      color: isCompleted ? Colors.green : Colors.grey[300],
    );
  }

  Widget _buildPersonalDataPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos Personales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Nombre
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre(s) *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Apellido paterno
          TextFormField(
            controller: _paternalLastNameController,
            decoration: const InputDecoration(
              labelText: 'Apellido Paterno *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El apellido paterno es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Apellido materno
          TextFormField(
            controller: _maternalLastNameController,
            decoration: const InputDecoration(
              labelText: 'Apellido Materno *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El apellido materno es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Edad
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Edad *',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                    suffixText: 'años',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La edad es obligatoria';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 150) {
                      return 'Edad inválida';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Sexo
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sexOptions.contains(_selectedSex) ? _selectedSex : _sexOptions.first,
                  decoration: const InputDecoration(
                    labelText: 'Sexo *',
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(),
                  ),
                  items: _sexOptions.map((sex) {
                    return DropdownMenuItem(
                      value: sex,
                      child: Text(sex),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSex = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Teléfono
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Teléfono *',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
              hintText: '4441234567',
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El teléfono es obligatorio';
              }
              if (value.length != 10) {
                return 'El teléfono debe tener 10 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Persona responsable (opcional)
          TextFormField(
            controller: _responsiblePersonController,
            decoration: const InputDecoration(
              labelText: 'Persona Responsable',
              prefixIcon: Icon(Icons.family_restroom),
              border: OutlineInputBorder(),
              hintText: 'Ej: Padre, Madre, Tutor',
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dirección',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Calle
          TextFormField(
            controller: _streetController,
            decoration: const InputDecoration(
              labelText: 'Calle *',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La calle es obligatoria';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Número exterior
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _exteriorNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Núm. Exterior *',
                    prefixIcon: Icon(Icons.home),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El número exterior es obligatorio';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Número interior (opcional)
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _interiorNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Núm. Interior',
                    prefixIcon: Icon(Icons.apartment),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Colonia/Barrio
          TextFormField(
            controller: _neighborhoodController,
            decoration: const InputDecoration(
              labelText: 'Colonia/Barrio *',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La colonia es obligatoria';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Ciudad
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Ciudad *',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La ciudad es obligatoria';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Médica',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Seguro médico
          DropdownButtonFormField<String>(
            value: _insuranceOptions.contains(_selectedInsurance) ? _selectedInsurance : _insuranceOptions.first,
            decoration: const InputDecoration(
              labelText: 'Seguro Médico *',
              prefixIcon: Icon(Icons.medical_services),
              border: OutlineInputBorder(),
            ),
            items: _insuranceOptions.map((insurance) {
              return DropdownMenuItem(
                value: insurance,
                child: Text(insurance),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedInsurance = value!;
              });
            },
          ),
          const SizedBox(height: 32),
          
          // Resumen de datos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de Datos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Nombre completo', 
                    '${_firstNameController.text} ${_paternalLastNameController.text} ${_maternalLastNameController.text}'),
                _buildSummaryRow('Edad', '${_ageController.text} años'),
                _buildSummaryRow('Sexo', _selectedSex),
                _buildSummaryRow('Teléfono', _phoneController.text),
                _buildSummaryRow('Dirección', 
                    '${_streetController.text} ${_exteriorNumberController.text}${_interiorNumberController.text.isNotEmpty ? ', Int. ${_interiorNumberController.text}' : ''}, ${_neighborhoodController.text}, ${_cityController.text}'),
                _buildSummaryRow('Seguro médico', _selectedInsurance),
                if (_responsiblePersonController.text.isNotEmpty)
                  _buildSummaryRow('Persona responsable', _responsiblePersonController.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'No especificado' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage == 0) {
      // Validar datos personales
      if (!_validatePersonalData()) return;
    } else if (_currentPage == 1) {
      // Validar dirección
      if (!_validateAddress()) return;
    }
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validatePersonalData() {
    return _firstNameController.text.trim().isNotEmpty &&
           _paternalLastNameController.text.trim().isNotEmpty &&
           _maternalLastNameController.text.trim().isNotEmpty &&
           _ageController.text.trim().isNotEmpty &&
           _phoneController.text.trim().isNotEmpty &&
           _phoneController.text.length == 10;
  }

  bool _validateAddress() {
    return _streetController.text.trim().isNotEmpty &&
           _exteriorNumberController.text.trim().isNotEmpty &&
           _neighborhoodController.text.trim().isNotEmpty &&
           _cityController.text.trim().isNotEmpty;
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patient = widget.patient?.copyWith(
        firstName: _firstNameController.text.trim(),
        paternalLastName: _paternalLastNameController.text.trim(),
        maternalLastName: _maternalLastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        sex: _selectedSex,
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        exteriorNumber: _exteriorNumberController.text.trim(),
        interiorNumber: _interiorNumberController.text.trim().isEmpty 
            ? null 
            : _interiorNumberController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        city: _cityController.text.trim(),
        insurance: _selectedInsurance,
        responsiblePerson: _responsiblePersonController.text.trim().isEmpty 
            ? null 
            : _responsiblePersonController.text.trim(),
        updatedAt: DateTime.now(),
      ) ?? PatientFirestore.create(
        firstName: _firstNameController.text.trim(),
        paternalLastName: _paternalLastNameController.text.trim(),
        maternalLastName: _maternalLastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        sex: _selectedSex,
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        exteriorNumber: _exteriorNumberController.text.trim(),
        interiorNumber: _interiorNumberController.text.trim().isEmpty 
            ? null 
            : _interiorNumberController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        city: _cityController.text.trim(),
        insurance: _selectedInsurance,
        responsiblePerson: _responsiblePersonController.text.trim().isEmpty 
            ? null 
            : _responsiblePersonController.text.trim(),
      );

      widget.onSave(patient);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar los datos: $e'),
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