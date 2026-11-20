import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/encounter.dart';
import 'api_config.dart';

class EncounterCalculatorService {
  final String _endpoint = '${ApiConfig.baseUrl}/encounters/calcular';

  // POST /encounters/calcular
  Future<EncounterResponse> calcularEncontro(EncounterRequest request) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return EncounterResponse.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Erro ao calcular encontro (${response.statusCode}): ${response.body}',
      );
    }
  }
}
