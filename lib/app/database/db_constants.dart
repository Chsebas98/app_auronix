class DbConstants {
  static const String dbName = 'auronix.db';
  static const int dbVersion = 4;

  static const String tableUser = 'user';
  static const String tableTripCache = 'trip_cache';

  // Columnas
  static const String colId = 'id';
  static const String colUserType = 'user_type';
  static const String colTokenAccess = 'token_access';
  static const String colTokenRefresh = 'token_refresh';
  static const String colRole = 'role';
  static const String colUsername = 'username';
  static const String colFirstName = 'first_name';
  static const String colSecondName = 'second_name';
  static const String colLastName = 'last_name';
  static const String colSecondLastName = 'second_last_name';
  static const String colEmail = 'email';
  static const String colPhotoUrl = 'photo_url';
  static const String colIsGoogleUser = 'is_google_user';
  static const String colTokenExpiresAt = 'token_expires_at';
  static const String colCreatedAt = 'created_at';

  static const String userTypeClient = 'CLIENT';
  static const String userTypeDriver = 'DRIVER';

  // trip_cache — alineada con tb_trips del backend (micro-auronix), mas los
  // campos locales de cache/borrador (colRemoteId, colSynced, colCachedAt).
  static const String colRemoteId = 'remote_id';
  static const String colCodigoViaje = 'codigo_viaje';
  static const String colPassengerId = 'passenger_id';
  static const String colDriverId = 'driver_id';
  static const String colCooperativaId = 'cooperativa_id';
  static const String colOrigenLatitud = 'origen_latitud';
  static const String colOrigenLongitud = 'origen_longitud';
  static const String colOrigenDireccion = 'origen_direccion';
  static const String colDestinoLatitud = 'destino_latitud';
  static const String colDestinoLongitud = 'destino_longitud';
  static const String colDestinoDireccion = 'destino_direccion';
  static const String colDistanciaKm = 'distancia_km';
  static const String colPrecioTotal = 'precio_total';
  static const String colEstado = 'estado';
  static const String colFechaSolicitud = 'fecha_solicitud';
  // 1 = copia en cache de un viaje ya confirmado por el backend (historial);
  // 0 = borrador creado offline, aun no enviado (pendiente de sincronizar).
  static const String colSynced = 'synced';
  static const String colCachedAt = 'cached_at';

  static const List<String> tripEstados = [
    'SOLICITADO',
    'OFERTADO',
    'ACEPTADO',
    'EN_CURSO',
    'COMPLETADO',
    'CANCELADO',
  ];
}
