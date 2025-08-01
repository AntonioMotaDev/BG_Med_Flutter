import 'package:bg_med/core/theme/app_theme.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agenda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        foregroundColor: AppTheme.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _focusedDate = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Widget
          Container(
            child: _buildCalendar(),
          ),
          
          // Selected Date Activities
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Actividades del ${_formatSelectedDate()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildActivitiesList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "calendar_fab",
        onPressed: _showAddEventDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month/Year Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(
                      _focusedDate.year,
                      _focusedDate.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                _getMonthYear(_focusedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(
                      _focusedDate.year,
                      _focusedDate.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Days of Week Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // Calendar Days
          _buildCalendarDays(),
        ],
      ),
    );
  }

  /// Calendario mejorado, visualmente atractivo y compatible con tema claro/oscuro
  Widget _buildCalendarDays() {
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstWeekday = (firstDayOfMonth.weekday + 6) % 7; // Lunes=0, Domingo=6

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getSelectedColor() => isDark ? AppTheme.primaryBlue.withOpacity(0.85) : AppTheme.primaryBlue;
    Color getTodayBgColor() => isDark ? AppTheme.primaryBlue.withOpacity(0.18) : AppTheme.primaryBlue.withOpacity(0.12);
    Color getDayTextColor({required bool isSelected, required bool isToday}) {
      if (isSelected) return Colors.white;
      if (isToday) return AppTheme.primaryBlue;
      return isDark ? Colors.white : Colors.black87;
    }
    Color getBorderColor({required bool isSelected, required bool hasActivity}) {
      if (isSelected) return getSelectedColor();
      if (hasActivity) return AppTheme.primaryBlue.withOpacity(isDark ? 0.9 : 0.7);
      return isDark ? Colors.grey[700]! : Colors.grey[300]!;
    }
    Color getDotColor({required bool isSelected}) =>
        isSelected ? Colors.white : AppTheme.primaryBlue;

    List<Widget> dayWidgets = [];

    // Celdas vacías antes del primer día del mes
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 48, height: 48));
    }

    // Días del mes
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      final isSelected = _isSameDay(date, _selectedDate);
      final isToday = _isSameDay(date, DateTime.now());
      final hasActivity = _hasActivityOnDate(date);

      dayWidgets.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? getSelectedColor()
                : isToday
                    ? getTodayBgColor()
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: getBorderColor(isSelected: isSelected, hasActivity: hasActivity),
              width: isSelected ? 2.5 : hasActivity ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: getSelectedColor().withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: getDayTextColor(isSelected: isSelected, isToday: isToday),
                      fontSize: 18,
                    ),
                  ),
                  if (hasActivity)
                    Positioned(
                      bottom: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: getDotColor(isSelected: isSelected),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Completar la última fila con celdas vacías si es necesario
    int totalCells = dayWidgets.length;
    int remainder = totalCells % 7;
    if (remainder != 0) {
      for (int i = 0; i < 7 - remainder; i++) {
        dayWidgets.add(const SizedBox(width: 48, height: 48));
      }
    }

    // Crear filas de 7 días cada una
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: dayWidgets.sublist(i, i + 7),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget _buildActivitiesList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Frap>('fraps').listenable(),
      builder: (context, Box<Frap> box, _) {
        try {
          final activitiesOnDate = box.values
              .where((frap) => _isSameDay(frap.createdAt, _selectedDate))
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          if (activitiesOnDate.isEmpty) {
            return _buildEmptyDayState();
          }

          return ListView.builder(
            itemCount: activitiesOnDate.length,
            itemBuilder: (context, index) {
              final frap = activitiesOnDate[index];
              return _buildActivityCard(frap);
            },
          );
        } catch (e) {
          // Si hay error con la caja de Hive, mostrar estado vacío
          return _buildEmptyDayState();
        }
      },
    );
  }

  Widget _buildEmptyDayState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay actividades programadas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'para ${_formatSelectedDate()}',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddEventDialog,
            icon: const Icon(Icons.add),
            label: const Text('Programar Cita'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Frap frap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          'FRAP - ${frap.patient.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
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
                  '${frap.createdAt.hour.toString().padLeft(2, '0')}:${frap.createdAt.minute.toString().padLeft(2, '0')}',
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
                  '${frap.patient.age} años • ${frap.patient.sex}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _showFrapDetails(frap);
                break;
              case 'edit':
                // TODO: Navigate to edit
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Ver detalles'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _hasActivityOnDate(DateTime date) {
    final box = Hive.box<Frap>('fraps');
    return box.values.any((frap) => _isSameDay(frap.createdAt, date));
  }

  String _getMonthYear(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedDate() {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${_selectedDate.day} de ${months[_selectedDate.month - 1]} de ${_selectedDate.year}';
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fecha: ${_formatSelectedDate()}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta funcionalidad estará disponible en futuras versiones para programar citas y recordatorios.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función en desarrollo'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Programar'),
          ),
        ],
      ),
    );
  }

  void _showFrapDetails(Frap frap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('FRAP - ${frap.patient.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Paciente', frap.patient.name),
              _buildDetailRow('Edad', '${frap.patient.age} años'),
              _buildDetailRow('Sexo', frap.patient.sex),
              _buildDetailRow('Dirección', frap.patient.address),
              const SizedBox(height: 16),
              Text(
                'Historia Clínica',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Alergias', 
                frap.clinicalHistory.allergies.isEmpty 
                  ? 'Ninguna' 
                  : frap.clinicalHistory.allergies),
              _buildDetailRow('Medicamentos', 
                frap.clinicalHistory.medications.isEmpty 
                  ? 'Ninguno' 
                  : frap.clinicalHistory.medications),
              const SizedBox(height: 16),
              Text(
                'Fecha y hora del registro:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${frap.createdAt.day}/${frap.createdAt.month}/${frap.createdAt.year} ${frap.createdAt.hour.toString().padLeft(2, '0')}:${frap.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 