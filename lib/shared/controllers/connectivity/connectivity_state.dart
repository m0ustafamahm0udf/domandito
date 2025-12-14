part of 'connectivity_cubit.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();
}

class ConnectivityStatus extends ConnectivityState {
  final bool hasConnection;

  const ConnectivityStatus({required this.hasConnection});

  @override
  List<Object> get props => [hasConnection];
}
