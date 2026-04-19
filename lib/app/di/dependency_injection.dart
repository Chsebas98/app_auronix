import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/network/dio_client.dart';
import 'package:auronix_app/app/core/network/interceptors/auth_interceptor.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/features/auth/auth.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_client_services.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_local_services.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/blocs/modals/modal_temp_cubit.dart';
import 'package:auronix_app/shared/widgets/widgets.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //?Globales
  sl.registerFactory<GlobalCubit>(() => GlobalCubit());
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerFactory<AppLifeCycleCubit>(() => AppLifeCycleCubit());
  sl.registerFactory<PermissionCubit>(() => PermissionCubit());
  sl.registerLazySingleton<RxSharedPreferences>(
    () => RxSharedPreferences.getInstance(),
  );
  sl.registerLazySingleton<DialogCubit>(() => DialogCubit());
  sl.registerLazySingleton<CacheOptions>(
    () => CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      hitCacheOnErrorCodes: [401, 403],
      priority: CachePriority.normal,
      maxStale: const Duration(days: 1),
      allowPostMethod: true,
    ),
  );

  //?Database (MOVER ANTES DE DIO)
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  // Datasources separados por tipo de usuario
  sl.registerLazySingleton<AuthLocalDbDataSource>(
    () => AuthLocalDbDataSource(
      sl<AppDatabase>(),
      userType: DbConstants.userTypeClient,
    ),
    instanceName: DbConstants.userTypeClient,
  );
  sl.registerLazySingleton<AuthLocalDbDataSource>(
    () => AuthLocalDbDataSource(
      sl<AppDatabase>(),
      userType: DbConstants.userTypeDriver,
    ),
    instanceName: DbConstants.userTypeDriver,
  );

  // Crear Dio SIN AuthInterceptor primero
  final dioBasic = await DioClient.getInstance(
    enableSSLPinning: false,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );

  // Crear AuthenticationService con Dio básico
  final authenticationService = AuthClientServices(dio: dioBasic);
  sl.registerLazySingleton<AuthClientServices>(() => authenticationService);

  // Agregar AuthInterceptor DESPUÉS
  dioBasic.interceptors.insert(
    2, // Después de Cache, antes de Retry
    AuthInterceptor(
      db: sl<AppDatabase>(),
      authenticationService: authenticationService,
    ),
  );

  // Registrar Dio configurado
  sl.registerLazySingleton<Dio>(() => dioBasic);

  //?auth
  //local
  sl.registerLazySingleton<AuthLocalServices>(
    () => AuthLocalServices(sl<RxSharedPreferences>()),
  );

  //Repository
  sl.registerLazySingleton<AuthRepositoryUnifiedImpl>(
    () => AuthRepositoryUnifiedImpl(
      local: sl<AuthLocalServices>(),
      clientDb: sl<AuthLocalDbDataSource>(
        instanceName: DbConstants.userTypeClient,
      ),
      driverDb: sl<AuthLocalDbDataSource>(
        instanceName: DbConstants.userTypeDriver,
      ),

      remote: sl<AuthRemoteDatasource>(),
      prefs: sl<RxSharedPreferences>(),
    ),
  );

  //Blocs
  sl.registerLazySingleton<SessionBloc>(
    () => SessionBloc(sl<AuthRepositoryUnifiedImpl>()),
  );
  sl.registerFactory<ModalTempCubit>(() => ModalTempCubit());
  sl.registerLazySingleton<BottomNavCubit>(() => BottomNavCubit());

  //?Unified Auth Feature
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<AuthUnifiedRepository>(
    () => AuthRepositoryUnifiedImpl(
      remote: sl<AuthRemoteDatasource>(),
      clientDb: sl<AuthLocalDbDataSource>(
        instanceName: DbConstants.userTypeClient,
      ),
      driverDb: sl<AuthLocalDbDataSource>(
        instanceName: DbConstants.userTypeDriver,
      ),
      local: sl<AuthLocalServices>(),
      prefs: sl<RxSharedPreferences>(),
    ),
  );

  sl.registerFactory<AuthUnifiedBloc>(
    () => AuthUnifiedBloc(
      repository: sl<AuthUnifiedRepository>(),
      prefs: sl<RxSharedPreferences>(),
    ),
  );

  sl.registerFactory<AuthFormCubit>(
    () => AuthFormCubit(prefs: sl<RxSharedPreferences>()),
  );
}
