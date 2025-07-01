import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/frap/presentation/screens/frap_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class FrapRecordsListScreen extends StatefulWidget {
  const FrapRecordsListScreen({super.key});

  @override
  State<FrapRecordsListScreen> createState() => _FrapRecordsListScreenState();
}

class _FrapRecordsListScreenState extends State<FrapRecordsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSortBy = 'Más reciente';
  DateTimeRange? _selectedDateRange;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Registros FRAP',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilters ? AppTheme.primaryBlue : Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewRecord(context),
            tooltip: 'Nuevo Registro',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con estadísticas y búsqueda
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Estadísticas rápidas
                ValueListenableBuilder(
                  valueListenable: Hive.box<Frap>('fraps').listenable(),
                  builder: (context, Box<Frap> box, _) {
                    final totalRecords = box.values.length;
                    final todayRecords = box.values
                        .where((frap) =>
                            frap.createdAt.day == DateTime.now().day &&
                            frap.createdAt.month == DateTime.now().month &&
                            frap.createdAt.year == DateTime.now().year)
                        .length;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildQuickStatCard(
                            'Total',
                            totalRecords.toString(),
                            Icons.assignment,
                            AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickStatCard(
                            'Hoy',
                            todayRecords.toString(),
                            Icons.today,
                            AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickStatCard(
                            'Esta semana',
                            _getWeeklyCount(box.values).toString(),
                            Icons.date_range,
                            Colors.orange[600]!,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre del paciente...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryBlue),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ],
            ),
          ),

          // Filtros avanzados (expandible)
          if (_showFilters)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Ordenar por
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSortBy,
                          decoration: InputDecoration(
                            labelText: 'Ordenar por',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            'Más reciente',
                            'Más antiguo',
                            'Nombre A-Z',
                            'Nombre Z-A'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSortBy = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filtro por fecha
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDateRangeFilter(context),
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _selectedDateRange == null
                                ? 'Filtrar por fecha'
                                : 'Fechas seleccionadas',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedDateRange != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                            style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDateRange = null;
                              });
                            },
                            child: Icon(Icons.close, size: 16, color: AppTheme.primaryBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Lista de registros
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Frap>('fraps').listenable(),
              builder: (context, Box<Frap> box, _) {
                if (box.values.isEmpty) {
                  return _buildEmptyState();
                }

                // Filtrar y ordenar registros
                var filteredRecords = box.values.where((frap) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      frap.patient.name.toLowerCase().contains(_searchQuery);
                  
                  final matchesDateRange = _selectedDateRange == null ||
                      (frap.createdAt.isAfter(_selectedDateRange!.start) &&
                       frap.createdAt.isBefore(_selectedDateRange!.end.add(
                         const Duration(days: 1))));
                  
                  return matchesSearch && matchesDateRange;
                }).toList();

                // Ordenar registros
                switch (_selectedSortBy) {
                  case 'Más reciente':
                    filteredRecords.sort((a, b) => 
                        b.createdAt.compareTo(a.createdAt));
                    break;
                  case 'Más antiguo':
                    filteredRecords.sort((a, b) => 
                        a.createdAt.compareTo(b.createdAt));
                    break;
                  case 'Nombre A-Z':
                    filteredRecords.sort((a, b) => 
                        a.patient.name.compareTo(b.patient.name));
                    break;
                  case 'Nombre Z-A':
                    filteredRecords.sort((a, b) => 
                        b.patient.name.compareTo(a.patient.name));
                    break;
                }

                if (filteredRecords.isEmpty) {
                  return _buildNoResultsState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final frap = filteredRecords[index];
                    return _buildRecordCard(frap, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewRecord(context),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo FRAP'),
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay registros FRAP',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer registro para comenzar',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewRecord(context),
            icon: const Icon(Icons.add),
            label: const Text('Crear Primer Registro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron registros',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta ajustar los filtros de búsqueda',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(Frap frap, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          frap.patient.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(frap.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${frap.patient.age} años • ${_getGenderText(frap.patient.gender)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleRecordAction(value, frap),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 16),
                  SizedBox(width: 8),
                  Text('Ver detalles'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 16),
                  SizedBox(width: 8),
                  Text('Duplicar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.share, size: 16),
                  SizedBox(width: 8),
                  Text('Exportar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection('Información del Paciente', [
                  'Nombre: ${frap.patient.name}',
                  'Edad: ${frap.patient.age} años',
                  'Género: ${_getGenderText(frap.patient.gender)}',
                  if (frap.patient.address.isNotEmpty)
                    'Dirección: ${frap.patient.address}',
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Historia Clínica', [
                  'Alergias: ${frap.clinicalHistory.allergies.isEmpty ? "Ninguna" : frap.clinicalHistory.allergies}',
                  'Medicamentos: ${frap.clinicalHistory.medications.isEmpty ? "Ninguno" : frap.clinicalHistory.medications}',
                  'Antecedentes patológicos: ${frap.clinicalHistory.previousIllnesses.isEmpty ? "Ninguna" : frap.clinicalHistory.previousIllnesses}',
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Examen Físico', [
                  'Signos vitales: ${frap.physicalExam.vitalSigns.isEmpty ? "No registrado" : frap.physicalExam.vitalSigns}',
                  'Cabeza: ${frap.physicalExam.head.isEmpty ? "Normal" : frap.physicalExam.head}',
                  'Cuello: ${frap.physicalExam.neck.isEmpty ? "Normal" : frap.physicalExam.neck}',
                  'Tórax: ${frap.physicalExam.thorax.isEmpty ? "Normal" : frap.physicalExam.thorax}',
                  'Abdomen: ${frap.physicalExam.abdomen.isEmpty ? "Normal" : frap.physicalExam.abdomen}',
                  'Extremidades: ${frap.physicalExam.extremities.isEmpty ? "Normal" : frap.physicalExam.extremities}',
                ]),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton('Ver', Icons.visibility, AppTheme.primaryBlue, () => _viewFullRecord(frap)),
                    _buildActionButton('Editar', Icons.edit, Colors.orange, () => _editRecord(frap)),
                    _buildActionButton('Duplicar', Icons.copy, Colors.green, () => _duplicateRecord(frap)),
                    _buildActionButton('Exportar', Icons.share, Colors.purple, () => _exportRecord(frap)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        ...details.map((detail) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            detail,
            style: const TextStyle(fontSize: 12),
          ),
        )),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  // Utility functions
  int _getWeeklyCount(Iterable<Frap> fraps) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return fraps.where((frap) =>
        frap.createdAt.isAfter(weekStart) &&
        frap.createdAt.isBefore(weekEnd.add(const Duration(days: 1)))
    ).length;
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getGenderText(String gender) {
    switch (gender) {
      case 'Male':
        return 'Masculino';
      case 'Female':
        return 'Femenino';
      default:
        return gender;
    }
  }

  // CRUD Operations
  void _createNewRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FrapScreen(),
      ),
    );
  }

  void _handleRecordAction(String action, Frap frap) {
    switch (action) {
      case 'view':
        _viewFullRecord(frap);
        break;
      case 'edit':
        _editRecord(frap);
        break;
      case 'duplicate':
        _duplicateRecord(frap);
        break;
      case 'export':
        _exportRecord(frap);
        break;
      case 'delete':
        _deleteRecord(frap);
        break;
    }
  }

  void _viewFullRecord(Frap frap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.assignment, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'FRAP - ${frap.patient.name}',
                style: TextStyle(color: AppTheme.primaryBlue),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Información del Paciente', [
                'Nombre: ${frap.patient.name}',
                'Edad: ${frap.patient.age} años',
                'Género: ${_getGenderText(frap.patient.gender)}',
                if (frap.patient.address.isNotEmpty)
                  'Dirección: ${frap.patient.address}',
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Historia Clínica', [
                'Alergias: ${frap.clinicalHistory.allergies.isEmpty ? "Ninguna" : frap.clinicalHistory.allergies}',
                'Medicamentos: ${frap.clinicalHistory.medications.isEmpty ? "Ninguno" : frap.clinicalHistory.medications}',
                'Antecedentes patológicos: ${frap.clinicalHistory.previousIllnesses.isEmpty ? "Ninguna" : frap.clinicalHistory.previousIllnesses}',
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Examen Físico', [
                'Signos vitales: ${frap.physicalExam.vitalSigns.isEmpty ? "No registrado" : frap.physicalExam.vitalSigns}',
                'Cabeza: ${frap.physicalExam.head.isEmpty ? "Normal" : frap.physicalExam.head}',
                'Cuello: ${frap.physicalExam.neck.isEmpty ? "Normal" : frap.physicalExam.neck}',
                'Tórax: ${frap.physicalExam.thorax.isEmpty ? "Normal" : frap.physicalExam.thorax}',
                'Abdomen: ${frap.physicalExam.abdomen.isEmpty ? "Normal" : frap.physicalExam.abdomen}',
                'Extremidades: ${frap.physicalExam.extremities.isEmpty ? "Normal" : frap.physicalExam.extremities}',
              ]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Registro creado: ${_formatDateTime(frap.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey[600],
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editRecord(frap);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  void _editRecord(Frap frap) {
    // TODO: Implementar navegación a pantalla de edición
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando registro de ${frap.patient.name}...'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Próximamente',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _duplicateRecord(Frap frap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicar Registro'),
        content: Text('¿Deseas crear una copia del registro de ${frap.patient.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final newFrap = Frap(
                  id: const Uuid().v4(),
                  patient: frap.patient,
                  clinicalHistory: frap.clinicalHistory,
                  physicalExam: frap.physicalExam,
                  createdAt: DateTime.now(),
                );
                
                final frapBox = Hive.box<Frap>('fraps');
                await frapBox.add(newFrap);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Registro duplicado exitosamente'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al duplicar registro: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );
  }

  void _exportRecord(Frap frap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Registro'),
        content: Text('¿Cómo deseas exportar el registro de ${frap.patient.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToPDF(frap);
            },
            child: const Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportToText(frap);
            },
            child: const Text('Texto'),
          ),
        ],
      ),
    );
  }

  void _exportToPDF(Frap frap) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportando ${frap.patient.name} a PDF...'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Próximamente',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _exportToText(Frap frap) {
    final textData = '''
REGISTRO FRAP - ${frap.patient.name}
=====================================

INFORMACIÓN DEL PACIENTE:
- Nombre: ${frap.patient.name}
- Edad: ${frap.patient.age} años
- Género: ${_getGenderText(frap.patient.gender)}
- Dirección: ${frap.patient.address.isEmpty ? "No especificada" : frap.patient.address}

HISTORIA CLÍNICA:
- Alergias: ${frap.clinicalHistory.allergies.isEmpty ? "Ninguna" : frap.clinicalHistory.allergies}
- Medicamentos: ${frap.clinicalHistory.medications.isEmpty ? "Ninguno" : frap.clinicalHistory.medications}
- Antecedentes patológicos: ${frap.clinicalHistory.previousIllnesses.isEmpty ? "Ninguna" : frap.clinicalHistory.previousIllnesses}

EXAMEN FÍSICO:
- Signos vitales: ${frap.physicalExam.vitalSigns.isEmpty ? "No registrado" : frap.physicalExam.vitalSigns}
- Cabeza: ${frap.physicalExam.head.isEmpty ? "Normal" : frap.physicalExam.head}
- Cuello: ${frap.physicalExam.neck.isEmpty ? "Normal" : frap.physicalExam.neck}
- Tórax: ${frap.physicalExam.thorax.isEmpty ? "Normal" : frap.physicalExam.thorax}
- Abdomen: ${frap.physicalExam.abdomen.isEmpty ? "Normal" : frap.physicalExam.abdomen}
- Extremidades: ${frap.physicalExam.extremities.isEmpty ? "Normal" : frap.physicalExam.extremities}

REGISTRO:
- Fecha: ${_formatDateTime(frap.createdAt)}
- ID: ${frap.id}
''';

    Clipboard.setData(ClipboardData(text: textData));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registro de ${frap.patient.name} copiado al portapapeles'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _deleteRecord(Frap frap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Registro'),
        content: Text('¿Estás seguro de que deseas eliminar el registro de ${frap.patient.name}?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final frapBox = Hive.box<Frap>('fraps');
                final key = frapBox.values
                    .toList()
                    .indexWhere((f) => f.id == frap.id);
                
                if (key != -1) {
                  await frapBox.deleteAt(key);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Registro de ${frap.patient.name} eliminado'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar registro: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDateRangeFilter(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
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
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
} 