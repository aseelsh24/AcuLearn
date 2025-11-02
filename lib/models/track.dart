import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

/// Represents a learning track (undergraduate or postgraduate specialty)
@JsonSerializable()
class Track {
  final String id;
  final String name;
  final String academicLevel; // 'undergraduate' or 'postgraduate'
  final String? specialtyModule; // e.g., 'cardiology', 'surgery'
  final String? description;
  final bool isPremium; // For future subscription features
  final DateTime? createdAt;

  Track({
    required this.id,
    required this.name,
    required this.academicLevel,
    this.specialtyModule,
    this.description,
    this.isPremium = false,
    this.createdAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
  Map<String, dynamic> toJson() => _$TrackToJson(this);
}
