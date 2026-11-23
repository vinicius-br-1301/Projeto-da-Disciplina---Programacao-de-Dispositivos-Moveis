import '../entities/encounter.dart';

abstract class EncounterRepositoryInterface {
  Future<EncounterResponse> calcularEncontro(EncounterRequest request);
}
