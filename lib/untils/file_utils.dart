import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'dart:html' as html;

import 'package:whms/widgets/custom_button.dart';

class FileUtils {
  static bool isImage(PlatformFile file) {
    // Kiểm tra phần mở rộng của file (ví dụ: jpg, png, gif, bmp)
    // final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
    // final fileExtension = file.name.split('.').last.toLowerCase();
    // return imageExtensions.contains(fileExtension);

    // JPG
    if (file.bytes!.length >= 3 &&
        file.bytes![0] == 0xFF &&
        file.bytes![1] == 0xD8 &&
        file.bytes![2] == 0xFF) {
      return true;
    }
    // PNG
    if (file.bytes!.length >= 8 &&
        file.bytes![0] == 0x89 &&
        file.bytes![1] == 0x50 &&
        file.bytes![2] == 0x4E &&
        file.bytes![3] == 0x47) {
      return true;
    }
    // GIF
    if (file.bytes!.length >= 6 &&
        file.bytes![0] == 0x47 &&
        file.bytes![1] == 0x49 &&
        file.bytes![2] == 0x46) {
      return true;
    }
    // BMP
    if (file.bytes!.length >= 2 &&
        file.bytes![0] == 0x42 &&
        file.bytes![1] == 0x4D) {
      return true;
    }
    return false;
  }

  static bool isVideo(PlatformFile file) {
    if (file.bytes == null || file.bytes!.length < 4) {
      return false;
    }

    List<int> bytes = file.bytes!;

    // MP4/MOV - Kiểm tra `ftyp`
    if (bytes.length >= 8 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70) {
      return true;
    }

    // AVI - Kiểm tra `RIFF`
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return true;
    }

    // MKV - Kiểm tra `1A 45 DF A3`
    if (bytes[0] == 0x1A &&
        bytes[1] == 0x45 &&
        bytes[2] == 0xDF &&
        bytes[3] == 0xA3) {
      return true;
    }

    // FLV - Kiểm tra `FLV`
    if (bytes.length >= 3 &&
        bytes[0] == 0x46 &&
        bytes[1] == 0x4C &&
        bytes[2] == 0x56) {
      return true;
    }

