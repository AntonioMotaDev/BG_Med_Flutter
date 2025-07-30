import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'escalas_obstetricas.g.dart';

@HiveType(typeId: 23)
class EscalasObstetricas extends Equatable {
  @HiveField(0)
  final Map<String, int> silvermanAnderson; // minuto, 3min, 5min, 10min
  @HiveField(1)
  final Map<String, int> apgar; // minuto, 3min, 5min, 10min
  @HiveField(2)
  final int frecuenciaCardiacaFetal;
  @HiveField(3)
  final String contracciones; // formato dinámico

  const EscalasObstetricas({
    this.silvermanAnderson = const {},
    this.apgar = const {},
    this.frecuenciaCardiacaFetal = 0,
    this.contracciones = '',
  });

  EscalasObstetricas copyWith({
    Map<String, int>? silvermanAnderson,
    Map<String, int>? apgar,
    int? frecuenciaCardiacaFetal,
    String? contracciones,
  }) {
    return EscalasObstetricas(
      silvermanAnderson: silvermanAnderson ?? this.silvermanAnderson,
      apgar: apgar ?? this.apgar,
      frecuenciaCardiacaFetal: frecuenciaCardiacaFetal ?? this.frecuenciaCardiacaFetal,
      contracciones: contracciones ?? this.contracciones,
    );
  }

  Map<String, dynamic> toJson() => {
    'silvermanAnderson': silvermanAnderson,
    'apgar': apgar,
    'frecuenciaCardiacaFetal': frecuenciaCardiacaFetal,
    'contracciones': contracciones,
  };

  @override
  List<Object?> get props => [silvermanAnderson, apgar, frecuenciaCardiacaFetal, contracciones];
} 