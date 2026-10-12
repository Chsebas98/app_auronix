part of 'select_destination_cubit.dart';

final class SelectDestinationState extends Equatable {
  const SelectDestinationState({
    this.center = const LatLng(-0.1807, -78.4678), // Quito, fallback
    this.label = '',
    this.isResolvingLabel = false,
    this.suggestions = const [],
    this.isSearching = false,
  });

  /// Punto actualmente marcado por el pin fijo al centro del mapa.
  final LatLng center;
  final String label;
  final bool isResolvingLabel;
  final List<AddressSuggestion> suggestions;
  final bool isSearching;

  SelectDestinationState copyWith({
    LatLng? center,
    String? label,
    bool? isResolvingLabel,
    List<AddressSuggestion>? suggestions,
    bool? isSearching,
  }) {
    return SelectDestinationState(
      center: center ?? this.center,
      label: label ?? this.label,
      isResolvingLabel: isResolvingLabel ?? this.isResolvingLabel,
      suggestions: suggestions ?? this.suggestions,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
    center,
    label,
    isResolvingLabel,
    suggestions,
    isSearching,
  ];
}
