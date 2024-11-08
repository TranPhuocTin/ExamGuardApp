import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'detect_cheating.g.dart';

enum InfractionType {
  @JsonValue('Face')
  face,
  @JsonValue('Switch_Tab')
  switchTab,
  @JsonValue('Screen Capture')
  screenCapture,
}

@JsonSerializable()
class DetectCheating extends Equatable {
  final InfractionType infractionType;
  final String description;

  DetectCheating({required this.infractionType, required this.description});

  factory DetectCheating.fromJson(Map<String, dynamic> json) => _$DetectCheatingFromJson(json);

  Map<String, dynamic> toJson() => _$DetectCheatingToJson(this);

  @override
  List<Object?> get props => [infractionType, description];
}
