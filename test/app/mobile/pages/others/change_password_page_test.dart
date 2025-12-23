import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stimmapp/app/mobile/pages/others/change_password_page.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/core/services/auth_service.dart';

import '../../../../mocks.dart';
import '../../../../test_helper.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    initializeAuthService();
    setAuthServiceMock(mockAuthService);
  });

  testWidgets('ChangePasswordPage has a title and a button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget(const ChangePasswordPage()));
    expect(find.text('Change password'), findsWidgets);
    expect(find.byType(ButtonWidget), findsOneWidget);
  });

  testWidgets('show snackbar when button is tapped', (
    WidgetTester tester,
  ) async {
    when(mockAuthService.currentUser).thenReturn(mockUser);
    when(
      mockAuthService.resetPasswordfromCurrentPassword(
        currentPassword: 'currentpassword',
        newPassword: 'newpassword',
        email: 'test@test.com',
      ),
    ).thenAnswer((_) async => {});

    await tester.pumpWidget(createTestWidget(const ChangePasswordPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'currentpassword');
    await tester.enterText(find.byType(TextFormField).at(1), 'newpassword');

    await tester.tap(find.byType(ButtonWidget));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
