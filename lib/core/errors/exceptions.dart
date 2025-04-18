import 'package:chatapp/core/errors/error_model.dart';

/// Exception thrown when there is a server error.
class ServerException implements Exception {
  final ErrorModel errorModel;
  ServerException(this.errorModel);
}

/// Exception thrown when there is a cache error.
class CacheException implements Exception {
  final String errorMessage;
  CacheException(this.errorMessage);
}

/// Exception thrown when there is a bad certificate error.
class BadCertificateException extends ServerException {
  BadCertificateException(super.errorModel);
}

/// Exception thrown when there is a connection timeout error.
class ConnectionTimeoutException extends ServerException {
  ConnectionTimeoutException(super.errorModel);
}

/// Exception thrown when there is a bad request error.
class BadRequestException extends ServerException {
  BadRequestException(super.errorModel);
}

/// Exception thrown when there is a receive timeout error.
class ReceiveTimeoutException extends ServerException {
  ReceiveTimeoutException(super.errorModel);
}

/// Exception thrown when there is a connection error.
class ConnectedErrorException extends ServerException {
  ConnectedErrorException(super.errorModel);
}

/// Exception thrown when there is a send timeout error.
class SendTimeoutException extends ServerException {
  SendTimeoutException(super.errorModel);
}

/// Exception thrown when there is an unauthorized error.
class UnauthorizedException extends ServerException {
  UnauthorizedException(super.errorModel);
}

/// Exception thrown when there is a forbidden error.
class ForbiddenException extends ServerException {
  ForbiddenException(super.errorModel);
}

/// Exception thrown when there is a not found error.
class NotFoundException extends ServerException {
  NotFoundException(super.errorModel);
}

/// Exception thrown when there is a conflict error.
class ConflictException extends ServerException {
  ConflictException(super.errorModel);
}

/// Exception thrown when there is an internal server error.
class InternalServerErrorException extends ServerException {
  InternalServerErrorException(super.errorModel);
}

/// Exception thrown when the service is unavailable.
class ServiceUnavailableException extends ServerException {
  ServiceUnavailableException(super.errorModel);
}

class OfflineException extends ServerException {
  OfflineException(super.errorModel);
}

/// Handles Dio exceptions and throws custom exceptions based on the type of DioException.
///
/// The function takes a [DioException] as a parameter and throws a specific custom exception
/// based on the type of the DioException. The custom exceptions are created using the
/// [ErrorModel] class which is populated from the response data.
///
/// The following custom exceptions are thrown based on the DioException type:
/// - [ConnectedErrorException] for [DioExceptionType.connectionError]
/// - [BadCertificateException] for [DioExceptionType.badCertificate]
/// - [ConnectionTimeoutException] for [DioExceptionType.connectionTimeout]
/// - [ReceiveTimeoutException] for [DioExceptionType.receiveTimeout]
/// - [SendTimeoutException] for [DioExceptionType.sendTimeout]
/// - [BadRequestException], [UnauthorizedException], [ForbiddenException], [NotFoundException],
///   [ConflictException], [InternalServerErrorException], [ServiceUnavailableException], or
///   [ServerException] for [DioExceptionType.badResponse] based on the response status code
/// - [ServerException] for [DioExceptionType.cancel] with a status of 499 and a specific error message
/// - [ServerException] for [DioExceptionType.unknown] with a status of 500 and a specific error message
///
/// Throws:
/// - [ConnectedErrorException]
/// - [BadCertificateException]
/// - [ConnectionTimeoutException]
/// - [ReceiveTimeoutException]
/// - [SendTimeoutException]
/// - [BadRequestException]
/// - [UnauthorizedException]
/// - [ForbiddenException]
/// - [NotFoundException]
/// - [ConflictException]
/// - [InternalServerErrorException]
/// - [ServiceUnavailableException]
/// - [ServerException]
///
/// Example usage:
/// ```dart
/// try {
///   // Some Dio request
/// } on DioException catch (e) {
///   handleDioException(e);
/// }
/// ```

// void handleDioException(DioException e) {
//   switch (e.type) {
//     case DioExceptionType.connectionError:
//       throw ConnectedErrorException(ErrorModel.fromJson(e.response!.data));
//     case DioExceptionType.badCertificate:
//       throw BadCertificateException(ErrorModel.fromJson(e.response!.data));
//     case DioExceptionType.connectionTimeout:
//       throw ConnectionTimeoutException(ErrorModel.fromJson(e.response!.data));
//     case DioExceptionType.receiveTimeout:
//       throw ReceiveTimeoutException(ErrorModel.fromJson(e.response!.data));
//     case DioExceptionType.sendTimeout:
//       throw SendTimeoutException(ErrorModel.fromJson(e.response!.data));
//     case DioExceptionType.badResponse:
//       switch (e.response?.statusCode) {
//         case 400:
//           throw BadRequestException(ErrorModel.fromJson(e.response!.data));
//         case 401:
//           throw UnauthorizedException(ErrorModel.fromJson(e.response!.data));
//         case 403:
//           throw ForbiddenException(ErrorModel.fromJson(e.response!.data));
//         case 404:
//           throw NotFoundException(ErrorModel.fromJson(e.response!.data));
//         case 409:
//           throw ConflictException(ErrorModel.fromJson(e.response!.data));
//         case 500:
//           throw InternalServerErrorException(
//             ErrorModel.fromJson(e.response!.data),
//           );
//         case 503:
//           throw ServiceUnavailableException(
//             ErrorModel.fromJson(e.response!.data),
//           );
//         default:
//           throw ServerException(ErrorModel.fromJson(e.response!.data));
//       }
//     case DioExceptionType.cancel:
//       throw ServerException(
//         ErrorModel(
//           status: 499,
//           errorMessage: 'Request to API server was cancelled',
//         ),
//       );
//     case DioExceptionType.unknown:
//       throw ServerException(
//         ErrorModel(
//           status: 500,
//           errorMessage:
//               'Connection to API server failed due to internet connection',
//         ),
//       );
//   }
// }

// void handleFirebaseException(FirebaseException e) {
//   switch (e.code) {
//     case 'permission-denied':
//       throw UnauthorizedException(
//         ErrorModel(
//           status: 403,
//           errorMessage: 'You do not have permission to access this resource.',
//         ),
//       );
//     case 'not-found':
//       throw NotFoundException(
//         ErrorModel(
//           status: 404,
//           errorMessage: 'The requested resource was not found.',
//         ),
//       );
//     case 'already-exists':
//       throw ConflictException(
//         ErrorModel(status: 409, errorMessage: 'The resource already exists.'),
//       );
//     case 'unavailable':
//       throw ServiceUnavailableException(
//         ErrorModel(
//           status: 503,
//           errorMessage: 'The service is currently unavailable.',
//         ),
//       );
//     case 'deadline-exceeded':
//       throw ConnectionTimeoutException(
//         ErrorModel(status: 408, errorMessage: 'The request timed out.'),
//       );
//     default:
//       throw ServerException(
//         ErrorModel(status: 500, errorMessage: 'An unknown error occurred.'),
//       );
//   }
// }


