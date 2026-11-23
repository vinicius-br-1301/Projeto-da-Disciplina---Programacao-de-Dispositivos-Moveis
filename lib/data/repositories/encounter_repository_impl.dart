import '../../domain/entities/encounter.dart';
import '../../domain/repositories/encounter_repository_interface.dart';
import '../dtos/encounter_dto.dart';
import '../services/encounter_calculator_service.dart';

class EncounterRepositoryImpl implements EncounterRepositoryInterface {
  final EncounterCalculatorService _service;

  EncounterRepositoryImpl(this._service);

  @override
  Future<EncounterResponse> calcularEncontro(EncounterRequest request) async {
    final responseDto = await _service.calcularEncontro(
      EncounterRequestDto.fromEntity(request),
    );
    return responseDto.toEntity();
  }
}
