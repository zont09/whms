// import 'package:whms/models/recommend_model.dart';
// import 'package:whms/services/recommend_service.dart';
//
// class RecommendationRepository {
//   final RecommendationService _service;
//
//   RecommendationRepository(this._service);
//
//   Future<RecommendationResponseModel> getRecommendations({
//     required String title,
//     required String description,
//     required String type,
//     String parent = '',
//     int topK = 5,
//   }) async {
//     try {
//       return await _service.recommendEmployees(
//         title: title,
//         description: description,
//         type: type,
//         parent: parent,
//         topK: topK,
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<bool> checkHealth() async {
//     try {
//       final health = await _service.recommendEmployees();
//       return health['status'] == 'ok';
//     } catch (e) {
//       return false;
//     }
//   }
// }
