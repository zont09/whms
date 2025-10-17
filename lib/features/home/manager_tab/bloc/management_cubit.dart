import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/sorted_list_name_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/sorted_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/pref_keys.dart';
import 'package:whms/repositories/configs_repository.dart';
import 'package:whms/services/sorted_service.dart';
import 'package:whms/untils/cache_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/main.dart';

class ManagementCubit extends Cubit<int> {
  ManagementCubit(this.urlScope, this.urlPosition, ConfigsCubit cubit)
      : super(0) {
    cfC = cubit;
    load();
  }

  late String urlScope;
  late String urlPosition;
  final ConfigsRepository _configsRepository = ConfigsRepository.instance;
  final SortedService _sortedService = SortedService.instance;

  List<ScopeModel> listScope = [];
  ScopeModel? selectedScope;
  List<WorkingUnitModel>? listWorkings;
  List<WorkingUnitModel> workings = [];
  List<WorkingUnitModel> tabX = [];
  List<WorkingUnitModel> tabY = [];
  List<WorkingUnitModel> tabZ = [];
  List<WorkingUnitModel> tabS = [];
  List<WorkingUnitModel> level1 = [];
  List<WorkingUnitModel> level2 = [];
  List<WorkingUnitModel> level3 = [];
  WorkingUnitModel? selectedWorking;
  List<UserModel>? users;
  List<UserModel> assignees = [];
  List<String> ancestries = [];
  List<WorkingUnitModel> link = [];
  WorkingUnitModel? directParent;
  List<ScopeModel> allScopes = [];

  List<WorkingUnitModel> get allWorking => [...level1, ...level2, ...level3];

  UserModel get handlerUser => _configsRepository.user;
  Map<String, WorkingUnitModel> mapWorkingUnit = {};
  Map<String, List<WorkingUnitModel>> mapWorkChild = {};
  Map<String, PlatformFile?> mapAvtEpic = {};

  Map<String, SortedModel> mapSorted = {};
  SortedModel currentSorted = SortedModel();
  List<String> listTabs = [
    AppText.txtSprint.text,
    AppText.txtStory.text,
    AppText.txtTask.text
  ];

  int tab = 0;
  late ConfigsCubit cfC;

  List<String> filters = [AppText.textOpened.text, AppText.textAll.text];
  String? selectedFilter;

  load() async {
    allScopes = cfC.allScopes;
    for (var e in cfC.allScopes) {
      debugPrint("[THINK] ====> get all scope: ${e.title} - ${e.id}");
    }
    debugPrint("[THINK] ====> Handler scope: ${handlerUser.scopes}");
    // for (var i in handlerUser.scopes) {
    //   for (var j in allScopes) {
    //     if (i == j.id) {
    //       listScope.add(j);
    //       break;
    //     }
    //   }
    // }
    for (var e in cfC.allScopes) {
      if (e.managers.contains(handlerUser.id) ||
          e.members.contains(handlerUser.id)) {
        listScope.add(e);
      }
    }
    for (var e in listScope) {
      debugPrint("[THINK] ====> get list scope: ${e.title}");
    }
    if (listScope.isNotEmpty) {
      selectedFilter = filters.first;
      if (ConfigsCubit.localScopeId.isEmpty) {
        await getIt<ConfigsCubit>().getLocalScope();
      }
      if (ConfigsCubit.localScopeId.isEmpty) {
        await chooseScope(listScope.first);
      } else {
        List<String> list = listScope.fold([], (prev, e) => [...prev, e.id]);
        Map<String, ScopeModel> allScopeMap = {
          for (var scope in listScope) scope.id: scope
        };

        if (list.contains(ConfigsCubit.localScopeId)) {
          await chooseScope(allScopeMap[ConfigsCubit.localScopeId]!);
        } else {
          await chooseScope(listScope.first);
        }
      }
      // if (urlScope != '0') {
      //   for (var s in listScope) {
      //     if (listScope.indexOf(s).toString() == urlScope) {
      //       await chooseScope(s);
      //       break;
      //     }
      //   }
      //   // print('==========> kk ${allScopeMap.isEmpty ? 'p': allScopeMap.length}');
      //   // await chooseScope(allScopeMap[ConfigsCubit.localScopeId]!);
      // } else {
      //   await chooseScope(ConfigsCubit.localScopeId.isEmpty
      //       ? listScope.first
      //       : allScopeMap[ConfigsCubit.localScopeId]!);
      // }
    } else {
      listWorkings = [];
      selectedWorking = WorkingUnitModel();
      buildUI();
    }
    if (selectedWorking == null) {
      selectedWorking = WorkingUnitModel();
      buildUI();
    }
    debugPrint(
        "====> Load scope: ${listWorkings?.length} - ${selectedWorking?.id}");
  }

