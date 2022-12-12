class ServiceType {
  static const String EMBARQUE_DEFAULT_SERVICE_ID = "6160b09f2401b00cd1e3e131";

  String? id;
  String? name;

  ServiceType({this.id, this.name});

  factory ServiceType.fromJson(dynamic json) {
    if (json is Map) {
      return ServiceType(
        id: json["_id"],
        name: json["name"],
      );
    } else {
      return ServiceType(
        id: json,
      );
    }
  }

  static List<ServiceType> fromJsonList(dynamic json) {
    if (json == null) {
      return [];
    }
    List<ServiceType> list = [];
    for (var item in json) {
      list.add(ServiceType.fromJson(item));
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}