    return false;
  }

  static bool isPdf(PlatformFile file) {
    if (file.bytes!.length >= 4 &&
        file.bytes![0] == 0x25 &&
        file.bytes![1] == 0x50 &&
        file.bytes![2] == 0x44 &&
        file.bytes![3] == 0x46) {
      return true;
    }
    return false;
  }

  static bool isDocument(PlatformFile file) {
    // const documentExtensions = ['pdf', 'doc', 'docx', 'txt'];
    // final extension = file.extension?.toLowerCase();
    // return documentExtensions.contains(extension);
    // PDF
    if (file.bytes!.length >= 4 &&
        file.bytes![0] == 0x25 &&
        file.bytes![1] == 0x50 &&
        file.bytes![2] == 0x44 &&
        file.bytes![3] == 0x46) {
      return true;
    }
    // DOC
    if (file.bytes!.length >= 8 &&
        file.bytes![0] == 0xD0 &&
        file.bytes![1] == 0xCF &&
        file.bytes![2] == 0x11 &&
        file.bytes![3] == 0xE0) {
      return true;
    }
    // DOCX
    if (file.bytes!.length >= 5 &&
        file.bytes![0] == 0x50 &&
        file.bytes![1] == 0x4B &&
        file.bytes![2] == 0x03 &&
        file.bytes![3] == 0x04) {
      return true;
    }
    // TXT
    if (file.bytes!.isNotEmpty &&
        file.bytes![0] >= 0x20 &&
        file.bytes![0] <= 0x7E) {
      return true;
    }
    return false;
  }

  static bool isAudio(PlatformFile file) {
    // final audioExtensions = ['.mp3', '.wav', '.aac', '.flac', '.ogg', '.m4a'];
    // final fileExtension = file.name.split('.').last.toLowerCase();
    // return audioExtensions.contains('.$fileExtension');
    // MP3
    if (file.bytes!.length >= 3 &&
        file.bytes![0] == 0x49 &&
        file.bytes![1] == 0x44 &&
        file.bytes![2] == 0x33) {
      return true;
    }
    // WAV
    if (file.bytes!.length >= 4 &&
        file.bytes![0] == 0x52 &&
        file.bytes![1] == 0x49 &&
        file.bytes![2] == 0x46 &&
        file.bytes![3] == 0x46) {
      return true;
    }
    // AAC
    if (file.bytes!.length >= 2 &&
        file.bytes![0] == 0xFF &&
        file.bytes![1] == 0xF1) {
      return true;
    }
    // FLAC
    if (file.bytes!.length >= 4 &&
        file.bytes![0] == 0x66 &&
        file.bytes![1] == 0x4C &&
        file.bytes![2] == 0x61 &&
        file.bytes![3] == 0x43) {
      return true;
    }
    // OGG
    if (file.bytes!.length >= 4 &&
        file.bytes![0] == 0x4F &&
        file.bytes![1] == 0x67 &&
        file.bytes![2] == 0x67 &&
        file.bytes![3] == 0x53) {
      return true;
    }
    // M4A
    if (file.bytes!.length >= 4 &&
        file.bytes![0] == 0x66 &&
        file.bytes![1] == 0x74 &&
        file.bytes![2] == 0x79 &&
        file.bytes![3] == 0x70) {
      return true;
    }
    return false;
  }

  static bool isOther(PlatformFile file) {
    return !isImage(file) &&
        !isVideo(file) &&
        !isDocument(file) &&
        !isAudio(file);
  }

  static Future<PlatformFile?> getFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String? contentDisposition = response.headers['content-disposition'];
        String fileName = '';
        RegExp regExp = RegExp(r"filename\*=.*''(.*)");
        if (contentDisposition != null) {
          var match = regExp.firstMatch(contentDisposition);

          if (match != null) {
            fileName = match
                .group(1)!
                .replaceAll("%20", " "); // Lấy tên file từ nhóm 1
          }
        }
        return PlatformFile(
          name: fileName,
          path: url,
          bytes: response.bodyBytes,
          size: response.contentLength ?? 0,
        );
      } else {
        debugPrint("Error fetching file: ${response.statusCode}");
        return null; // Trả về null nếu có lỗi
      }
    } catch (e) {
      debugPrint("Error downloading file: $e");
      return null; // Trả về null nếu có lỗi
    }
  }

  static void downloadPlatformFile(PlatformFile file) {
    if (file.bytes == null) {
      debugPrint("No file bytes available.");
      return;
    }

    Uint8List fileBytes = file.bytes!;

    final blob = html.Blob([fileBytes]);

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url);
    anchor.target = 'blank';
    anchor.download = file.name;
    anchor.click();

    html.Url.revokeObjectUrl(url);
  }

  static int defineDoc(PlatformFile file) {
    // PDF
    if (file.bytes!.length >= 4 &&
        file.bytes![0] == 0x25 &&
        file.bytes![1] == 0x50 &&
        file.bytes![2] == 0x44 &&
        file.bytes![3] == 0x46) {
      return 1;
    }
    // TXT
    if (file.bytes!.isNotEmpty &&
        file.bytes![0] >= 0x20 &&
        file.bytes![0] <= 0x7E) {
      return 2;
    }
    // DOC
    if (file.bytes!.length >= 8 &&
        file.bytes![0] == 0xD0 &&
        file.bytes![1] == 0xCF &&
        file.bytes![2] == 0x11 &&
        file.bytes![3] == 0xE0) {
      return 3;
    }
    // DOCX
    if (file.bytes!.length >= 5 &&
        file.bytes![0] == 0x50 &&
        file.bytes![1] == 0x4B &&
        file.bytes![2] == 0x03 &&
        file.bytes![3] == 0x04) {
      return 4;
    }
    return 0;
  }

  static void handleFileDocuments(BuildContext context, PlatformFile file) {
    int tmp = defineDoc(file);
    if (tmp == 1) {
      const mimeType = 'application/pdf';
      // : 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      final blob = html.Blob([file.bytes!], mimeType);

      final url = html.Url.createObjectUrlFromBlob(blob);

      html.window.open(url, '_blank');

      html.Url.revokeObjectUrl(url);
    } else if (tmp == 3 || tmp == 4) {
      const mimeType = 'application/msword';
      // 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      final blob = html.Blob([file.bytes!], mimeType);

      final url = html.Url.createObjectUrlFromBlob(blob);

      html.window.open(url, '_blank');

      html.Url.revokeObjectUrl(url);
    } else if (tmp == 2) {
      final content = String.fromCharCodes(file.bytes!);
      DialogUtils.showAlertDialog(context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(ScaleUtils.scaleSize(12, context)),
                  child:
                      Container(width: double.infinity, child: Text(content)),
                ),
              )),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(ScaleUtils.scaleSize(12, context)),
                  child: CustomButton(
                      title: AppText.btnClose.text,
                      icon: "",
                      paddingVer: 6,
                      paddingHor: 16,
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ),
              )
            ],
          ));
    } else {
      // Nếu file không phải PDF, DOCX, hoặc TXT
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Không hỗ trợ định dạng"),
          content: const Text("File này không được hỗ trợ để hiển thị."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Đóng"),
            ),
          ],
        ),
      );
    }
  }

  static Future<PlatformFile?> pickFile({FileType fileType = FileType.any}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final files = result.files.firstOrNull;
        return files;
      }
    } catch (e) {
      print("Error picking file: $e");
      return null;
    }
    return null;
  }

  static Future<List<String>> getImages(BuildContext context, String path) async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final images = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith(path)).toList();
    return images;
  }
}
