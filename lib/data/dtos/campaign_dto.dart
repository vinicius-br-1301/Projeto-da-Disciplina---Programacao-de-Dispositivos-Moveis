import '../../domain/entities/campaign.dart';
import '../../domain/entities/enums.dart';

class CampaignDto {
  final String id;
  final String mestreId;
  final String titulo;
  final String descricao;
  final String sistema;
  final String status;
  final int minJogadores;
  final int maxJogadores;
  final String capacidadeDescricao;
  final String criadaEm;

  const CampaignDto({
    required this.id,
    required this.mestreId,
    required this.titulo,
    required this.descricao,
    required this.sistema,
    required this.status,
    required this.minJogadores,
    required this.maxJogadores,
    required this.capacidadeDescricao,
    required this.criadaEm,
  });

  factory CampaignDto.fromJson(Map<String, dynamic> json) {
    return CampaignDto(
      id: json['id']?.toString() ?? '',
      mestreId: json['mestreId']?.toString() ?? '',
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      sistema: json['sistema'] as String? ?? '',
      status: json['status'] as String? ?? 'ATIVA',
      minJogadores: (json['minJogadores'] as num?)?.toInt() ?? 1,
      maxJogadores: (json['maxJogadores'] as num?)?.toInt() ?? 1,
      capacidadeDescricao: json['capacidadeDescricao'] as String? ?? '',
      criadaEm: json['criadaEm'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  factory CampaignDto.fromEntity(Campaign entity) {
    return CampaignDto(
      id: entity.id,
      mestreId: entity.mestreId,
      titulo: entity.titulo,
      descricao: entity.descricao,
      sistema: entity.sistema,
      status: entity.status.name,
      minJogadores: entity.minJogadores,
      maxJogadores: entity.maxJogadores,
      capacidadeDescricao: entity.capacidadeDescricao,
      criadaEm: entity.criadaEm.toIso8601String(),
    );
  }

  // Formato esperado pelo CampaignRequestDTO no Spring Boot
  Map<String, dynamic> toRequestJson() {
    return {
      'mestreId': mestreId,
      'titulo': titulo,
      'descricao': descricao,
      'sistema': sistema,
      'minJogadores': minJogadores,
      'maxJogadores': maxJogadores,
    };
  }

  Campaign toEntity() {
    return Campaign(
      id: id,
      mestreId: mestreId,
      titulo: titulo,
      descricao: descricao,
      sistema: sistema,
      status: StatusEnum.values.firstWhere(
        (e) => e.name.toUpperCase() == status.toUpperCase(),
        orElse: () => StatusEnum.ATIVA,
      ),
      minJogadores: minJogadores,
      maxJogadores: maxJogadores,
      capacidadeDescricao: capacidadeDescricao,
      criadaEm: DateTime.tryParse(criadaEm) ?? DateTime.now(),
    );
  }
}
