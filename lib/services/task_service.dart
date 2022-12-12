import 'package:asi/models/api_error.dart';
import 'package:asi/models/task.dart';
import 'package:asi/utils/asi_client.dart';
import 'package:dio/dio.dart';

class TaskService {
  static final Dio _dio = AsiClient.authDio;

  static Future<List<Task>> getTasks() async {
    String uri = "/tasks";

    try {
      Response response = await _dio.get(uri);

      List<Task> tasks = Task.fromJsonList(response.data);

      return tasks;
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
