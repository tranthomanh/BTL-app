import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class CreatePostCubit {
  final BehaviorSubject<bool> isPost = BehaviorSubject.seeded(false);

  final BehaviorSubject<Uint8List?> imageSubject = BehaviorSubject.seeded(null);

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    Uint8List? result;
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      result = await image.readAsBytes();
      isPost.add(true);
    }

    imageSubject.add(result);
  }
}
