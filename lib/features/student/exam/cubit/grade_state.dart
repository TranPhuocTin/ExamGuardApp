abstract class GradeState {}

class GradeInitial extends GradeState {}

class GradeLoading extends GradeState {}

class GradeLoaded extends GradeState {
  final int score;
  final DateTime createdAt;
  final DateTime updatedAt;

  GradeLoaded({
    required this.score,
    required this.createdAt,
    required this.updatedAt,
  });
}

class GradeError extends GradeState {
  final String message;

  GradeError(this.message);
} 