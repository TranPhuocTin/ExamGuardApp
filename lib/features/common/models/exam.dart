import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'exam.g.dart';

enum ExamStatus { scheduled, inProgress, completed }

@JsonSerializable()
class Exam extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String title;
  final String description;
  final int? questionCount;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
   @JsonKey(defaultValue: null)
  final int? duration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Exam({
    this.id,
    required this.title,
    required this.description,
    this.questionCount,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
  Map<String, dynamic> toJson() => _$ExamToJson(this);

  @override
  List<Object?> get props => [id, title, description, questionCount, startTime, endTime, status, duration, createdAt, updatedAt];

  Exam copyWith({
    String? id,
    String? title,
    String? description,
    int? questionCount,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    int? duration,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questionCount: questionCount ?? this.questionCount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      duration: duration ?? this.duration,
    );
  }
}
