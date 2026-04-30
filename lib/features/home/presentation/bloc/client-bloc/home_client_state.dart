part of 'home_client_bloc.dart';

enum HomeClientStatus { initial, loading, ready, error }

final class HomeClientState extends Equatable {
  const HomeClientState({
    this.status = HomeClientStatus.initial,
    this.dataProfile = const AuthenticationCredentials.empty(),
    this.currentAddress = '',
    this.isLoadingAddress = false,
    this.currentTrip,
  });

  final HomeClientStatus status;
  final AuthenticationCredentials dataProfile; // reemplaza con tu modelo
  final String currentAddress;
  final bool isLoadingAddress;
  final dynamic currentTrip; // reemplaza con tu modelo Trip

  bool get isLoading => status == HomeClientStatus.loading;
  bool get isReady => status == HomeClientStatus.ready;

  HomeClientState copyWith({
    HomeClientStatus? status,
    AuthenticationCredentials? dataProfile,
    String? currentAddress,
    bool? isLoadingAddress,
    dynamic currentTrip,
  }) {
    return HomeClientState(
      status: status ?? this.status,
      dataProfile: dataProfile ?? this.dataProfile,
      currentAddress: currentAddress ?? this.currentAddress,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      currentTrip: currentTrip ?? this.currentTrip,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dataProfile,
    currentAddress,
    isLoadingAddress,
    currentTrip,
  ];
}
