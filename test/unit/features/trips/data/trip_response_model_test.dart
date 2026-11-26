// Prueba TripEntity/TripResponseModel (T22). Nota Tarea 0: ya existian
// estas clases (no lib/features/trips/domain/entities/trip.dart ni
// data/models/trip_model.dart como sugiere el texto de la tarea) — se
// adaptan en vez de crear un modelo paralelo.

import 'package:auronix_app/features/trips/data/models/trip_response_model.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_entity.dart';
import 'package:auronix_app/features/trips/domain/models/interfaces/trip_status.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _fullJson({String estado = 'SOLICITADO'}) => {
  'id': 42,
  'codigoViaje': 'ABC12345',
  'passengerId': 7,
  'driverId': 9,
  'vehicleId': 3,
  'cooperativaId': 1,
  'origenLatitud': -0.18,
  'origenLongitud': -78.47,
  'origenDireccion': 'Av. Amazonas',
  'destinoLatitud': -0.20,
  'destinoLongitud': -78.50,
  'destinoDireccion': 'Parque La Carolina',
  'distanciaKm': 5.2,
  'precioTotal': 6.75,
  'estado': estado,
  'fechaSolicitud': '2026-11-21T10:00:00Z',
};

void main() {
  group(
    'T22-C3: TripEntity contiene todos los campos del esquema tb_trips',
    () {
      test('acepta todos los campos reales de tb_trips/TripResponseDto', () {
        const entity = TripEntity(
          id: 1,
          codigoViaje: 'ABC12345',
          passengerId: 7,
          driverId: 9,
          vehicleId: 3,
          cooperativaId: 1,
          origenLatitud: -0.18,
          origenLongitud: -78.47,
          origenDireccion: 'Av. Amazonas',
          destinoLatitud: -0.20,
          destinoLongitud: -78.50,
          destinoDireccion: 'Parque La Carolina',
          distanciaKm: 5.2,
          precioTotal: 6.75,
          estado: TripStatus.solicitado,
          fechaSolicitud: '2026-11-21T10:00:00Z',
        );

        // tb_trips (V6__create_trips.sql): id, codigo_viaje, passenger_id,
        // driver_id, vehicle_id, cooperativa_id, origen_*, destino_*,
        // precio_total, estado.
        expect(entity.id, 1);
        expect(entity.codigoViaje, 'ABC12345');
        expect(entity.passengerId, 7);
        expect(entity.driverId, 9);
        expect(entity.vehicleId, 3);
        expect(entity.cooperativaId, 1);
        expect(entity.origenLatitud, -0.18);
        expect(entity.destinoDireccion, 'Parque La Carolina');
        expect(entity.precioTotal, 6.75);
        expect(entity.estado, TripStatus.solicitado);
      });

      test('driverId y vehicleId son nulos antes de asignar conductor', () {
        const entity = TripEntity(
          id: 1,
          codigoViaje: 'ABC12345',
          passengerId: 7,
          cooperativaId: 1,
          origenLatitud: -0.18,
          origenLongitud: -78.47,
          origenDireccion: 'Av. Amazonas',
          destinoLatitud: -0.20,
          destinoLongitud: -78.50,
          destinoDireccion: 'Parque La Carolina',
          distanciaKm: 5.2,
          precioTotal: 6.75,
          estado: TripStatus.solicitado,
          fechaSolicitud: '2026-11-21T10:00:00Z',
        );

        expect(entity.driverId, isNull);
        expect(entity.vehicleId, isNull);
      });
    },
  );

  group('T22-C4: TripResponseModel convierte JSON respetando tipos y nulos', () {
    for (final status in TripStatus.values) {
      test(
        'mapea correctamente el estado ${status.toBackendValue()} del enum del backend',
        () {
          final model = TripResponseModel.fromJson(
            _fullJson(estado: status.toBackendValue()),
          );
          expect(model.estado, status);
        },
      );
    }

    test(
      'respeta los tipos num->double y preserva enteros id/driverId/vehicleId',
      () {
        final model = TripResponseModel.fromJson(_fullJson());

        expect(model.id, isA<int>());
        expect(model.id, 42);
        expect(model.driverId, isA<int>());
        expect(model.driverId, 9);
        expect(model.vehicleId, 3);
        expect(model.origenLatitud, isA<double>());
        expect(model.origenLatitud, -0.18);
        expect(model.precioTotal, 6.75);
      },
    );

    test(
      'driverId, vehicleId y campos de texto nulos no hacen fallar el parseo',
      () {
        final json = _fullJson()
          ..remove('driverId')
          ..remove('vehicleId')
          ..remove('codigoViaje')
          ..remove('origenDireccion');

        final model = TripResponseModel.fromJson(json);

        expect(model.driverId, isNull);
        expect(model.vehicleId, isNull);
        expect(model.codigoViaje, '');
        expect(model.origenDireccion, '');
      },
    );

    test(
      'un estado desconocido lanza InvalidTripStatusException en vez de fallar silenciosamente',
      () {
        expect(
          () => TripResponseModel.fromJson(_fullJson(estado: 'NO_EXISTE')),
          throwsA(isA<InvalidTripStatusException>()),
        );
      },
    );

    test('toEntity() preserva todos los campos sin perder datos', () {
      final model = TripResponseModel.fromJson(_fullJson());
      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.vehicleId, model.vehicleId);
      expect(entity.estado, model.estado);
      expect(entity.destinoLongitud, model.destinoLongitud);
    });
  });
}
