import 'package:auronix_app/app/core/bloc/bloc.dart';
import 'package:auronix_app/app/core/bloc/dialog-cubit/dialog_cubit.dart';
import 'package:auronix_app/app/core/network/dio_client.dart';
import 'package:auronix_app/app/core/network/interceptors/auth_interceptor.dart';
import 'package:auronix_app/app/database/app_database.dart';
import 'package:auronix_app/app/database/auth_local_db_datasource.dart';
import 'package:auronix_app/app/database/db_constants.dart';
import 'package:auronix_app/app/environments/environment.dart';
import 'package:auronix_app/features/auth/auth.dart';
import 'package:auronix_app/features/auth/data/datasources/auth_local_services.dart';
import 'package:auronix_app/features/client/data/datasources/remote/client_profile_remote_datasource.dart';
import 'package:auronix_app/features/client/data/repositories/client_profile_repository_impl.dart';
import 'package:auronix_app/features/client/domain/repositories/client_profile_repository.dart';
import 'package:auronix_app/features/client/domain/usecases/get_client_profile_usecase.dart';
import 'package:auronix_app/features/client/domain/usecases/update_client_profile_usecase.dart';
import 'package:auronix_app/features/features.dart';
import 'package:auronix_app/features/home/data/datasources/remote/home_driver_remote_datasource.dart';
import 'package:auronix_app/features/home/data/repository/home_repository_impl.dart';
import 'package:auronix_app/features/home/domain/repository/home_repository.dart';
import 'package:auronix_app/features/home/domain/usecases/get_driver_home_usecase.dart';
import 'package:auronix_app/features/home/presentation/bloc/client-bloc/home_client_bloc.dart';
import 'package:auronix_app/features/home/presentation/bloc/driver-bloc/home_driver_bloc.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/client_trip_remote_datasource.dart';
import 'package:auronix_app/features/trips/data/datasources/remote/driver_trip_remote_datasource.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/driver_trip_socket.dart';
import 'package:auronix_app/features/trips/data/datasources/socket/trip_status_socket.dart';
import 'package:auronix_app/features/trips/data/repository/trip_repository_impl.dart';
import 'package:auronix_app/features/trips/domain/repository/trip_repository.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/cancel_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/get_trip_status_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/rate_driver_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/client/request_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/accept_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/complete_trip_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/get_available_trips_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/rate_passenger_usecase.dart';
import 'package:auronix_app/features/trips/domain/usecases/driver/start_trip_usecase.dart';
import 'package:auronix_app/features/trips/presentation/bloc/client-bloc/client_trip_bloc.dart';
import 'package:auronix_app/features/trips/presentation/bloc/driver-bloc/driver_trip_bloc.dart';
import 'package:auronix_app/shared/blocs/modals/modal_temp_cubit.dart';
import 'package:auronix_app/shared/templates/appbar/bottom-appbar/cubit/bottom_nav_cubit.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get_it/get_it.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── 1. Globales ───────────────────────────────────────────────────────────

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

  // ── 2. Base de datos ──────────────────────────────────────────────────────

  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

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

  // ── 3. Red ────────────────────────────────────────────────────────────────

  final dioBasic = await DioClient.getInstance(
    enableSSLPinning: false,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );

  final authRemote = AuthRemoteDatasource(dio: dioBasic);
  sl.registerLazySingleton<AuthRemoteDatasource>(() => authRemote);

  dioBasic.interceptors.insert(
    2,
    AuthInterceptor(
      db: sl<AppDatabase>(),
      dio: dioBasic,
      authRemote: authRemote,
    ),
  );

  sl.registerLazySingleton<Dio>(() => dioBasic);

  // ── 4. Auth — datasources locales ────────────────────────────────────────

  sl.registerLazySingleton<AuthLocalServices>(
    () => AuthLocalServices(sl<RxSharedPreferences>()),
  );

  // ── 5. Auth — repository ──────────────────────────────────────────────────

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

  // ── 6. Auth — blocs ───────────────────────────────────────────────────────

  sl.registerLazySingleton<SessionBloc>(
    () => SessionBloc(sl<AuthUnifiedRepository>()),
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

  // ── 7. Home — datasource + repository + usecases ─────────────────────────

  sl.registerLazySingleton<HomeDriverRemoteDatasource>(
    () => HomeDriverRemoteDatasource(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remote: sl<HomeDriverRemoteDatasource>()),
  );

  sl.registerLazySingleton<GetDriverHomeUseCase>(
    () => GetDriverHomeUseCase(sl<HomeRepository>()),
  );

  // ── 8. Home — blocs ───────────────────────────────────────────────────────

  sl.registerFactory<HomeClientBloc>(() => HomeClientBloc());

  sl.registerFactory<HomeDriverBloc>(
    () => HomeDriverBloc(getDriverHome: sl<GetDriverHomeUseCase>()),
  );

  // ── 9. Trips — datasources + repositorio + usecases ──────────────────────

  sl.registerLazySingleton<ClientTripRemoteDatasource>(
    () => ClientTripRemoteDatasource(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<DriverTripRemoteDatasource>(
    () => DriverTripRemoteDatasource(dio: sl<Dio>()),
  );

  // WebSocket URL derivada de apiBaseUrl: http://host:port/api → ws://host:port
  final wsBaseUrl = Environment()
      .config!
      .apiBaseUrl
      .replaceFirst(RegExp(r'https?://'), 'ws://')
      .replaceFirst(RegExp(r'/api.*'), '');

  sl.registerFactory<DriverTripSocket>(
    () => DriverTripSocket(serverUrl: wsBaseUrl),
  );

  sl.registerFactory<TripStatusSocket>(
    () => TripStatusSocket(serverUrl: wsBaseUrl),
  );

  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(
      clientRemote: sl<ClientTripRemoteDatasource>(),
      driverRemote: sl<DriverTripRemoteDatasource>(),
    ),
  );

  sl.registerLazySingleton<RequestTripUseCase>(
    () => RequestTripUseCase(sl<TripRepository>()),
  );
  sl.registerLazySingleton<GetTripStatusUseCase>(
    () => GetTripStatusUseCase(sl<TripRepository>()),
  );
  sl.registerLazySingleton<CancelTripUseCase>(
    () => CancelTripUseCase(sl<TripRepository>()),
  );
  sl.registerLazySingleton<RateDriverUseCase>(
    () => RateDriverUseCase(sl<TripRepository>()),
  );
  sl.registerLazySingleton<GetAvailableTripsUseCase>(
    () => GetAvailableTripsUseCase(sl<TripRepository>()),
  );
  sl.registerLazySingleton<AcceptTripUseCase>(
    () => AcceptTripUseCase(sl<TripRepository>()),
  );
  sl.registerLazySingleton<StartTripUseCase>(
    () => StartTripUseCase(sl<TripRepository>()),
  );
  sl.registerLazySingleton<CompleteTripUseCase>(
    () => CompleteTripUseCase(sl<TripRepository>()),
  );
  sl.registerLazySingleton<RatePassengerUseCase>(
    () => RatePassengerUseCase(sl<TripRepository>()),
  );

  // ── 10. Trips — blocs ─────────────────────────────────────────────────────

  sl.registerLazySingleton<DriverTripBloc>(
    () => DriverTripBloc(
      getAvailableTrips: sl<GetAvailableTripsUseCase>(),
      acceptTrip: sl<AcceptTripUseCase>(),
      startTrip: sl<StartTripUseCase>(),
      completeTrip: sl<CompleteTripUseCase>(),
      ratePassenger: sl<RatePassengerUseCase>(),
      socket: sl<DriverTripSocket>(),
    ),
  );

  sl.registerLazySingleton<ClientTripBloc>(
    () => ClientTripBloc(
      requestTrip: sl<RequestTripUseCase>(),
      cancelTrip: sl<CancelTripUseCase>(),
      rateDriver: sl<RateDriverUseCase>(),
      socket: sl<TripStatusSocket>(),
    ),
  );

  // ── 11. Perfil cliente — datasource + repository + usecases ──────────────

  sl.registerLazySingleton<ClientProfileRemoteDatasource>(
    () => ClientProfileRemoteDatasource(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<ClientProfileRepository>(
    () => ClientProfileRepositoryImpl(
      remote: sl<ClientProfileRemoteDatasource>(),
    ),
  );

  sl.registerLazySingleton<GetClientProfileUseCase>(
    () => GetClientProfileUseCase(sl<ClientProfileRepository>()),
  );

  sl.registerLazySingleton<UpdateClientProfileUseCase>(
    () => UpdateClientProfileUseCase(sl<ClientProfileRepository>()),
  );

  // ── 12. Globales de navegación y modales ──────────────────────────────────

  sl.registerLazySingleton<BottomNavCubit>(() => BottomNavCubit());
  sl.registerFactory<ModalTempCubit>(() => ModalTempCubit());
}
