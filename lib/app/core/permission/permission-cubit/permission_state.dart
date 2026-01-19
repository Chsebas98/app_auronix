part of 'permission_cubit.dart';

class PermissionUiRequest extends Equatable {
  final AppPermissionType type;
  final int seq; // para que el listener detecte un nuevo request

  const PermissionUiRequest({required this.type, required this.seq});

  @override
  List<Object> get props => [type, seq];
}

class PermissionState extends Equatable {
  final Map<AppPermissionType, PermissionStatus> statuses;
  final bool checking;
  final PermissionUiRequest? uiRequest;

  const PermissionState({
    this.statuses = const {},
    this.checking = true,
    this.uiRequest,
  });

  PermissionStatus statusOf(AppPermissionType type) =>
      statuses[type] ?? PermissionStatus.denied;

  bool granted(AppPermissionType type) =>
      statusOf(type) == PermissionStatus.granted;

  PermissionState copyWith({
    Map<AppPermissionType, PermissionStatus>? statuses,
    bool? checking,
    PermissionUiRequest? uiRequest,
  }) {
    return PermissionState(
      statuses: statuses ?? this.statuses,
      checking: checking ?? this.checking,
      uiRequest: uiRequest,
    );
  }

  @override
  List<Object?> get props => [statuses, checking, uiRequest];
}
