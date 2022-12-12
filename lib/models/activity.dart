import 'package:asi/models/task.dart';
import 'package:asi/models/user.dart';
import 'package:intl/intl.dart';

class Activity {
  String? id;
  String? name;
  Task? task;
  DateTime? activityDate;
  DateTime? createdAt;
  String? description;
  List<dynamic>? images;
  dynamic ton;
  User? createdBy;
  bool isSync;

  Activity({
    this.id,
    this.name,
    this.task,
    this.activityDate,
    this.description,
    this.images,
    this.ton,
    this.createdBy,
    this.createdAt,
    required this.isSync,
  });

  factory Activity.fromJson(dynamic json) {
    if (json is Map) {
      return Activity(
        id: json["_id"],
        name: json["name"],
        task: json["task"] != null ? Task.fromJson(json["task"]) : null,
        activityDate: json["activityDate"] != null
            ? DateFormat('dd/MM/yyyy HH:mm').parse(json["activityDate"])
            : null,
        description: json["description"],
        images: json["images"],
        ton: json["ton"],
        createdBy:
            json["createdBy"] != null ? User.fromJson(json["createdBy"]) : null,
        isSync: json["isSync"] ?? false,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
      );
    } else {
      return Activity(id: json, isSync: false);
    }
  }

  static List<Activity> fromJsonList(dynamic json) {
    if (json == null) {
      return [];
    }
    List<Activity> list = [];
    for (var item in json) {
      list.add(Activity.fromJson(item));
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "task": task?.toJson(),
        "activityDate": activityDate != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(activityDate!)
            : null,
        "description": description,
        "images": images,
        "ton": ton,
        "createdBy": createdBy?.toJson(),
        "isSync": isSync,
        "createdAt": createdAt?.toIso8601String(),
      };
}
