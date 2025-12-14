import 'package:stimmapp/core/config/verify_app_connection.dart';
import 'package:stimmapp/core/errors/error_log_tool.dart';

import '../errors/error_message.dart';

Future<void> initApp() async {
  await initInternetChecker();
  await initAppVersionNotifier();
}

Future<void> initInternetChecker() async {
  try {
    await verifyAppConnection();
  } catch (e) {
    errorLogTool(
      exception: e,
      errorCustomMessage: ErrorMessage.thisIsNotWorking,
    );
  }
}

Future<void> initAppVersionNotifier() async {
  try {} catch (e) {
    errorLogTool(
      exception: e,
      errorCustomMessage: ErrorMessage.thisIsNotWorking,
    );
  }
}
