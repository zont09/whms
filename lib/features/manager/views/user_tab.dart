import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/manager/views/list_user_view.dart';
import 'package:whms/features/manager/views/user_information_view.dart';
import 'package:whms/untils/app_text.dart';

class UserTab extends StatelessWidget {
  const UserTab({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controllerSearch = TextEditingController();
    final List<String> listHeader = [
      AppText.titleName.text,
      AppText.titlePosition.text,
      AppText.titlePhone.text,
      AppText.titleEmail.text,
      AppText.titleIdStaff.text,
      AppText.titleDepartments.text
    ];
    final List<int> listWeight = [3, 3, 2, 4, 2, 2];
    const int dataPerPage = 15;
    return BlocProvider(
      create: (context) => UserTabCubit(),
      child: BlocBuilder<UserTabCubit, int>(
        builder: (c, s) {
          var cubit = BlocProvider.of<UserTabCubit>(c);
          if (cubit.mode == 0) {
            return ListUserView(
              cubitUser: cubit,
                controllerSearch: controllerSearch,
                dataPerPage: dataPerPage,
                listHeader: listHeader,
                listWeight: listWeight);
          }
          return UserInformationView(cubit: cubit, isEdit: true,);
        },
      ),
    );
  }
}

class UserTabCubit extends Cubit<int> {
  UserTabCubit() : super(0);

  int mode = 0; // 0: List user || 1: Add user

  changeMode(int newMode) {
    mode = newMode;
    emit(state + 1);
  }
}
