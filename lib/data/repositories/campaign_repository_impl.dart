import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository_interface.dart';
import '../dtos/campaign_dto.dart';
import '../services/campaign_service.dart';

class CampaignRepositoryImpl implements CampaignRepositoryInterface {
  final CampaignService _service;

  CampaignRepositoryImpl(this._service);

  @override
  Future<List<Campaign>> listarCampanhas({
    String? titulo,
    int page = 0,
    int size = 10,
  }) async {
    final dtos = await _service.listarCampanhas(
      titulo: titulo,
      page: page,
      size: size,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Campaign> buscarPorId(String id) async {
    final dto = await _service.buscarPorId(id);
    return dto.toEntity();
  }

  @override
  Future<Campaign> criar(Campaign campaign) async {
    final dto = await _service.criar(CampaignDto.fromEntity(campaign));
    return dto.toEntity();
  }

  @override
  Future<Campaign> atualizar(String id, Campaign campaign) async {
    final dto = await _service.atualizar(id, CampaignDto.fromEntity(campaign));
    return dto.toEntity();
  }

  @override
  Future<void> deletar(String id) {
    return _service.deletar(id);
  }

  @override
  Future<Campaign> pausar(String id) async {
    final dto = await _service.pausar(id);
    return dto.toEntity();
  }

  @override
  Future<Campaign> reativar(String id) async {
    final dto = await _service.reativar(id);
    return dto.toEntity();
  }

  @override
  Future<Campaign> encerrar(String id) async {
    final dto = await _service.encerrar(id);
    return dto.toEntity();
  }

  @override
  Future<String> iniciarSessao(String id) {
    return _service.iniciarSessao(id);
  }
}
