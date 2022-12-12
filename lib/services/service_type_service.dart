import 'package:asi/models/api_error.dart';
import 'package:asi/models/service_type.dart';
import 'package:asi/utils/asi_client.dart';
import 'package:dio/dio.dart';

class ServiceTypeService {
  static final Dio _dio = AsiClient.authDio;

  static Future<List<ServiceType>> getServiceTypes() async {
    String uri = "/serviceTypes";

    try {
      Response response = await _dio.get(uri);

      List<ServiceType> serviceTypes = ServiceType.fromJsonList(response.data);
      serviceTypes.retainWhere(
          (service) => service.id != ServiceType.EMBARQUE_DEFAULT_SERVICE_ID);

      return serviceTypes;
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

  static Future<ServiceType> createServiceTypes(String name) async {
    String uri = "/serviceType";

    try {
      Response response = await _dio.post(uri, data: {
        "name": name,
      });

      ServiceType serviceType = ServiceType.fromJson(response.data);

      return serviceType;
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
