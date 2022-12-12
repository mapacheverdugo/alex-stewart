import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:asi/models/activity.dart';
import 'package:asi/models/api_error.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/models/user.dart';
import 'package:asi/services/user_service.dart';
import 'package:asi/utils/asi_client.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class ActivityService {
  static final Dio _dio = AsiClient.authDio;
  static final GetStorage box = GetStorage();

  static Future<List<Activity>> getActivities() async {
    String uri = "/activities";

    try {
      Response response = await _dio.get(uri);

      List<Activity> activities = Activity.fromJsonList(response.data);

      activities = activities.map((e) {
        e.isSync = true;
        return e;
      }).toList();

      return activities;
    } on DioError catch (e) {
      if (e.response?.data != null &&
          (e.type == DioErrorType.response || e.type == DioErrorType.other)) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        throw e;
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Ot> createActivity(
      Activity activity, Ot ot, List<Uint8List> images) async {
    bool hasInternetConnection = await checkInternetConnection();
    if (!hasInternetConnection) {
      Activity newLocalActivity = createLocalActivity(activity, ot, images);
      ot.activities?.add(newLocalActivity);
      return ot;
    } else {
      Activity newNetworkActivity =
          await createNetworkActivity(activity, ot, images);
      return addActivitiesToOt(ot.id!, [newNetworkActivity.id!]);
    }
  }

  static Activity createLocalActivity(
      Activity activity, Ot ot, List<Uint8List> images) {
    late String localId = "0";
    if (box.hasData("lastLocalActivityId")) {
      localId = box.read("lastLocalActivityId").toString();
    }

    List<dynamic> localActivities = [];
    if (box.hasData("localActivities")) {
      localActivities = jsonDecode(box.read("localActivities"));
    }

    activity.isSync = false;
    Map<String, dynamic> localActivityMap = {
      "id": localId,
      "activity": activity.toJson(),
      "otId": ot.id,
      "images": images.map((e) => base64Encode(e)).toList()
    };

    localActivities.add(localActivityMap);
    box.write("localActivities", jsonEncode(localActivities));
    box.write("lastLocalActivityId", int.parse(localId) + 1);

    return activity;
  }

  static void removeLocalActivity(String localActivityId) {
    List<dynamic> localActivities = [];
    if (box.hasData("localActivities")) {
      localActivities = jsonDecode(box.read("localActivities"));
    }

    localActivities.removeWhere((e) => e["id"] == localActivityId);
    box.write("localActivities", jsonEncode(localActivities));
  }

  static Future<Activity> createNetworkActivity(
      Activity activity, Ot ot, List<Uint8List> images) async {
    try {
      String activityUri = "/activity";
      FormData formData;
      User? user = UserService.getLocalUser();
      if (images.length > 0) {
        formData = FormData.fromMap({
          "name": activity.name,
          "task": activity.task?.id,
          "ot": ot.id,
          "activityDate":
              DateFormat('dd/MM/yyyy HH:mm').format(activity.activityDate!),
          "description": activity.description,
          "ton": activity.ton,
          "createdBy": user?.id,
          "images": images.asMap().entries.map((entry) {
            Uint8List image = entry.value;
            DateTime now = DateTime.now();
            return MultipartFile.fromBytes(
              image,
              contentType: MediaType("image", "jpg"),
              filename: "${now.millisecondsSinceEpoch}_${entry.key}.jpg",
            );
          }).toList(),
        });
      } else {
        formData = FormData.fromMap({
          "name": activity.name,
          "task": activity.task?.id,
          "ot": ot.id,
          "activityDate":
              DateFormat('dd/MM/yyyy HH:mm').format(activity.activityDate!),
          "description": activity.description,
          "ton": activity.ton,
          "createdBy": user?.id,
        });
      }

      Response activityResponse = await _dio.post(activityUri, data: formData);

      Activity newActivity = Activity.fromJson(activityResponse.data);
      newActivity.isSync = true;

      return newActivity;
    } on DioError catch (e) {
      if (e.response?.data != null &&
          (e.type == DioErrorType.response || e.type == DioErrorType.other)) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        log(e.toString());
        throw e;
      }
    } catch (e) {
      log(e.toString());
      throw e;
    }
  }

  static Future<Ot> addActivitiesToOt(
      String otId, List<String> newActivities) async {
    try {
      String otUri = "/work/app-terreno/$otId";
      Response otResponse = await _dio.put(otUri, data: {
        "newActivities": newActivities,
      });

      Ot newOt = Ot.fromJson(otResponse.data);
      newOt.activities = newOt.activities?.map((e) {
        e.isSync = true;
        return e;
      }).toList();

      return newOt;
    } on DioError catch (e) {
      if (e.response?.data != null &&
          (e.type == DioErrorType.response || e.type == DioErrorType.other)) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        log(e.toString());
        throw e;
      }
    } catch (e) {
      log(e.toString());
      throw e;
    }
  }

  static Future<bool> syncActivities() async {
    bool hasInternetConnection = await checkInternetConnection();
    if (hasInternetConnection) {
      List<dynamic> localActivities = [];
      if (box.hasData("localActivities")) {
        localActivities = jsonDecode(box.read("localActivities"));
      }

      try {
        Map<String, List<String>> activitiesToSync = {};
        log(localActivities.toString());
        for (var e in localActivities) {
          String otId = e["otId"];
          String localActivityId = e["id"];
          Activity activity = Activity.fromJson(e["activity"]);

          List<Uint8List> images = [];
          e["images"].forEach((image) {
            images.add(base64Decode(image));
          });
          Activity newNetworkActivity =
              await createNetworkActivity(activity, Ot(id: otId), images);

          removeLocalActivity(localActivityId);
          if (activitiesToSync[otId] == null) {
            activitiesToSync[otId] = [];
          }
          activitiesToSync[otId]!.add(newNetworkActivity.id!);
        }
        log(activitiesToSync.toString());
        for (String otId in activitiesToSync.keys) {
          await addActivitiesToOt(otId, activitiesToSync[otId]!);
        }
        return true;
      } catch (e) {
        throw e;
      }
    } else {
      return false;
    }
  }

  static Future<Ot> editActivity(Activity activity, Ot ot) async {
    try {
      String activityUri = "/activity/${activity.id}";

      Response activityResponse = await _dio.put(activityUri, data: {
        "activityDate":
            DateFormat('dd/MM/yyyy HH:mm').format(activity.activityDate!),
        "description": activity.description,
        "ton": activity.ton,
      });

      Activity newActivity = Activity.fromJson(activityResponse.data);
      newActivity.isSync = true;

      ot.activities = ot.activities?.map((activity) {
        if (activity.id == newActivity.id) {
          return newActivity;
        } else {
          return activity;
        }
      }).toList();

      return ot;
    } on DioError catch (e) {
      if (e.response?.data != null &&
          (e.type == DioErrorType.response || e.type == DioErrorType.other)) {
        throw ApiError.fromJson(e.response!.data);
      } else {
        log(e.toString());
        throw e;
      }
    } catch (e) {
      log(e.toString());
      throw e;
    }
  }
}
