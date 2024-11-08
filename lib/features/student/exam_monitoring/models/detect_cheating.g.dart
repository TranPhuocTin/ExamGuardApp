// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detect_cheating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectCheating _$DetectCheatingFromJson(Map<String, dynamic> json) =>
    DetectCheating(
      infractionType:
          $enumDecode(_$InfractionTypeEnumMap, json['infractionType']),
      description: json['description'] as String,
    );

Map<String, dynamic> _$DetectCheatingToJson(DetectCheating instance) =>
    <String, dynamic>{
      'infractionType': _$InfractionTypeEnumMap[instance.infractionType]!,
      'description': instance.description,
    };

const _$InfractionTypeEnumMap = {
  InfractionType.face: 'Face',
  InfractionType.switchTab: 'Switch_Tab',
  InfractionType.screenCapture: 'Screen Capture',
};
