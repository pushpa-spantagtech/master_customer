class OutstationTariffModel {
  bool? status;
  List<OutstationTariff>? data;

  OutstationTariffModel({
    this.status,
    this.data,
  });

  OutstationTariffModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <OutstationTariff>[];
      json['data'].forEach((v) {
        data!.add(OutstationTariff.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['status'] = status;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class OutstationTariff {
  int? id;
  String? vehicleType;
  int? baseKm;
  String? baseFare;
  String? extraPerKm;
  String? extraPerHour;
  String? extraPerMinute;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  OutstationTariff({
    this.id,
    this.vehicleType,
    this.baseKm,
    this.baseFare,
    this.extraPerKm,
    this.extraPerHour,
    this.extraPerMinute,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  OutstationTariff.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vehicleType = json['vehicle_type'];
    baseKm = json['base_km'];
    baseFare = json['base_fare'];
    extraPerKm = json['extra_per_km'];
    extraPerHour = json['extra_per_hour'];
    extraPerMinute = json['extra_per_minute'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['vehicle_type'] = vehicleType;
    data['base_km'] = baseKm;
    data['base_fare'] = baseFare;
    data['extra_per_km'] = extraPerKm;
    data['extra_per_hour'] = extraPerHour;
    data['extra_per_minute'] = extraPerMinute;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
