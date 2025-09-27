import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/pref_keys.dart';
import 'package:whms/repositories/caches_repository.dart';
import 'package:whms/repositories/configs_repository.dart';
import 'package:whms/services/scope_service.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/date_time_utils.dart';

class ConfigsCubit extends Cubit<ConfigsState> {
  ConfigsCubit() : super(ConfigsState(updatedEvent: ConfigStateEvent.init));

  static ConfigsCubit fromContext(BuildContext context) =>
      BlocProvider.of<ConfigsCubit>(context);

  late final ConfigsRepository _configsRepository;
  late final CachesRepository _cachesRepository;

  int get role => _configsRepository.role;

  UserModel get user => _configsRepository.user;

  //  ==================> CACHE TAB <==================
  final String keySaveTabMainTab = 'save_tab_main_tab';
  final String keySaveTabOverview = 'save_tab_over_view';
  final String keySaveTabManagement = 'save_tab_management';
  final String keySaveTabHr = 'save_tab_hr';
  final String keySaveTabOKRs = 'save_tab_okrs';
  final String keySaveTabIssue = 'save_tab_issue';

  //   // ==================> CHECKLIST ITEM <==================
  //   List<StaffChecklistItemModel> get allChecklistItems =>
  //       _cachesRepository.allChecklistItems;
  //
  //   List<StaffChecklistTemplateModel> get allChecklistTemplates =>
  //       _cachesRepository.allChecklistTemplates;
  //
  //   Map<String, StaffChecklistItemModel> get mapChecklistItem =>
  //       _cachesRepository.mapChecklistItem;
  //
  //   // ==================> PROCESS <==================
  //   List<ProcessModel> get allProcess => _cachesRepository.allProcess;
  //
  //   List<ProcessItemModel> get allProcessItems =>
  //       _cachesRepository.allProcessItems;
  //
  //   List<ProcessResultModel> get allProcessResult =>
  //       _cachesRepository.allProcessResult;
  //
    // ==================> WORKING UNIT <==================
    List<WorkingUnitModel> get allWorkingUnit => _cachesRepository.allWorkingUnit;

    Map<String, WorkingUnitModel> get mapWorkingUnit =>
        _cachesRepository.mapWorkingUnit;

    Map<String, List<WorkingUnitModel>> get mapWorkChild =>
        _cachesRepository.mapWorkChild;

    // ==================> WORK SHIFT <==================
    List<WorkShiftModel> get allWorkShifts => _cachesRepository.allWorkShifts;

    Map<String, WorkShiftModel> get mapWorkShift =>
        _cachesRepository.mapWorkShift;

    Map<String, WorkShiftModel> get mapWorkShiftFromUserAndDate =>
        _cachesRepository.mapWorkShiftFromUserAndDate;

    // ==================> WORK FIELD <==================
    List<WorkFieldModel> get allWorkFields => _cachesRepository.allWorkFields;

    Map<String, WorkFieldModel> get mapWorkField =>
        _cachesRepository.mapWorkField;

    Map<String, List<WorkFieldModel>> get mapWFfWS => _cachesRepository.mapWFfWS;

  bool doneInitData = false;

  //
  final UserServices _userServices = UserServices.instance;

    final WorkingService _workingService = WorkingService.instance;
  final ScopeService _scopeService = ScopeService.instance;

  //   final OkrsService _okrsService = OkrsService.instance;
  //   final ConfigsService _configsService = ConfigsService.instance;
  //   final ProcessService _processService = ProcessService.instance;
  //   final QuoteService _quoteService = QuoteService.instance;
  //
  //   final StaffEvaluationService _evaluationService =
  //       StaffEvaluationService.instance;
  //   final StaffChecklistService _checklistService =
  //       StaffChecklistService.instance;
  //
  late Map<String, UserModel> usersMap = {};

  //   late Map<String, OkrsGroupModel> okrsGroupsMap = {};
    late Map<String, ScopeModel> allScopeByUserId = {};
    late Map<String, ScopeModel> allScopeMap = {};
  late List<UserModel> allUsers = [];

