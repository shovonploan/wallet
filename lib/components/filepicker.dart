import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

bool _isPicking = false;

Future<Uint8List?> pickImageSafely() async {
  if (_isPicking) return null;
  _isPicking = true;

  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      return result.files.single.bytes!;
    } else {
      return null;
    }
  } catch (e) {
    print('Error picking image: $e');
    return null;
  } finally {
    _isPicking = false;
  }
}
