import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/notes.dart';
import '../services/notes_service.dart';

class NotesViewModel extends ChangeNotifier {
  final NotesService _service = NotesService();

  List<Notes> _notes = [];
  List<Notes> get notes => List.unmodifiable(_notes);

  bool isLoading = false;
  String? errorMessage;
  PostItCat? filtroCategoria;

  Future<void> carregarNotas({String? titulo, PostItCat? categoria}) async {
    try {
      isLoading = true;
      errorMessage = null;
      filtroCategoria = categoria;
      notifyListeners();

      _notes = await _service.buscarTodos(titulo: titulo, categoria: categoria);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarNota(Map<String, dynamic> body) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final nova = await _service.criar(body);
      _notes.insert(0, nova);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarNota(String id, Map<String, dynamic> body) async {
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

  Future<bool> deletarNota(String id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _service.deletar(id);
      _notes.removeWhere((n) => n.id == id);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> alternarFixacao(String id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final atualizada = await _service.alternarFixacao(id);
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

  void _substituirNaLista(Notes atualizada) {
    final index = _notes.indexWhere((n) => n.id == atualizada.id);
    if (index != -1) {
      _notes[index] = atualizada;
    }
  }
}
