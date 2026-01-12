import 'package:flutter/material.dart';
import 'error_page.dart';

void errorLogTool({
  required Object exception,
  required String errorCustomMessage,
}) {
  debugPrint('Error: $errorCustomMessage - $exception');
  errorList.add(exception);
  errorListId.add(errorCustomMessage);
}
