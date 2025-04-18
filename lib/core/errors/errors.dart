import 'package:chatapp/core/errors/failure.dart';
import 'dart:async';
import 'dart:io';

/// Failure when there is no internet connection.
class OfflineFailure implements Failure {
  @override
  String get message => "No Internet Connection";
}

/// Failure when there is a server-related error.
class ServerFailure implements Failure {
  @override
  String get message => "Server Error. Please try again later.";
}

/// Failure when the request times out.
class TimeoutFailure implements Failure {
  @override
  String get message => "Request timed out. Please check your connection.";
}

/// Failure related to cache/data not found.
class CacheFailure implements Failure {
  @override
  String get message => "Cache Error. Data not found.";
}

/// Failure for unauthorized access (e.g. HTTP 401).
class UnauthorizedFailure implements Failure {
  @override
  String get message => "Unauthorized. Please login again.";
}

/// Failure when a resource is not found (e.g. HTTP 404).
class NotFoundFailure implements Failure {
  @override
  String get message => "Requested resource not found.";
}

/// Failure when there's a data conflict (e.g. HTTP 409).
class ConflictFailure implements Failure {
  @override
  String get message => "Conflict detected. Please try again.";
}

/// Failure for unexpected or unknown errors.
class UnknownFailure implements Failure {
  @override
  String get message => "An unexpected error occurred.";
}

/// Failure when a response has an invalid format.
class FormatFailure implements Failure {
  @override
  String get message => "Data format error. Please contact support.";
}

/// Failure when SSL handshake or certificate verification fails.
class SSLFailure implements Failure {
  @override
  String get message => "SSL Handshake failed. Check certificate or internet.";
}

/// Maps known exception types to their corresponding [Failure] class.
Failure handleException(Exception e) {
  if (e is TimeoutException) {
    return TimeoutFailure();
  } else if (e is SocketException) {
    return OfflineFailure();
  } else if (e is HttpException) {
    return ServerFailure();
  } else if (e is FormatException) {
    return FormatFailure();
  } else if (e is HandshakeException) {
    return SSLFailure();
  } else {
    return UnknownFailure();
  }
}
