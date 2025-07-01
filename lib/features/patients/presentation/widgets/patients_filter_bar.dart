import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PatientsFilterBar extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFilterChanged;
  final VoidCallback onClearFilters;

  const PatientsFilterBar({
    super.key,
    required this.currentFilters,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  @override
  State<PatientsFilterBar> createState() => _PatientsFilterBarState();
}

class _PatientsFilterBarState extends State<PatientsFilterBar> {
  String? _selectedGender;
  String? _selectedAgeGroup;
  String? _selectedInsurance;
  final TextEditingController _cityController = TextEditingController();

  final List<String> _genderOptions = ['Todos', 'Masculino', 'Femenino'];
  final List<String> _ageGroupOptions = [
    'Todas las edades',
    'Niños (0-17)',
    'Jóvenes (18-34)',
    'Adultos (35-59)',
    'Adultos mayores (60+)',
  ];
  final List<String> _insuranceOptions = [
    'Todos los seguros',
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
    _initializeFilters();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _initializeFilters() {
    _selectedGender = widget.currentFilters['gender'] ?? 'Todos';
    _selectedInsurance = widget.currentFilters['insurance'] ?? 'Todos los seguros';
    _cityController.text = widget.currentFilters['city'] ?? '';
    
    // Determinar grupo de edad basado en minAge y maxAge
    final minAge = widget.currentFilters['minAge'];
    final maxAge = widget.currentFilters['maxAge'];
    
    if (minAge == null && maxAge == null) {
      _selectedAgeGroup = 'Todas las edades';
    } else if (minAge == 0 && maxAge == 17) {
      _selectedAgeGroup = 'Niños (0-17)';
    } else if (minAge == 18 && maxAge == 34) {
      _selectedAgeGroup = 'Jóvenes (18-34)';
    } else if (minAge == 35 && maxAge == 59) {
      _selectedAgeGroup = 'Adultos (35-59)';
    } else if (minAge == 60) {
      _selectedAgeGroup = 'Adultos mayores (60+)';
    } else {
      _selectedAgeGroup = 'Todas las edades';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Filtros Avanzados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Limpiar todo'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filtros en grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
            children: [
              // Género
              _buildFilterDropdown(
                label: 'Género',
                value: _selectedGender!,
                options: _genderOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                  _applyFilters();
                },
                icon: Icons.wc,
              ),
              
              // Grupo de edad
              _buildFilterDropdown(
                label: 'Edad',
                value: _selectedAgeGroup!,
                options: _ageGroupOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedAgeGroup = value;
                  });
                  _applyFilters();
                },
                icon: Icons.cake,
              ),
              
              // Seguro médico
              _buildFilterDropdown(
                label: 'Seguro',
                value: _selectedInsurance!,
                options: _insuranceOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedInsurance = value;
                  });
                  _applyFilters();
                },
                icon: Icons.medical_services,
              ),
              
              // Ciudad
              _buildCityFilter(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Resumen de filtros activos
          _buildActiveFiltersChips(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(
              option,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }

  Widget _buildCityFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _cityController,
        decoration: const InputDecoration(
          labelText: 'Ciudad',
          prefixIcon: Icon(Icons.location_city, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintText: 'Ej: SLP, MTY...',
        ),
        style: const TextStyle(fontSize: 14),
        onChanged: (value) {
          // Aplicar filtro después de un pequeño delay para evitar muchas consultas
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_cityController.text == value) {
              _applyFilters();
            }
          });
        },
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    final List<Widget> chips = [];
    
    // Género
    if (_selectedGender != null && _selectedGender != 'Todos') {
      chips.add(_buildFilterChip('Género: $_selectedGender', () {
        setState(() {
          _selectedGender = 'Todos';
        });
        _applyFilters();
      }));
    }
    
    // Edad
    if (_selectedAgeGroup != null && _selectedAgeGroup != 'Todas las edades') {
      chips.add(_buildFilterChip('$_selectedAgeGroup', () {
        setState(() {
          _selectedAgeGroup = 'Todas las edades';
        });
        _applyFilters();
      }));
    }
    
    // Seguro
    if (_selectedInsurance != null && _selectedInsurance != 'Todos los seguros') {
      chips.add(_buildFilterChip('Seguro: $_selectedInsurance', () {
        setState(() {
          _selectedInsurance = 'Todos los seguros';
        });
        _applyFilters();
      }));
    }
    
    // Ciudad
    if (_cityController.text.isNotEmpty) {
      chips.add(_buildFilterChip('Ciudad: ${_cityController.text}', () {
        _cityController.clear();
        _applyFilters();
      }));
    }
    
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtros activos:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  void _applyFilters() {
    final Map<String, dynamic> filters = {};
    
    // Género
    if (_selectedGender != null && _selectedGender != 'Todos') {
      filters['gender'] = _selectedGender;
    }
    
    // Edad
    if (_selectedAgeGroup != null && _selectedAgeGroup != 'Todas las edades') {
      switch (_selectedAgeGroup) {
        case 'Niños (0-17)':
          filters['minAge'] = 0;
          filters['maxAge'] = 17;
          break;
        case 'Jóvenes (18-34)':
          filters['minAge'] = 18;
          filters['maxAge'] = 34;
          break;
        case 'Adultos (35-59)':
          filters['minAge'] = 35;
          filters['maxAge'] = 59;
          break;
        case 'Adultos mayores (60+)':
          filters['minAge'] = 60;
          break;
      }
    }
    
    // Seguro
    if (_selectedInsurance != null && _selectedInsurance != 'Todos los seguros') {
      filters['insurance'] = _selectedInsurance;
    }
    
    // Ciudad
    if (_cityController.text.isNotEmpty) {
      filters['city'] = _cityController.text.trim();
    }
    
    widget.onFilterChanged(filters);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedGender = 'Todos';
      _selectedAgeGroup = 'Todas las edades';
      _selectedInsurance = 'Todos los seguros';
      _cityController.clear();
    });
    widget.onClearFilters();
  }
} 