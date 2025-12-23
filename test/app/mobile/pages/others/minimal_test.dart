import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

import '../../../../test_helper.dart';

class MinimalWidget extends StatelessWidget {
  const MinimalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.changePassword);
  }
}

void main() {
  testWidgets('MinimalWidget shows localized text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget(const MinimalWidget()));
    expect(find.text('Change password'), findsOneWidget);
  });
}