  getListNameFromTab(int tab) {
    switch (tab) {
      case 0:
        return SortedListNameDefine.managerSprint.title;
      case 1:
        return SortedListNameDefine.managerStory.title;
      default:
        return SortedListNameDefine.managerTask.title;
    }
  }

  changeOrder(int index1, int index2) async {
    var listWork = tab == 0
        ? tabX
        : tab == 1
            ? tabY
            : tabZ;
    final tmp = listWork[index1];
    listWork.removeAt(index1);
    listWork.insert(index2, tmp);
    _sortedService.updateSorted(currentSorted.copyWith(
        sorted: listWork.map((item) => item.id).toList()));
  }

  changeTab(int index) async {
    tab = index;
    SortedModel? sorted;
    String listName = '${getListNameFromTab(tab)}_${selectedWorking!.id}';
    var listWork = tab == 0
        ? tabX
        : tab == 1
            ? tabY
            : tabZ;

    if (mapSorted['id_sorted_${handlerUser.id}_$listName'] != null) {
      sorted = mapSorted['id_sorted_${handlerUser.id}_$listName'];
    } else {
      sorted = await SortedService.instance
          .getSortedByUserAndListName(handlerUser.id, listName);
    }
    if (sorted != null) {
      List<WorkingUnitModel> taskInSorted = [];
      for (var work in sorted.sorted) {
        final task = listWork.where((item) => item.id == work).firstOrNull;
        if (task != null) {
          taskInSorted.add(task);
        }
      }
      for (var work in listWork) {
        if (!taskInSorted.contains(work)) {
          taskInSorted.add(work);
        }
      }
      // if (request != currentRequest) return;
      listWork.clear();
      listWork.addAll(taskInSorted);
    } else {
      String id = FirebaseFirestore.instance
          .collection('daily_pls_working_unit')
          .doc()
          .id;
      sorted = SortedModel(
          id: id,
          user: handlerUser.id,
          listName: listName,
          sorted: listWork.map((item) => item.id).toList(),
          enable: true);
      _sortedService.addNewSorted(sorted);
    }

    currentSorted = sorted;
    buildUI();
  }

  Future<bool?> shouldStopItem(WorkingUnitModel item) async {
    if (item.parent.isEmpty) {
      return null;
    }

    WorkingUnitModel? parentItem = cfC.mapWorkingUnit[item.parent];
    if (parentItem != null &&
        parentItem.closed &&
        selectedFilter == filters[0]) {
      parentItem = null;
    }
    // await _workingService.getWorkingUnitById(item.parent);

    if (parentItem == null) {
      return false;
    }

    // if (!parentItem.enable) {
    //   return true;
    // }

    return await shouldStopItem(parentItem);
  }

  Map<String, int> sortType = {
    TypeAssignmentDefine.okrs.title: 1,
    TypeAssignmentDefine.epic.title: 2,
    TypeAssignmentDefine.sprint.title: 3,
    TypeAssignmentDefine.story.title: 4,
    TypeAssignmentDefine.task.title: 5,
    TypeAssignmentDefine.subtask.title: 6,
  };

  getAvatarEpic() async {
    for (var e in listWorkings ?? []) {
      if (e.icon.isEmpty) continue;
      final file = await CacheUtils.instance.getFileGB(e.icon);
      mapAvtEpic[e.id] = file;
    }
  }

