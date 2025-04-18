class Failure {
  final String message;
  const Failure(this.message);
}

/// Custom Failure for Firebase-related errors.
class FirebaseFailure implements Failure {
  final String error;
  FirebaseFailure(this.error);

  @override
  String get message => error;
}
