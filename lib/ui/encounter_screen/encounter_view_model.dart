import 'package:flutter/foundation.dart';

import '../../domain/entities/encounter.dart';
import '../../domain/repositories/encounter_repository_interface.dart';

class EncounterViewModel extends ChangeNotifier {
  final EncounterRepositoryInterface _repository;

  EncounterViewModel(this._repository);

  final List<int> _niveisJogadores = [];
  final List<int> _xpMonstros = [];

  EncounterResponse? _resultado;
  bool _isLoading = false;
  String? _errorMessage;

  List<int> get niveisJogadores => List.unmodifiable(_niveisJogadores);
  List<int> get xpMonstros => List.unmodifiable(_xpMonstros);
  EncounterResponse? get resultado => _resultado;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void adicionarJogador(int nivel) {
    _niveisJogadores.add(nivel);
    _errorMessage = null;
    notifyListeners();
  }

  void removerJogador(int index) {
    if (index >= 0 && index < _niveisJogadores.length) {
      _niveisJogadores.removeAt(index);
      notifyListeners();
    }
  }

  void adicionarMonstro(int xp) {
    _xpMonstros.add(xp);
    _errorMessage = null;
    notifyListeners();
  }

  void removerMonstro(int index) {
    if (index >= 0 && index < _xpMonstros.length) {
      _xpMonstros.removeAt(index);
      notifyListeners();
    }
  }

  void limpar() {
    _niveisJogadores.clear();
    _xpMonstros.clear();
    _resultado = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> calcularEncontro() async {
    if (_niveisJogadores.isEmpty || _xpMonstros.isEmpty) {
      _errorMessage =
          'Adicione pelo menos 1 jogador e 1 monstro antes de calcular.';
      _resultado = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _resultado = null;
    notifyListeners();

    try {
      final request = EncounterRequest(
        niveisJogadores: List<int>.from(_niveisJogadores),
        xpMonstros: List<int>.from(_xpMonstros),
      );
      _resultado = await _repository.calcularEncontro(request);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
