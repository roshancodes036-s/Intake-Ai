import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraHelper {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  
  // कैमरा कंट्रोलर प्राप्त करने के लिए (UI में प्रीव्यू दिखाने के काम आएगा)
  CameraController? get controller => _cameraController;
  
  // क्या कैमरा चालू (Initialize) हो चुका है?
  bool get isInitialized => _cameraController != null && _cameraController!.value.isInitialized;

  /// कैमरे को इनिशियलाइज़ (चालू) करने का फंक्शन
  Future<void> initializeCamera() async {
    try {
      // डिवाइस में मौजूद सभी कैमरे ढूँढें (Front/Back)
      _cameras = await availableCameras();
      
      if (_cameras != null && _cameras!.isNotEmpty) {
        // डिफ़ॉल्ट रूप से पीछे वाला (Back) कैमरा चुनें
        final backCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );

        // कंट्रोलर सेटअप करें (High Resolution के साथ)
        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false, // खाने की फोटो के लिए ऑडियो नहीं चाहिए
          imageFormatGroup: ImageFormatGroup.jpeg, // JPEG फॉर्मेट
        );

        // कैमरे को स्टार्ट करें
        await _cameraController!.initialize();
      } else {
        throw Exception('डिवाइस में कोई कैमरा नहीं मिला!');
      }
    } catch (e) {
      debugPrint('कैमरा चालू करने में एरर: $e');
      throw Exception('कैमरा चालू करने में दिक्कत आई: $e');
    }
  }

  /// फोटो खींचने (Take Picture) का फंक्शन
  Future<XFile?> takePicture() async {
    if (!isInitialized) {
      debugPrint('कैमरा अभी चालू नहीं हुआ है!');
      return null;
    }

    // अगर कैमरा फोटो खींचने में व्यस्त है तो कुछ न करें
    if (_cameraController!.value.isTakingPicture) {
      return null;
    }

    try {
      // फ्लैश को ऑटो पर सेट कर सकते हैं (ऑप्शनल)
      await _cameraController!.setFlashMode(FlashMode.auto);
      
      // फोटो क्लिक करें और फाइल (XFile) वापस करें
      final XFile picture = await _cameraController!.takePicture();
      return picture;
    } on CameraException catch (e) {
      debugPrint('फोटो खींचने में एरर: $e');
      return null;
    }
  }

  /// जब कैमरा स्क्रीन बंद हो, तो मेमोरी बचाने के लिए कैमरे को बंद (Dispose) करें
  void dispose() {
    _cameraController?.dispose();
    _cameraController = null;
  }
}
