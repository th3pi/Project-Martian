import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class DepositCamera {
  List<CameraDescription> cameras;
  CameraController controller;
  var imageFile;

  void takePicture() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
  }
}