    late List<ScopeModel> allScopes = [];

  //   static String version = '';
    static String localScopeId = '';
  //   bool isNewVersion = false;
  //
  //   int loadingEvaluation = 0;
  //
  //   DateTime? ltu;
  late SharedPreferences _sharedPreferences;

  //
    StatusCheckInDefine get isCheckIn => _configsRepository.isCheckIn;
  //
  final String keyLTUWorkingUnit = 'last_time_updated_working_unit_model';
  final String keyLTUWorkingUnitClosed =
      'last_time_updated_working_unit_model_closed';
  final String keyLTUWorkingUnitScope =
      'last_time_updated_working_unit_model_scope';
  final String keyLTUWorkingUnitScopeType =
      'last_time_updated_working_unit_model_scope_type';
  final String keyLTUWorkingUnitByParent =
      'last_time_updated_working_unit_model_by_parent';
  final String keyLTUWorkField = 'last_time_updated_work_field_model';
  final String keyLTUQuote = 'last_time_updated_quote_model';

  //
  Future<void> init() async {
    _configsRepository = ConfigsRepository.instance;
    _cachesRepository = CachesRepository.instance;
    final prefs = await SharedPreferences.getInstance();
    _sharedPreferences = await SharedPreferences.getInstance();
    doneInitData = false;
    // final currentDate = "${today.year}-${today.month}-${today.day}";
    // final lastDate = prefs.getString('last_saved_date');
    // if (lastDate == null || lastDate != currentDate) {
    //   await prefs.clear();
    //   await prefs.setString('last_saved_date', currentDate);
    // }
    // await _sharedPreferences.remove(keyLTUWorkingUnit);
    final keys = prefs.getKeys();

    for (String key in keys) {
      if (key.startsWith(keyLTUWorkField) ||
          key.startsWith(keyLTUWorkingUnit) ||
          key.startsWith(keyLTUQuote)) {
        await prefs.remove(key);
      }
    }
    final savedRole = prefs.getInt('role');
    final saveUser = prefs.getString('user');
        final saveCheckIn = null;
    //
    if (savedRole != null) {
      _configsRepository.changeRole(savedRole);
    }
    if (saveUser != null) {
      final userInfo = await UserServices.instance.getUserById(
        UserModel.fromJson(jsonDecode(saveUser)).id,
      );
      if (userInfo != null) {
        _configsRepository.changeUser(userInfo);
      } else {
        _configsRepository.changeUser(UserModel.fromJson(jsonDecode(saveUser)));
      }
    }
        if (saveCheckIn == null) {
          WorkShiftModel? workShift = await UserServices.instance
              .getWorkShiftByIdUserAndDate(
                  _configsRepository.user.id, DateTimeUtils.getCurrentDate());
          if (workShift != null) {
            await changeCheckIn(
                StatusCheckInDefineExtension.getStatusByValue(workShift.status));
          } else {
            await changeCheckIn(StatusCheckInDefine.notCheckIn);
          }
        } else {
          _configsRepository.changeCheckIn(
              StatusCheckInDefineExtension.getStatusByValue(saveCheckIn));
        }
    //
    //     final dataUserQuote = _sharedPreferences.getStringList(keyUserQuote) ?? [];
    //     listUserQuote = [...dataUserQuote];
    await loadAllUsers();
    //     await loadAllOkrsGroups();
        await loadAllScopeByUserId();
        await loadAllScopes();
        await getLocalScope();
    //     await _cachesRepository.loadChecklistTemplates(prefs);
    //     await _cachesRepository.loadChecklistItems(prefs);
    //     // await _cachesRepository.loadProcess(prefs);
    //     // await _cachesRepository.loadProcessItem(prefs);
    doneInitData = true;
    EMIT(event: ConfigStateEvent.init);
    //     // getDataWorkingUnitNewest(user.id);
  }

