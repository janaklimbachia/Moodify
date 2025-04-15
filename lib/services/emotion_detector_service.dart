import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class EmotionDetectorService {
  static Future<String> detectMoodFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final options = FaceDetectorOptions(
      enableClassification: true, // for smiling probability
      enableContours: true,
    );

    final faceDetector = FaceDetector(options: options);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) return "No face detected";

    final Face face = faces[0];
    final double? smileProb = face.smilingProbability;

    if (smileProb != null) {
      if (smileProb > 0.75) return "Happy 😊";
      if (smileProb > 0.3) return "Neutral 😐";
      return "Sad 😞";
    } else {
      return "Could not determine mood";
    }
  }
}
