import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/campaign.dart';
import 'api_config.dart';

class CampaignService {
  final String _endpoint = '${ApiConfig.baseUrl}/campaigns';

  // GET /campaigns (com paginação e filtro opcional por título)
  Future<List<Campaign>> listarCampanhas({
    String? titulo,
    int page = 0,
    int size = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (titulo != null && titulo.trim().isNotEmpty) 'titulo': titulo.trim(),
    };

    final uri = Uri.parse(_endpoint).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: ApiConfig.defaultHeaders);

    if (response.statusCode == 200) {
      final Map<String, dynamic> pageJson = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      final List<dynamic> content = pageJson['content'] as List<dynamic>? ?? [];
      return content
          .map((item) => Campaign.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Erro ao listar campanhas (${response.statusCode}): ${response.body}',
      );
    }
  }

  // GET /campaigns/{id}
  Future<Campaign> buscarPorId(String id) async {
    final response = await http.get(
      Uri.parse('$_endpoint/$id'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode == 200) {
      return Campaign.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Erro ao buscar campanha (${response.statusCode})');
    }
  }

  // POST /campaigns
  Future<Campaign> criar(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Campaign.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao criar campanha (${response.statusCode}): ${response.body}',
      );
    }
  }

  // PUT /campaigns/{id}
  Future<Campaign> atualizar(String id, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$_endpoint/$id'),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Campaign.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao atualizar campanha (${response.statusCode}): ${response.body}',
      );
    }
  }

  // DELETE /campaigns/{id}
  Future<void> deletar(String id) async {
    final response = await http.delete(
      Uri.parse('$_endpoint/$id'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao remover campanha (${response.statusCode})');
    }
  }

  // PATCH /campaigns/{id}/pausar
  Future<Campaign> pausar(String id) async {
    return _patchAcao(id, 'pausar');
  }

  // PATCH /campaigns/{id}/reativar
  Future<Campaign> reativar(String id) async {
    return _patchAcao(id, 'reativar');
  }

  // PATCH /campaigns/{id}/encerrar
  Future<Campaign> encerrar(String id) async {
    return _patchAcao(id, 'encerrar');
  }

  Future<Campaign> _patchAcao(String id, String acao) async {
    final response = await http.patch(
      Uri.parse('$_endpoint/$id/$acao'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode == 200) {
      return Campaign.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao $acao campanha (${response.statusCode}): ${response.body}',
      );
    }
  }

  // POST /campaigns/{id}/iniciar-sessao
  Future<String> iniciarSessao(String id) async {
    final response = await http.post(
      Uri.parse('$_endpoint/$id/iniciar-sessao'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode == 200) {
      // Remove aspas caso o UUID venha serializado como string JSON ("uuid")
      return jsonDecode(response.body).toString();
    } else {
      throw Exception(
        'Erro ao iniciar sessão (${response.statusCode}): ${response.body}',
      );
    }
  }
}
