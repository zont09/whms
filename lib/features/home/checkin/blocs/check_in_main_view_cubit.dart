import 'package:flutter_bloc/flutter_bloc.dart';

class CheckInMainViewCubit extends Cubit<int> {
  CheckInMainViewCubit() : super(0);

  bool isShowSelectTime = false;

  changeStatusSelectTime() {
    isShowSelectTime = !isShowSelectTime;
    EMIT();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}