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
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Exam({
    this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
  Map<String, dynamic> toJson() => _$ExamToJson(this);

  @override
  List<Object?> get props => [id, title, description, startTime, endTime, status, createdAt, updatedAt];

  Exam copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }
}
