import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/update_username_page.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';

import '../test/mocks.dart';
import '../test/test_helper.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    authService = ValueNotifier(mockAuthService);
  });

  // Helper function to pump the widget and set up initial mocks
  Future<void> pumpPage(WidgetTester tester) async {
    when(mockAuthService.currentUser).thenReturn(mockUser);
    when(mockUser.displayName).thenReturn('OldUsername');
    await tester.pumpWidget(createTestWidget(const UpdateUsernamePage()));
  }

  testWidgets('renders correctly with initial username', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    // Check for the AppBar title
    expect(find.byType(AppBar), findsOneWidget);

    // Check that the text field is pre-filled with the current username
    final usernameField = find.byType(TextFormField);
    expect(usernameField, findsOneWidget);
    expect(
      tester.widget<TextFormField>(usernameField).controller?.text,
      'OldUsername',
    );

    // Check for the save button
    expect(find.byType(ButtonWidget), findsOneWidget);
  });

  testWidgets('updates username and shows success snackbar on valid input', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPage(tester);
    when(
      mockAuthService.updateUsername(username: 'NewUsername'),
    ).thenAnswer((_) async {});

    // Act
    await tester.enterText(find.byType(TextFormField), 'NewUsername');
    await tester.tap(find.byType(ButtonWidget));
    await tester.pumpAndSettle(); // For animations and async calls

    // Assert
    verify(mockAuthService.updateUsername(username: 'NewUsername')).called(1);
    expect(find.byType(SnackBar), findsOneWidget);
    // NOTE: Using hardcoded strings can be brittle. Using localization keys is better.
    expect(find.text('Username updated successfully!'), findsOneWidget);
  });

  testWidgets('shows error snackbar when username update fails', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPage(tester);
    final exception = Exception('Update failed');
    when(
      mockAuthService.updateUsername(username: 'NewUsername'),
    ).thenThrow(exception);

    // Act
    await tester.enterText(find.byType(TextFormField), 'NewUsername');
    await tester.tap(find.byType(ButtonWidget));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Update failed'), findsOneWidget);
  });

  testWidgets('shows validation error for empty username', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPage(tester);

    // Act
    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.byType(ButtonWidget));
    await tester.pump(); // Let form validation run

    // Assert
    expect(find.text('Username cannot be empty'), findsOneWidget);
    verifyNever(mockAuthService.updateUsername(username: ''));
  });

  testWidgets('shows validation error for username that is too short', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextFormField), 'ab');
    await tester.tap(find.byType(ButtonWidget));
    await tester.pump();

    expect(find.text('Username must be at least 3 characters'), findsOneWidget);
    verifyNever(mockAuthService.updateUsername(username: 'ab'));
  });
}
