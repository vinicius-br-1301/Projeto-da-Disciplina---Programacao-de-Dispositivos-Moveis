import 'package:flutter/foundation.dart';

import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaign_repository_interface.dart';

class CampaignViewModel extends ChangeNotifier {
  final CampaignRepositoryInterface _repository;

  CampaignViewModel(this._repository);

  List<Campaign> _campaigns = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _ultimoSessionId;

  List<Campaign> get campaigns => List.unmodifiable(_campaigns);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get ultimoSessionId => _ultimoSessionId;

  Future<void> carregarCampanhas({
    String? titulo,
    int page = 0,
    int size = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _campaigns = await _repository.listarCampanhas(
        titulo: titulo,
        page: page,
        size: size,
      );
    } catch (e) {
      _errorMessage = _formatarErro(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarCampanha(Campaign campaign) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final criada = await _repository.criar(campaign);
      _campaigns = [criada, ..._campaigns];
      return true;
    } catch (e) {
      _errorMessage = _formatarErro(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarCampanha(String id, Campaign campaign) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final atualizada = await _repository.atualizar(id, campaign);
      _substituirNaLista(atualizada);
      return true;
    } catch (e) {
      _errorMessage = _formatarErro(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletarCampanha(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deletar(id);
      _campaigns = _campaigns.where((c) => c.id != id).toList();
      return true;
    } catch (e) {
      _errorMessage = _formatarErro(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pausarCampanha(String id) async {
    return _executarTransicao(() => _repository.pausar(id));
  }

  Future<bool> reativarCampanha(String id) async {
    return _executarTransicao(() => _repository.reativar(id));
  }

  Future<bool> encerrarCampanha(String id) async {
    return _executarTransicao(() => _repository.encerrar(id));
  }

  Future<String?> iniciarSessao(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionId = await _repository.iniciarSessao(id);
      _ultimoSessionId = sessionId;
      return sessionId;
    } catch (e) {
      _errorMessage = _formatarErro(e);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _executarTransicao(Future<Campaign> Function() acao) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final atualizada = await acao();
      _substituirNaLista(atualizada);
      return true;
    } catch (e) {
      _errorMessage = _formatarErro(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _substituirNaLista(Campaign atualizada) {
    final index = _campaigns.indexWhere((c) => c.id == atualizada.id);
    if (index != -1) {
      final novaLista = List<Campaign>.from(_campaigns);
      novaLista[index] = atualizada;
      _campaigns = novaLista;
    }
  }

  String _formatarErro(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }
}
