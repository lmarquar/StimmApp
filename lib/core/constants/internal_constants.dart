import 'package:flutter/material.dart';

class IConst {
  static const String themeModeKey = 'isDarkMode';
  static const String localeKey = 'locale';
  static const String appName = 'stimmapp-dev';
  static const String active = 'active';
  static const String closed = 'closed';

  static const Color appColor = Colors.greenAccent;
  static const Color lightColor = Colors.blue;

  static const String adminEmail = 'service@stimmapp.org';
  static const String supportEmail = 'support@stimmapp.org';
  static const String privacyPolicyUrl =
      'https://www.stimmapp.org/privacy-policy';
  static const String termsOfServiceUrl =
      'https://www.stimmapp.org/terms-of-service';
  static const String faqUrl = 'https://www.stimmapp.org/faq';

  static const String revenueCatApiKey = 'test_VEGOJICjsOpHUeSPdwjeXBwfLph';

  // Google Places API Key.
  // If your Firebase API key is restricted and doesn't work for Places,
  // create an unrestricted API key in Google Cloud Console and put it here.
  static const String googlePlacesApiKey =
      'AIzaSyC2FIfql1gfwTanWRLCMU3ixmJkzpSIN8M'; // Default to Android key for now
}
