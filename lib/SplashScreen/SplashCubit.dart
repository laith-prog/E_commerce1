import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<void> {
  SplashCubit() : super(null);

  Future<void> navigateToLogin(Function navigateCallback) async {
    await Future.delayed(Duration(seconds: 3));
    navigateCallback();
  }
}
