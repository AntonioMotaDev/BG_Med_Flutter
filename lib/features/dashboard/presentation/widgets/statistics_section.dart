import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/features/patients/presentation/providers/patients_provider.dart';
import 'package:bg_med/features/frap/presentation/screens/frap_records_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StatisticsSection extends ConsumerWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsState = ref.watch(patientsNotifierProvider);

    return ValueListenableBuilder(
      valueListenable: Hive.box<Frap>('fraps').listenable(),
      builder: (context, Box<Frap> box, _) {
        // Estadísticas de FRAP
        final totalFrapRecords = box.values.length;
        final todayFrapRecords = box.values
            .where((frap) =>
                frap.createdAt.day == DateTime.now().day &&
                frap.createdAt.month == DateTime.now().month &&
                frap.createdAt.year == DateTime.now().year)
            .length;

        // Estadísticas de Pacientes
        int totalPatients = 0;
        int todayPatients = 0;
        
        if (patientsState.status == PatientsStatus.success) {
          totalPatients = patientsState.patients.length;
          todayPatients = patientsState.patients
              .where((patient) =>
                  patient.createdAt.day == DateTime.now().day &&
                  patient.createdAt.month == DateTime.now().month &&
                  patient.createdAt.year == DateTime.now().year)
              .length;
        }

        return Column(
          children: [
            // Primera fila: Registros FRAP
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Registros FRAP',
                    totalFrapRecords.toString(),
                    Icons.assignment_outlined,
                    AppTheme.primaryBlue,
                    onTap: () => _navigateToFrapRecords(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'FRAP Hoy',
                    todayFrapRecords.toString(),
                    Icons.today,
                    AppTheme.primaryGreen,
                    onTap: () => _navigateToFrapRecords(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Segunda fila: Pacientes
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Pacientes',
                    totalPatients.toString(),
                    Icons.people_outlined,
                    Colors.purple[600]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pacientes Hoy',
                    todayPatients.toString(),
                    Icons.person_add,
                    Colors.orange[600]!,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title, 
    String value, 
    IconData icon, 
    Color color, {
    VoidCallback? onTap,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: onTap != null ? [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }

  void _navigateToFrapRecords(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FrapRecordsListScreen(),
      ),
    );
  }
} 