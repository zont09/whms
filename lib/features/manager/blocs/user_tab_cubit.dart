import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/defines/role_define.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_text.dart';

class DataTableCubit extends Cubit<int> {
  DataTableCubit() : super(0);

  List<List<String>> data = [];
  List<List<String>> listData = [];
  final TextEditingController conSearch = TextEditingController();
  String filterRole = AppText.textAllRole.text;
  String filterDepartment = AppText.textAllDepartment.text;

  initData() async {
    final listUser = await UserServices.instance.getAllUser();
    for (var user in listUser) {
      if (user.roles > 0) {
        data.add([
          user.id.toString(),
          user.name,
          RoleDefineExtension.roleName(user.roles),
          user.phone,
          user.email,
          user.code,
          user.location
        ]);
      }
    }
    listData = [...data];
    emit(state + 1);
  }

  updateListShow() {
    List<List<String>> list = [...data];
    list = [...updateRole(list)];
    list = [...updateDepartment(list)];
    list = [...updateSearch(list)];
    listData.clear();
    listData = [...list];
    EMIT();
  }

  updateSearch(List<List<String>> listData) {
    return listData.where((e) =>
        conSearch.text.isEmpty ||
        (normalizeString(e[1]).contains(normalizeString(conSearch.text))));
  }

  updateRole(List<List<String>> listData) {
    if (filterRole == AppText.textAllRole.text) return listData;
    return listData.where((e) => e[2] == filterRole).toList();
  }

  updateDepartment(List<List<String>> listData) {
    if (filterDepartment == AppText.textAllDepartment.text) return listData;
    return listData.where((e) => e[6] == filterDepartment).toList();
  }

  onChangeSearch() {
    updateListShow();
  }

  onChangeRole(String v) {
    filterRole = v;
    updateListShow();
  }

  onChangeDepartment(String v) {
    filterDepartment = v;
    updateListShow();
  }

  EMIT() {
    if (!isClosed) {
      emit(state + 1);
    }
  }
}

class NavigatorPageCubit extends Cubit<int> {
  NavigatorPageCubit(maxNum) : super(1) {
    num = maxNum;
  }

  int num = 0;

  updateNum(int newNum) {
    num = newNum;
    if (state > num) {
      emit(1);
    } else {
      emit(state);
    }
  }

  moveTo(int page) {
    if (page != state && 0 < page && page <= num) {
      emit(page);
    }
  }

  nextPage() {
    if (state < num) {
      emit(state + 1);
    }
  }

  previousPage() {
    if (1 < state) {
      emit(state - 1);
    }
  }
}

String normalizeString(String input) {
  // Bản đồ thay thế các ký tự có dấu sang không dấu
  const vietnameseMap = {
    'á': 'a',
    'à': 'a',
    'ả': 'a',
    'ã': 'a',
    'ạ': 'a',
    'ă': 'a',
    'ắ': 'a',
    'ằ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'ặ': 'a',
    'â': 'a',
    'ấ': 'a',
    'ầ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ậ': 'a',
    'é': 'e',
    'è': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ẹ': 'e',
    'ê': 'e',
    'ế': 'e',
    'ề': 'e',
    'ể': 'e',
    'ễ': 'e',
    'ệ': 'e',
    'í': 'i',
    'ì': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'ị': 'i',
    'ó': 'o',
    'ò': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ọ': 'o',
    'ô': 'o',
    'ố': 'o',
    'ồ': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ộ': 'o',
    'ơ': 'o',
    'ớ': 'o',
    'ờ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'ợ': 'o',
    'ú': 'u',
    'ù': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ụ': 'u',
    'ư': 'u',
    'ứ': 'u',
    'ừ': 'u',
    'ử': 'u',
    'ữ': 'u',
    'ự': 'u',
    'ý': 'y',
    'ỳ': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'ỵ': 'y',
    'đ': 'd',
    'Á': 'a',
    'À': 'a',
    'Ả': 'a',
    'Ã': 'a',
    'Ạ': 'a',
    'Ă': 'a',
    'Ắ': 'a',
    'Ằ': 'a',
    'Ẳ': 'a',
    'Ẵ': 'a',
    'Ặ': 'a',
    'Â': 'a',
    'Ấ': 'a',
    'Ầ': 'a',
    'Ẩ': 'a',
    'Ẫ': 'a',
    'Ậ': 'a',
    'É': 'e',
    'È': 'e',
    'Ẻ': 'e',
    'Ẽ': 'e',
    'Ẹ': 'e',
    'Ê': 'e',
    'Ế': 'e',
    'Ề': 'e',
    'Ể': 'e',
    'Ễ': 'e',
    'Ệ': 'e',
    'Í': 'i',
    'Ì': 'i',
    'Ỉ': 'i',
    'Ĩ': 'i',
    'Ị': 'i',
    'Ó': 'o',
    'Ò': 'o',
    'Ỏ': 'o',
    'Õ': 'o',
    'Ọ': 'o',
    'Ô': 'o',
    'Ố': 'o',
    'Ồ': 'o',
    'Ổ': 'o',
    'Ỗ': 'o',
    'Ộ': 'o',
    'Ơ': 'o',
    'Ớ': 'o',
    'Ờ': 'o',
    'Ở': 'o',
    'Ỡ': 'o',
    'Ợ': 'o',
    'Ú': 'u',
    'Ù': 'u',
    'Ủ': 'u',
    'Ũ': 'u',
    'Ụ': 'u',
    'Ư': 'u',
    'Ứ': 'u',
    'Ừ': 'u',
    'Ử': 'u',
    'Ữ': 'u',
    'Ự': 'u',
    'Ý': 'y',
    'Ỳ': 'y',
    'Ỷ': 'y',
    'Ỹ': 'y',
    'Ỵ': 'y',
    'Đ': 'd'
  };

  // Chuyển chuỗi về chữ thường
  String lowercasedInput = input.toLowerCase();

  // Loại bỏ dấu bằng cách thay thế các ký tự có dấu
  String normalized = lowercasedInput.split('').map((char) {
    return vietnameseMap[char] ??
        char; // Thay thế nếu có trong bản đồ, không thì giữ nguyên
  }).join();

  return normalized;
}
