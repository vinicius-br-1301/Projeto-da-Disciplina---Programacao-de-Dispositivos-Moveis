import '../../domain/entities/enums.dart';
import '../../domain/entities/notes.dart';

class NotesDto {
  final String id;
  final String? campaignId;
  final String sessionId;
  final String authorId;
  final String titulo;
  final String categoria;
  final String visibilidade;
  final bool fixado;
  final String conteudo;
  final String criadoEm;

  const NotesDto({
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

  factory NotesDto.fromJson(Map<String, dynamic> json) {
    return NotesDto(
      id: json['id']?.toString() ?? '',
      campaignId: json['campaignId']?.toString(),
      sessionId: json['sessionId']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      titulo: json['titulo'] as String? ?? '',
      categoria: json['categoria'] as String? ?? 'LORE',
      visibilidade: json['visibilidade'] as String? ?? 'JOGADOR',
      fixado: json['fixado'] as bool? ?? false,
      conteudo: json['conteudo'] as String? ?? '',
      criadoEm: json['criadoEm'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  factory NotesDto.fromEntity(Notes entity) {
    return NotesDto(
      id: entity.id,
      campaignId: entity.campaignId,
      sessionId: entity.sessionId,
      authorId: entity.authorId,
      titulo: entity.titulo,
      categoria: entity.categoria.name,
      visibilidade: entity.visibilidade.name,
      fixado: entity.fixado,
      conteudo: entity.conteudo,
      criadoEm: entity.criadoEm.toIso8601String(),
    );
  }

  // Formato esperado pelo NotesRequestDTO no Spring Boot
  Map<String, dynamic> toRequestJson() {
    return {
      'campaignId': campaignId ?? '',
      'sessionId': sessionId,
      'authorId': authorId,
      'titulo': titulo,
      'categoria': categoria,
      'visibilidade': visibilidade,
      'fixado': fixado,
      'conteudo': conteudo,
    };
  }

  Notes toEntity() {
    return Notes(
      id: id,
      campaignId: campaignId,
      sessionId: sessionId,
      authorId: authorId,
      titulo: titulo,
      categoria: PostItCat.values.firstWhere(
        (e) => e.name.toUpperCase() == categoria.toUpperCase(),
        orElse: () => PostItCat.LORE,
      ),
      visibilidade: RoleEnum.values.firstWhere(
        (e) => e.name.toUpperCase() == visibilidade.toUpperCase(),
        orElse: () => RoleEnum.JOGADOR,
      ),
      fixado: fixado,
      conteudo: conteudo,
      criadoEm: DateTime.tryParse(criadoEm) ?? DateTime.now(),
    );
  }
}
