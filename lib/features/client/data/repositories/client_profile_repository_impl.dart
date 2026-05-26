import 'package:auronix_app/core/core.dart';
import 'package:auronix_app/features/auth/domain/models/interfaces/authentication_credentials.dart';
import 'package:auronix_app/features/client/data/datasources/remote/client_profile_remote_datasource.dart';
import 'package:auronix_app/features/client/data/models/profile_update_request_model.dart';
import 'package:auronix_app/features/client/domain/repositories/client_profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ClientProfileRepositoryImpl implements ClientProfileRepository {
  final ClientProfileRemoteDatasource _remote;

  ClientProfileRepositoryImpl({required ClientProfileRemoteDatasource remote})
      : _remote = remote;

  Either<Failure, T> _handleError<T>(Object e) {
    if (e is DioException && e.response?.data != null) {
      final body = e.response!.data as Map<String, dynamic>;
      return Left(ServerFailure(
        message: body['message'] as String? ?? 'Error del servidor',
        statusCode: e.response?.statusCode,
      ));
    }
    return Left(UnexpectedFailure(message: e.toString()));
  }

  AuthenticationCredentials _parseCredentials(Map<String, dynamic> result) =>
      AuthenticationCredentials(
        tokenAccess: result['token_access'] as String? ?? '',
        tokenRefresh: result['token_refresh'] as String? ?? '',
        role: RoleHelpers.mapRole(result['role']),
        username: result['username'] as String? ?? '',
        firstName: result['first_name'] as String? ?? '',
        secondName: result['second_name'] as String?,
        lastName: result['last_name'] as String? ?? '',
        secondlastName: result['second_last_name'] as String?,
        email: result['email'] as String? ?? '',
        photoUrl: result['photo_url'] as String? ?? '',
        isGoogleUser: result['is_google_user'] as bool? ?? false,
      );

  @override
  Future<Either<Failure, AuthenticationCredentials>> getProfile(
      int userId) async {
    try {
      final result = await _remote.getProfile(userId);
      return Right(_parseCredentials(result));
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<Either<Failure, AuthenticationCredentials>> updateProfile({
    required int userId,
    required ProfileUpdateRequestModel data,
  }) async {
    try {
      final result = await _remote.updateProfile(userId: userId, data: data);
      return Right(_parseCredentials(result));
    } catch (e) {
      return _handleError(e);
    }
  }
}
