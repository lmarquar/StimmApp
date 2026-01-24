import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:stimmapp/main.dart';

void main() {
  patrolTest('navigate to registration and back', ($) async {
    // Start the app
    await $.pumpWidgetAndSettle(const MyApp());

    // Wait for WelcomePage to appear.
    // We look for the "Get started" button.
    await $('Get started').waitUntilVisible();

    // Click Get started
    await $.tap($('Get started'));

    // Now we should be on the Onboarding/Registration page.
    // Verifying by the AppBar title "Register here"
    await $.waitUntilVisible($('Register here'));

    // Verification: we are on the register page
    expect($('Register here'), findsOneWidget);
    expect($('Email'), findsOneWidget);

    // Now go back
    await $.tap(find.byIcon(Icons.arrow_back));

    // Wait for WelcomePage again
    await $('Get started').waitUntilVisible();
    expect($('Get started'), findsOneWidget);
  });
}
