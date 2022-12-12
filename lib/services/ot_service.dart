import 'dart:convert';

import 'package:asi/models/activity.dart';
import 'package:asi/models/api_error.dart';
import 'package:asi/models/ot.dart';
import 'package:asi/models/service_type.dart';
import 'package:asi/utils/asi_client.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class OtService {
  static final Dio dio = AsiClient.authDio;
  static final GetStorage box = GetStorage();

  static Future<List<Ot>> searchOts([int time = 3, String? query]) async {
    String uri = "/works/app-terreno/$time";
    if (query != null && query.isNotEmpty) {
      uri += "/$query";
    }

    try {
      Response response = await dio.get(uri);

      List<Ot> ots = Ot.fromJsonList(response.data);

      ots = ots.map((o) {
        if (o.activities != null) {
          o.activities = o.activities?.map((e) {
            e.isSync = true;
            return e;
          }).toList();
        }
        return o;
      }).toList();

      ots = ots.map<Ot>((o) {
        if (o.activities == null) {
          o.activities = [];
        }
        List<dynamic> localActivities = [];
        if (box.hasData("localActivities")) {
          localActivities = jsonDecode(box.read("localActivities"));
        }
        List<Activity> actualOtLocalActivities = [];
        localActivities.forEach((a) {
          if (a["otId"] == o.id) {
            actualOtLocalActivities.add(Activity.fromJson(a["activity"]));
          }
        });

        o.activities!.addAll(actualOtLocalActivities);

        return o;
      }).toList();

      return ots;
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

  static List<Ot> getPinnedOts() {
    List<Ot> pinnedOts = [];
    String? pinnedOtsString = box.read("pinnedOts");
    if (pinnedOtsString != null) {
      pinnedOts = Ot.fromJsonList(jsonDecode(pinnedOtsString));
    }
    return pinnedOts;
  }

  static bool togglePinOt(Ot newOt) {
    print(box.read("pinnedOts"));
    List<Ot> pinnedOts = OtService.getPinnedOts();

    if (newOt.isPinned) {
      pinnedOts.removeWhere((ot) => ot.id == newOt.id);
    } else {
      pinnedOts.add(newOt);
    }

    box.write(
      "pinnedOts",
      jsonEncode(
        pinnedOts.map((e) => e.toJson()).toList(),
      ),
    );
    return newOt.isPinned;
  }

  static Future<Ot> setOtType(Ot ot, OtType type) async {
    String uri = "/work/app-terreno/${ot.id}";
    late Ot updatedOt;

    try {
      if (type == OtType.embarque) {
        Response response = await dio.put(uri, data: {
          "otType": Ot.EMBARQUE_TYPE,
        });

        response = await dio.put(uri, data: {
          "serviceType": ServiceType.EMBARQUE_DEFAULT_SERVICE_ID,
        });

        updatedOt = Ot.fromJson(response.data);
      } else {
        Response response = await dio.put(uri, data: {
          "otType": Ot.INSPECCION_TYPE,
        });
        updatedOt = Ot.fromJson(response.data);
      }

      updatedOt.activities = updatedOt.activities?.map((e) {
        e.isSync = true;
        return e;
      }).toList();

      return updatedOt;
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

  static Future<Ot> setOtService(Ot ot, String serviceTypeId) async {
    String uri = "/work/app-terreno/${ot.id}";
    late Ot updatedOt;

    try {
      if (ot.otType == OtType.embarque) {
        Response response = await dio.put(uri, data: {
          "serviceType": ServiceType.EMBARQUE_DEFAULT_SERVICE_ID,
        });

        updatedOt = Ot.fromJson(response.data);
      } else {
        Response response = await dio.put(uri, data: {
          "serviceType": serviceTypeId,
        });
        updatedOt = Ot.fromJson(response.data);
      }

      updatedOt.activities = updatedOt.activities?.map((e) {
        e.isSync = true;
        return e;
      }).toList();

      return updatedOt;
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

  static Future<bool> sendReport(Ot ot, String comment) async {
    String uri = "/app-terreno/report";
    late Ot updatedOt;

    try {
      Response response =
          await dio.post(uri, data: {"otId": ot.id, "comment": comment});

      return true;
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

  static Future<Ot> updateTon(
      Ot oldOt, double totalInspected, double balance, DateTime date) async {
    String uri = "/work/app-terreno/${oldOt.id}";
    DateFormat dateTimeFormat = DateFormat("dd/MM/yyyy HH:mm");

    try {
      Response response = await dio.put(uri, data: {
        "totalInspected": totalInspected,
        "totalInspectedDate": dateTimeFormat.format(date),
        "balance": balance,
      });

      Ot ot = Ot.fromJson(response.data["data"]);

      ot.activities = ot.activities?.map((e) {
        e.isSync = true;
        return e;
      }).toList();

      return ot;
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
}
