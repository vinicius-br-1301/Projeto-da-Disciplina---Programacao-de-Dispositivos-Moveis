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
}
