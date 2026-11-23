import '../../domain/entities/encounter.dart';

class EncounterRequestDto {
  final List<int> niveisJogadores;
  final List<int> xpMonstros;

  const EncounterRequestDto({
    required this.niveisJogadores,
    required this.xpMonstros,
  });

  factory EncounterRequestDto.fromEntity(EncounterRequest entity) {
    return EncounterRequestDto(
      niveisJogadores: List<int>.from(entity.niveisJogadores),
      xpMonstros: List<int>.from(entity.xpMonstros),
    );
  }

  Map<String, dynamic> toJson() {
    return {'niveisJogadores': niveisJogadores, 'xpMonstros': xpMonstros};
  }
}

class EncounterResponseDto {
  final String dificuldadeFinal;
  final int xpAjustado;
  final Map<String, int> limitesGrupo;

  const EncounterResponseDto({
    required this.dificuldadeFinal,
    required this.xpAjustado,
    required this.limitesGrupo,
  });

  factory EncounterResponseDto.fromJson(Map<String, dynamic> json) {
    final rawLimites = json['limitesGrupo'] as Map<String, dynamic>? ?? {};
    final limites = rawLimites.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );

    return EncounterResponseDto(
      dificuldadeFinal: json['dificuldadeFinal'] as String? ?? '',
      xpAjustado: (json['xpAjustado'] as num?)?.toInt() ?? 0,
      limitesGrupo: limites,
    );
  }

  EncounterResponse toEntity() {
    return EncounterResponse(
      dificuldadeFinal: dificuldadeFinal,
      xpAjustado: xpAjustado,
      limitesGrupo: limitesGrupo,
    );
  }
}
