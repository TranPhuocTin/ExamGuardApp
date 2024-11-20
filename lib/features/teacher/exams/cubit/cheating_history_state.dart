import 'package:equatable/equatable.dart';
import '../model/cheating_history_response.dart';

abstract class CheatingHistoryState extends Equatable {
  const CheatingHistoryState();

  @override
  List<Object?> get props => [];
}

class CheatingHistoryInitial extends CheatingHistoryState {}

class CheatingHistoryLoading extends CheatingHistoryState {}

class CheatingHistoryLoaded extends CheatingHistoryState {
  final List<CheatingHistory> histories;
  final String? selectedFilter;
  final bool hasReachedMax;

  CheatingHistoryLoaded({
    required this.histories,
    this.selectedFilter,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [histories, selectedFilter, hasReachedMax];

  CheatingHistoryLoaded copyWith({
    List<CheatingHistory>? histories,
    String? selectedFilter,
    bool? hasReachedMax,
  }) {
    return CheatingHistoryLoaded(
      histories: histories ?? this.histories,
      selectedFilter: selectedFilter,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class CheatingHistoryError extends CheatingHistoryState {
  final String message;

  const CheatingHistoryError(this.message);

  @override
  List<Object> get props => [message];
} 