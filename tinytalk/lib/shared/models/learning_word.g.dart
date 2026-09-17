// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LearningWordImpl _$$LearningWordImplFromJson(Map<String, dynamic> json) =>
    _$LearningWordImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      titleEs: json['titleEs'] as String?,
      image: json['image'] as String,
      audio: json['audio'] as String,
      audioEs: json['audioEs'] as String?,
      audioEn: json['audioEn'] as String?,
      category: json['category'] as String,
      animation: json['animation'] as String?,
      difficultyLevel: (json['difficultyLevel'] as num).toInt(),
    );

Map<String, dynamic> _$$LearningWordImplToJson(_$LearningWordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'titleEs': instance.titleEs,
      'image': instance.image,
      'audio': instance.audio,
      'audioEs': instance.audioEs,
      'audioEn': instance.audioEn,
      'category': instance.category,
      'animation': instance.animation,
      'difficultyLevel': instance.difficultyLevel,
    };
