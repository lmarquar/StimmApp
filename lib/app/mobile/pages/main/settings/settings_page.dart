import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/profile_page.dart';
import 'package:stimmapp/app/mobile/widgets/unaffected_child_widget.dart';
import 'package:stimmapp/core/constants/words.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:stimmapp/etc/button_widgets_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void popUntilLast() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  TextEditingController controller = TextEditingController();
  bool isChecked = false;
  bool isSwitched = false;
  double sliderValue = 0.0;
  String? menuItem = 'e1';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              UnaffectedChildWidget(
                child: Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    trailing: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.white38,
                    ),
                    title: const Text(Words.myProfile),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProfilePage();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              UnaffectedChildWidget(
                child: ListTile(
                  title: const Text(Words.aboutThisApp),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(Words.flutterPro),
                          content: const Text(
                            Words.myProfile,
                            style: AppTextStyles.m,
                          ),
                          actions: [
                            FilledButton(
                              onPressed: () async {
                                popUntilLast();
                                showLicensePage(context: context);
                              },
                              child: const Text(Words.viewLicenses),
                            ),
                            TextButton(
                              onPressed: () {
                                popUntilLast();
                              },
                              child: const Text(Words.close),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              Divider(color: Colors.teal, thickness: 5),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ButtonWidgetsPage(title: "Testing Widgets here");
                      },
                    ),
                  );
                },
                child: Text('Developer Sandbox'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
