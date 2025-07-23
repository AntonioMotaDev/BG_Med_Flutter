import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/services/search_service.dart';
import 'package:bg_med/core/theme/app_theme.dart';

class SearchBar extends ConsumerStatefulWidget {
  final String? initialQuery;
  final SearchFilters? initialFilters;
  final Function(String query) onSearch;
  final Function(SearchFilters filters) onFiltersChanged;
  final Function() onClear;
  final List<Frap> records;
  final bool showFilters;
  final bool showSuggestions;

  const SearchBar({
    super.key,
    this.initialQuery,
    this.initialFilters,
    required this.onSearch,
    required this.onFiltersChanged,
    required this.onClear,
    required this.records,
    this.showFilters = true,
    this.showSuggestions = true,
  });

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SearchService _searchService = SearchService();
  
  String _currentQuery = '';
  SearchFilters _currentFilters = SearchFilters();
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery ?? '';
    _currentFilters = widget.initialFilters ?? SearchFilters();
    _controller.text = _currentQuery;
    
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus && _suggestions.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {
      _currentQuery = query;
      _isSearching = true;
    });

    // Generar sugerencias
    if (widget.showSuggestions && query.isNotEmpty) {
      _generateSuggestions(query);
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }

    // Realizar búsqueda con debounce
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentQuery == query) {
        widget.onSearch(query);
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _generateSuggestions(String query) async {
    final suggestions = _searchService.getSearchSuggestions(widget.records, query);
    setState(() {
      _suggestions = suggestions;
      _showSuggestions = _focusNode.hasFocus && suggestions.isNotEmpty;
    });
  }

  void _onSuggestionSelected(String suggestion) {
    setState(() {
      _currentQuery = suggestion;
      _controller.text = suggestion;
      _suggestions = [];
      _showSuggestions = false;
    });
    widget.onSearch(suggestion);
    _focusNode.unfocus();
  }

  void _onClear() {
    setState(() {
      _currentQuery = '';
      _controller.clear();
      _suggestions = [];
      _showSuggestions = false;
    });
    widget.onClear();
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FiltersBottomSheet(
        currentFilters: _currentFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          widget.onFiltersChanged(filters);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda principal
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono de búsqueda
              Icon(
                Icons.search,
                color: AppTheme.neutralGray,
                size: 20,
              ),
              const SizedBox(width: 12),
              
              // Campo de texto
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Buscar registros FRAP...',
                    hintStyle: TextStyle(
                      color: AppTheme.neutralGray,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: _onQueryChanged,
                  onSubmitted: (query) {
                    widget.onSearch(query);
                    _focusNode.unfocus();
                  },
                ),
              ),
              
              // Indicador de búsqueda
              if (_isSearching) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
              
              // Botón de filtros
              if (widget.showFilters) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showFiltersDialog,
                  icon: Icon(
                    Icons.filter_list,
                    color: _currentFilters.isEmpty 
                        ? AppTheme.neutralGray 
                        : AppTheme.primaryBlue,
                  ),
                  tooltip: 'Filtros',
                ),
              ],
              
              // Botón de limpiar
              if (_currentQuery.isNotEmpty) ...[
                IconButton(
                  onPressed: _onClear,
                  icon: const Icon(
                    Icons.clear,
                    color: AppTheme.neutralGray,
                  ),
                  tooltip: 'Limpiar búsqueda',
                ),
              ],
            ],
          ),
        ),
        
        // Filtros activos
        if (widget.showFilters && !_currentFilters.isEmpty) ...[
          const SizedBox(height: 8),
          _buildActiveFilters(),
        ],
        
        // Sugerencias
        if (_showSuggestions) ...[
          const SizedBox(height: 8),
          _buildSuggestions(),
        ],
      ],
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <Widget>[];
    
    if (_currentFilters.dateRange != null) {
      activeFilters.add(_buildFilterChip(
        'Fecha: ${_formatDateRange(_currentFilters.dateRange!)}',
        () => _removeFilter('dateRange'),
      ));
    }
    
    if (_currentFilters.patientName != null) {
      activeFilters.add(_buildFilterChip(
        'Paciente: ${_currentFilters.patientName}',
        () => _removeFilter('patientName'),
      ));
    }
    
    if (_currentFilters.emergencyType != null) {
      activeFilters.add(_buildFilterChip(
        'Tipo: ${_currentFilters.emergencyType}',
        () => _removeFilter('emergencyType'),
      ));
    }
    
    if (_currentFilters.gender != null) {
      activeFilters.add(_buildFilterChip(
        'Género: ${_currentFilters.gender}',
        () => _removeFilter('gender'),
      ));
    }
    
    if (_currentFilters.isSynced != null) {
      activeFilters.add(_buildFilterChip(
        _currentFilters.isSynced! ? 'Sincronizado' : 'Local',
        () => _removeFilter('isSynced'),
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: activeFilters,
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.search, size: 16),
            title: Text(
              suggestion,
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () => _onSuggestionSelected(suggestion),
          );
        },
      ),
    );
  }

  void _removeFilter(String filterType) {
    SearchFilters newFilters;
    
    switch (filterType) {
      case 'dateRange':
        newFilters = _currentFilters.copyWith(dateRange: null);
        break;
      case 'patientName':
        newFilters = _currentFilters.copyWith(patientName: null);
        break;
      case 'emergencyType':
        newFilters = _currentFilters.copyWith(emergencyType: null);
        break;
      case 'gender':
        newFilters = _currentFilters.copyWith(gender: null);
        break;
      case 'isSynced':
        newFilters = _currentFilters.copyWith(isSynced: null);
        break;
      default:
        newFilters = _currentFilters;
    }
    
    setState(() {
      _currentFilters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  String _formatDateRange(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${start.day}/${start.month}/${start.year}';
    }
    
    return '${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}';
  }
}

class _FiltersBottomSheet extends StatefulWidget {
  final SearchFilters currentFilters;
  final Function(SearchFilters) onFiltersChanged;

  const _FiltersBottomSheet({
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late SearchFilters _filters;
  DateTimeRange? _dateRange;
  String? _patientName;
  String? _emergencyType;
  String? _gender;
  bool? _isSynced;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    _dateRange = _filters.dateRange;
    _patientName = _filters.patientName;
    _emergencyType = _filters.emergencyType;
    _gender = _filters.gender;
    _isSynced = _filters.isSynced;
  }

  void _applyFilters() {
    final newFilters = SearchFilters(
      dateRange: _dateRange,
      patientName: _patientName,
      emergencyType: _emergencyType,
      gender: _gender,
      isSynced: _isSynced,
    );
    widget.onFiltersChanged(newFilters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _dateRange = null;
      _patientName = null;
      _emergencyType = null;
      _gender = null;
      _isSynced = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                const Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Limpiar'),
                ),
              ],
            ),
          ),
          
          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rango de fechas
                  const Text(
                    'Rango de fechas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange,
                      );
                      if (range != null) {
                        setState(() {
                          _dateRange = range;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _dateRange != null
                                ? '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}'
                                : 'Seleccionar fechas',
                            style: TextStyle(
                              color: _dateRange != null 
                                  ? Colors.black 
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Nombre del paciente
                  const Text(
                    'Nombre del paciente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _patientName = value.isEmpty ? null : value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tipo de emergencia
                  const Text(
                    'Tipo de emergencia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Seleccionar tipo'),
                    value: _emergencyType,
                    items: const [
                      DropdownMenuItem(value: 'Clínico', child: Text('Clínico')),
                      DropdownMenuItem(value: 'Trauma', child: Text('Trauma')),
                      DropdownMenuItem(value: 'Obstétrico', child: Text('Obstétrico')),
                      DropdownMenuItem(value: 'Pediátrico', child: Text('Pediátrico')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _emergencyType = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Género
                  const Text(
                    'Género',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Seleccionar género'),
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Estado de sincronización
                  const Text(
                    'Estado de sincronización',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Todos'),
                    value: _isSynced,
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Sincronizado')),
                      DropdownMenuItem(value: false, child: Text('Local')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _isSynced = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Botones
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 