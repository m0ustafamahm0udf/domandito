import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/connectivity/connectivity.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit()
      : super(ConnectivityStatus(
            hasConnection: ConnectivityHandler().hasConnection)) {
    listen();
  }

  static ConnectivityCubit get(context) => BlocProvider.of(context);
  bool isInternet = false;
  listen() {
    ConnectivityHandler().start().listen((data) {
      isInternet = data != ConnectivityResult.none;
      emit(ConnectivityStatus(hasConnection: data != ConnectivityResult.none));
    });
  }
}
