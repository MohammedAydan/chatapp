import 'package:data_connection_checker_tv/data_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool>? get isConnected;
  Stream<DataConnectionStatus> onStatusChange();
}

class NetworkInfoImpl implements NetworkInfo {
  final DataConnectionChecker dataConnectionChecker;

  NetworkInfoImpl(this.dataConnectionChecker);

  @override
  Future<bool>? get isConnected => dataConnectionChecker.hasConnection;

  @override
  Stream<DataConnectionStatus> onStatusChange() {
    return dataConnectionChecker.onStatusChange;
  }
}
