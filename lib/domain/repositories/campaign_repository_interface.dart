import '../entities/campaign.dart';

abstract class CampaignRepositoryInterface {
  Future<List<Campaign>> listarCampanhas({
    String? titulo,
    int page = 0,
    int size = 10,
  });

  Future<Campaign> buscarPorId(String id);
  Future<Campaign> criar(Campaign campaign);
  Future<Campaign> atualizar(String id, Campaign campaign);
  Future<void> deletar(String id);
  Future<Campaign> pausar(String id);
  Future<Campaign> reativar(String id);
  Future<Campaign> encerrar(String id);
  Future<String> iniciarSessao(String id);
}
