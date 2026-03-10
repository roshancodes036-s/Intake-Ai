import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  // यह लाइन सबसे ज़रूरी है! यह Flutter को डेटाबेस और कैमरा चालू करने की परमिशन देती है
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const IntakeApp());
}
