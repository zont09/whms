import 'package:whms/models/response_model.dart';
import 'package:whms/models/sorted_model.dart';
import 'package:whms/repositories/sorted_reposity.dart';

class SortedService {
  SortedService._privateConstructor();

  static SortedService instance = SortedService._privateConstructor();

  final SortedRepository _sortedRepository = SortedRepository.instance;

  Future<SortedModel?> getSortedByUserAndListName(
      String idUser, String listName) async {
    final response =
        await _sortedRepository.getSortedByUserAndListName(idUser, listName);
    if (response.status == ResponseStatus.ok && response.results != null) {
      return response.results!;
    }
    return null;
  }

  Future<void> addNewSorted(SortedModel model) async {
    await _sortedRepository.addNewSorted(model);
  }

  Future<void> updateSorted(SortedModel model) async {
    await _sortedRepository.updateSorted(model);
  }
}
