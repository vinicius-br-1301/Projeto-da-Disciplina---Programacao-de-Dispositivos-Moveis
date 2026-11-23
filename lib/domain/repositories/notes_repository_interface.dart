import '../entities/enums.dart';
import '../entities/notes.dart';

abstract class NotesRepositoryInterface {
  Future<List<Notes>> buscarTodos({
    String? titulo,
    PostItCat? categoria,
    int page = 0,
    int size = 10,
  });

  Future<Notes> buscarPorId(String id);
  Future<Notes> criar(Notes note);
  Future<Notes> atualizar(String id, Notes note);
  Future<void> deletar(String id);
  Future<Notes> alternarFixacao(String id);
}