  loadListWorkings({bool isFirst = true}) async {
    List<String> isUsedGet = [];
    level1.clear();
    level2.clear();
    level3.clear();
    workings.clear();
    await cfC.getDataWorkingUnitByScopeNewest(selectedScope!.id,
        isAll: filters.indexOf(selectedFilter!) == 1);
    listWorkings = cfC.allWorkingUnit
        .where((e) =>
            e.scopes.contains(selectedScope!.id) &&
            (filters.indexOf(selectedFilter!) == 1 || !e.closed))
        .toList();
    // listWorkings = await _workingService.getWorkingUnitByScopeId(
    //     selectedScope!.id,
    //     isAll: filters.indexOf(selectedFilter!) == 1);
    if (listWorkings!.isNotEmpty) {
      workings = buildTree(listWorkings!, '', 1, '000000000');

      getAvatarEpic();
      List<WorkingUnitModel> listChild = [];
      for (var w in workings) {
        if (true) {
          var shouldStop = await shouldStopItem(w);
          if (shouldStop == null) {
            // if (true) {
            for (var i in w.scopes) {
              if (i != selectedScope!.id) {
                if (!isUsedGet.contains(i)) {
                  await cfC.getDataWorkingUnitByScopeNewest(i);
                  isUsedGet.add(i);
                }
                var tmpChild1 = cfC.allWorkingUnit
                    .where((e) =>
                        e.scopes.contains(i) &&
                        (filters.indexOf(selectedFilter!) == 1 || !e.closed))
                    .toList();
                // var tmpChild1 =
                //     await _workingService.getWorkingUnitByScopeId(i);
                var tmp2 = await findDescendantsRecursive(w.id, tmpChild1);
                listChild.addAll(tmp2);
              }
            }
          } else {
            listWorkings!.removeWhere((e) => e.id == w.id);
            final listDescendants =
                findDescendantsRecursive(w.id, listWorkings!);
            for (var e in listDescendants) {
              listWorkings!.remove(e);
            }
          }
        }
      }
      listWorkings!.addAll(listChild);
      final seenIds = <String>{};
      var tmp = listWorkings!.where((item) => seenIds.add(item.id)).toList();
      listWorkings = tmp;
      listWorkings!
          .sort((a, b) => sortType[a.type]!.compareTo(sortType[b.type]!));
      workings.clear();
      workings = buildTree(listWorkings!, '', 1, '000000000');
      if (workings.isNotEmpty) {
        for (var i in workings) {
          calculatePercent(i.id, listWorkings!);
          if (i.type != TypeAssignmentDefine.task.title &&
              i.type != TypeAssignmentDefine.subtask.title) {
            cfC.updateWorkingUnit(
                i.copyWith(status: int.parse('${i.percent}')), i);
            // await _workingService.updateWorkingUnitField(
            //     i.copyWith(status: int.parse('${i.percent}')), i, idUser);
          }
        }
        if (urlPosition != '001000000') {
          for (var w in listWorkings!) {
            if (w.position == urlPosition) {
              if (w.level < 4) {
                selectedWorking = w;
              }
              break;
            }
          }
        } else {
          selectedWorking = workings.first;
        }

        // for (var w in workings) {
        //   if (selectedWorking!.parent == w.id) {
        //     w.isOpen = true;
        //     selectedWorking!.isOpen = true;
        //   }
        // }
        await generateTabs();
        if (selectedWorking!.tabs.isEmpty) {
          tab = -1;
        } else {
          await changeTab(listTabs.indexOf(selectedWorking!.tabs.first));
        }
        await findAncestry();
      } else {
        selectedWorking = WorkingUnitModel();
      }
    }
  }

  removeFromAncestor(List<WorkingUnitModel> list, WorkingUnitModel work) {
    list.remove(work);
  }

  loadUsers({bool isAll = true}) async {
    final response = cfC.allUsers;
    // await _scopeService.getUsersForAddingScope(0);

    assignees.clear();
    users = response;

    if (isAll) {
      getListUser(selectedScope!.members, assignees);
    }
  }

  chooseFilter(String value) async {
    selectedFilter = value;
    await loadListWorkings();
  }

  chooseScope(ScopeModel scope) async {
    emit(-99999);
    selectedFilter = filters.first;
    selectedScope = scope;
    selectedWorking = null;
    listWorkings = null;
    urlPosition = '001000000';
    await PrefKeys.saveLocalScopeId(selectedScope!.id);
    ConfigsCubit.localScopeId = selectedScope!.id;
    await loadListWorkings();

    await loadUsers();

    if (!isClosed) {
      emit(1);
    }
    // buildUI();
  }

  chooseWorkingUnit(WorkingUnitModel model) async {
    print("=====> Choose working unit: ${model.title} - ${model.level}");
    selectedWorking = model;
    await generateTabs();

    if (selectedWorking!.tabs.isEmpty) {
      tab = -1;
    } else {
      await changeTab(listTabs.indexOf(selectedWorking!.tabs.first));
    }

    await findAncestry();

    buildUI();
  }

  updateTitle(String title) async {
    selectedWorking!.title = title;
    buildUI();
  }

