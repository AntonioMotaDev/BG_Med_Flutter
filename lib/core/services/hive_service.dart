import 'package:hive_flutter/hive_flutter.dart';
import 'package:bg_med/core/models/frap.dart';

class HiveService {
  static const String _frapBoxName = 'fraps';
  
  // Verificar si la caja está disponible
  static bool isBoxAvailable(String boxName) {
    try {
      return Hive.isBoxOpen(boxName);
    } catch (e) {
      print('Error verificando disponibilidad de caja $boxName: $e');
      return false;
    }
  }
  
  // Obtener la caja de FRAP de manera segura
  static Box<Frap>? getFrapBox() {
    try {
      if (isBoxAvailable(_frapBoxName)) {
        return Hive.box<Frap>(_frapBoxName);
      }
      return null;
    } catch (e) {
      print('Error obteniendo caja de FRAP: $e');
      return null;
    }
  }
  
  // Abrir la caja de FRAP de manera segura
  static Future<Box<Frap>?> openFrapBox() async {
    try {
      if (!isBoxAvailable(_frapBoxName)) {
        return await Hive.openBox<Frap>(_frapBoxName);
      }
      return Hive.box<Frap>(_frapBoxName);
    } catch (e) {
      print('Error abriendo caja de FRAP: $e');
      return null;
    }
  }
  
  // Obtener todos los registros FRAP de manera segura
  static List<Frap> getAllFrapRecords() {
    try {
      final box = getFrapBox();
      if (box != null) {
        return box.values.toList();
      }
      return [];
    } catch (e) {
      print('Error obteniendo registros FRAP: $e');
      return [];
    }
  }
  
  // Agregar un registro FRAP de manera segura
  static Future<bool> addFrapRecord(Frap frap) async {
    try {
      final box = getFrapBox();
      if (box != null) {
        await box.add(frap);
        return true;
      }
      return false;
    } catch (e) {
      print('Error agregando registro FRAP: $e');
      return false;
    }
  }
  
  // Limpiar todos los registros FRAP de manera segura
  static Future<bool> clearFrapRecords() async {
    try {
      final box = getFrapBox();
      if (box != null) {
        await box.clear();
        return true;
      }
      return false;
    } catch (e) {
      print('Error limpiando registros FRAP: $e');
      return false;
    }
  }
} 