import 'enums.dart';

class Campaign {
  final String id;
  final String mestreId;
  final String titulo;
  final String descricao;
  final String sistema;
  final StatusEnum status;
  final int minJogadores;
  final int maxJogadores;
  final String capacidadeDescricao;
  final DateTime criadaEm;

  const Campaign({
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

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id']?.toString() ?? '',
      mestreId: json['mestreId']?.toString() ?? '',
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      sistema: json['sistema'] as String? ?? '',
      status: StatusEnum.fromJson(json['status'] as String? ?? 'ATIVA'),
      minJogadores: (json['minJogadores'] as num?)?.toInt() ?? 1,
      maxJogadores: (json['maxJogadores'] as num?)?.toInt() ?? 1,
      capacidadeDescricao: json['capacidadeDescricao'] as String? ?? '',
      criadaEm: json['criadaEm'] != null
          ? DateTime.parse(json['criadaEm'] as String)
          : DateTime.now(),
    );
  }

  // formato do DTO
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
}
