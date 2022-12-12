class Task {
  static const String EMERGENCY_TASK_ID = "616f222496621b4094b26790";

  String? id;
  String? name;
  bool? tonIsRequired;
  String? activity;

  Task({this.id, this.name, this.tonIsRequired, this.activity});

  factory Task.fromJson(dynamic json) {
    if (json is Map) {
      return Task(
        id: json["_id"],
        name: json["name"],
        tonIsRequired: json["tonIsRequired"],
        activity: json["activity"],
      );
    } else {
      return Task(
        id: json,
      );
    }
  }

  static List<Task> fromJsonList(dynamic json) {
    if (json == null) {
      return [];
    }
    List<Task> list = [];
    for (var item in json) {
      list.add(Task.fromJson(item));
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "tonIsRequired": tonIsRequired,
        "activity": activity,
      };
}
