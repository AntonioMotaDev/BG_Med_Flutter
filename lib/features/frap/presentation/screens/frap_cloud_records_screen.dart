import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_firestore_provider.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class FrapCloudRecordsScreen extends ConsumerStatefulWidget {
  const FrapCloudRecordsScreen({super.key});

  @override
  ConsumerState<FrapCloudRecordsScreen> createState() => _FrapCloudRecordsScreenState();
}

class _FrapCloudRecordsScreenState extends ConsumerState<FrapCloudRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedFilter = 'Todos';
  String _selectedSortBy = 'Más reciente';
  bool _showFilters = false;
  
  // Paginación
  int _currentPage = 1;
  int _itemsPerPage = 10;
  final List<int> _itemsPerPageOptions = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    // Cargar registros de la nube al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(frapFirestoreProvider.notifier).loadFrapRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cloudState = ref.watch(frapFirestoreProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Registros FRAP en la Nube'),
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
                  ref.read(frapFirestoreProvider.notifier).loadFrapRecords();
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
              ref.read(frapFirestoreProvider.notifier).loadFrapRecords();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync_local',
                child: Row(
                  children: [
                    Icon(Icons.cloud_download),
                    SizedBox(width: 8),
                    Text('Sincronizar Local'),
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
                          ref.read(frapFirestoreProvider.notifier).loadFrapRecords();
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
                      ref.read(frapFirestoreProvider.notifier).searchFrapRecords(value);
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
          // Información de estado y estadísticas
          _buildStatusInfo(cloudState),
          
          // Lista de registros
          Expanded(
            child: _buildRecordsList(cloudState),
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
            value: _selectedFilter,
            style: const TextStyle(color: Colors.white),
            dropdownColor: AppTheme.primaryGreen,
            decoration: InputDecoration(
              labelText: 'Filtrar por',
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
              'Todos',
              'Hoy',
              'Esta semana',
              'Este mes',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedFilter = newValue;
                  _currentPage = 1; // Reset to first page when filter changes
                });
                _applyFilter();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
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
              'Más completo',
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

  void _applyFilter() {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    setState(() {
      _currentPage = 1; // Reset to first page when applying filter
    });

    switch (_selectedFilter) {
      case 'Hoy':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1));
        ref.read(frapFirestoreProvider.notifier).getFrapRecordsByDateRange(startDate, endDate);
        break;
      case 'Esta semana':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate.add(const Duration(days: 7));
        ref.read(frapFirestoreProvider.notifier).getFrapRecordsByDateRange(startDate, endDate);
        break;
      case 'Este mes':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1);
        ref.read(frapFirestoreProvider.notifier).getFrapRecordsByDateRange(startDate, endDate);
        break;
      default:
        ref.read(frapFirestoreProvider.notifier).loadFrapRecords();
        break;
    }
  }

  Widget _buildStatusInfo(FrapFirestoreState state) {
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
                  Icons.cloud,
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
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completos',
                  '${_getCompleteCount(state.records)}',
                  Icons.check_circle,
                  Colors.green,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _getTodayCount(List<FrapFirestore> records) {
    final today = DateTime.now();
    return records.where((record) {
      final recordDate = record.createdAt;
      return recordDate.day == today.day &&
             recordDate.month == today.month &&
             recordDate.year == today.year;
    }).length;
  }

  int _getWeekCount(List<FrapFirestore> records) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return records.where((record) {
      return record.createdAt.isAfter(weekStart) &&
             record.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).length;
  }

  int _getCompleteCount(List<FrapFirestore> records) {
    return records.where((record) => record.isComplete).length;
  }

  Widget _buildRecordsList(FrapFirestoreState state) {
    if (state.isLoading && state.records.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.records.isEmpty) {
      return _buildEmptyState();
    }

    // Ordenar registros
    var sortedRecords = List<FrapFirestore>.from(state.records);
    switch (_selectedSortBy) {
      case 'Más reciente':
        sortedRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Más antiguo':
        sortedRecords.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Nombre A-Z':
        sortedRecords.sort((a, b) => a.patientName.compareTo(b.patientName));
        break;
      case 'Nombre Z-A':
        sortedRecords.sort((a, b) => b.patientName.compareTo(a.patientName));
        break;
      case 'Más completo':
        sortedRecords.sort((a, b) => b.completionPercentage.compareTo(a.completionPercentage));
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
            Icons.cloud_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No hay registros FRAP en la nube',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los registros aparecerán aquí una vez sincronizados',
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

  Widget _buildRecordCard(FrapFirestore record, int index) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final patientAddress = record.patientInfo['address'] ?? 
                          '${record.patientInfo['street'] ?? ''} ${record.patientInfo['neighborhood'] ?? ''}'.trim();
    
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
                        record.patientName.isNotEmpty 
                          ? record.patientName[0].toUpperCase()
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                record.patientName.isNotEmpty 
                                  ? record.patientName
                                  : 'Paciente sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            // Indicador de sincronización
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cloud_done, size: 14, color: Colors.blue[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Nube',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${record.patientAge} años • ${record.patientGender}',
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
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Descargar Local'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Compartir'),
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
              
              // Barra de progreso y dirección
              const SizedBox(height: 12),
              
              // Barra de progreso de completitud
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Completitud',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${record.completionPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: record.completionPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        record.completionPercentage >= 80 ? Colors.green :
                        record.completionPercentage >= 50 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Dirección del paciente si está disponible
              if (patientAddress.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          patientAddress,
                          style: TextStyle(
                            color: Colors.blue[700],
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
      case 'sync_local':
        _syncWithLocal();
        break;
      case 'statistics':
        _showStatistics();
        break;
      case 'backup':
        _createBackup();
        break;
    }
  }

  void _handleRecordAction(String action, FrapFirestore record) {
    switch (action) {
      case 'view':
        _viewRecord(record);
        break;
      case 'download':
        _downloadRecord(record);
        break;
      case 'share':
        _shareRecord(record);
        break;
      case 'delete':
        _deleteRecord(record);
        break;
    }
  }

  void _viewRecord(FrapFirestore record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cloud, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'FRAP - ${record.patientName}',
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
                _buildInfoSection('Información del Paciente', record.patientInfo),
                const SizedBox(height: 16),
                _buildInfoSection('Historia Clínica', record.clinicalHistory),
                const SizedBox(height: 16),
                _buildInfoSection('Examen Físico', record.physicalExam),
                const SizedBox(height: 16),
                _buildInfoSection('Información del Servicio', record.serviceInfo),
                if (record.management.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoSection('Manejo', record.management),
                ],
                if (record.medications.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoSection('Medicamentos', record.medications),
                ],
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
              _downloadRecord(record);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Descargar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, Map<String, dynamic> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    final items = data.entries
        .where((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty)
        .map((entry) => '${_formatFieldName(entry.key)}: ${entry.value}')
        .toList();
    
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

  String _formatFieldName(String fieldName) {
    // Convertir camelCase a título legible
    return fieldName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ')
        .trim();
  }

  void _downloadRecord(FrapFirestore record) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Descarga a almacenamiento local en desarrollo'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _shareRecord(FrapFirestore record) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Función de compartir en desarrollo'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _deleteRecord(FrapFirestore record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de que desea eliminar el registro de ${record.patientName}?'),
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
              
              final success = await ref.read(frapFirestoreProvider.notifier).deleteFrapRecord(record.id ?? '');
              
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

  void _syncWithLocal() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sincronización con almacenamiento local en desarrollo'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showStatistics() {
    final records = ref.read(frapFirestoreProvider).records;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.analytics, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text('Estadísticas en la Nube'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatisticRow('Total de registros', '${records.length}'),
            _buildStatisticRow('Registros de hoy', '${_getTodayCount(records)}'),
            _buildStatisticRow('Registros de esta semana', '${_getWeekCount(records)}'),
            _buildStatisticRow('Registros de este mes', '${_getMonthCount(records)}'),
            _buildStatisticRow('Registros completos', '${_getCompleteCount(records)}'),
            _buildStatisticRow('Promedio de completitud', '${_getAverageCompletion(records).toStringAsFixed(1)}%'),
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

  int _getMonthCount(List<FrapFirestore> records) {
    final now = DateTime.now();
    return records.where((record) {
      return record.createdAt.month == now.month &&
             record.createdAt.year == now.year;
    }).length;
  }

  double _getAverageCompletion(List<FrapFirestore> records) {
    if (records.isEmpty) return 0.0;
    final total = records.map((record) => record.completionPercentage).reduce((a, b) => a + b);
    return total / records.length;
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
} 