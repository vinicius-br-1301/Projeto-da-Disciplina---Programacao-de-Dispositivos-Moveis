import 'dart:convert';

import 'package:http/http.dart' as http;

import '../dtos/notes_dto.dart';
import 'api_config.dart';

class NotesService {
  final String _endpoint = '${ApiConfig.baseUrl}/notes';

  Future<List<NotesDto>> buscarTodos({
    String? titulo,
    String? categoria,
    int page = 0,
    int size = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (titulo != null && titulo.trim().isNotEmpty) 'titulo': titulo.trim(),
      if (categoria != null && categoria.isNotEmpty) 'categoria': categoria,
    };

    final uri = Uri.parse(_endpoint).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: ApiConfig.defaultHeaders);

    if (response.statusCode == 200) {
      final Map<String, dynamic> pageJson =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final List<dynamic> content = pageJson['content'] as List<dynamic>? ?? [];
      return content
          .map((item) => NotesDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Erro ao listar notas (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<NotesDto> buscarPorId(String id) async {
    final response = await http.get(
      Uri.parse('$_endpoint/$id'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode == 200) {
      return NotesDto.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Erro ao buscar nota (${response.statusCode})');
    }
  }

  Future<NotesDto> criar(NotesDto dto) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(dto.toRequestJson()),
    );

    if (response.statusCode == 201) {
      return NotesDto.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao criar nota (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<NotesDto> atualizar(String id, NotesDto dto) async {
    final response = await http.put(
      Uri.parse('$_endpoint/$id'),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(dto.toRequestJson()),
    );

    if (response.statusCode == 200) {
      return NotesDto.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao atualizar nota (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> deletar(String id) async {
    final response = await http.delete(
      Uri.parse('$_endpoint/$id'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao remover nota (${response.statusCode})');
    }
  }

  Future<NotesDto> alternarFixacao(String id) async {
    final response = await http.patch(
      Uri.parse('$_endpoint/$id/alternar-fixacao'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode == 200) {
      return NotesDto.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao alternar fixação (${response.statusCode}): ${response.body}',
      );
    }
  }
}
