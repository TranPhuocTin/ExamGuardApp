import 'package:equatable/equatable.dart';
import '../model/cheating_statistics_response.dart';

abstract class CheatingStatisticsState extends Equatable {
  const CheatingStatisticsState();

  @override
  List<Object?> get props => [];
}

class CheatingStatisticsInitial extends CheatingStatisticsState {}

class CheatingStatisticsLoading extends CheatingStatisticsState {}

class CheatingStatisticsLoaded extends CheatingStatisticsState {
  final List<CheatingStatistic> statistics;
  final bool hasReachedMax;
  
  const CheatingStatisticsLoaded({
    required this.statistics,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [statistics, hasReachedMax];

  CheatingStatisticsLoaded copyWith({
    List<CheatingStatistic>? statistics,
    bool? hasReachedMax,
  }) {
    return CheatingStatisticsLoaded(
      statistics: statistics ?? this.statistics,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class CheatingStatisticsError extends CheatingStatisticsState {
  final String message;

  const CheatingStatisticsError(this.message);

  @override
  List<Object> get props => [message];
}