
import 'package:whms/untils/app_text.dart';

enum RoleDefine { function, admin, manager, subManager, handler, tasker }

extension RoleDefineExtension on RoleDefine {
  int idRole() {
    switch (this) {
      case RoleDefine.function:
        return -229;
      case RoleDefine.admin:
        return 0;
      case RoleDefine.manager:
        return 10;
      case RoleDefine.subManager:
        return 20;
      case RoleDefine.handler:
        return 30;
      default:
        return 40;
    }
  }

  RoleDefine role(int roleId) {
    switch (roleId) {
      case -229:
        return RoleDefine.function;
      case 0:
        return RoleDefine.admin;
      case 10:
        return RoleDefine.manager;
      case 20:
        return RoleDefine.subManager;
      case 30:
        return RoleDefine.handler;
      default:
        return RoleDefine.tasker;
    }
  }

  static String roleName(int roleId) {
    switch (roleId) {
      case 0:
        return AppText.textAdmin.text;
      case 10:
        return AppText.textManager.text;
      case 20:
        return AppText.textSubManager.text;
      case 30:
        return AppText.textHandler.text;
      default:
        return AppText.textTasker.text;
    }
  }

  static int roleIdByName(String roleName) {
    if (roleName == AppText.textAdmin.text) {
      return 0;
    } else if (roleName == AppText.textManager.text) {
      return 10;
    } else if (roleName == AppText.textSubManager.text) {
      return 20;
    } else if (roleName == AppText.textHandler.text) {
      return 30;
    } else {
      return 40;
    }
  }
}
