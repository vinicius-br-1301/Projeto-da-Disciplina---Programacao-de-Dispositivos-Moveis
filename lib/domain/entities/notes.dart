import 'enums.dart';

class Notes {
  final String id;
  final String? campaignId;
  final String sessionId;
  final String authorId;
  final String titulo;
  final PostItCat categoria;
  final RoleEnum visibilidade;
  final bool fixado;
  final String conteudo;
  final DateTime criadoEm;

  const Notes({
    required this.id,
    this.campaignId,
    required this.sessionId,
    required this.authorId,
    required this.titulo,
    required this.categoria,
    required this.visibilidade,
    required this.fixado,
    required this.conteudo,
    required this.criadoEm,
  });
}
