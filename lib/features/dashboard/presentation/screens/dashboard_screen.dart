import 'package:bg_med/features/dashboard/presentation/screens/home_tab.dart';
import 'package:bg_med/features/dashboard/presentation/screens/patients_tab.dart';
import 'package:bg_med/features/dashboard/presentation/screens/records_tab.dart';
import 'package:bg_med/features/dashboard/presentation/screens/calendar_tab.dart';
import 'package:bg_med/features/dashboard/presentation/screens/settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  
  const DashboardScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late int _currentIndex;

  final List<Widget> _tabs = [
    const HomeTab(),
    const PatientsTab(),
    const RecordsTab(),
    const CalendarTab(),
    const SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Validar que el índice inicial esté dentro del rango válido
    _currentIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pacientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Registros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
} 