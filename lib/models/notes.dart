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

  factory Notes.fromJson(Map<String, dynamic> json) {
    return Notes(
      id: json['id']?.toString() ?? '',
      campaignId: json['campaignId']?.toString(),
      sessionId: json['sessionId']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      titulo: json['titulo'] as String? ?? '',
      categoria: PostItCat.fromJson(json['categoria'] as String? ?? 'LORE'),
      visibilidade: RoleEnum.fromJson(
        json['visibilidade'] as String? ?? 'JOGADOR',
      ),
      fixado: json['fixado'] as bool? ?? false,
      conteudo: json['conteudo'] as String? ?? '',
      criadoEm: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : DateTime.now(),
    );
  }

  // formato exato do DTO
  Map<String, dynamic> toRequestJson({required String campaignId}) {
    return {
      'campaignId': campaignId,
      'sessionId': sessionId,
      'authorId': authorId,
      'titulo': titulo,
      'categoria': categoria.name,
      'visibilidade': visibilidade.name,
      'fixado': fixado,
      'conteudo': conteudo,
    };
  }
}
