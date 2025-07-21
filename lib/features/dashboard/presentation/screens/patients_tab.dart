import 'package:bg_med/core/models/patient_firestore.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/patients/presentation/providers/patients_provider.dart';
import 'package:bg_med/features/patients/presentation/dialogs/patient_form_dialog.dart';
import 'package:bg_med/features/patients/presentation/dialogs/patient_details_dialog.dart';
import 'package:bg_med/features/patients/presentation/widgets/patients_search_bar.dart';
import 'package:bg_med/features/patients/presentation/widgets/patients_filter_bar.dart';
import 'package:bg_med/features/patients/presentation/widgets/patient_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientsTab extends ConsumerStatefulWidget {
  const PatientsTab({super.key});

  @override
  ConsumerState<PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends ConsumerState<PatientsTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsState = ref.watch(patientsNotifierProvider);
    final patientsNotifier = ref.read(patientsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pacientes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              patientsNotifier.refresh();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            child: PatientsSearchBar(
              controller: _searchController,
              onSearch: (query) {
                if (query.isEmpty) {
                  patientsNotifier.clearFilters();
                } else {
                  patientsNotifier.searchPatients(query);
                }
              },
              onClear: () {
                _searchController.clear();
                patientsNotifier.clearFilters();
              },
            ),
          ),

          // Barra de filtros (mostrar/ocultar)
          if (_showFilters)
            Container(
              child: PatientsFilterBar(
                currentFilters: patientsState.filters,
                onFilterChanged: (filters) {
                  patientsNotifier.advancedSearch(
                    nameQuery: filters['nameQuery'],
                    gender: filters['gender'],
                    minAge: filters['minAge'],
                    maxAge: filters['maxAge'],
                    city: filters['city'],
                    insurance: filters['insurance'],
                  );
                },
                onClearFilters: () {
                  patientsNotifier.clearFilters();
                },
              ),
            ),

          // Estadísticas rápidas
          if (patientsState.status == PatientsStatus.success)
            Container(
              color: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${patientsState.patients.length} paciente(s)',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  if (patientsState.isSearching || patientsState.filters.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Filtrado',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (patientsState.filters.isNotEmpty || patientsState.searchQuery.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        patientsNotifier.clearFilters();
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Limpiar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
            ),

          // Lista de pacientes
          Expanded(
            child: _buildPatientsList(patientsState, patientsNotifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "patients_fab",
        onPressed: () => _showAddPatientDialog(context),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Paciente'),
      ),
    );
  }

  Widget _buildPatientsList(PatientsState state, PatientsNotifier notifier) {
    switch (state.status) {
      case PatientsStatus.initial:
      case PatientsStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando pacientes...'),
            ],
          ),
        );

      case PatientsStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar pacientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Error desconocido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => notifier.refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );

      case PatientsStatus.success:
        if (state.patients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.isSearching || state.filters.isNotEmpty
                      ? Icons.search_off
                      : Icons.people_outline,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  state.isSearching || state.filters.isNotEmpty
                      ? 'No se encontraron pacientes'
                      : 'No hay pacientes registrados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.isSearching || state.filters.isNotEmpty
                      ? 'Intenta con otros criterios de búsqueda'
                      : 'Agrega tu primer paciente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                if (!(state.isSearching || state.filters.isNotEmpty)) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddPatientDialog(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Agregar Paciente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => notifier.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.patients.length,
            itemBuilder: (context, index) {
              final patient = state.patients[index];
              return PatientCard(
                patient: patient,
                onTap: () => _showPatientDetails(context, patient),
                onEdit: () => _showEditPatientDialog(context, patient),
                onDelete: () => _showDeleteConfirmation(context, patient, notifier),
              );
            },
          ),
        );
    }
  }

  void _showAddPatientDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PatientFormDialog(
        title: 'Nuevo Paciente',
        onSave: (patient) async {
          final notifier = ref.read(patientsNotifierProvider.notifier);
          final result = await notifier.createPatient(patient);
          
          if (result != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paciente registrado exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.of(context).pop();
          } else if (context.mounted) {
            final errorMessage = ref.read(patientsNotifierProvider).errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage ?? 'Error al registrar paciente'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditPatientDialog(BuildContext context, PatientFirestore patient) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PatientFormDialog(
        title: 'Editar Paciente',
        patient: patient,
        onSave: (updatedPatient) async {
          final notifier = ref.read(patientsNotifierProvider.notifier);
          final result = await notifier.updatePatient(patient.id!, updatedPatient);
          
          if (result != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paciente actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (context.mounted) {
            final errorMessage = ref.read(patientsNotifierProvider).errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage ?? 'Error al actualizar paciente'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showPatientDetails(BuildContext context, PatientFirestore patient) {
    showDialog(
      context: context,
      builder: (context) => PatientDetailsDialog(
        patient: patient,
        onEdit: () {
          Navigator.of(context).pop();
          _showEditPatientDialog(context, patient);
        },
        onDelete: () {
          Navigator.of(context).pop();
          _showDeleteConfirmation(context, patient, ref.read(patientsNotifierProvider.notifier));
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PatientFirestore patient, PatientsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que deseas eliminar al paciente?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${patient.age} años • ${patient.sex}'),
                  Text(patient.fullAddress),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Esta acción no se puede deshacer.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await notifier.deletePatient(patient.id!);
              
              if (context.mounted) {
                Navigator.of(context).pop();
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paciente eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  final errorMessage = ref.read(patientsNotifierProvider).errorMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage ?? 'Error al eliminar paciente'),
                      backgroundColor: Colors.red,
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
} 