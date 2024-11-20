import 'package:json_annotation/json_annotation.dart';

part 'cheating_history_response.g.dart';

@JsonSerializable()
class CheatingHistoryResponse {
  final String message;
  final int status;
  final CheatingHistoryMetadata metadata;

  CheatingHistoryResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory CheatingHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CheatingHistoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CheatingHistoryResponseToJson(this);
}

@JsonSerializable()
class CheatingHistoryMetadata {
  final int total;
  final int totalPages;
  @JsonKey(name: 'cheatingHistories')
  final List<CheatingHistory> histories;

  CheatingHistoryMetadata({
    required this.total,
    required this.totalPages,
    required this.histories,
  });

  factory CheatingHistoryMetadata.fromJson(Map<String, dynamic> json) =>
      _$CheatingHistoryMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$CheatingHistoryMetadataToJson(this);
}

@JsonSerializable()
class CheatingHistory {
  @JsonKey(name: '_id')
  final String id;
  final String infractionType;
  final String description;
  // final String? student;
  final String exam;
  // final DateTime createdAt;
  final DateTime updatedAt;

  CheatingHistory({
    required this.id,
    required this.infractionType,
    required this.description,
    // this.student,
    required this.exam,
    // required this.createdAt,
    required this.updatedAt,
  });

  factory CheatingHistory.fromJson(Map<String, dynamic> json) =>
      _$CheatingHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$CheatingHistoryToJson(this);
}
