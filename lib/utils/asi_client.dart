import 'package:asi/screens/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AsiClient {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static const String debugUrl = "http://138.68.22.33:8080";
  static const String productionUrl =
      "https://asi-api-test-aerlu.ondigitalocean.app";

  static const String url = isProduction ? productionUrl : productionUrl;

  static Dio get initDio => Dio(
        BaseOptions(
          baseUrl: url,
        ),
      );

  static Dio baseDio = Dio(
    BaseOptions(
      baseUrl: url,
    ),
  );

  static Dio get authDio => baseDio
    ..interceptors.addAll(
      [
        InterceptorsWrapper(onRequest: (options, handler) async {
          final FlutterSecureStorage storage = new FlutterSecureStorage();
          String? token = await storage.read(key: "token");

          options.headers.addAll({"Authorization": "Bearer $token"});

          return handler.next(options);
        }, onResponse: (response, handler) async {
          return handler.next(response);
        }, onError: (dioError, handler) async {
          print("onError");
          if (dioError.response?.statusCode == 500 &&
              dioError.response?.data['message'] ==
                  "Invalid or Expired Token") {
            await Get.offAll(LoginScreen());
            return handler.resolve(dioError.response!);
          } else {
            return handler.next(dioError);
          }
        }),
      ],
    );
}
