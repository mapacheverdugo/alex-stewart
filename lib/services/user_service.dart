import 'dart:convert';

import 'package:asi/models/api_error.dart';
import 'package:asi/models/user.dart';
import 'package:asi/utils/asi_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

class UserService {
  static final Dio dio = AsiClient.initDio;
  static final GetStorage box = GetStorage();
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  static Future<User> login(String email, String password) async {
    String uri = "/auth/login";

    try {
      dynamic data = {'email': email, 'password': password};

      Response response = await dio.post(uri, data: data);

      User user = User.fromJson(response.data);

      box.write("id", user.id);
      box.write("user", jsonEncode(user.toJson()));

      await secureStorage.write(key: "token", value: user.token);

      return user;
    } on DioError catch (e) {
      print(e);
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

  static User? getLocalUser() {
    try {
      String? userJson = box.read("user");

      print(userJson);

      if (userJson != null) {
        User user = User.fromJson(jsonDecode(userJson));
        return user;
      }

      return null;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  static Future<bool> isFirstOpen() async {
    try {
      bool? isFirstOpen = box.read("isFirstOpen");
      return isFirstOpen ?? true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      String? accessToken = await secureStorage.read(key: "token");
      bool isLoggedIn = accessToken?.isNotEmpty ?? false;

      if (!isLoggedIn) {
        await logOut();
      }

      return isLoggedIn;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<void> logOut() async {
    try {
      box.remove("id");
      box.remove("user");
      await secureStorage.deleteAll();
    } catch (e) {
      throw e;
    }
  }

  static Future passwordRecoverySendEmail(String email) async {
    String uri = "/auth/recoverPassword";

    try {
      return await dio.post(uri, data: {"email": email});
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

  static Future passwordRecoveryChangePassword(
      String code, String newPassword) async {
    String uri = "/auth/changePassword";

    try {
      Response response =
          await dio.post(uri, data: {"code": code, "password": newPassword});
      if (response.data["httpCode"] != null &&
          response.data["httpCode"] != 200) {
        throw ApiError.fromJson(response.data);
      } else {
        return response;
      }
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
