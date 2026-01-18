import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:universal_io/io.dart';

Future<void> initializeRevenueCat() async {
  // Platform-specific API keys
  String apiKey;
  if (Platform.isIOS) {
    apiKey = 'test_VEGOJICjsOpHUeSPdwjeXBwfLph';
  } else if (Platform.isAndroid) {
    apiKey = 'test_VEGOJICjsOpHUeSPdwjeXBwfLph';
  } else {
    throw UnsupportedError('Platform not supported');
  }

  await Purchases.configure(PurchasesConfiguration(apiKey));
}
