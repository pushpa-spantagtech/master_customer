class RemainingDistanceModel {
  double? distance;
  String? distanceText;
  String? duration;
  int? durationSec;
  String? status;
  String? driveMode;
  String? encodedPolyline;

  RemainingDistanceModel(
      {this.distance,
      this.distanceText,
      this.duration,
      this.durationSec,
      this.status,
      this.driveMode,
      this.encodedPolyline});

  RemainingDistanceModel.fromJson(Map<String, dynamic> json) {
    distance = (json['distance'] as num?)?.toDouble() ?? 0.0;
    distanceText = json['distance_text']?.toString() ?? '';
    duration = json['duration']?.toString() ?? '';
    durationSec = (json['duration_sec'] as num?)?.toInt() ?? 0;
    status = json['status']?.toString() ?? '';
    driveMode = json['drive_mode']?.toString() ?? '';
    encodedPolyline = json['encoded_polyline']?.toString() ?? '';
  }
}