  updateWU(WorkingUnitModel model) async {
    selectedWorking!.title = model.title;
    selectedWorking!.description = model.description;
    selectedWorking!.start = model.start;
    selectedWorking!.deadline = model.deadline;
    selectedWorking!.urgent = model.urgent;
    selectedWorking!.priority = model.priority;
    selectedWorking!.workingPoint = model.workingPoint;
    selectedWorking!.okrs = model.okrs;
    selectedWorking!.followers = model.followers;
    buildUI();
  }

  updateParent(String id) async {
    selectedWorking!.id = id;
    cfC.updateWorkingUnit(
        selectedWorking!.copyWith(parent: id), selectedWorking!);
    // await _workingService.updateWorkingUnitField(
    //     selectedWorking!.copyWith(parent: id), selectedWorking!, idUser);
    buildUI();
  }

  findAncestry() {
    ancestries.clear();
    link.clear();
    print(
        "selected workingunit: ${selectedWorking?.title} - ${selectedWorking?.level}");
    if (selectedWorking!.level == 2) {
      WorkingUnitModel temp =
          level1.where((e) => e.id == selectedWorking!.parent).first;
      ancestries.add(temp.title);
      link.add(temp);
      directParent = temp;
      WorkingUnitModel tmp1 =
          allWorking.where((e) => e.id == selectedWorking!.family!.id).first;
      tmp1.isOpen = true;
    }
    if (selectedWorking!.level == 3) {
      WorkingUnitModel temp1 =
          level2.where((e) => e.id == selectedWorking!.parent).first;
      WorkingUnitModel temp2 = level1.where((e) => e.id == temp1.parent).first;
      ancestries.add(temp2.title);
      link.add(temp2);
      ancestries.add(temp1.title);
      link.add(temp1);
      directParent = temp1;
      WorkingUnitModel tmp1 =
          allWorking.where((e) => e.id == selectedWorking!.family!.id).first;
      WorkingUnitModel tmp2 =
          allWorking.where((e) => e.id == tmp1.family?.id).firstOrNull ??
              WorkingUnitModel();
      tmp1.isOpen = true;
      tmp2.isOpen = true;
    }
    if (selectedWorking!.level == 4) {
      WorkingUnitModel temp1 =
          level3.where((e) => e.id == selectedWorking!.parent).first;
      WorkingUnitModel temp2 = level2.where((e) => e.id == temp1.parent).first;
      WorkingUnitModel temp3 = level1.where((e) => e.id == temp2.parent).first;
      link.add(temp3);
      link.add(temp2);
      link.add(temp1);
      // listParent = level3;
      directParent = temp1;
    }
    ancestries.add(selectedWorking!.title);
    // link.add(selectedWorking!);
  }

  findDescendantsRecursive(String id, List<WorkingUnitModel> allItems) {
    List<WorkingUnitModel> descendants = [];
    for (var item in allItems) {
      if (item.parent == id) {
        descendants.add(item);
        var childDescendants = findDescendantsRecursive(item.id, allItems);
        descendants.addAll(childDescendants);
      }
    }
    return descendants;
  }

  double calculatePercent(String parentId, List<WorkingUnitModel> allItems) {
    if (parentId == 'kJbigpjwa4xRMnImsG0X') {
      debugPrint("=====> Starting calc percent: $parentId");
    }
    var children = allItems
        .where((item) =>
            item.parent == parentId &&
            item.type != TypeAssignmentDefine.subtask.title &&
            StatusWorkingExtension.fromValue(item.status) !=
                StatusWorkingDefine.cancelled)
        .toList();

    if (children.isEmpty) {
      for (var i in allItems) {
        if (i.id == parentId) {
          i.percent = 0;
          break;
        }
      }
      return 0;
      // return allItems.firstWhere((item) => item.id == parentId).percent;
    }

    for (var child in children) {
      child.percent = calculatePercent(child.id, allItems);
    }

    int average = children.fold<int>(
        0,
        (prev, e) =>
            prev +
            StatusWorkingExtension.fromPercent(e.status,
                isTask: e.type == TypeAssignmentDefine.task.title));

    double percent = (average / (children.length)).ceilToDouble();

    for (var i in allItems) {
      if (i.id == parentId) {
        i.percent = percent;
        break;
      }
    }
    if (parentId == 'kJbigpjwa4xRMnImsG0X') {
      debugPrint("=====> calc percent: $parentId -> $percent");
    }

    return percent;
  }

  buildUI() {
    if (isClosed) {
      return;
    }
    emit(state + 1);
  }

  getListUser(List<String> list, List<UserModel> models) {
    for (var u in users!) {
      for (var m in list) {
        if (m == u.id) {
          models.add(u);
          break;
        }
      }
    }
  }

