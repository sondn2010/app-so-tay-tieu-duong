import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AvatarService {
  static Future<String?> pickAndSave() async {
    final picker = ImagePicker();
    final img =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 400);
    if (img == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/avatar.jpg');
    await File(img.path).copy(dest.path);
    return dest.path;
  }
}
