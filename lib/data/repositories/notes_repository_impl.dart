import '../../domain/entities/enums.dart';
import '../../domain/entities/notes.dart';
import '../../domain/repositories/notes_repository_interface.dart';
import '../dtos/notes_dto.dart';
import '../services/notes_service.dart';

class NotesRepositoryImpl implements NotesRepositoryInterface {
  final NotesService _service;

  NotesRepositoryImpl(this._service);

  @override
  Future<List<Notes>> buscarTodos({
    String? titulo,
    PostItCat? categoria,
    int page = 0,
    int size = 10,
  }) async {
    final dtos = await _service.buscarTodos(
      titulo: titulo,
      categoria: categoria?.name,
      page: page,
      size: size,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<Notes> buscarPorId(String id) async {
    final dto = await _service.buscarPorId(id);
    return dto.toEntity();
  }

  @override
  Future<Notes> criar(Notes note) async {
    final dto = await _service.criar(NotesDto.fromEntity(note));
    return dto.toEntity();
  }

  @override
  Future<Notes> atualizar(String id, Notes note) async {
    final dto = await _service.atualizar(id, NotesDto.fromEntity(note));
    return dto.toEntity();
  }

  @override
  Future<void> deletar(String id) {
    return _service.deletar(id);
  }

  @override
  Future<Notes> alternarFixacao(String id) async {
    final dto = await _service.alternarFixacao(id);
    return dto.toEntity();
  }
}
