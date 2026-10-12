class StaticVariables {
  static const String welcomeViewed = 'welcomeViewed';
  static const String rememberKey = 'rememberKey';
  static const String rememberConductorKey = 'rememberConductorKey';
  static const String needsProfileComplete = 'needs_profile_complete';
  static const String tokenKey = 'tokenKey';

  /// Versión del texto placeholder de Términos y Condiciones (ver
  /// docs/flow.md sección 11.1). Reemplazar por la del departamento legal
  /// sin romper el historial de aceptaciones ya registradas — subir este
  /// valor cada vez que cambie el texto mostrado en el checkbox de registro.
  static const String currentTerminosVersion = 'v1-placeholder';
}
