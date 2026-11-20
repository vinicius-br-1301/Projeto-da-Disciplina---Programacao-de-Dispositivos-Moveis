import 'package:flutter/foundation.dart';

import '../models/encounter.dart';
import '../services/encounter_calculator_service.dart';

class EncounterViewModel extends ChangeNotifier {
  final EncounterCalculatorService _service = EncounterCalculatorService();

  final List<int> _niveisJogadores = [];
  final List<int> _xpMonstros = [];

  List<int> get niveisJogadores => List.unmodifiable(_niveisJogadores);
  List<int> get xpMonstros => List.unmodifiable(_xpMonstros);

  EncounterResponse? resultado;
  bool isLoading = false;
  String? errorMessage;

  void adicionarJogador(int nivel) {
    if (nivel < 1) return;
    _niveisJogadores.add(nivel);
    resultado = null;
    errorMessage = null;
    notifyListeners();
  }

  void removerJogador(int index) {
    if (index >= 0 && index < _niveisJogadores.length) {
      _niveisJogadores.removeAt(index);
      resultado = null;
      notifyListeners();
    }
  }

  void adicionarMonstro(int xp) {
    if (xp < 0) return;
    _xpMonstros.add(xp);
    resultado = null;
    errorMessage = null;
    notifyListeners();
  }

  void removerMonstro(int index) {
    if (index >= 0 && index < _xpMonstros.length) {
      _xpMonstros.removeAt(index);
      resultado = null;
      notifyListeners();
    }
  }

  void limpar() {
    _niveisJogadores.clear();
    _xpMonstros.clear();
    resultado = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> calcularEncontro() async {
    if (_niveisJogadores.isEmpty || _xpMonstros.isEmpty) {
      errorMessage =
          'Adicione pelo menos 1 jogador e 1 monstro antes de calcular.';
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final request = EncounterRequest(
        niveisJogadores: List.from(_niveisJogadores),
        xpMonstros: List.from(_xpMonstros),
      );
      resultado = await _service.calcularEncontro(request);
    } catch (e) {
      errorMessage = e.toString();
      resultado = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
