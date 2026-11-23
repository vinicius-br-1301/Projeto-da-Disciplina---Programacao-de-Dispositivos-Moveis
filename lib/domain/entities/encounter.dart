class EncounterRequest {
  final List<int> niveisJogadores;
  final List<int> xpMonstros;

  const EncounterRequest({
    required this.niveisJogadores,
    required this.xpMonstros,
  });
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
}
