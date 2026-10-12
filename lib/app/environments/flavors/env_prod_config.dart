import 'package:auronix_app/app/environments/flavors/env_base_config.dart';

class EnvProdConfig extends EnvBaseConfig {
  @override
  String get apiBaseUrl => 'prodUrl';

  @override
  String get tokenKey =>
      'f3cb615b34c7db7c45269a79bb86a200095dadf96b304d90f9d58d0dcfc8c95b7724ffca1522f97c1a041b7d3c6042d653a4b8df20d6b45664e56aec1ddce86b57bc589171d9a4e5cd5e042697199e1d7e3224072597d0e094adcca4ca3935495bafc9b6bbe020ea5f5a9296d3daddc16ee7723128e03e1112d0917b74bfbc8f';

  @override
  String get googleMapsApiKey => 'AIzaSyAwWACRwNg6aLMJqZJ0ti-unD-IYl5gWo4';
}
