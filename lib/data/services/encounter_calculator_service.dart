import 'dart:convert';

import 'package:http/http.dart' as http;

import '../dtos/encounter_dto.dart';
import 'api_config.dart';

class EncounterCalculatorService {
  final String _endpoint = '${ApiConfig.baseUrl}/encounters/calcular';

  Future<EncounterResponseDto> calcularEncontro(EncounterRequestDto dto) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return EncounterResponseDto.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao calcular encontro (${response.statusCode}): ${response.body}',
      );
    }
  }
}
