import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_local_provider.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class FrapLocalRecordsScreen extends ConsumerStatefulWidget {
  const FrapLocalRecordsScreen({super.key});

  @override
  ConsumerState<FrapLocalRecordsScreen> createState() => _FrapLocalRecordsScreenState();
}

class _FrapLocalRecordsScreenState extends ConsumerState<FrapLocalRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedSortBy = 'Más reciente';
  bool _showFilters = false;
  
  // Paginación
  int _currentPage = 1;
  int _itemsPerPage = 10;
  final List<int> _itemsPerPageOptions = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    // Cargar registros locales al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(frapLocalProvider.notifier).loadLocalFrapRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localState = ref.watch(frapLocalProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Registros FRAP Locales'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(frapLocalProvider.notifier).loadLocalFrapRecords();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(frapLocalProvider.notifier).loadLocalFrapRecords();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload),
                    SizedBox(width: 8),
                    Text('Sincronizar Todo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Estadísticas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    Icon(Icons.backup),
                    SizedBox(width: 8),
                    Text('Crear Backup'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpiar Todo', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: _isSearching || _showFilters ? PreferredSize(
          preferredSize: Size.fromHeight(_isSearching && _showFilters ? 120 : 60),
          child: Container(
            color: AppTheme.primaryGreen,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_isSearching)
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre del paciente...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(frapLocalProvider.notifier).loadLocalFrapRecords();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    onChanged: (value) {
                      ref.read(frapLocalProvider.notifier).searchLocalFrapRecords(value);
                    },
                  ),
                if (_isSearching && _showFilters)
                  const SizedBox(height: 8),
                if (_showFilters)
                  _buildFiltersRow(),
              ],
            ),
          ),
        ) : null,
      ),
      body: Column(
        children: [
          // Información de estado
          _buildStatusInfo(localState),
          
          // Lista de registros
          Expanded(
            child: _buildRecordsList(localState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/frap');
        },
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo FRAP'),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedSortBy,
            style: const TextStyle(color: Colors.white),
            dropdownColor: AppTheme.primaryGreen,
            decoration: InputDecoration(
              labelText: 'Ordenar por',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.2),
            ),
            items: [
              'Más reciente',
              'Más antiguo',
              'Nombre A-Z',
              'Nombre Z-A',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedSortBy = newValue;
                  _currentPage = 1; // Reset to first page when sorting changes
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _itemsPerPage,
            style: const TextStyle(color: Colors.white),
            dropdownColor: AppTheme.primaryGreen,
            decoration: InputDecoration(
              labelText: 'Por página',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.2),
            ),
            items: _itemsPerPageOptions.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value', style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _itemsPerPage = newValue;
                  _currentPage = 1; // Reset to first page when items per page changes
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo(FrapLocalState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${state.records.length}',
                  Icons.assignment,
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Hoy',
                  '${_getTodayCount(state.records)}',
                  Icons.today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Esta semana',
                  '${_getWeekCount(state.records)}',
                  Icons.date_range,
                  Colors.orange,
                ),
              ),
            ],
          ),
          if (state.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _getTodayCount(List<Frap> records) {
    final today = DateTime.now();
    return records.where((record) {
      final recordDate = record.createdAt;
      return recordDate.day == today.day &&
             recordDate.month == today.month &&
             recordDate.year == today.year;
    }).length;
  }

  int _getWeekCount(List<Frap> records) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return records.where((record) {
      return record.createdAt.isAfter(weekStart) &&
             record.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).length;
  }

  Widget _buildRecordsList(FrapLocalState state) {
    if (state.isLoading && state.records.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.records.isEmpty) {
      return _buildEmptyState();
    }

    // Ordenar registros
    var sortedRecords = List<Frap>.from(state.records);
    switch (_selectedSortBy) {
      case 'Más reciente':
        sortedRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Más antiguo':
        sortedRecords.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Nombre A-Z':
        sortedRecords.sort((a, b) => a.patient.name.compareTo(b.patient.name));
        break;
      case 'Nombre Z-A':
        sortedRecords.sort((a, b) => b.patient.name.compareTo(a.patient.name));
        break;
    }

    // Aplicar paginación
    final totalPages = (sortedRecords.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, sortedRecords.length);
    final paginatedRecords = sortedRecords.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Información de paginación
        _buildPaginationInfo(sortedRecords.length, startIndex, endIndex),
        
        // Lista de registros
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: paginatedRecords.length,
            itemBuilder: (context, index) {
              final record = paginatedRecords[index];
              final globalIndex = startIndex + index;
              return _buildRecordCard(record, globalIndex);
            },
          ),
        ),
        
        // Controles de paginación
        if (totalPages > 1)
          _buildPaginationControls(totalPages),
      ],
    );
  }

  Widget _buildPaginationInfo(int totalRecords, int startIndex, int endIndex) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando ${startIndex + 1}-$endIndex de $totalRecords registros',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Página $_currentPage de ${(totalRecords / _itemsPerPage).ceil()}',
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón Primera página
          IconButton(
            onPressed: _currentPage > 1 ? () => _goToPage(1) : null,
            icon: const Icon(Icons.first_page),
            tooltip: 'Primera página',
          ),
          
          // Botón Página anterior
          IconButton(
            onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
          ),
          
          // Números de página
          ..._buildPageNumbers(totalPages),
          
          // Botón Página siguiente
          IconButton(
            onPressed: _currentPage < totalPages ? () => _goToPage(_currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Página siguiente',
          ),
          
          // Botón Última página
          IconButton(
            onPressed: _currentPage < totalPages ? () => _goToPage(totalPages) : null,
            icon: const Icon(Icons.last_page),
            tooltip: 'Última página',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    List<Widget> pageNumbers = [];
    
    // Determinar qué páginas mostrar
    int start = 1;
    int end = totalPages;
    
    if (totalPages > 7) {
      if (_currentPage <= 4) {
        end = 7;
      } else if (_currentPage >= totalPages - 3) {
        start = totalPages - 6;
      } else {
        start = _currentPage - 3;
        end = _currentPage + 3;
      }
    }
    
    // Agregar puntos suspensivos al inicio si es necesario
    if (start > 1) {
      pageNumbers.add(_buildPageButton(1));
      if (start > 2) {
        pageNumbers.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: TextStyle(color: Colors.grey[600])),
          ),
        );
      }
    }
    
    // Agregar números de página
    for (int i = start; i <= end; i++) {
      pageNumbers.add(_buildPageButton(i));
    }
    
    // Agregar puntos suspensivos al final si es necesario
    if (end < totalPages) {
      if (end < totalPages - 1) {
        pageNumbers.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('...', style: TextStyle(color: Colors.grey[600])),
          ),
        );
      }
      pageNumbers.add(_buildPageButton(totalPages));
    }
    
    return pageNumbers;
  }

  Widget _buildPageButton(int pageNumber) {
    final isCurrentPage = pageNumber == _currentPage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => _goToPage(pageNumber),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrentPage ? AppTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentPage ? AppTheme.primaryGreen : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Text(
              '$pageNumber',
              style: TextStyle(
                color: isCurrentPage ? Colors.white : Colors.grey[700],
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No hay registros FRAP locales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer registro FRAP para comenzar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/frap');
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear Primer Registro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(Frap record, int index) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _viewRecord(record),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar del paciente
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        record.patient.name.isNotEmpty 
                          ? record.patient.name[0].toUpperCase()
                          : 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Información del paciente
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.patient.name.isNotEmpty 
                            ? record.patient.name
                            : 'Paciente sin nombre',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${record.patient.age} años • ${record.patient.gender}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(record.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Menú de acciones
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleRecordAction(value, record),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Ver Detalles'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Duplicar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'sync',
                        child: Row(
                          children: [
                            Icon(Icons.cloud_upload, color: Colors.purple),
                            SizedBox(width: 8),
                            Text('Sincronizar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Información adicional
              if (record.patient.address.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          record.patient.address,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sync':
        _syncAllRecords();
        break;
      case 'statistics':
        _showStatistics();
        break;
      case 'backup':
        _createBackup();
        break;
      case 'clear':
        _clearAllRecords();
        break;
    }
  }

  void _handleRecordAction(String action, Frap record) {
    switch (action) {
      case 'view':
        _viewRecord(record);
        break;
      case 'edit':
        _editRecord(record);
        break;
      case 'duplicate':
        _duplicateRecord(record);
        break;
      case 'sync':
        _syncRecord(record);
        break;
      case 'delete':
        _deleteRecord(record);
        break;
    }
  }

  void _viewRecord(Frap record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.assignment, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'FRAP - ${record.patient.name}',
                style: TextStyle(color: AppTheme.primaryGreen),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoSection('Información del Paciente', [
                  'Nombre: ${record.patient.name}',
                  'Edad: ${record.patient.age} años',
                  'Género: ${record.patient.gender}',
                  if (record.patient.address.isNotEmpty)
                    'Dirección: ${record.patient.address}',
                ]),
                const SizedBox(height: 16),
                _buildInfoSection('Historia Clínica', [
                  if (record.clinicalHistory.allergies.isNotEmpty)
                    'Alergias: ${record.clinicalHistory.allergies}',
                  if (record.clinicalHistory.medications.isNotEmpty)
                    'Medicamentos: ${record.clinicalHistory.medications}',
                  if (record.clinicalHistory.previousIllnesses.isNotEmpty)
                    'Enfermedades previas: ${record.clinicalHistory.previousIllnesses}',
                ]),
                const SizedBox(height: 16),
                _buildInfoSection('Examen Físico', [
                  if (record.physicalExam.vitalSigns.isNotEmpty)
                    'Signos vitales: ${record.physicalExam.vitalSigns}',
                  if (record.physicalExam.head.isNotEmpty)
                    'Cabeza: ${record.physicalExam.head}',
                  if (record.physicalExam.neck.isNotEmpty)
                    'Cuello: ${record.physicalExam.neck}',
                  if (record.physicalExam.thorax.isNotEmpty)
                    'Tórax: ${record.physicalExam.thorax}',
                  if (record.physicalExam.abdomen.isNotEmpty)
                    'Abdomen: ${record.physicalExam.abdomen}',
                  if (record.physicalExam.extremities.isNotEmpty)
                    'Extremidades: ${record.physicalExam.extremities}',
                ]),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editRecord(record);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  void _editRecord(Frap record) {
    // Convertir Frap a FrapData
    final frapData = ref.read(frapLocalProvider.notifier).convertFrapToFrapData(record);
    
    // Establecer los datos en el provider
    ref.read(frapDataProvider.notifier).setAllData(frapData);
    
    // Navegar a la pantalla de edición
    Navigator.pushNamed(context, '/frap', arguments: record.id);
  }

  void _duplicateRecord(Frap record) async {
    final success = await ref.read(frapLocalProvider.notifier).duplicateLocalFrapRecord(record.id);
    
    if (success != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registro duplicado exitosamente'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al duplicar el registro'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _syncRecord(Frap record) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sincronización individual en desarrollo'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _deleteRecord(Frap record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de que desea eliminar el registro de ${record.patient.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              navigator.pop();
              
              final success = await ref.read(frapLocalProvider.notifier).deleteLocalFrapRecord(record.id);
              
              if (mounted) {
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Text('Registro eliminado exitosamente'),
                      backgroundColor: AppTheme.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Text('Error al eliminar el registro'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _syncAllRecords() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sincronización completa en desarrollo'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showStatistics() {
    final records = ref.read(frapLocalProvider).records;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.analytics, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text('Estadísticas Locales'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticRow('Total de registros', '${records.length}'),
            _buildStatisticRow('Registros de hoy', '${_getTodayCount(records)}'),
            _buildStatisticRow('Registros de esta semana', '${_getWeekCount(records)}'),
            _buildStatisticRow('Registros de este mes', '${_getMonthCount(records)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  int _getMonthCount(List<Frap> records) {
    final now = DateTime.now();
    return records.where((record) {
      return record.createdAt.month == now.month &&
             record.createdAt.year == now.year;
    }).length;
  }

  void _createBackup() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Función de backup en desarrollo'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _clearAllRecords() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar eliminación masiva'),
        content: const Text('¿Está seguro de que desea eliminar TODOS los registros locales? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar eliminación masiva
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Función de eliminación masiva en desarrollo'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }
} 