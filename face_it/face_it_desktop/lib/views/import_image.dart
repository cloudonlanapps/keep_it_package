import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

Future<String?> pickImageFromGallery() async =>
    (await _picker.pickImage(source: ImageSource.gallery))?.path;
