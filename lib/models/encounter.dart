class EncounterRequest {
  final List<int> niveisJogadores;
  final List<int> xpMonstros;

  const EncounterRequest({
    required this.niveisJogadores,
    required this.xpMonstros,
  });

  Map<String, dynamic> toJson() {
    return {'niveisJogadores': niveisJogadores, 'xpMonstros': xpMonstros};
  }
}

class EncounterResponse {
  final String dificuldadeFinal;
  final int xpAjustado;
  final Map<String, int> limitesGrupo;

  const EncounterResponse({
    required this.dificuldadeFinal,
    required this.xpAjustado,
    required this.limitesGrupo,
  });

  factory EncounterResponse.fromJson(Map<String, dynamic> json) {
    final rawLimites = json['limitesGrupo'] as Map<String, dynamic>? ?? {};
    final limites = rawLimites.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );

    return EncounterResponse(
      dificuldadeFinal: json['dificuldadeFinal'] as String? ?? '',
      xpAjustado: (json['xpAjustado'] as num?)?.toInt() ?? 0,
      limitesGrupo: limites,
    );
  }
}
