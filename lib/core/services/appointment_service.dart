import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:bg_med/core/models/appointment.dart';

class AppointmentService {
  static const String _boxName = 'appointments';
  Box<Appointment>? _appointmentBox;

  // Obtener la caja de Hive de forma segura
  Future<Box<Appointment>> get _getAppointmentBox async {
    if (_appointmentBox != null && _appointmentBox!.isOpen) {
      return _appointmentBox!;
    }

    if (Hive.isBoxOpen(_boxName)) {
      _appointmentBox = Hive.box<Appointment>(_boxName);
      return _appointmentBox!;
    }

    try {
      _appointmentBox = await Hive.openBox<Appointment>(_boxName);
      return _appointmentBox!;
    } catch (e) {
      throw Exception('Error al abrir la caja de citas: $e');
    }
  }

  // Generar ID único para citas
  String _generateId() {
    return const Uuid().v4();
  }

  // CREAR una nueva cita
  Future<String?> createAppointment({
    required String title,
    required String description,
    required DateTime dateTime,
    required String patientName,
    String? patientPhone,
    String? patientAddress,
    String? appointmentType,
    String? notes,
  }) async {
    try {
      final appointment = Appointment(
        id: _generateId(),
        title: title,
        description: description,
        dateTime: dateTime,
        patientName: patientName,
        patientPhone: patientPhone ?? '',
        patientAddress: patientAddress ?? '',
        appointmentType: appointmentType ?? 'consulta',
        notes: notes ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final box = await _getAppointmentBox;
      await box.add(appointment);

      return appointment.id;
    } catch (e) {
      throw Exception('Error al crear la cita: $e');
    }
  }

  // OBTENER todas las citas
  Future<List<Appointment>> getAllAppointments() async {
    try {
      final box = await _getAppointmentBox;
      final appointments = box.values.toList();

      // Ordenar por fecha y hora
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      return appointments;
    } catch (e) {
      throw Exception('Error al obtener las citas: $e');
    }
  }

  // OBTENER citas por fecha
  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    try {
      final allAppointments = await getAllAppointments();

      return allAppointments.where((appointment) {
        return appointment.dateTime.year == date.year &&
            appointment.dateTime.month == date.month &&
            appointment.dateTime.day == date.day;
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener citas por fecha: $e');
    }
  }

  // OBTENER una cita por ID
  Future<Appointment?> getAppointmentById(String id) async {
    try {
      final box = await _getAppointmentBox;
      return box.values.firstWhere(
        (appointment) => appointment.id == id,
        orElse: () => throw Exception('Cita no encontrada'),
      );
    } catch (e) {
      return null;
    }
  }

  // ACTUALIZAR una cita
  Future<void> updateAppointment({
    required String id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? patientName,
    String? patientPhone,
    String? patientAddress,
    String? appointmentType,
    String? status,
    String? notes,
  }) async {
    try {
      final appointment = await getAppointmentById(id);
      if (appointment == null) {
        throw Exception('Cita no encontrada');
      }

      final updatedAppointment = appointment.copyWith(
        title: title,
        description: description,
        dateTime: dateTime,
        patientName: patientName,
        patientPhone: patientPhone,
        patientAddress: patientAddress,
        appointmentType: appointmentType,
        status: status,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      final box = await _getAppointmentBox;
      final index = box.values.toList().indexWhere((a) => a.id == id);
      await box.putAt(index, updatedAppointment);
    } catch (e) {
      throw Exception('Error al actualizar la cita: $e');
    }
  }

  // ELIMINAR una cita
  Future<void> deleteAppointment(String id) async {
    try {
      final box = await _getAppointmentBox;
      final index = box.values.toList().indexWhere((a) => a.id == id);

      if (index == -1) {
        throw Exception('Cita no encontrada');
      }

      await box.deleteAt(index);
    } catch (e) {
      throw Exception('Error al eliminar la cita: $e');
    }
  }

  // OBTENER estadísticas de citas
  Future<Map<String, dynamic>> getAppointmentStatistics() async {
    try {
      final appointments = await getAllAppointments();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return {
        'total': appointments.length,
        'today':
            appointments.where((a) {
              final appointmentDate = DateTime(
                a.dateTime.year,
                a.dateTime.month,
                a.dateTime.day,
              );
              return appointmentDate.isAtSameMomentAs(today);
            }).length,
        'pending': appointments.where((a) => a.status == 'programada').length,
        'confirmed': appointments.where((a) => a.status == 'confirmada').length,
        'completed': appointments.where((a) => a.status == 'completada').length,
        'cancelled': appointments.where((a) => a.status == 'cancelada').length,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}
