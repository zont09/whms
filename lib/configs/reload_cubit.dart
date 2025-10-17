import 'package:flutter_bloc/flutter_bloc.dart';

enum ReloadEvent { home, overview, manager, hr, okrs, improve }

class ReloadModel {
  final ReloadEvent event;
  final int index;

  ReloadModel(this.event, this.index);
}

class ReloadCubit extends Cubit<ReloadModel?> {
  int index = 0;

  ReloadCubit() : super(null);

  reload(ReloadEvent event) {
    index++;
    emit(ReloadModel(event, index));
  }
}