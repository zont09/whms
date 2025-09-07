import 'package:file_picker/file_picker.dart';
import 'package:whms/untils/file_utils.dart';

class CacheUtils {
  CacheUtils._privateConstructor();
  static CacheUtils instance = CacheUtils._privateConstructor();
  static Map<String, dynamic> data = {};
  static Map<String, PlatformFile> mapFileGB = {};

  Future<PlatformFile?> getFileGB(String url) async {
    if(mapFileGB.containsKey(url)) return mapFileGB[url]!;
    else {
      final file = await FileUtils.getFile(url);
      if(file != null) {
        mapFileGB[url] = file;
        return file;
      }
    }
    return null;
  }

  setFileGB(String url, PlatformFile file) {
    if(mapFileGB.containsKey(url)) return;
    mapFileGB[url] = file;
  }
}