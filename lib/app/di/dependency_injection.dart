import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/network/dio_client.dart';
import 'package:auronix_app/app/core/network/interceptors/auth_interceptor.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/features/auth/auth.dart';
import 'package:auronix_app/features/client/features/trip/data/google_places_datasource.dart';
import 'package:auronix_app/features/client/features/trip/domain/repository/trip_repository.dart';
import 'package:auronix_app/features/client/features/trip/domain/repository/trip_repository_impl.dart';
import 'package:auronix_app/features/conductor/auth/data/remote/conductor_auth_service.dart';
import 'package:auronix_app/features/conductor/auth/domain/repository/auth_conductor_repository.dart';
import 'package:auronix_app/features/conductor/auth/data/repositories/auth_conductor_repository_impl.dart';
import 'package:auronix_app/features/conductor/auth/presentation/bloc/auth_conductor_bloc.dart';
import 'package:auronix_app/features/conductor/home/presentation/bloc/home_conductor_bloc.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/shared/modals/modal_temp_cubit.dart';
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
  final authenticationService = AuthenticationService(dio: dioBasic);
  sl.registerLazySingleton<AuthenticationService>(() => authenticationService);

  // Crear ConductorAuthService con Dio básico
  final conductorAuthService = ConductorAuthService(dio: dioBasic);
  sl.registerLazySingleton<ConductorAuthService>(() => conductorAuthService);

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
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      local: sl<AuthLocalServices>(),
      localDb: sl<AuthLocalDbDataSource>(
        instanceName: DbConstants.userTypeClient,
      ),
      authenticationService: sl<AuthenticationService>(),
      prefs: sl<RxSharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<AuthConductorRepository>(
    () => AuthConductorRepositoryImpl(
      conductorAuthService: sl<ConductorAuthService>(),
      localDb: sl<AuthLocalDbDataSource>(
        instanceName: DbConstants.userTypeDriver,
      ),
      prefs: sl<RxSharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<HomeClientRepository>(
    () => HomeClientRepositoryImpl(
      localDb: sl<AuthLocalDbDataSource>(
        instanceName: DbConstants.userTypeClient,
      ),
    ),
  );

  //Blocs
  sl.registerLazySingleton<SessionBloc>(
    () => SessionBloc(sl<AuthRepository>()),
  );
  sl.registerFactory<ModalTempCubit>(() => ModalTempCubit());
  sl.registerLazySingleton<BottomNavCubit>(() => BottomNavCubit());
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      sl<AuthRepository>(),
      prefs: sl<RxSharedPreferences>(),
    ),
  );
  sl.registerFactory<AuthConductorBloc>(
    () => AuthConductorBloc(sl<AuthConductorRepository>()),
  );
  sl.registerFactory<HomeConductorBloc>(() => HomeConductorBloc());
  sl.registerFactory<HomeClientBloc>(
    () => HomeClientBloc(
      sl<HomeClientRepository>(),
      prefs: sl<RxSharedPreferences>(),
    ),
  );

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

  //?Trip
  sl.registerLazySingleton<GooglePlacesDatasource>(
    () => GooglePlacesDatasource(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(placesDataSource: sl<GooglePlacesDatasource>()),
  );
  sl.registerFactory<RequestTripBloc>(
    () => RequestTripBloc(tripRepository: sl<TripRepository>()),
  );
}
