import 'package:auronix_app/features/client/client.dart';

abstract class HomeClientRepository {
  Future<AuthenticationCredentials> fetchDataProfile();
}
