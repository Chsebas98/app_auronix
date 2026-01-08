import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/features/client/auth/infraestructure/models/authentication_credentials.dart';
import 'package:auronix_app/features/client/home/domain/repository/home_client_repository.dart';
import 'package:flutter/widgets.dart';

class HomeClientRepositoryImpl implements HomeClientRepository {
  final AuthLocalDbDataSource localDb;

  HomeClientRepositoryImpl({required this.localDb});

  @override
  Future<AuthenticationCredentials> fetchDataProfile() async {
    try {
      final dataDb = await localDb.readUser();
      final dataUser = AuthenticationCredentials.fromJson(dataDb!.toJson());
      return dataUser;
    } catch (e) {
      debugPrint('Error fetching data profile: $e');
      return const AuthenticationCredentials.empty();
    }
  }
}
