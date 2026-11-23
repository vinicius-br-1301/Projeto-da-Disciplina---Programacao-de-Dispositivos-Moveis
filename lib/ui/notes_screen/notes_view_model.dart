import 'package:flutter/foundation.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/notes.dart';
import '../../domain/repositories/notes_repository_interface.dart';

class NotesViewModel extends ChangeNotifier {
  final NotesRepositoryInterface _repository;

  NotesViewModel(this._repository);

  List<Notes> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;
  PostItCat? _filtroCategoria;

  List<Notes> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PostItCat? get filtroCategoria => _filtroCategoria;

  Future<void> carregarNotas({
    String? titulo,
    PostItCat? categoria,
    int page = 0,
    int size = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _filtroCategoria = categoria;
    notifyListeners();

    try {
      _notes = await _repository.buscarTodos(
        titulo: titulo,
        categoria: categoria,
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

  Future<bool> criarNota(Notes note) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final criada = await _repository.criar(note);
      _notes = [criada, ..._notes];
      return true;
    } catch (e) {
      _errorMessage = _formatarErro(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarNota(String id, Notes note) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final atualizada = await _repository.atualizar(id, note);
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

  Future<bool> deletarNota(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deletar(id);
      _notes = _notes.where((n) => n.id != id).toList();
      return true;
    } catch (e) {
      _errorMessage = _formatarErro(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> alternarFixacao(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final atualizada = await _repository.alternarFixacao(id);
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

  void _substituirNaLista(Notes atualizada) {
    final index = _notes.indexWhere((n) => n.id == atualizada.id);
    if (index != -1) {
      final novaLista = List<Notes>.from(_notes);
      novaLista[index] = atualizada;
      _notes = novaLista;
    }
  }

  String _formatarErro(Object e) {
    return e.toString().replaceFirst('Exception: ', '');
  }
}
