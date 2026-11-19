import 'package:auronix_app/features/home/data/models/place_prediction_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'T17-C6: deserializa un JSON de autocompletado completo de Google Places',
    () {
      final dto = PlacePredictionDto.fromJson({
        'place_id': 'abc123',
        'description': 'Av. Amazonas, Quito, Ecuador',
        'structured_formatting': {
          'main_text': 'Av. Amazonas',
          'secondary_text': 'Quito, Ecuador',
        },
      });

      expect(dto.placeId, 'abc123');
      expect(dto.description, 'Av. Amazonas, Quito, Ecuador');
      expect(dto.mainText, 'Av. Amazonas');
      expect(dto.secondaryText, 'Quito, Ecuador');
    },
  );

  test('T17-C6: sin structured_formatting, usa fallback seguro sin lanzar', () {
    final dto = PlacePredictionDto.fromJson({
      'place_id': 'xyz789',
      'description': 'Solo descripcion',
    });

    expect(dto.placeId, 'xyz789');
    expect(dto.mainText, 'Solo descripcion');
    expect(dto.secondaryText, '');
  });

  test(
    'T17-C6: con secondary_text ausente dentro de structured_formatting, usa cadena vacia',
    () {
      final dto = PlacePredictionDto.fromJson({
        'place_id': 'id1',
        'description': 'Descripcion',
        'structured_formatting': {'main_text': 'Nombre principal'},
      });

      expect(dto.mainText, 'Nombre principal');
      expect(dto.secondaryText, '');
    },
  );

  test('T17-C6: con JSON vacio, no lanza y usa cadenas vacias', () {
    final dto = PlacePredictionDto.fromJson(const {});

    expect(dto.placeId, '');
    expect(dto.description, '');
    expect(dto.mainText, '');
    expect(dto.secondaryText, '');
  });
}
