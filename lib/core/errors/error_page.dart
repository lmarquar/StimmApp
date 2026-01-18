import 'package:flutter/material.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

List<Object> errorList = [];
List<String> errorListId = [];

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.errors)),
      body: ListView.builder(
        itemCount: errorList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(errorList.elementAt(index).toString()),
            subtitle: Text(
                '${context.l10n.error}${errorListId.elementAt(index).toString()}'),
            leading: Text((index + 1).toString()),
          );
        },
      ),
    );
  }
}
