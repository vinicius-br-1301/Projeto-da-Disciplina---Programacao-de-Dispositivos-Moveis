import 'dart:convert';

import 'package:http/http.dart' as http;

import '../dtos/campaign_dto.dart';
import 'api_config.dart';

class CampaignService {
  final String _endpoint = '${ApiConfig.baseUrl}/campaigns';

  Future<List<CampaignDto>> listarCampanhas({
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
      final Map<String, dynamic> pageJson =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final List<dynamic> content = pageJson['content'] as List<dynamic>? ?? [];
      return content
          .map((item) => CampaignDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Erro ao listar campanhas (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<CampaignDto> buscarPorId(String id) async {
    final response = await http.get(
      Uri.parse('$_endpoint/$id'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode == 200) {
      return CampaignDto.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Erro ao buscar campanha (${response.statusCode})');
    }
  }

  Future<CampaignDto> criar(CampaignDto dto) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(dto.toRequestJson()),
    );

    if (response.statusCode == 201) {
      return CampaignDto.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao criar campanha (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<CampaignDto> atualizar(String id, CampaignDto dto) async {
    final response = await http.put(
      Uri.parse('$_endpoint/$id'),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(dto.toRequestJson()),
    );

    if (response.statusCode == 200) {
      return CampaignDto.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao atualizar campanha (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> deletar(String id) async {
    final response = await http.delete(
      Uri.parse('$_endpoint/$id'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Erro ao remover campanha (${response.statusCode})');
    }
  }

  Future<CampaignDto> pausar(String id) => _patchAcao(id, 'pausar');
  Future<CampaignDto> reativar(String id) => _patchAcao(id, 'reativar');
  Future<CampaignDto> encerrar(String id) => _patchAcao(id, 'encerrar');

  Future<CampaignDto> _patchAcao(String id, String acao) async {
    final response = await http.patch(
      Uri.parse('$_endpoint/$id/$acao'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode == 200) {
      return CampaignDto.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao $acao campanha (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<String> iniciarSessao(String id) async {
    final response = await http.post(
      Uri.parse('$_endpoint/$id/iniciar-sessao'),
      headers: ApiConfig.defaultHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body).toString();
    } else {
      throw Exception(
        'Erro ao iniciar sessão (${response.statusCode}): ${response.body}',
      );
    }
  }
}
