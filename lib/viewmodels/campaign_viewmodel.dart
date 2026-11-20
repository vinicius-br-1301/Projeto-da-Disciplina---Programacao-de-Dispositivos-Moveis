import 'package:flutter/foundation.dart';

import '../models/campaign.dart';
import '../services/campaign_service.dart';

class CampaignViewModel extends ChangeNotifier {
  final CampaignService _service = CampaignService();

  List<Campaign> _campaigns = [];
  List<Campaign> get campaigns => List.unmodifiable(_campaigns);

  bool isLoading = false;
  String? errorMessage;
  String? ultimoSessionId;

  Future<void> carregarCampanhas({String? titulo}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      _campaigns = await _service.listarCampanhas(titulo: titulo);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarCampanha(Map<String, dynamic> body) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final nova = await _service.criar(body);
      _campaigns.insert(0, nova);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarCampanha(String id, Map<String, dynamic> body) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final atualizada = await _service.atualizar(id, body);
      _substituirNaLista(atualizada);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletarCampanha(String id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _service.deletar(id);
      _campaigns.removeWhere((c) => c.id == id);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pausarCampanha(String id) async {
    return _executarTransicao(() => _service.pausar(id));
  }

  Future<bool> reativarCampanha(String id) async {
    return _executarTransicao(() => _service.reativar(id));
  }

  Future<bool> encerrarCampanha(String id) async {
    return _executarTransicao(() => _service.encerrar(id));
  }

  Future<String?> iniciarSessao(String id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final sessionId = await _service.iniciarSessao(id);
      ultimoSessionId = sessionId;
      return sessionId;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _executarTransicao(Future<Campaign> Function() acao) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final atualizada = await acao();
      _substituirNaLista(atualizada);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _substituirNaLista(Campaign atualizada) {
    final index = _campaigns.indexWhere((c) => c.id == atualizada.id);
    if (index != -1) {
      _campaigns[index] = atualizada;
    }
  }
}
