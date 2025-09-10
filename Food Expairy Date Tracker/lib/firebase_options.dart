import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: "AIzaSyCJBN8flwJ4S8VrNgt4Lp9C8T79I_KNB-A",
      appId: "1:88216758248:web:067504181ebf78f7c4265d",
      messagingSenderId: "88216758248",
      projectId: "expiry-food-date-tracker",
      authDomain: "expiry-food-date-tracker.firebaseapp.com",
      storageBucket: "expiry-food-date-tracker.firebasestorage.app",
      measurementId: "G-S4RX880R3D",
      databaseURL: "https://expiry-food-date-tracker-default-rtdb.firebaseio.com",
    );
  }
}