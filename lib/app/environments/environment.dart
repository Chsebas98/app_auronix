import 'package:auronix_app/app/environments/flavors/env_base_config.dart';
import 'package:auronix_app/app/environments/flavors/env_dev_config.dart';
import 'package:auronix_app/app/environments/flavors/env_prod_config.dart';

class Environment {
  static final Environment _singleton = Environment._internal();

  factory Environment() => _singleton;

  Environment._internal();

  static const String dev = "DEV";
  static const String prod = "PROD";
  EnvBaseConfig? config;
  String _activeEnvironment = dev;

  String get activeEnvironment => _activeEnvironment;

  void initConfig(String environment) {
    _activeEnvironment = environment == prod ? prod : dev;
    config = _getConfig(_activeEnvironment);
  }

  EnvBaseConfig _getConfig(String environment) {
    switch (environment) {
      case Environment.dev:
        return EnvDevConfig();
      case Environment.prod:
        return EnvProdConfig();
      default:
        return EnvDevConfig();
    }
  }
}