  generateTabs() async {
    tabX.clear();
    tabY.clear();
    tabZ.clear();
    tabS.clear();
    List<WorkingUnitModel> list = listWorkings!.fold(
        [], (prev, e) => [...prev, if (e.parent == selectedWorking!.id) e]);
    // if (!selectedWorking!.scopes.contains(selectedScope!.id)) {
    if (selectedWorking?.type != TypeAssignmentDefine.task.title) {
      await cfC.getDataWorkingUnitByIdParentNewest(selectedWorking!.id);
      var tmp = cfC.allWorkingUnit.where((e) =>
          e.parent == selectedWorking!.id &&
          (selectedFilter == filters[1] || !e.closed));
      // await _workingService.getWorkingUnitByIdParent(selectedWorking!.id);
      list.addAll(tmp);
      final seenIds = <String>{};
      list.retainWhere((item) => seenIds.add(item.id));
      // list.map((item) => seenIds.add(item.id));
      // for (int i = 0; i < tmp2.length; i++) {
      //   for (int j = i + 1; j < tmp2.length; j++) {
      //     if (tmp2[i].id == tmp2[j].id) {
      //       seenIds.add(tmp2[i].id);
      //     }
      //   }
      // }
      // for (var e in tmp2) {
      //   for (var f in seenIds) {
      //     if (f == e.id) {
      //       list.remove(e);
      //       break;
      //     }
      //   }
      // }
    } else if (selectedWorking?.type == TypeAssignmentDefine.task.title) {
      await cfC.getDataWorkingUnitByIdParentNewest(selectedWorking!.id);

      var tmp = cfC.allWorkingUnit
          .where((e) => e.parent == selectedWorking!.id && !e.closed);
      list.addAll(tmp);
      list.sort((a, b) => a.id.compareTo(b.id));
      List<WorkingUnitModel> tmp2 = [];
      if (list.isNotEmpty) {
        tmp2.add(list.first);
      }
      for (int i = 1; i < list.length; i++) {
        if (list[i].id != list[i - 1].id) {
          tmp2.add(list[i]);
        }
      }
      list.clear();
      list.addAll(tmp2);
    }

    for (var i in list) {
      if (i.type == AppText.txtSprint.text) {
        tabX.add(i);
      }
      if (i.type == AppText.txtStory.text) {
        tabY.add(i);
      }
      if (i.type == AppText.txtTask.text) {
        tabZ.add(i);
      }
      if (i.type == AppText.txtSubTask.text) {
        tabS.add(i);
      }
    }
    if (tabX.length > 1) {
      tabX.sort((a, b) => a.createAt.compareTo(b.createAt));
    }
    if (tabY.length > 1) {
      tabY.sort((a, b) => a.createAt.compareTo(b.createAt));
    }
    if (tabZ.length > 1) {
      tabZ.sort((a, b) => a.createAt.compareTo(b.createAt));
    }
    if (tabS.length > 1) {
      tabS.sort((a, b) => a.createAt.compareTo(b.createAt));
    }
  }

  List<WorkingUnitModel> buildTree(List<WorkingUnitModel> allItems,
      String parentId, int level, String position) {
    int index = 0;
    return allItems.where((item) {
      bool isRootItem = parentId.isEmpty &&
          // item.parent == '' &&
          (item.parent == '' ||
              !(allItems.any((parent) => parent.id == item.parent))) &&
          item.type != TypeAssignmentDefine.subtask.title;
      bool isChildItem = (item.parent == parentId &&
          item.type != TypeAssignmentDefine.subtask.title);
      // if(item.id == "PW1OLe4rd2RkrZJgyzPz") {
      //   print("===========+> check task manager: ${item.title} - $isRootItem - $isChildItem - $parentId - ${allItems.any((parent) => parent.id == item.parent)} - ${allItems.length}");
      // }
      return isRootItem || isChildItem;
    }).map((item) {
      index++;
      String newPosition = '';
      switch (level) {
        case 1:
          newPosition = '${index.toString().padLeft(3, '0')}000000';
          break;
        case 2:
          newPosition =
              '${position.substring(0, 3)}${index.toString().padLeft(3, '0')}000';
          break;
        case 3:
          newPosition =
              '${position.substring(0, 6)}${index.toString().padLeft(3, '0')}';
          break;
      }

      item.level = level;
      item.position = newPosition;

      item.children = buildTree(allItems, item.id, level + 1, newPosition);
      for (var i in item.children) {
        i.family = item;
      }

      switch (level) {
        case 1:
          level1.add(item);
          break;
        case 2:
          level2.add(item);
          break;
        case 3:
          level3.add(item);
      }

      return item;
    }).toList();
  }

