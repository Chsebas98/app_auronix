// Prueba los modelos de T10 (entidades de dominio y DTOs de auth) contra el
// JSON real que el backend (micro-auronix LoginResponseDto) envia hoy:
// userId, email, roles (lista), accessToken, refreshToken.

import 'package:auronix_app/features/auth/data/models/auth_response_model.dart';
import 'package:auronix_app/features/auth/domain/models/auth_tokens.dart';
import 'package:auronix_app/features/auth/domain/models/user_data.dart';
import 'package:auronix_app/features/auth/domain/models/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole', () {
    test(
      'T10-C2: PASAJERO y CONDUCTOR mapean a un enum estricto (UserRole.pasajero/conductor)',
      () {
        expect(UserRole.fromBackendValue('PASAJERO'), UserRole.pasajero);
        expect(UserRole.fromBackendValue('CONDUCTOR'), UserRole.conductor);
        expect(UserRole.pasajero.toBackendValue(), 'PASAJERO');
        expect(UserRole.conductor.toBackendValue(), 'CONDUCTOR');
      },
    );

    test(
      'T10-C4 T10-C6: un rol desconocido lanza una excepcion de dominio, no cae a un default',
      () {
        expect(
          () => UserRole.fromBackendValue('ADMIN'),
          throwsA(isA<InvalidUserRoleException>()),
        );
        expect(
          () => UserRole.fromBackendValue(''),
          throwsA(isA<InvalidUserRoleException>()),
        );
      },
    );
  });

  group('UserData y AuthTokens', () {
    test(
      'T10-C3: UserData y AuthTokens son inmutables (comparables por valor)',
      () {
        final a = UserData(id: 1, email: 'a@test.com', role: UserRole.pasajero);
        final b = UserData(id: 1, email: 'a@test.com', role: UserRole.pasajero);
        expect(a, equals(b));
        expect(identical(a, b), isFalse);

        const tokensA = AuthTokens(accessToken: 'x', refreshToken: 'y');
        const tokensB = AuthTokens(accessToken: 'x', refreshToken: 'y');
        expect(tokensA, equals(tokensB));
      },
    );
  });

  group('AuthResponseModel', () {
    Map<String, dynamic> backendJson({dynamic roles = const ['PASAJERO']}) => {
      'userId': 42,
      'email': 'pasajero@test.com',
      'roles': roles,
      'accessToken': 'access-abc',
      'refreshToken': 'refresh-abc',
    };

    test(
      'T10-C1: deserializa el JSON real del backend (userId, email, roles) sin perder datos',
      () {
        final model = AuthResponseModel.fromJson(backendJson());

        expect(model.id, 42);
        expect(model.email, 'pasajero@test.com');
        expect(model.role, UserRole.pasajero);
        expect(model.accessToken, 'access-abc');
        expect(model.refreshToken, 'refresh-abc');
      },
    );

    test(
      'T10-C5: mapea a UserData/AuthTokens (id, email, role, token, refreshToken) con sound null safety',
      () {
        final model = AuthResponseModel.fromJson(
          backendJson(roles: const ['CONDUCTOR']),
        );

        expect(
          model.toUserData(),
          const UserData(
            id: 42,
            email: 'pasajero@test.com',
            role: UserRole.conductor,
          ),
        );
        expect(
          model.toAuthTokens(),
          const AuthTokens(
            accessToken: 'access-abc',
            refreshToken: 'refresh-abc',
          ),
        );
      },
    );

    test(
      'T10-C4 T10-C6: un rol desconocido en el JSON del backend lanza excepcion, no un default silencioso',
      () {
        expect(
          () => AuthResponseModel.fromJson(backendJson(roles: const ['ADMIN'])),
          throwsA(isA<InvalidUserRoleException>()),
        );
      },
    );

    test(
      'T10-C3: un campo requerido ausente lanza MalformedAuthResponseException, no un TypeError crudo',
      () {
        final incomplete = backendJson()..remove('accessToken');
        expect(
          () => AuthResponseModel.fromJson(incomplete),
          throwsA(isA<MalformedAuthResponseException>()),
        );
      },
    );
  });
}
