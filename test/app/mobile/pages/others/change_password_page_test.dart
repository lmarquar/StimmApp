import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/app/mobile/pages/others/change_password_page.dart';

void main() {
  testWidgets('ChangePasswordPage has a title and a button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('show snackbar when button is tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));

    await tester.enterText(
        find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'newpassword');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