  addItemToTree(WorkingUnitModel newItem) async {
    bool isDone = false;
    if (newItem.parent.isEmpty) {
      int newIndex = workings.length + 1;
      newItem.position = '${newIndex.toString().padLeft(3, '0')}000000';
      newItem.level = 1;
      workings.add(newItem);
      listWorkings!.add(newItem);
      level1.add(newItem);
      isDone = true;
    } else {
      for (var item in allWorking) {
        if (item.id == newItem.parent) {
          newItem.family = item;
          int newIndex = item.children.length + 1;
          String newPosition = '';
          switch (item.level) {
            case 1:
              newPosition =
                  '${item.position.substring(0, 3)}${newIndex.toString().padLeft(3, '0')}000';
            case 2:
              newPosition =
                  '${item.position.substring(0, 6)}${newIndex.toString().padLeft(3, '0')}';
            case 3:
              newPosition =
                  '${item.position.substring(0, 9)}${newIndex.toString().padLeft(3, '0')}';
          }
          newItem.position = newPosition;
          newItem.level = item.level + 1;
          item.children.add(newItem);

          listWorkings!.add(newItem);

          isDone = true;

          switch (newItem.level) {
            case 2:
              level2.add(newItem);
            // break;
            case 3:
              level3.add(newItem);
            // break;
          }

          if (newItem.type == AppText.txtSprint.text) {
            tabX.add(newItem);
          }
          if (newItem.type == AppText.txtStory.text) {
            tabY.add(newItem);
          }
          if (newItem.type == AppText.txtTask.text) {
            tabZ.add(newItem);
          }
          if (newItem.type == AppText.txtSubTask.text) {
            tabS.add(newItem);
          }
          break;
        }
      }

      if (!isDone) {
        int newIndex = workings.length + 1;
        newItem.position = '${newIndex.toString().padLeft(3, '0')}000000';
        newItem.level = 1;
        workings.add(newItem);
        listWorkings!.add(newItem);
        level1.add(newItem);
        isDone = true;
      }
    }

    await generateTabs();
    changeTab(tab);
    buildUI();
  }

  updateWorkingUnit(WorkingUnitModel work, {bool isEmit = true}) {
    if (listWorkings != null) {
      int index2 = listWorkings!.indexWhere((e) => e.id == work.id);
      if (index2 != -1) {
        final diff =
            WorkingUnitModel.getDifferentFields(work, listWorkings![index2]);
        if (diff.isEmpty) return false;
        if (index2 != -1) {
          final tmp = listWorkings![index2];
          listWorkings![index2] = work;
          listWorkings![index2].level = tmp.level;
          listWorkings![index2].family = tmp.family;
        }
      }
    }
    updateWorkingUnitInList(workings, work);
    updateWorkingUnitInList(tabX, work);
    updateWorkingUnitInList(tabY, work);
    updateWorkingUnitInList(tabZ, work);
    updateWorkingUnitInList(tabS, work);
    updateWorkingUnitInList(level1, work);
    updateWorkingUnitInList(level2, work);
    updateWorkingUnitInList(level3, work);
    updateWorkingUnitInList(link, work);
    // listWorkings.con
    print(
        "=====> check update working unit: ${selectedWorking?.id} - ${work.id}");
    if (selectedWorking?.id == work.id) {
      int levelZZZZ = selectedWorking!.level;
      WorkingUnitModel? fmlZZZZ = selectedWorking!.family;
      selectedWorking = work;
      selectedWorking!.level = levelZZZZ;
      selectedWorking!.family = fmlZZZZ;
      print(
          "=====> update task WP: ${selectedWorking?.id} - ${selectedWorking?.workingPoint}");
    }
    if (directParent?.id == work.id) {
      directParent = work;
    }
    if (isEmit) {
      buildUI();
    }
    return true;
  }

  updateWorkingUnitInList(List<WorkingUnitModel> list, WorkingUnitModel model) {
    int index = list.indexWhere((e) => e.id == model.id);
    if (index != -1) {
      final diff = WorkingUnitModel.getDifferentFields(model, list[index]);
      if (diff.isEmpty) return;
      if (model.enable) {
        model.level = list[index].level;
        model.family = list[index].family;
        list[index] = model;
      } else {
        list.removeAt(index);
      }
    }
    // buildUI();
  }
}