  //
  Future<void> changRole(int newRole) async {
    _configsRepository.changeRole(newRole);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('role', newRole);
    reload();
  }

  //
  Future<void> changUser(UserModel newUser) async {
    _configsRepository.changeUser(newUser);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(newUser.toJson()));
    WorkShiftModel? workShift = await UserServices.instance
        .getWorkShiftByIdUserAndDate(
            newUser.id, DateTimeUtils.getCurrentDate());
    if (workShift != null) {
      await changeCheckIn(
          StatusCheckInDefineExtension.getStatusByValue(workShift.status));
    } else {
      await changeCheckIn(StatusCheckInDefine.notCheckIn);
    }
    reload();
  }

  //
    Future<void> changeCheckIn(StatusCheckInDefine newStatus) async {
      _configsRepository.changeCheckIn(newStatus);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('checkIn', newStatus.value);
      reload();
    }
  //
  loadAllUsers() async {
    ResponseModel response = await _scopeService.getUsersForAddingScope(0);
    if (response.status == ResponseStatus.ok) {
      List<UserModel> users = response.results ?? [];
      allUsers = users.where((e) => e.roles > 20).toList();
      usersMap = {for (var user in users) user.id: user};
    }
  }

  //
  updateUser(UserModel model) {
    int index = allUsers.indexWhere((e) => e.id == model.id);
    if (index != -1) {
      if (model.enable) {
        allUsers[index] = model;
        usersMap[model.id] = model;
      } else {
        allUsers.removeAt(index);
        usersMap.remove(model.id);
      }
    }
    _userServices.updateUser(model);
    reload();
  }

  //
  //   loadAllOkrsGroups() async {
  //     ResponseModel responseOKRs = await _okrsService.getListOkrsGroup();
  //     if (responseOKRs.status == ResponseStatus.ok) {
  //       var okrs = responseOKRs.results ?? [];
  //       okrsGroupsMap = {for (var okr in okrs) okr.id: okr};
  //     }
  //   }

    loadAllScopeByUserId() async {
      var scopes = await _scopeService.getScopeByIdUser(user.id);
      allScopeByUserId = {for (var scope in scopes) scope.id: scope};
    }

    loadAllScopes() async {
      var scopes =
          await _scopeService.getListScope() as ResponseModel<List<ScopeModel>>;
      if (scopes.status == ResponseStatus.ok && scopes.results != null) {
        allScopes = [...scopes.results!];
        allScopeMap = {
          for (var scope in scopes.results!.toList()) scope.id: scope
        };
      }
    }
  //
  //   getConfiguration() async {
  //     var tmp = await _configsService.getConfiguration();
  //     var oldVersion = await PrefKeys.getVersion();
  //
  //     if (oldVersion != null) {
  //       if (tmp.version != oldVersion) {
  //         await PrefKeys.saveVersion(tmp.version);
  //         version = tmp.version;
  //         isNewVersion = true;
  //       } else {
  //         version = oldVersion;
  //         isNewVersion = false;
  //       }
  //     } else {
  //       await PrefKeys.saveVersion(tmp.version);
  //     }
  //   }
  //
    getLocalScope() async {
      var tmp = await PrefKeys.getLocalScopeId();
      ConfigsCubit.localScopeId = tmp ?? '';
    }
  //
  //   reloadVersion() {
  //     html.window.location.reload();
  //   }
    // =================== WORKING UNIT MODEL ===================
    int loadingWorkingUnit = 0;
    int cntGetNewestWU = 0;

    getDataWorkingUnitNewest(String uid) async {
      if (loadingWorkingUnit > 0) return;
      loadingWorkingUnit++;
      EMIT(event: ConfigStateEvent.task, data: WorkingUnitModel());

      final ltu = DateTime.fromMillisecondsSinceEpoch(
          _sharedPreferences.getInt("${keyLTUWorkingUnit}_$uid") ?? 0);
      final data = await _workingService.getWorkingUnitForUserUpdated(ltu, uid);
      // debugPrint("=================================> get task newest: $ltu - ${uid} - ${data.length}");
      for (var e in data) {
        int index = allWorkingUnit.indexWhere((f) => f.id == e.id);
        if (index != -1) {
          _cachesRepository.updateWorkingUnit(e);
        } else {
          _cachesRepository.addWorkingUnit(e);
        }
        List<String> announces = [...e.announces];
        int index2 = announces.indexWhere((e) => e == user.id);
        if (index2 != -1) {
          announces.removeAt(index2);
          _workingService.updateWorkingUnitField(
              e.copyWith(announces: announces), e, user.id,
              isGetUpdateTime: false, isUpdateAnnounces: true);
        }
      }
      _sharedPreferences.setInt(
          "${keyLTUWorkingUnit}_$uid", DateTime.now().millisecondsSinceEpoch);
      loadingWorkingUnit--;
      // reload();
      EMIT(event: ConfigStateEvent.task, data: data);
      // emit(state.copyWith(
      //     state: state.state + 1, updatedEvent: CacheUpdatedEvent.task));
    }

    getDataWorkingUnitClosedNewest(String uid) async {
      // if (loadingWorkingUnit > 0) return;
      loadingWorkingUnit++;
      EMIT(event: ConfigStateEvent.task, data: WorkingUnitModel());

      final ltu = DateTime.fromMillisecondsSinceEpoch(
          _sharedPreferences.getInt("${keyLTUWorkingUnitClosed}_$uid") ?? 0);
      final data =
          await _workingService.getWorkingUnitClosedForUserUpdated(ltu, uid);
      // debugPrint("=================================> get closed task: ${data.length} - ${_sharedPreferences.getInt("${keyLTUWorkingUnitClosed}_$uid")}");
      for (var e in data) {
        int index = allWorkingUnit.indexWhere((f) => f.id == e.id);
        if (index != -1) {
          _cachesRepository.updateWorkingUnit(e);
        } else {
          _cachesRepository.addWorkingUnit(e);
        }
        List<String> announces = [...e.announces];
        int index2 = announces.indexWhere((e) => e == user.id);
        if (index2 != -1) {
          announces.removeAt(index2);
          _workingService.updateWorkingUnitField(
              e.copyWith(announces: announces), e, user.id,
              isGetUpdateTime: false, isUpdateAnnounces: true);
        }
      }
      _sharedPreferences.setInt("${keyLTUWorkingUnitClosed}_$uid",
          DateTime.now().millisecondsSinceEpoch);
      loadingWorkingUnit--;
      EMIT(event: ConfigStateEvent.task, data: data);
    }

    getDataWorkingUnitByScopeNewest(String uid, {bool isAll = false}) async {
      // if (loadingWorkingUnit > 0) return;
      // loadingWorkingUnit++;
      EMIT(event: ConfigStateEvent.task, data: WorkingUnitModel());

      final ltu = DateTime.fromMillisecondsSinceEpoch(_sharedPreferences
              .getInt("${keyLTUWorkingUnitScope}_${uid}_${isAll}") ??
          0);
      final data = await _workingService.getWorkingUnitByScopeIdUpdated(ltu, uid,
          isAll: isAll);
      debugPrint(
          "=====> get data by scope: $ltu - ${uid} - ${isAll} - ${data.length} - ${data.any((e) => e.id == "bYQY18KDcvHAH4g2AHMl")}");
      for (var e in data) {
        int index = allWorkingUnit.indexWhere((f) => f.id == e.id);
        if (index != -1) {
          _cachesRepository.updateWorkingUnit(e);
        } else {
          _cachesRepository.addWorkingUnit(e);
        }
        List<String> announces = [...e.announces];
        int index2 = announces.indexWhere((e) => e == user.id);
        if (index2 != -1) {
          announces.removeAt(index2);
          _workingService.updateWorkingUnitField(
              e.copyWith(announces: announces), e, user.id,
              isGetUpdateTime: false, isUpdateAnnounces: true);
        }
      }
      _sharedPreferences.setInt("${keyLTUWorkingUnitScope}_${uid}_${isAll}",
          DateTime.now().millisecondsSinceEpoch);
      // loadingWorkingUnit--;
      EMIT(event: ConfigStateEvent.task, data: data);
    }

    getDataWorkingUnitTypeByScopeNewest(String uid, String type,
        {bool isAll = false}) async {
      // if (loadingWorkingUnit > 0) return;
      // loadingWorkingUnit++;
      EMIT(event: ConfigStateEvent.task, data: WorkingUnitModel());

      final ltu = DateTime.fromMillisecondsSinceEpoch(_sharedPreferences
              .getInt("${keyLTUWorkingUnitScopeType}_${uid}_$type") ??
          0);
      final data = await _workingService
          .getAllWorkingUnitInScopeByTypeIgnoreClosedUpdate(ltu, uid, type);
      // debugPrint("======> get data by scope: $ltu - $uid - $type - ${data.length}");
      for (var e in data) {
        int index = allWorkingUnit.indexWhere((f) => f.id == e.id);
        if (index != -1) {
          _cachesRepository.updateWorkingUnit(e);
        } else {
          _cachesRepository.addWorkingUnit(e);
        }
        List<String> announces = [...e.announces];
        int index2 = announces.indexWhere((e) => e == user.id);
        if (index2 != -1) {
          announces.removeAt(index2);
          _workingService.updateWorkingUnitField(
              e.copyWith(announces: announces), e, user.id,
              isGetUpdateTime: false, isUpdateAnnounces: true);
        }
      }
      _sharedPreferences.setInt("${keyLTUWorkingUnitScopeType}_${uid}_$type",
          DateTime.now().millisecondsSinceEpoch);
      // loadingWorkingUnit--;
      EMIT(event: ConfigStateEvent.task, data: data);
    }

    getDataWorkingUnitByIdParentNewest(String uid) async {
      // if (loadingWorkingUnit > 0) return;
      loadingWorkingUnit++;
      EMIT(event: ConfigStateEvent.task, data: WorkingUnitModel());

      final ltu = DateTime.fromMillisecondsSinceEpoch(
          _sharedPreferences.getInt("${keyLTUWorkingUnitByParent}_$uid") ?? 0);
      final data = await _workingService
          .getWorkingUnitByIdParentIgnoreClosedUpdated(ltu, uid);
      debugPrint("====> Get wu by id parent: $ltu - $uid - ${data.length}");
      for (var e in data) {
        int index = allWorkingUnit.indexWhere((f) => f.id == e.id);
        if (index != -1) {
          _cachesRepository.updateWorkingUnit(e);
        } else {
          _cachesRepository.addWorkingUnit(e);
        }
        List<String> announces = [...e.announces];
        int index2 = announces.indexWhere((e) => e == user.id);
        if (index2 != -1) {
          announces.removeAt(index2);
          _workingService.updateWorkingUnitField(
              e.copyWith(announces: announces), e, user.id,
              isGetUpdateTime: false, isUpdateAnnounces: true);
        }
      }
      _sharedPreferences.setInt("${keyLTUWorkingUnitByParent}_$uid",
          DateTime.now().millisecondsSinceEpoch);
      loadingWorkingUnit--;
      // reload();
      EMIT(event: ConfigStateEvent.task, data: data);
      // emit(state.copyWith(
      //     state: state.state + 1, updatedEvent: CacheUpdatedEvent.task));
    }

    addWorkingUnit(WorkingUnitModel model, {bool isLocal = false}) async {
      _cachesRepository.addWorkingUnit(model);
      if (!isLocal) {
        _workingService.addNewWorkingUnit(model);
      }
      EMIT(
          event: ConfigStateEvent.task,
          data: isLocal ? WorkingUnitModel() : model);
    }

    updateWorkingUnit(WorkingUnitModel model, WorkingUnitModel oldModel,
        {bool isLocalUpdate = false}) async {
      final diff = WorkingUnitModel.getDifferentFields(model, oldModel);
      if (diff.isEmpty) return;
      if (!isLocalUpdate) {
        _workingService.updateWorkingUnitField(model, oldModel, user.id);
      }
      _cachesRepository.updateWorkingUnit(model);
      EMIT(
          event: ConfigStateEvent.task,
          data: isLocalUpdate ? WorkingUnitModel() : model);
      // reload();
    }

    // =================== WORK SHIFT MODEL ===================
    int loadingWorkShift = 0;

    // getDataWorkShiftNewest() async {
    //   if (loadingWorkShift > 0) return;
    //   loadingWorkShift++;
    //   EMIT(event: CacheUpdatedEvent.workShift);
    //
    //   final ltu = DateTime.fromMillisecondsSinceEpoch(
    //       _sharedPreferences.getInt(keyLTUWorkShift) ?? 0);
    //   final data =
    //   await _workingService.getWorkingUnitForUserUpdated(ltu, user.id);
    //   for (var e in data) {
    //     int index = allWorkingUnit.indexWhere((f) => f.id == e.id);
    //     if (index != -1) {
    //       _cachesRepository.updateWorkingUnit(e);
    //     } else {
    //       _cachesRepository.addWorkingUnit(e);
    //     }
    //     List<String> announces = [...e.announces];
    //     int index2 = announces.indexWhere((e) => e == user.id);
    //     if (index2 != -1) {
    //       announces.removeAt(index2);
    //       _workingService.updateWorkingUnitField(
    //           e.copyWith(announces: announces), e, user.id,
    //           isGetUpdateTime: false,
    //           isUpdateAnnounces: true);
    //     }
    //   }
    //   _sharedPreferences.setInt(
    //       keyLTUWorkShift, DateTime.now().millisecondsSinceEpoch);
    //   loadingWorkShift--;
    //   // reload();
    //   EMIT(event: CacheUpdatedEvent.task);
    //   // emit(state.copyWith(
    //   //     state: state.state + 1, updatedEvent: CacheUpdatedEvent.task));
    // }

    getWorkShiftByUser(String uid, DateTime date) async {
      // if (loadingWorkShift > 0) return;
      loadingWorkShift++;
      EMIT(event: ConfigStateEvent.workShift);

      final model = await _userServices.getWorkShiftByIdUserAndDate(uid, date);
      // debugPrint("====> Get workshift: $uid - $date - ${model?.id} - ${model != null}");
      if (model != null) {
        await getWorkFieldByWorkShift(model.id);
        if (allWorkShifts.any((e) => e.id == model.id)) {
          _cachesRepository.updateWorkingShift(model);
        } else {
          _cachesRepository.addWorkingShift(model);
        }
      }
      loadingWorkShift--;
      EMIT(event: ConfigStateEvent.workShift, data: model);
      return model ?? mapWorkShift["${uid}_${date}"];
    }

    addWorkShift(WorkShiftModel model, {bool isLocal = false}) async {
      _cachesRepository.addWorkingShift(model);
      if (!isLocal) {
        _userServices.addNewWorkShift(model);
      }
      EMIT(
          event: ConfigStateEvent.workShift,
          data: isLocal ? WorkShiftModel() : model);
    }

    updateWorkShift(WorkShiftModel model, WorkShiftModel oldModel,
        {bool isLocalUpdate = false}) async {
      if (!isLocalUpdate) {
        _userServices.updateWorkShiftField(model, oldModel);
      }
      _cachesRepository.updateWorkingShift(model);

      EMIT(
          event: ConfigStateEvent.workShift,
          data: isLocalUpdate ? WorkShiftModel() : model);
      // reload();
    }

    // =================== WORK FIELD MODEL ===================
    int loadingWorkField = 0;

    getWorkFieldByWorkShift(String wid) async {
      // if (loadingWorkField > 0) return;
      loadingWorkField++;
      EMIT(event: ConfigStateEvent.workField);

      final ltu = DateTime.fromMillisecondsSinceEpoch(
          _sharedPreferences.getInt("${keyLTUWorkField}_$wid") ?? 0);
      List<WorkFieldModel> wfs = [];
      if (ltu == DateTime.fromMillisecondsSinceEpoch(0)) {
        final data = await _workingService.getWorkFieldByIdWorkShift(wid);
        wfs = [...data];
      } else {
        final data =
            await _workingService.getWorkFieldByIdWorkShiftUpdated(ltu, wid);
        wfs = [...data];
      }

      for (var e in wfs) {
        int index = allWorkFields.indexWhere((f) => f.id == e.id);
        if (index != -1) {
          _cachesRepository.updateWorkingField(e);
        } else {
          _cachesRepository.addWorkingField(e);
        }
      }
      _sharedPreferences.setInt(
          "${keyLTUWorkField}_$wid", DateTime.now().millisecondsSinceEpoch);
      loadingWorkField--;
      EMIT(event: ConfigStateEvent.workField, data: wfs);
    }

    addWorkField(WorkFieldModel model,
        {bool isLocal = false, bool isAsync = false}) async {
      _cachesRepository.addWorkingField(model);
      if (!isLocal) {
        if (isAsync) {
          await _workingService.addNewWorkField(model);
        } else {
          _workingService.addNewWorkField(model);
        }
      }
      EMIT(
          event: ConfigStateEvent.workField,
          data: isLocal ? WorkFieldModel() : model);
    }

    updateWorkField(WorkFieldModel model, WorkFieldModel oldModel,
        {bool isLocalUpdate = false}) async {
      if (!isLocalUpdate) {
        _workingService.updateWorkFieldWithField(model, oldModel);
      }
      _cachesRepository.updateWorkingField(model);
      EMIT(
          event: ConfigStateEvent.workField,
          data: isLocalUpdate ? WorkFieldModel() : model);
      // reload();
    }
  //
  //   // =================== QUOTE MODEL ===================
  //   int loadingQuote = 0;
  //
  //   getQuote() async {
  //     if (loadingQuote > 0) return;
  //     loadingQuote++;
  //     EMIT(event: ConfigStateEvent.quote);
  //
  //     final ltu = DateTime.fromMillisecondsSinceEpoch(
  //         _sharedPreferences.getInt(keyLTUQuote) ?? 0);
  //
  //     final data = await _quoteService.getAllQuoteUpdated(ltu);
  //     for (var e in data) {
  //       int index = allQuotes.indexWhere((f) => f.id == e.id);
  //       if (index != -1) {
  //         _cachesRepository.updateQuote(e);
  //       } else {
  //         _cachesRepository.addQuote(e);
  //       }
  //     }
  //     _sharedPreferences.setInt(
  //         keyLTUQuote, DateTime.now().millisecondsSinceEpoch);
  //     loadingQuote--;
  //     EMIT(event: ConfigStateEvent.quote, data: data);
  //   }
  //
  //   addQuote(QuoteModel model,
  //       {bool isLocal = false, bool isAsync = false}) async {
  //     _cachesRepository.addQuote(model);
  //     if (!isLocal) {
  //       if (isAsync) {
  //         await _quoteService.addQuote(model);
  //       } else {
  //         _quoteService.addQuote(model);
  //       }
  //     }
  //     EMIT(event: ConfigStateEvent.quote, data: isLocal ? QuoteModel() : model);
  //   }
  //
  //   updateQuote(QuoteModel model, QuoteModel oldModel,
  //       {bool isLocalUpdate = false}) async {
  //     if (!isLocalUpdate) {
  //       _quoteService.updateQuote(model, oldModel, user.id);
  //     }
  //     _cachesRepository.updateQuote(model);
  //
  //     EMIT(
  //         event: ConfigStateEvent.quote,
  //         data: isLocalUpdate ? QuoteModel() : model);
  //     // reload();
  //   }
  //
  //   // =================== SAVE TAB STATE ===================
  //
    getSaveTab(String tabKey) {
      final tab = _sharedPreferences.getString(tabKey);
      return tab;
    }

    saveSaveTab(String tabKey, String url) {
      _sharedPreferences.setString(tabKey, url);
    }
  //
  //   // =================== QUOTE ===================
  //
  //   addUserQuote(String id) {
  //     if (listUserQuote.contains(id)) return;
  //     listUserQuote.add(id);
  //     _sharedPreferences.setStringList(keyUserQuote, listUserQuote);
  //     EMIT(event: ConfigStateEvent.quote, data: listUserQuote);
  //   }
  //
  //   removeUserQuote(String id) {
  //     listUserQuote.remove(id);
  //     _sharedPreferences.setStringList(keyUserQuote, listUserQuote);
  //     EMIT(event: ConfigStateEvent.quote, data: listUserQuote);
  //   }
  //
  //   getCloseToday() {
  //     final dateClose = DateTime.fromMillisecondsSinceEpoch(
  //         _sharedPreferences.getInt(keyQuoteCloseToday) ?? 0);
  //     return dateClose.isAtSameMomentAs(DateTimeUtils.getCurrentDate());
  //   }
  //
  //   updateCloseToday() {
  //     final dateClose = DateTime.fromMillisecondsSinceEpoch(
  //         _sharedPreferences.getInt(keyQuoteCloseToday) ?? 0);
  //     if (dateClose.isAtSameMomentAs(DateTimeUtils.getCurrentDate())) {
  //       _sharedPreferences.setInt(keyQuoteCloseToday, 0);
  //     } else {
  //       _sharedPreferences.setInt(keyQuoteCloseToday,
  //           DateTimeUtils.getCurrentDate().millisecondsSinceEpoch);
  //     }
  //     EMIT(
  //         event: ConfigStateEvent.quote,
  //         data: Pair("close",
  //             !(dateClose.isAtSameMomentAs(DateTimeUtils.getCurrentDate()))));
  //   }
  //
  //   getAutoNext() {
  //     final isAuto = _sharedPreferences.getBool(keyQuoteAutoNext);
  //     return isAuto != null && isAuto;
  //   }
  //
  //   updateAutoNext() {
  //     final isAuto = _sharedPreferences.getBool(keyQuoteAutoNext);
  //     if (isAuto != null && isAuto) {
  //       _sharedPreferences.setBool(keyQuoteAutoNext, false);
  //     } else {
  //       _sharedPreferences.setBool(keyQuoteAutoNext, true);
  //     }
  //     EMIT(
  //         event: ConfigStateEvent.quote,
  //         data: Pair("auto_next", !(isAuto != null && isAuto)));
  //   }
  //
  //   // =================== EMIT ===================
  //
  EMIT({ConfigStateEvent? event, dynamic data}) {
    if (!isClosed) {
      emit(
        state.copyWith(
          state: state.state + 1,
          updatedEvent: event,
          model: data,
        ),
      );
    }
  }

  //
  reload() {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        state: state.state + 1,
        updatedEvent: ConfigStateEvent.none,
        model: null,
      ),
    );
  }

  // }
  //
}

enum ConfigStateEvent { none, init, task, workShift, workField, quote }

class ConfigsState {
  final int state;
  final ConfigStateEvent updatedEvent;
  final dynamic data;

  // With working unit model: data = null -> load all, data.id.isEmpty -> no handle, data.id.isNotEmpty -> add/update

  ConfigsState({
    this.state = 0,
    this.updatedEvent = ConfigStateEvent.none,
    this.data,
  });

  ConfigsState copyWith({
    int? state,
    ConfigStateEvent? updatedEvent,
    dynamic model,
  }) {
    return ConfigsState(
      state: state ?? this.state,
      updatedEvent: updatedEvent ?? this.updatedEvent,
      data: model,
    );
  }
}
