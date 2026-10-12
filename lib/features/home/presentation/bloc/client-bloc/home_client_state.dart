part of 'home_client_bloc.dart';

enum HomeClientStatus { initial, loading, ready, error }

final class HomeClientState extends Equatable {
  const HomeClientState({
    this.status = HomeClientStatus.initial,
    this.dataProfile = const AuthenticationCredentials.empty(),
    this.currentAddress = '',
    this.isLoadingAddress = false,
    this.currentTrip,
    this.emergencyContactRequired = false,
    this.tripRequestNonce = 0,
  });

  final HomeClientStatus status;
  final AuthenticationCredentials dataProfile; // reemplaza con tu modelo
  final String currentAddress;
  final bool isLoadingAddress;
  final dynamic currentTrip; // reemplaza con tu modelo Trip
  final bool emergencyContactRequired;

  /// Se incrementa cada vez que pasa el gate de contacto de emergencia — la
  /// UI escucha el cambio para navegar a "Seleccionar destino" una sola vez.
  final int tripRequestNonce;

  bool get isLoading => status == HomeClientStatus.loading;
  bool get isReady => status == HomeClientStatus.ready;

  HomeClientState copyWith({
    HomeClientStatus? status,
    AuthenticationCredentials? dataProfile,
    String? currentAddress,
    bool? isLoadingAddress,
    dynamic currentTrip,
    bool? emergencyContactRequired,
    int? tripRequestNonce,
  }) {
    return HomeClientState(
      status: status ?? this.status,
      dataProfile: dataProfile ?? this.dataProfile,
      currentAddress: currentAddress ?? this.currentAddress,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      currentTrip: currentTrip ?? this.currentTrip,
      emergencyContactRequired:
          emergencyContactRequired ?? this.emergencyContactRequired,
      tripRequestNonce: tripRequestNonce ?? this.tripRequestNonce,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dataProfile,
    currentAddress,
    isLoadingAddress,
    currentTrip,
    emergencyContactRequired,
    tripRequestNonce,
  ];
}
