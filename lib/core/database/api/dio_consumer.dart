// import 'package:dio/dio.dart';
// import 'package:chatapp/core/database/api/api_consumer.dart';
// import 'package:chatapp/core/database/api/end_points.dart';
// import 'package:chatapp/core/errors/exceptions.dart';

// class DioConsumer extends ApiConsumer {
//   final Dio dio;

//   DioConsumer({required this.dio}) {
//     dio.options.baseUrl = EndPoints.baseUrl;
//   }

//   @override
//   Future<Map<String, dynamic>> delete(String url,
//       {Object? data, Map<String, dynamic>? queryParameters}) async {
//     try {
//       final response =
//           await dio.delete(url, data: data, queryParameters: queryParameters);
//       return response.data;
//     } on DioException catch (e) {
//       // Handle the exception as needed
//       handleDioException(e);
//       rethrow;
//     }
//   }

//   @override
//   Future<Map<String, dynamic>> get(String url,
//       {Object? data, Map<String, dynamic>? queryParameters}) async {
//     try {
//       final response = await dio.get(url, queryParameters: queryParameters);
//       return response.data;
//     } on DioException catch (e) {
//       // Handle the exception as needed
//       handleDioException(e);
//       rethrow;
//     }
//   }

//   @override
//   Future<Map<String, dynamic>> post(String url,
//       {Object? data,
//       Map<String, dynamic>? queryParameters,
//       bool isFormData = false}) async {
//     try {
//       final response = await dio.post(url,
//           data: isFormData
//               ? FormData.fromMap(data as Map<String, dynamic>)
//               : data,
//           queryParameters: queryParameters);
//       return response.data;
//     } on DioException catch (e) {
//       // Handle the exception as needed
//       handleDioException(e);
//       rethrow;
//     }
//   }

//   @override
//   Future<Map<String, dynamic>> put(String url,
//       {Object? data,
//       Map<String, dynamic>? queryParameters,
//       bool isFormData = false}) async {
//     try {
//       final response = await dio.put(url,
//           data: isFormData
//               ? FormData.fromMap(data as Map<String, dynamic>)
//               : data,
//           queryParameters: queryParameters);
//       return response.data;
//     } on DioException catch (e) {
//       // Handle the exception as needed
//       handleDioException(e);
//       rethrow;
//     }
//   }
// }
